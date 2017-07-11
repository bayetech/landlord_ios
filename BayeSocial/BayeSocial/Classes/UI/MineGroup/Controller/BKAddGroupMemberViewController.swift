//
//  BKAddGroupMemberViewController.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/11/14.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD

@objc enum SelectMembersType : Int {
    case detail = 0     // 查看详情
    case invitation     // 邀请
    case remind         // 提醒某人
    case transmit       // 转发消息
    case businessCard   // 个人名片
    case newGroupOwner  // 选择新群主
}

@objc protocol BKAddGroupMemberViewControllerDelegate : NSObjectProtocol {
    @objc optional func didFinishedGroupMembers(_ contacts:[String:String],viewController : BKAddGroupMemberViewController)
    @objc optional func userDetail(_ customer : BKCustomersContact,viewController : BKAddGroupMemberViewController)
}

@objc class BKAddGroupMemberViewController: BKBaseViewController {
    
    var cacheMembers : NSMutableDictionary = NSMutableDictionary()
    weak var delegate : BKAddGroupMemberViewControllerDelegate?
    lazy var tableView : UITableView = {
        let tableView                   = UITableView(frame: CGRect.zero, style: .plain)
        tableView.backgroundColor = UIColor.RGBColor(243.0, green: 243.0, blue: 243.0)
        tableView.register(UINib(nibName: "BYContactTableViewCell", bundle: nil), forCellReuseIdentifier: "BYContactTableViewCell")
        tableView.delegate              = self
        tableView.dataSource            = self
        tableView.tableFooterView       = UIView()
        return tableView
    }()
    var groupId : String?
    var userId : String?
    var displayType : SelectMembersType = .detail
    var userContacts : [BKCustomersContact]?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = true
        self.setup()
        self.loadDatas()
        
