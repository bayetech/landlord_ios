//
//  BKAddFriendReqeustViewController.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/27.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD

/// 新的请求的页面
class BKAddFriendReqeustViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView! {
        didSet {
            tableView.backgroundColor   = UIColor.RGBColor(243.0, green: 243.0, blue: 243.0)
            tableView.register(UINib(nibName: "BKAddFriendReqeustView", bundle: nil), forCellReuseIdentifier: "BKAddFriendReqeustView")
            tableView.tableFooterView   = UIView()
        }
    }
    var reasonDict : [String : String] = [String : String]()
    var dataArray : [BKAddFriendReqeust] = [BKAddFriendReqeust]()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
        self.loadDatas()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    func setup() {
        
        self.title                              = "新的好友"
        self.navigationItem.rightBarButtonItem  = UIBarButtonItem(title: "添加好友", style: .done, target: self, action: #selector(BKAddFriendReqeustViewController.addFriendAction))
        
        // 读取未读消息 每次进来默认所有未读消息为已读
        BKRealmManager.shared().userDidReadApplyFriendsNotice()
        // 用户联系人发生了改变
        NotificationCenter.bk_addObserver(self, selector: #selector(contactDidChange), name: "ContactDidChange", object:nil)
        
    }
    
    /// 加载本地数据
    func loadDatas() {
        
        //  获取数据库中所有加好友信息
        self.dataArray = BKRealmManager.shared().queryContatctApplys(inRealm: false)
        tableView.reloadData()
        
    }
    
    // 联系人列表发生改变的时候
    func contactDidChange(_ noti:Notification) {
        
        if let custome_uid = noti.object as? String {
            BKRealmManager.shared().deleteContactReqeust(custome_uid)
            loadDatas()
        }
                
    }
    
    /// 添加好友
    func addFriendAction() {
        
        let addNewFriendViewController = BKAddFriendsViewController()
        self.navigationController?.pushViewController(addNewFriendViewController, animated: true)
        
    }
    
    /// 提供了 BKAddFriendReqeust 向 BKCustomersContact转换的方法
    fileprivate func customerUser(by applay : BKAddFriendReqeust) -> BKCustomersContact {
        
        let contact                 = BKCustomersContact()
        contact.avatar              = applay.customer_avatar ?? ""
        contact.name                = applay.customer_name ?? ""
        contact.uid                 = applay.customer_uid ?? ""
        contact.company             = applay.customer_company ?? ""
        contact.company_position    = applay.customer_company_position ?? ""
        contact.applyReason         = applay.resion ?? ""
        let isFriend                = BKRealmManager.shared().customerUserIsFriendOrder(by: contact.uid)
        contact.isFriend            = isFriend
        
        return contact
    }

    deinit {
        NJLog(self)
    }
    
    
    
}
 // MARK: - UITableViewDataSource && UITableViewDelegate
 extension BKAddFriendReqeustViewController : UITableViewDataSource , UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell                    = tableView.dequeueReusableCell(withIdentifier: "BKAddFriendReqeustView") as! BKAddFriendReqeustView
        cell.delegate               = self
        cell.indexPath              = indexPath
        
        let applyModel              = dataArray[indexPath.row]
        
        // 用户资料的模型
        let contact                 = customerUser(by:applyModel)
        
        cell.contact                = contact
        
        if (applyModel.actionType == .decline) {
            cell.buttonWidth.updateConstraint(0)
        } else {
            cell.buttonWidth.updateConstraint(70.0)
        }

        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CYLayoutConstraintValue(97.5)
    }


    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {


    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let applay         = self.dataArray[indexPath.row]
        let contact        = customerUser(by: applay)
        
        let action = UITableViewRowAction(style: .destructive, title: "删除") {[weak self] (act, indexPath) in
            
            // 对方不是你的好友 并且消息类型是添加好友申请时 可以通过删除拒绝添加
            if !contact.isFriend && applay.actionType == .add {
                // 不是好友时左滑拒绝添加,并把数据库好友请求数据删除
                EMClient.shared().contactManager.declineFriendRequest(fromUser: contact.uid, completion: { (name, error) in
                    if error != nil {
                        NJLog(error?.errorDescription)
                    }
                })
            }
            
            // 删除本次加好友的记录
            BKRealmManager.shared().deleteContactReqeust(contact.uid)
            self?.dataArray.remove(at: indexPath.row);
            self?.tableView.deleteRows(at: [indexPath], with: .automatic)
            
        }
        
        return [action]
        
    }

}


// MARK: - BKAddFriendReqeustViewDelegate
extension BKAddFriendReqeustViewController : BKAddFriendReqeustViewDelegate {
    
    /// 点击了用户头像
    func didSelectUserImageView(_ cell: BKAddFriendReqeustView, indexPath: IndexPath) {
        
        let contact                         = self.dataArray[indexPath.row]
        let userDetailViewController        = BKUserDetailViewController()
        userDetailViewController.userId     = contact.customer_uid ?? ""
        self.navigationController?.pushViewController(userDetailViewController, animated: true)
        
    }
    
    /// 点击了右边的按钮
    func didSelectButton(_ cell: BKAddFriendReqeustView, indexPath: IndexPath, isSelect: Bool) {
        
        let applay                  = self.dataArray[indexPath.row]
        
        if isSelect {
            
            // 发送消息
            EMIMHelper.shared().hy_chatRoom(withConversationChatter: applay.customer_uid ?? "",soureViewController: self)
            
        } else {
            
            // 同意添加好友
            HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
            
            BKNetworkManager.postOperationReqeust(baseURLPath + "customer_friends/accept", params: ["customer_uid" : applay.customer_uid ?? ""], success: {[weak self] (success) in
                HUD.hide(animated: true)
                
                let return_code     = success.value["return_code"]?.intValue ?? 0
                let return_message  = success.value["return_message"]?.stringValue ?? "同意添加好友失败"
                guard return_code == 201 else {
                    UnitTools.addLabelInWindow(return_message, vc: self)
                    return
                }
                
                // 存储用户的资料信息
                if let customer = success.value["customer"]?.dictionaryValue {
                    let contact = BKCustomersContact(by: JSON(customer))
                    BKRealmManager.shared().insertEaseMobContact([contact.uid])
                    BKRealmManager.shared().insertCustomerContact([contact])
                    NotificationCenter.bk_postNotication("ContactDidChange")
                }
                
                UnitTools.addLabelInWindow("同意加好友成功", vc: self)
                self?.tableView.reloadRows(at: [indexPath], with: .automatic)

            }, failure: {[weak self] (failure) in
                
                HUD.hide(animated: true)
                UnitTools.addLabelInWindow(failure.errorMsg, vc: self)

            })
            
        }
        
        
    }
    
}
