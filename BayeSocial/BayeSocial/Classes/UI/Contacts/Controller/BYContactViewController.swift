//
//  BYContactViewController.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/21.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD

/// 巴爷供销社人脉
class BYContactViewController: UIViewController {
    
    var tableView: UITableView              = UITableView(frame: CGRect.zero, style: .grouped)
    var popoverView : BYContactPopoverView?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets   = false
        self.setup()
        self.loadDatas()
        
        // 当人脉发生改变的时候
        NotificationCenter.bk_addObserver(self, selector: #selector(contactDidChange), name: "ContactDidChange", object: nil)
        
        // 监听 app 运行状态 进入后台存储数据
        BKApplicationHelper.addDelegate(self)
        
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)

    }
    
    // 当人脉发生改变的时候
    func contactDidChange() {
        loadDatas()
    }
    
    var dataArray  = [BKCustomerContactGroup]()
    var userContacts : [BKCustomersContact]?
    var headView : BYContactHeadView? {
        didSet {
            headView?.delegate = self
        }
    }
    
    func setup() {
    
        self.view.addSubview(self.tableView)
        self.tableView.delegate                     = self
        self.tableView.dataSource                   = self
        self.tableView.snp.makeConstraints {[weak self] (make) in
            make.edges.equalTo((self?.view)!).inset(UIEdgeInsetsMake(0.0, 0.0, 49.0, 0.0))
        }
        
        tableView.backgroundColor       = UIColor.RGBColor(243.0, green: 243.0, blue: 243.0)
        tableView.register(UINib(nibName: "BYContactTableViewCell", bundle: nil), forCellReuseIdentifier: "BYContactTableViewCell")
        tableView.tableFooterView       = UIView(frame: CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: 30.0))
        let contactHeadView                         = BYContactHeadView.viewFromNib() as! BYContactHeadView
        self.tableView.tableHeaderView              = contactHeadView
        contactHeadView.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo(self.tableView.snp.top)
            make.left.equalTo(self.tableView.snp.left)
            make.size.equalTo(CGSize(width: KScreenWidth, height: CYLayoutConstraintValue(275.0)))
        }
        self.headView                               = contactHeadView
        self.tableView.perform(#selector(UITableView.reloadData), with: nil, afterDelay: 0.01)
        self.tableView.sectionIndexBackgroundColor  = UIColor.clear
        self.tableView.sectionIndexColor            = UIColor.colorWithHexString("#999999")
        
    }
    
    /// 更新头部视图
    public func updateHeadView() {
        
        let unreadCount                                = BKRealmManager.shared().queryContatctApplys(inRealm: true).count
        
        if unreadCount != 0 {
            self.headView?.badgeView.isHidden = false
            self.headView?.newReqeustBadgeLabel.text    = unreadCount>100 ? "99+" : String(format: "%d", unreadCount)
        } else {
            self.headView?.badgeView.isHidden = true
        }
        
        self.headView?.newReqeustBadgeLabel.isHidden    = (self.headView?.badgeView.isHidden)!
        
        // 改变 badgeValue
        EMIMHelper.shared().setupContactViewBadgeValue()
        
    }

    public func loadDatas() {
  
        let contacts =  BKRealmManager.shared().readUserContacts(easemob_username)
        reloadDatas(by: contacts);
        reqeustUserContacts()
        
    }
    
    /// 获取用户联系人列表
    func reqeustUserContacts() {
        
        BKNetworkManager.getOperationReqeust(baseURLPath + "customer_friends/friend_contacts", params: ["customer_uid" : easemob_username], success: {[weak self] (result) in
            
            HUD.hide(animated: true)
            let json                        = result.value
            let customers                   = json["customers"]?.arrayValue
            let error_code                  = json["return_code"]?.intValue ?? 0
            let return_message              = json["return_message"]?.stringValue ?? "获取联系人失败!"
            if (error_code != 200 || customers == nil) {
                self?.reloadDatas(by: [BKCustomersContact]())
                UnitTools.addLabelInWindow(return_message, vc:nil)
                return;
            }
            
            DispatchQueue.globalAsync {
                var contacts            = [BKCustomersContact]()
                for item in customers! {
                    let customer        = BKCustomersContact(by: item)
                    contacts.append(customer)
                }
                self?.reloadDatas(by: contacts)
            };
            
        }) {[weak self] (result) in
            HUD.hide(animated: true)
            UnitTools.addLabelInWindow("获取联系人失败!", vc:self)
        }
        
    }
    
    func reloadDatas(by contacts:[BKCustomersContact]) {
        
        self.dataArray = (BKCustomerContactGroup.appendFormatterData(customers: contacts))
        self.userContacts = contacts
        DispatchQueue.mainAsync { [weak self] () in
            self?.tableView.reloadData()
        };
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.updateHeadView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(true)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.popoverView?.removeFromSuperview()
        self.popoverView        = nil

    }

    deinit {
        
        NotificationCenter.default.removeObserver(self)
        
    }
    
}


