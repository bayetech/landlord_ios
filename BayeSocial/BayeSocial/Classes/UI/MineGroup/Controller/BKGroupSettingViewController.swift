//
//  BKGroupSettingViewController.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/11/3.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD

@objc protocol BKGroupSettingViewControllerDelegate : NSObjectProtocol {
    
    ///  清除聊天群设置里边点击了清除聊天记录
    @objc optional func groupSettingViewController(cleanChatMessage viewController : BKGroupSettingViewController)
}

/// 群设置控制器
class BKGroupSettingViewController: BKBaseViewController {
    
    lazy var tableView : UITableView = {
        let tableView                   = UITableView(frame: CGRect.zero, style: .plain)
        tableView.backgroundColor = UIColor.RGBColor(243.0, green: 243.0, blue: 243.0)
        tableView.register(UINib(nibName: "BKGroupAddMemberViewCell", bundle: nil), forCellReuseIdentifier: "BKGroupAddMemberViewCell")
        tableView.delegate              = self
        tableView.dataSource            = self
        return tableView
    }()
    var isNotdisturbing : Bool          = false {
        didSet {
            BKGlobalOptions.curret.groupDisturbings[self.group_id] = isNotdisturbing
        }
    }
    var titles : [[String]]?
    var avatarImageView : UIImageView?
    var groupNameLabel  : UILabel?
    var groupDescLabel  : UILabel?
    var group_id : String = ""
    var chatGroupModel : BKChatGroupModel?
    var groupMembers : [BKCustomersContact] =  [BKCustomersContact]()
    weak var delegate : BKGroupSettingViewControllerDelegate?
    var arrowImageView:  UIImageView?
    var groupView : UIView?
    var groupMembersView : [UIImageView] = [UIImageView]()
    var isGroupOwner : Bool = false
    weak var backButton : BKAdjustButton?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        self.addHeadView()
        self.addFootView()
        self.loadDatas()

        self.showHUD()