        self.setLeftBarbuttonItemWithTitles(["取消"], actions: [#selector(cancel)])
        
    }
 
    func setup() {
    
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        self.tableView.perform(#selector(UITableView.reloadData), with: nil, afterDelay: 0.01)
        self.tableView.sectionIndexBackgroundColor  = UIColor.clear
        self.tableView.sectionIndexColor            = UIColor.colorWithHexString("#999999")
        
    }
    
    /// 下一步
    @objc func nextStep() {
       
        var contacts : [String:String]    = [String:String]()
        for (_,item) in self.cacheMembers.reversed() {
            let contact = (item as! BKCustomersContact)
            contacts[contact.uid] = contact.name
        }
      
        self.delegate?.didFinishedGroupMembers?(contacts,viewController:self)

        self.dismiss(animated: true, completion: nil)
        
    }
    
    /// 取消
    @objc func cancel() {
        self.dismiss(animated: true, completion: nil)
    }
    
    // 当人脉发生改变的时候
    func contactDidChange() {
        self.loadDatas()
    }
    
    public func loadDatas() {
        
        // 群组成员 可以使用上个页面传递过来的群成员信息
        if let contacts = self.userContacts {
            reloadData(by: contacts);
            return
        }
        
        /// 获取个人人脉信息
        if let uid = self.userId {
            let contacts  = BKRealmManager.shared().readUserContacts(uid)
            reloadData(by: contacts)
            requstUserContacts(by: uid)
        }
        
        
    }
    
    var dataArray       = [BKCustomerContactGroup]()
    var letterArray     = [String]()
    
    /// 请求用户人脉信息
    func requstUserContacts(by userId: String) {
        
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        
        BKNetworkManager.getOperationReqeust(baseURLPath + "customer_friends/friend_contacts", params: ["customer_uid" : userId], success: {[weak self] (success) in
            
            HUD.hide(animated: true)
            let json                                                = success.value
            let return_code             = json["return_code"]?.int ?? 0
            let return_message          = json["return_message"]?.string ?? "获取人脉列表失败"
            guard return_code == 200 else {
                UnitTools.addLabelInWindow(return_message, vc: self)
                return
            }
            let customers   = json["customers"]?.arrayValue
            guard customers != nil else {
                UnitTools.addLabelInWindow("获取人脉列表失败", vc: self)
                return
            }
            
            var userContacts : [BKCustomersContact] = [BKCustomersContact]()
            for json in customers! {
                let customer = BKCustomersContact(by: json)
                userContacts.append(customer)
            }
            
            self?.reloadData(by: userContacts)
            
        }) { (failure) in
            UnitTools.addLabelInWindow("获取人脉列表失败", vc: self)
        }
        
    }
    
    func reloadData(by contacts:[BKCustomersContact]) {
        
        self.dataArray      =  BKCustomerContactGroup.appendFormatterData(customers: contacts)
        self.userContacts   = contacts
        self.tableView.reloadData()

    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard (userId != nil && userContacts != nil) else {
            return
        }
        
        BKRealmManager.shared().insertUserContacts(self.userContacts!, userId: userId!)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }

}

// MARK: - UITableViewDataSource && UITableViewDelegate
extension BKAddGroupMemberViewController : UITableViewDataSource , UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let items = self.dataArray[section].items
        return (Int(items.count))
        
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell                            = tableView.dequeueReusableCell(withIdentifier: "BYContactTableViewCell") as! BYContactTableViewCell
        cell.selectionStyle                 = .none
        let contactGroup                    = self.dataArray[indexPath.section]
        
        let contact                         = contactGroup.items[UInt(indexPath.row)] as! BKCustomersContact
       
        // 选择的industry_checkbox
        let button                          = UIButton(type: .custom)
        button.setImage(UIImage(named: "industry_checkbox_sel"), for: .selected)
        button.setImage(UIImage(named: "industry_checkbox_nor"), for: .normal)
        button.frame                        = CGRect(x: 0.0, y: 0.0, width: CYLayoutConstraintValue(20.0), height: CYLayoutConstraintValue(20.0))
        button.tag                          = indexPath.row
        button.isUserInteractionEnabled     = false
        cell.accessoryView                  = button

        button.isSelected                   = (contact.isSelectContact)
        button.isHidden                     = self.displayType != .invitation
        cell.nameLabel.text                 = contact.name
        
        // 头像
        let avatar : String                 = contact.avatar
        cell.headImageView.kf.setImage(with: URL(string: avatar), placeholder: KCustomerUserHeadImage, options: nil, progressBlock: nil, completionHandler: nil)
        
        
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CYLayoutConstraintValue(55.0)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let contactGroup                    = self.dataArray[indexPath.section]
        let contact                         = contactGroup.items[UInt(indexPath.row)] as! BKCustomersContact

        switch self.displayType {
        case .detail , .businessCard , .newGroupOwner:
            self.delegate?.userDetail?((contact), viewController: self)
            self.dismiss(animated: false, completion: nil)
            return
        case .remind :
            self.cacheMembers[contact.uid] = contact
            self.nextStep()
            return

        default:
            
            break
        }
      
    
        contact.isSelectContact            = !(contact.isSelectContact)
      
        self.tableView.reloadRows(at: [indexPath], with: .automatic)
        let userId                          = contact.uid
        let key                             = "\(userId)"
        if (contact.isSelectContact) {
            self.cacheMembers[key] = contact
        } else {
            self.cacheMembers.removeObject(forKey: key)
        }
        
        if self.cacheMembers.count != 0 {
            self.setRightBarbuttonItemWithTitles(["完成(\(self.cacheMembers.count))"], actions: [#selector(nextStep)])
        } else {
            self.navigationItem.rightBarButtonItem = nil
        }
   
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CYLayoutConstraintValue(22.0)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return self.letterArray
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label           = UILabel()
        label.textColor     = UIColor.colorWithHexString("#333333")
        label.font          = CYLayoutConstraintFont(14.0)
        label.frame         = CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: CYLayoutConstraintValue(22.0))
        let contactGroup    = self.dataArray[section]
        label.text          = "     \(contactGroup.letter)"
        
        return label
    }
}