// MARK: - UITableViewDataSource && UITableViewDelegate
extension BYContactViewController : UITableViewDataSource , UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.dataArray.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let items = self.dataArray[section].items
        return Int(items.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell            = tableView.dequeueReusableCell(withIdentifier: "BYContactTableViewCell") as! BYContactTableViewCell
        
        let contactGroup    = self.dataArray[indexPath.section]
        let contact         = contactGroup.items[UInt(indexPath.row)] as! BKCustomersContact
        cell.nameLabel.text = contact.name
        cell.headImageView.kf.setImage(with: URL(string : (contact.avatar)), placeholder: KCustomerUserHeadImage, options: nil, progressBlock: nil, completionHandler: nil)
        cell.delegate       = self
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CYLayoutConstraintValue(55.0)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        self.userDetail(at: indexPath)
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CYLayoutConstraintValue(22.0)
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label                           = UILabel()
        label.textColor                     = UIColor.colorWithHexString("#333333")
        label.font                          = CYLayoutConstraintFont(14.0)
        label.frame                         = CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: CYLayoutConstraintValue(22.0))
        let contactGroup                    = self.dataArray[section]
        label.text                          = "     \(contactGroup.letter)"
        
        return label
    }
}

// MARK: - BYContactHeadViewDelegate
extension BYContactViewController : BYContactHeadViewDelegate {
    
     /// 选择了添加的按钮
    func by_ContactHeadView(_ didSelectAddBtn: BYContactHeadView) {
        
        guard self.popoverView == nil else {
            return
        }
        
        let popoverView                     = BYContactPopoverView.viewFromNib() as! BYContactPopoverView
        self.view.addSubview(popoverView)
        popoverView.delegate                = self
        popoverView.snp.makeConstraints {[weak self] (make) in
            make.edges.equalTo((self?.view)!)
        }
        self.popoverView                    = popoverView

    }
    
    /// 选择了我的社群
    func by_ContactHeadViewDidSelectMyGroupView(_ headView: BYContactHeadView) {
        
        let mineGroupViewController                         = BKMyJoinGroupViewController()
        mineGroupViewController.hidesBottomBarWhenPushed    = true
        self.navigationController?.pushViewController(mineGroupViewController, animated: true)
        
    }
    
    ///点击了新的的请求的视图
    func by_ContactHeadViewDidSelectNewReqeustView(_ headView: BYContactHeadView) {
        
        let newReqeustViewController                        = BKAddFriendReqeustViewController()
        newReqeustViewController.hidesBottomBarWhenPushed   = true
        self.navigationController?.pushViewController(newReqeustViewController, animated: true)
        
    }
    
    /// 点击了搜索输入框
    func by_ContactHeadViewDidSelectSearchTextField(_ headView: BYContactHeadView) {
        
        let searchViewController                        = BKSearchResultViewController()
        searchViewController.hidesBottomBarWhenPushed   = true
        self.navigationController?.pushViewController(searchViewController, animated: false)
        
    }
    
}

// MARK: - BYContactPopoverViewDelegate
extension BYContactViewController : BYContactPopoverViewDelegate , BYContactTableViewCellDelegate {
    
    /// 选择了 popoverView 的某个选项
    func didSelectButton(_ popoverView: BYContactPopoverView, type: ContactAddBtnType) {
        
        switch type {
        case .createGroup: // 创建群聊
            let createGroupViewController                       = BKCreateGroupViewController()
            createGroupViewController.hidesBottomBarWhenPushed  = true
            self.navigationController?.pushViewController(createGroupViewController, animated: true)
            break
        case .addFriend : // 添加好友
            
            let addFriendViewController                         = BKAddFriendsViewController()
            addFriendViewController.hidesBottomBarWhenPushed    = true
            self.navigationController?.pushViewController(addFriendViewController, animated: true)
            
            break
        default: // 扫描二维码
            
            let scanQRCodeViewController                        = BKScanQRCodeViewController()
            scanQRCodeViewController.hidesBottomBarWhenPushed   = true
            self.navigationController?.pushViewController(scanQRCodeViewController, animated: true)

            break
        }
        
    }
    /// popoverView 即将消失
    func didDismissPopoverView(_ popoverView: BYContactPopoverView) {
        self.popoverView = nil
    }

    /// 点击头像查看个人资料
    func didSelectUserAvatar(_ cell: BYContactTableViewCell) {
        
        let indexPath                                       = self.tableView.indexPath(for: cell)
        
        guard indexPath                                     != nil else {
            return
        }
        
        self.userDetail(at: indexPath!)
    }
    
    /// 用户详情页面
    func userDetail(at indexPath : IndexPath) {
        
        let contactGroup                                    = self.dataArray[indexPath.section]
        let contact                                         = contactGroup.items[UInt(indexPath.row)] as! BKCustomersContact
        let userDetailViewCotroller                         = BKUserDetailViewController()
        userDetailViewCotroller.userId                      = contact.uid
        userDetailViewCotroller.hidesBottomBarWhenPushed    = true
        self.navigationController?.pushViewController(userDetailViewCotroller, animated: true)
        
    }
    
    
}


extension  BYContactViewController : BKApplicationHelperDelegate {
    
    func bk_ApplicationDidEnterBackgroundNotificationno(_ application: UIApplication) {
        
        // 存储用户人脉信息
        BKRealmManager.shared().insertUserContacts(self.userContacts!, userId: easemob_username)
        
    }
    
}