        guard self.groupMembers.count != 0 else {
            reqeustGroupMembers()
            return
        }
        
    }
    
    /// 获取群组的成员列表
    func reqeustGroupMembers() {
    
        AppDelegate.appDelegate().requestGroupMembers(by: self.group_id) {[weak self] (gruopMembers) in
            self?.groupMembers = gruopMembers
            self?.tableView.reloadData()
        }
        
    }
    
    /// 部落的详细资料
    func reqeustChatGroupDetail() {
        
        
        let reqeusetURL             = String(format: "%@/%@", KURL_MineJoinChat_groupsApi,self.group_id)
        BKNetworkManager.getReqeust(reqeusetURL, params: nil, success: {[unowned self] (success) in
            HUD.hide(animated: true)
            let json                = success.value
            let chat_group          = json["chat_group"]?.dictionaryValue
            guard chat_group != nil else {
                let error_code      = json["error_code"]?.int
                if error_code != nil  {
                    let msg         = json["error"]?.stringValue ?? "获取我的社群失败"
                    UnitTools.addLabelInWindow(msg, vc: self)
                }
                return
            }

            self.chatGroupModel = BKChatGroupModel(by: JSON(chat_group!))
            self.isGroupOwner   = ((self.chatGroupModel?.owner_uid)! == KCustomAuthorizationToken.easemob_username)
            self.reloadHeadViewInfo()
            self.tableView.reloadData()
            
            }) {[unowned self]  (failure) in
                HUD.hide(animated: true)
                UnitTools.addLabelInWindow(failure.errorMsg, vc: self)
        }
        
    }
    
    /// 刷新头部视图内容显示
    func reloadHeadViewInfo() {
        
        guard self.chatGroupModel != nil else {
            return
        }
        
        if let avatar   = self.chatGroupModel?.avatar {
            let url     = URL(string: avatar)
            self.avatarImageView?.kf.setImage(with: url, placeholder: KCustomerUserHeadImage, options: nil, progressBlock: nil, completionHandler: nil)
        }
        
        self.groupNameLabel?.text       = self.chatGroupModel?.groupname
        self.groupDescLabel?.text       = self.chatGroupModel?.desc
        self.arrowImageView?.isHidden   = !self.isGroupOwner
        self.groupView?.isUserInteractionEnabled = !(self.arrowImageView?.isHidden)!
        
    }
    
    func setup() {
        
        self.view.addSubview(self.tableView)
        self.tableView.snp.makeConstraints {[weak self] (make) in
            make.edges.equalTo((self?.view)!).inset(UIEdgeInsetsMake(0.0, 0.0, 50.0, 0.0))
        }
        
    }
    
    func loadDatas() {
        
        self.isNotdisturbing        = BKGlobalOptions.curret.groupDisturbings[self.group_id] ?? false
        self.titles = [["部落成员 \(self.groupMembers.count)"],["消息免打扰"],["举报","清空聊天记录"]]
        self.tableView.delayReload(with: 0.1)
     
    }

    /// 添加头部视图
    
    func addHeadView() {
        
        let headView                            = UIView()
         headView.backgroundColor               = UIColor.white
        self.tableView.tableHeaderView          = headView
        headView.snp.makeConstraints {[unowned self] (make) in
            make.top.left.equalTo(self.tableView)
            make.size.equalTo(CGSize(width: KScreenWidth, height: CYLayoutConstraintValue(140.0)))
        }

        let button                              = BKAdjustButton(type: .custom)
        button.setImage(UIImage(named:"black_backArrow"), for: .normal)
        button.addTarget(self, action: #selector(BKGroupSettingViewController.back), for: .touchUpInside)
        headView.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.top.equalTo(headView.snp.top).offset(CYLayoutConstraintValue(34.0))
            make.left.equalTo(headView.snp.left).offset(CYLayoutConstraintValue(11.5))
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(30.0), height: CYLayoutConstraintValue(21.0)))
        }
        
        backButton                              = button
        
        // 导航title
        let titleLabel                          = UILabel()
        titleLabel.font                         = CYLayoutConstraintFont(17.0)
        titleLabel.text                         = "聊天设置"
        titleLabel.addTarget(self, action: #selector(BKGroupSettingViewController.back))
        headView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.left.equalTo(button.snp.right)
            make.top.equalTo(headView.snp.top).offset(CYLayoutConstraintValue(36.0))
        }
        
        self.groupView                           = UIView()
        groupView?.addTarget(self, action: #selector(BKGroupSettingViewController.editingGroupInfo))
        headView.addSubview(groupView!)
        groupView?.snp.makeConstraints { (make) in
            make.top.equalTo(headView.snp.top).offset(CYLayoutConstraintValue(65.0))
            make.left.right.bottom.equalTo(headView)
        }
        
        // 头像
        let imageView                           = UIImageView()
        imageView.setCornerRadius(CYLayoutConstraintValue(22.5))
        imageView.image                         = KCustomerUserHeadImage
        groupView?.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo((groupView?.snp.top)!).offset(CYLayoutConstraintValue(12.0))
            make.left.equalTo(headView.snp.left).offset(CYLayoutConstraintValue(20.0))
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(45.0), height: CYLayoutConstraintValue(45.0)))
        }
        self.avatarImageView                    = imageView
        
        // 群名称
        let label                               = UILabel()
        label.font                              = CYLayoutConstraintFont(17.0)
        label.text                              = ""
        headView.addSubview(label)
        label.snp.makeConstraints {[weak self] (make) in
            make.left.equalTo( (self?.avatarImageView?.snp.right)!).offset(CYLayoutConstraintValue(19.0))
            make.top.equalTo((self?.groupView?.snp.top)!).offset(CYLayoutConstraintValue(13.0))
            make.right.equalTo(headView.snp.right).offset(-CYLayoutConstraintValue(10.0))
        }
        self.groupNameLabel                     = label
        
        // 群介绍
        let descLabel                           = UILabel()
        descLabel.font                          = CYLayoutConstraintFont(16.0)
        descLabel.textColor                     = UIColor.colorWithHexString("#979797")
        descLabel.text                          = ""
        groupView?.addSubview(descLabel)
        descLabel.snp.makeConstraints {[weak self] (make) in
            make.left.equalTo((self?.avatarImageView?.snp.right)!).offset(CYLayoutConstraintValue(19.0))
            make.top.equalTo(label.snp.bottom).offset(CYLayoutConstraintValue(3.0))
            make.right.equalTo((self?.groupNameLabel!)!)
        }
        self.groupDescLabel                     = descLabel
        
        let righImageView                      = UIImageView()
        righImageView.image                    = UIImage(named: "right_nextarrow")
        groupView?.addSubview(righImageView)
        righImageView.snp.makeConstraints { (make) in
            make.right.equalTo((groupView?.snp.right)!).offset(-CYLayoutConstraintValue(17.5))
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(12.0), height: CYLayoutConstraintValue(20.0)))
            make.centerY.equalTo(groupView!)
        }
        self.arrowImageView                     = righImageView
        
        // 底部横线
        let bottomlineView                      = UIView()
        bottomlineView.backgroundColor          = UIColor.RGBColor(210.0, green: 210.0, blue: 210.0)
        groupView?.addSubview(bottomlineView)
        bottomlineView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalTo(groupView!)
            make.height.equalTo(0.5)
        }
        
    }

    /// FOOTVIEW
    func addFootView() {

        // 删除按钮
        let deleteButton                    = UIButton(type: .custom)
        deleteButton.setTitle("删除并退出", for: .normal)
        deleteButton.addTarget(self, action: #selector(deleteAndExitGroup), for: .touchUpInside)
        deleteButton.backgroundColor        = UIColor.colorWithHexString("#39BBA1")
        deleteButton.layer.masksToBounds    = true
        self.view.addSubview(deleteButton)
        deleteButton.snp.makeConstraints {[weak self] (make) in
            make.bottom.equalTo((self?.view.snp.bottom)!)
            make.left.equalTo((self?.view)!)
            make.size.equalTo(CGSize(width: KScreenWidth, height: 50.0))
        }
        
        self.tableView.tableFooterView      = UIView(frame: CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: 30.0))
    }
    
    /// 删除并退出
    @objc func deleteAndExitGroup() {
        
        guard self.chatGroupModel != nil else {
            return
        }
      
        let title = String(format: "你将退出 %@，退出部落通知仅部落管理员可见。", self.chatGroupModel?.groupname ?? "部落聊")
        
        let _ = YepAlertKit.showAlertView(in: self, title: title, message: nil, titles: nil, cancelTitle: "取消", destructive: "退出") {[weak self] (index) in
            if index == 1000 {
                if (self?.isGroupOwner)! {
                    self?.groupOwnerDeleteGroup()
                } else {
                    self?.exitGroup()
                }
            }
        }
    
    }
    
    /// 群组解散群组
    func groupOwnerDeleteGroup() {
        
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        let groupId                 = self.chatGroupModel?.groupid ?? ""
        let reqeustURL              = KURL_MineJoinChat_groupsApi + "/\(groupId)"
        
        BKNetworkManager.deleteRequst(reqeustURL, params :nil, success: {[weak self]  (success) in
            
            HUD.hide(animated: true)
            let json            = success.value
            let notice          = json["notice"]?.dictionary
            guard notice != nil else {
                UnitTools.addLabelInWindow("删除并退出部落失败", vc: self)
                return
            }
            let code = notice?["code"]?.int ?? 0
            if code == 200 {
                UnitTools.addLabelInWindow("删除并退出部落成功", vc: self)
                BKRealmManager.shared().userExitGroup(byGroupId: (self?.group_id)!)
                self?.deleteGroupConversation((self?.group_id)!)
                self?.navigationController?.popToRootViewControllerAnimated(true, delay: 0.5)
            } else {
                let msg = notice?["message"]?.string ?? "删除并退出部落失败"
                UnitTools.addLabelInWindow(msg, vc: self)
            }
            
        }) {[weak self] (failure) in
            HUD.hide(animated: true)
            UnitTools.addLabelInWindow("网络错误,请稍后再试", vc: self)
        }
        
    }
    
    /// 删除之前的聊天会话
    func deleteGroupConversation(_ groupId : String) {
        
        let conversations = EMClient.shared().chatManager.getAllConversations()
        guard conversations?.count != 0 else {
            return
        }
        // 退出群聊成功就删除之前群聊会话
        for item in conversations! {
            let conversation = item as! EMConversation
            if conversation.conversationId == self.group_id {
                EMClient.shared().chatManager.deleteConversation(conversation.conversationId, isDeleteMessages: true, completion: nil)
                break
            }
        }
        
    }
    
    /// 普通群成员只能退群
    func exitGroup() {
   
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)        
        EMClient.shared().groupManager.leaveGroup(self.group_id) {[weak self]  (error) in
            HUD.hide(animated: true)
            
            if error == nil {
                UnitTools.addLabelInWindow("删除并退出部落成功", vc: self)
                
                // 用户退出群组
                BKRealmManager.shared().userExitGroup(byGroupId: (self?.group_id)!)
                self?.deleteGroupConversation((self?.group_id)!)
                self?.navigationController?.popToRootViewControllerAnimated(true, delay: 0.5)
            } else {
                let msg = "删除并退出部落失败"
                UnitTools.addLabelInWindow(msg, vc: self)
            }
            

        }
        
        
    }
    
    @objc func back() {
        
       let _ =  self.navigationController?.popViewController(animated: true)
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        reqeustChatGroupDetail()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }

    deinit {
        NJLog(self)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.tableView.separatorInset = UIEdgeInsets.zero
        self.backButton?.setImageViewSizeEqualToCenter(CGSize(width: 13.0, height: 21.0))

    }
    
    
    /// 编辑群资料
    @objc func editingGroupInfo() {
        
        guard self.chatGroupModel != nil else {
            UnitTools.addLabelInWindow("暂时无法编辑部落资料", vc: self)
            return
        }
        
        let editingInfoViewController               = BKEditingGroupInfoViewController()
        editingInfoViewController.chat_groupModel   = self.chatGroupModel
        self.navigationController?.pushViewController(editingInfoViewController, animated: true)
        
    }
    
    /// 清楚聊天缓存记录
    func cleanChatMessageHistory() {
        
        let _ = YepAlertKit.showAlertView(in: self, title: "是否清空部落聊天记录", message: nil, titles:  nil, cancelTitle: "取消", destructive: "清空") {[weak self] (index) in
            if index == 1000 {
                self?.delegate?.groupSettingViewController?(cleanChatMessage: self!)
                UnitTools.addLabelInWindow("清空聊天记录", vc: self)
            }
        }
        
    }
    
    /// 举报功能
    func reportAction() {
        
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        BKNetworkManager.getOperationReqeust(KURL_ReportOptions, params: nil, success: {[weak self] (success) in
            HUD.hide(animated: true)
            let json                        = success.value
            let report_options              = json["report_options"]?.arrayObject
            guard report_options            != nil else {
                UnitTools.addLabelInWindow("获取举报内容失败!", vc:  self)
                return
            }
            self?.showReportActionSheet(report_options as! [String])
            }) { (failure) in
                UnitTools.addLabelInWindow("获取举报内容失败!", vc:  self)
        }
        
    }
    
    /// 举报功能
    func showReportActionSheet(_ reports : [String]) {
      
        let _ = YepAlertKit.showActionSheet(in: self, title: "举报部落", message: nil, titles: reports, cancelTitle: "取消", destructive: nil) {[weak self] (index) in
            
            if (index != 0) {
                self?.startReport(with: reports[index-1] , customerId: (self?.group_id)!)
            }
        }
        
    }
    
    /// 开始举报用户
    func startReport(with reason : String,customerId : String) {
        
        BKNetworkManager.postOperationReqeust(baseURLPath + "reports/chat_group", params: ["groupid" : customerId ,"message" : reason], success: {[weak self] (success) in
            
            let json            = success.value
            let return_code     = json["return_code"]?.int ?? 0
            guard return_code   == 201 else {
                UnitTools.addLabelInWindow("举报失败", vc: self)
                return
            }
            UnitTools.addLabelInWindow("举报成功", vc: self)
            }) {[weak self] (failure) in
                UnitTools.addLabelInWindow("举报失败", vc: self)
                
        }
        
    }
    
    /// 是否接受群消息
    @objc func swictcViewValueChanged(_ switchView : UISwitch) {
      
        EMClient.shared().groupManager.updatePushService(forGroup: self.group_id, isPushEnabled: switchView.isOn) {[weak self] (group, erorr) in
            guard erorr != nil else {
                self?.isNotdisturbing           = !(self?.isNotdisturbing)!
                self?.tableView.reloadData()
                return
            }
            UnitTools.addLabelInWindow("设置失败", vc: self)
        }
        
    }
    
    /// 添加群成员
    @objc func addMemberClick(_ btn :UIButton) {
        
        let addMemberViewController         = BKAddGroupMemberViewController()
        addMemberViewController.title       = "邀请新成员"
        addMemberViewController.userId      = KCustomAuthorizationToken.easemob_username
        addMemberViewController.displayType = .invitation
        addMemberViewController.groupId     = self.chatGroupModel?.groupid ?? ""
        addMemberViewController.delegate    = self
        
        let nav                             = BKNavigaitonController(rootViewController: addMemberViewController)
        self.present(nav, animated: true, completion: nil)
        
    }
    
}


// MARK: - UITableViewDataSource && UITableViewDelegate
extension BKGroupSettingViewController : UITableViewDataSource , UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard self.chatGroupModel != nil else {
            return 0
        }
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0  {
            guard self.groupMembers.count != 0 else {
                return 0
            }
            return self.isGroupOwner ? 2  : 1
        } else if section == 1 {
            return 0
        } else if section == 3 {
            return self.isGroupOwner ? 1 : 0
        } else if section == 2 {
            return 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // 群成员和邀请群成员
        if indexPath.section == 0 && indexPath.row == 0 {
        
            var groupMembersCell   = tableView.dequeueReusableCell(withIdentifier: "groupMembersCell")
            if groupMembersCell == nil {
                groupMembersCell                    = UITableViewCell(style: .default, reuseIdentifier: "groupMembersCell")
                groupMembersCell?.selectionStyle    = .none
                groupMembersCell?.accessoryType     = .disclosureIndicator
                // 标题
                let titleLabel                      = UILabel()
                titleLabel.text                     = "群成员"
                titleLabel.tag                      = 200
                titleLabel.font                     = CYLayoutConstraintFont(17.0)
                groupMembersCell?.contentView.addSubview(titleLabel)
                titleLabel.snp.makeConstraints({ (make) in
                    make.top.equalTo((groupMembersCell?.contentView.snp.top)!).offset(CYLayoutConstraintValue(10.0))
                    make.left.equalTo((groupMembersCell?.contentView.snp.left)!).offset(15.0)
                })
                
                // 群成员头像
                var lastImageView : UIImageView?
                for i in 0..<5 {
                    let imageView                       = UIImageView()
                    imageView.image                     = KCustomerUserHeadImage
                    imageView.setCornerRadius(CYLayoutConstraintValue(20.0))
                    groupMembersCell?.contentView.addSubview(imageView)
                    imageView.snp.makeConstraints({ (make) in
                        make.top.equalTo(titleLabel.snp.bottom).offset(CYLayoutConstraintValue(10.0))
                        if lastImageView != nil {
                            make.left.equalTo((lastImageView?.snp.right)!).offset(CYLayoutConstraintValue(10.0))
                        } else {
                            make.left.equalTo((groupMembersCell?.contentView.snp.left)!).offset(15.0)
                        }
                        make.size.equalTo(CGSize(width: CYLayoutConstraintValue(40.0), height: CYLayoutConstraintValue(40.0)))
                    })
                    lastImageView                          = imageView
                    imageView.isHidden                     = true

                    // 姓名 label
                    let nameLabel                          = UILabel()

                    nameLabel.font                         = CYLayoutConstraintFont(14.0)
                    nameLabel.textAlignment                = .center
                    nameLabel.tag                          = i+100
                    nameLabel.textColor                    = UIColor.colorWithHexString("#979797")
                    groupMembersCell?.contentView.addSubview(nameLabel)
                    nameLabel.snp.makeConstraints({ (make) in
                        make.top.equalTo(imageView.snp.bottom).offset(CYLayoutConstraintValue(5.0))
                        make.centerX.equalTo(imageView)
                        make.width.equalTo(CYLayoutConstraintValue(50.0))
                    })
                    
                    // 增加群主标签
                    if i == 0 {
                        
                        // 群主的 label
                        let groupOwnerLabel                          = UILabel()
                        groupOwnerLabel.text                         = "酋长"
                        groupOwnerLabel.setCornerRadius(CYLayoutConstraintValue(2.0))
                        groupOwnerLabel.font                         = UIFont.systemFont(ofSize: 8.0)
                        groupOwnerLabel.textAlignment                = .center
                        groupOwnerLabel.textColor                    = UIColor.white
                        groupOwnerLabel.backgroundColor              = UIColor.RGBColor(57.0, green: 187.0, blue: 161.0)
                        groupMembersCell?.contentView.addSubview(groupOwnerLabel)
                        groupOwnerLabel.snp.makeConstraints({ (make) in
                            make.bottom.right.equalTo(imageView)
                            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(19.0), height: CYLayoutConstraintValue(12.0)))
                        })
                        
                    }
                    
                    self.groupMembersView.append(imageView)
                }
            }
            //  设置头像内容
            for (idx,imageView) in self.groupMembersView.enumerated() {
                
                let nameLabel                   = groupMembersCell?.viewWithTag(idx+100) as! UILabel
                if idx < self.groupMembers.count {
                    
                    let user                    = self.groupMembers[idx]
                    imageView.isHidden          = false
                    let avatar                  = user.avatar
                    imageView.kf.setImage(with: URL(string : avatar), placeholder: KCustomerUserHeadImage, options: nil, progressBlock: nil, completionHandler: nil)
                    nameLabel.text              = user.name
                    
                } else {
                    imageView.isHidden = true
                }
                
                nameLabel.isHidden              = imageView.isHidden
                
            }
            
            // 设置群成员人数
            let titleLabel                          = groupMembersCell?.contentView.viewWithTag(200) as! UILabel
            let attributedString                    = NSMutableAttributedString(string: "群成员", attributes: [NSAttributedStringKey.font : CYLayoutConstraintFont(16.0),NSAttributedStringKey.foregroundColor : UIColor.colorWithHexString("#333333")])
            let membersCount                        = self.groupMembers.count
            attributedString.append(NSAttributedString(string: " \(membersCount) / \((self.chatGroupModel?.maxusers)!)", attributes: [NSAttributedStringKey.foregroundColor : UIColor.colorWithHexString("#FAB66F")]))
            titleLabel.attributedText               = attributedString;

            
            return groupMembersCell!
        
        } else if indexPath.section == 0 && indexPath.row == 1 {
            
            var addMembersCell = tableView.dequeueReusableCell(withIdentifier: "addMembersCell")
            if addMembersCell == nil  {
               addMembersCell                       = UITableViewCell(style: .default, reuseIdentifier: "addMembersCell")
               addMembersCell?.selectionStyle       = .none
                // 邀请按钮
                let button : UIButton               = UIButton(type: .custom)
                button.setBackgroundImage(UIImage(named : "addNewMembers"), for: .normal)
                button.addTarget(self, action: #selector(addMemberClick(_:)), for: .touchUpInside)
                addMembersCell?.contentView.addSubview(button)
                button.snp.makeConstraints({ (make) in
                    make.left.equalTo((addMembersCell?.contentView.snp.left)!).offset(15.0)
                    make.centerY.equalTo(addMembersCell!)
                    make.size.equalTo(CGSize(width: CYLayoutConstraintValue(108.0), height: CYLayoutConstraintValue(17.0)))
                })
            }
            
            return addMembersCell!
        }
        
        else {
            
            // 普通的 cell
            var normalCell = tableView.dequeueReusableCell(withIdentifier: "normalCell")
            if normalCell == nil {
                normalCell                      = UITableViewCell(style: .value1, reuseIdentifier: "normalCell")
                normalCell?.selectionStyle      = .none
            }
            normalCell?.textLabel?.text         = sectionTitle(by: indexPath)
            
            
            if indexPath.section == 2 {
                
                // 开关switch
                let switchView              = UISwitch()
                switchView.setOn(self.isNotdisturbing, animated: false)
                switchView.tag              = indexPath.row
                switchView.onTintColor      = UIColor.colorWithHexString("#FAB66F")
                normalCell?.accessoryView = switchView
                switchView.addTarget(self, action: #selector(swictcViewValueChanged(_:)), for: .valueChanged)
                
            }
            
            return normalCell!
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.section == 0 && indexPath.row == 0 {
            return CYLayoutConstraintValue(110.0)
        } else if indexPath.section == 0 && indexPath.row == 1 {
            return CYLayoutConstraintValue(45.0)
        } else if indexPath.section == 1 && indexPath.row == 1 {
            return CYLayoutConstraintValue(97.0)
        }
        return CYLayoutConstraintValue(60.0)
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        switch (indexPath.section,indexPath.row) {
        case (0,0),(3,0): // 群成员或者管理权转让
            
            let groupMembersViewController            = BKAddGroupMemberViewController()
            groupMembersViewController.displayType    = indexPath.section == 0 ? .detail : .newGroupOwner
            groupMembersViewController.delegate       = self
            
            var userContacts                          = self.groupMembers
            // 不能讲管理权转给群主
            if groupMembersViewController.displayType == .newGroupOwner {
                BKRealmManager.beginWriteTransaction()
                userContacts.remove(at: 0)
                BKRealmManager.commitWriteTransaction()
            }

            groupMembersViewController.userContacts   = userContacts
            groupMembersViewController.title          = indexPath.section == 0 ? "群成员" : "选择新酋长"
            let nav                                   = BKNavigaitonController(rootViewController: groupMembersViewController)
            self.present(nav, animated: true, completion: nil)

            break

        case (4,0) : // 举报
            self.reportAction()
            break
        case (4,1) : //
            self.cleanChatMessageHistory()
            break
        default:
            
            break
        }
        
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets.zero
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.001
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CYLayoutConstraintValue(10.0)
    }
    
    
    func sectionTitle(by indexPath : IndexPath) -> String {
        
        switch (indexPath.section,indexPath.row) {
        case (1,0):
            return "群二维码"
//        case (2,0) :
//            return "置顶聊天"
        case (2,0) :
            return "消息免打扰"
        case (2,1) :
            return "消息免打扰"
        case (3,0) :
            return "群主管理权转让"
        case (4,0) :
            return "举报"
        case (4,1) :
            return "清空聊天记录"
        default:
            return ""
        }
        
    }
    
    
    
}

// MARK: - BKGroupAddMemberViewCellDelegate

extension BKGroupSettingViewController : BKAddGroupMemberViewControllerDelegate {
    
    
    /// 完成选择群成员代理
    func didFinishedGroupMembers(_ contacts: [String : String], viewController: BKAddGroupMemberViewController) {
        
        if contacts.isEmpty {
            return
        }
        let uids            = contacts.keys.reversed()
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        EMClient.shared().groupManager.addMembers(uids, toGroup: self.group_id, message: "欢迎加入部落") {[weak self] (group, error) in
            HUD.hide(animated: true)
            if (error != nil) {
//                NJLog(error?.errorDescription)
                UnitTools.addLabelInWindow((error?.errorDescription)!, vc: self)
            } else {
                UnitTools.addLabelInWindow("邀请部落成员成功", vc: self)
            }
            
        }
    
    }
    
    /// 查看用户详情资料

    func userDetail(_ customer: BKCustomersContact, viewController: BKAddGroupMemberViewController) {
        
        let userId          = customer.uid
        switch viewController.displayType.rawValue {
            
        case 5:
          
            UnitTools.delay(0.25, closure: {[weak self] () in
                let _ =  YepAlertKit.showAlertView(in: self!, title: nil, message: "确定选择\(customer.name)为新酋长，你将自动放弃酋长身份", titles: nil, cancelTitle: "取消", destructive: "确定", callBack: { (index) in
                    if (index == 1000) {
                        self?.transferGroupOwner((self?.group_id)!, userId: userId)
                    }
                })
            })
            
            break
        default: // 默认看详情页面
            
            let userDetailViewController        = BKUserDetailViewController()
            userDetailViewController.userId     = customer.uid
            self.navigationController?.pushViewController(userDetailViewController, animated: true)
            break
            
        }
     
        
    }
    
    /// 转移群主管理权
    func transferGroupOwner(_ groupId : String,userId : String) {
        
        BKNetworkManager.patchOperationReqeust(KURL_MineJoinChat_groupsApi+"/\(groupId)"+"/set_owner", params: ["customer_uid" : userId], success: {[weak self] (success) in
            
            let code    = success.value["return_code"]?.int ?? 0
            let msg     = success.value["return_message"]?.stringValue ?? "转让酋长管理权失败"
            guard code == 403 else {
                UnitTools.addLabelInWindow(msg, vc: self)
                return
            }
            
            UnitTools.addLabelInWindow(msg, vc: self)
            self?.navigationController?.popViewControllerAnimated(true, delay: 0.5)
            
        }) {[weak self] (failure) in
            
            UnitTools.addLabelInWindow(failure.errorMsg, vc: self)

        }
        
    }
    
}
