//
//  BKUserChatGroupsViewController.swift
//  BayeSocial
//
//  Created by dzb on 2017/1/19.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit
import PKHUD

/// 用户加入的群资料
class BKUserChatGroupsViewController: BKBaseViewController {

    var userId : String = "" {
        didSet {
            userSelf = (userId == easemob_username)
        }
    }
    var isVerifyGroup : Bool = false
    var groupId : String?
    var selectIndexPath : IndexPath?
    var groupName : String?
    var chatgroupArray : [BKChatGroupModel] = [BKChatGroupModel]() {
        didSet {
            BKRealmManager.shared().insertChatGroup(chatgroupArray)
        }
    }
    var tableView : UITableView = UITableView(frame: CGRect.zero, style: .plain)
    var userSelf : Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.leftTitle                              = userSelf ? "我的部落" : "他的部落"
        self.automaticallyAdjustsScrollViewInsets   = true
        tableView.delegate                          = self
        tableView.dataSource                        = self
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints {[weak self] (make) in
            make.edges.equalTo((self?.view)!)
        }
        
    }
    
    /// 获取某人加入过的群组
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    

    
}

// MARK: - UITableViewDelegate , UITableViewDataSource
extension BKUserChatGroupsViewController : UITableViewDelegate , UITableViewDataSource  {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard self.chatgroupArray.count > 0 else {
            return 0
        }
        return self.chatgroupArray.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "ChatGroupCell")
        
        if cell == nil {
            cell                            = UITableViewCell(style: .default, reuseIdentifier: "ChatGroupCell")
            cell?.selectionStyle            = .none
            
            // iconView
            let iconView                    = UIImageView()
            iconView.image                  = UIImage(named: "by_contact_group")
            iconView.tag                    = 100
            iconView.setCornerRadius(CYLayoutConstraintValue(22.5))
            cell?.contentView.addSubview(iconView)
            iconView.snp.makeConstraints({ (make) in
                make.left.equalTo((cell?.contentView.snp.left)!).offset(CYLayoutConstraintValue(12.0))
                make.centerY.equalTo((cell?.contentView)!)
                make.size.equalTo(CGSize(width: CYLayoutConstraintValue(45.0), height: CYLayoutConstraintValue(45.0)))
            })
            
            // 加好友按钮
            let addGroupButton                             = UIButton(type: .custom)
            addGroupButton.setBackgroundColor(backgroundColor: UIColor.colorWithHexString("#42C099"), forState: .normal)
            addGroupButton.setBackgroundColor(backgroundColor: UIColor.colorWithHexString("#BFC0C0"), forState: .selected)
            addGroupButton.tag                             = 500
            addGroupButton.setTitleColor(UIColor.white, for: .normal)
            addGroupButton.setCornerRadius(CYLayoutConstraintValue(4.0))
            addGroupButton.titleLabel?.font                = CYLayoutConstraintFont(14.0)
            addGroupButton.titleLabel?.textAlignment       = .center
            addGroupButton.setTitle("加入", for: .normal)
            addGroupButton.setTitle("已发送", for: .selected)
            addGroupButton.addTarget(self, action: #selector(joinGroupClick(_:event:)), for: .touchUpInside)
            cell?.contentView.addSubview(addGroupButton)
            addGroupButton.snp.makeConstraints({ (make) in
                make.right.equalTo(-CYLayoutConstraintValue(11.5))
                make.top.equalTo((cell?.contentView.snp.top)!).offset(CYLayoutConstraintValue(5.5))
                make.size.equalTo(CGSize(width: CYLayoutConstraintValue(65.0), height: CYLayoutConstraintValue(30.0)))
            })
            
            // 姓名
            let titleLabel                  = UILabel()
            titleLabel.tag                  = 200
            titleLabel.font                 = CYLayoutConstraintFont(16.0)
            titleLabel.textColor            = UIColor.colorWithHexString("#333333")
            cell?.contentView.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (make) in
                make.left.equalTo(iconView.snp.right).offset(CYLayoutConstraintValue(15.0))
                make.top.equalTo(addGroupButton)
                make.right.equalTo(addGroupButton.snp.left).offset(-CYLayoutConstraintValue(10.0))
            }
            
            // 群组人数 label
            let groupMembersLabel           = UILabel()
            groupMembersLabel.text          = "300人"
            groupMembersLabel.tag           = 1000
            groupMembersLabel.font          = CYLayoutConstraintFont(12.0)
            groupMembersLabel.textColor     = UIColor.colorWithHexString("#666666")
            cell?.contentView.addSubview(groupMembersLabel)
            groupMembersLabel.snp.makeConstraints({ (make) in
                make.top.equalTo(titleLabel.snp.bottom).offset(CYLayoutConstraintValue(3.0))
                make.left.right.equalTo(titleLabel)
            })
            
            // 子标题
            let subTitleLabel               = UILabel()
            subTitleLabel.tag               = 300
            subTitleLabel.font              = CYLayoutConstraintFont(14.0)
            cell?.contentView.addSubview(subTitleLabel)
            subTitleLabel.snp.makeConstraints { (make) in
                make.top.equalTo((groupMembersLabel.snp.bottom)).offset(CYLayoutConstraintValue(3.0))
                make.left.right.equalTo(titleLabel)
            }
            
            
        }
        
        let chatGroupModel                      = self.chatgroupArray[indexPath.row]
        
        let imageView                           = cell?.contentView.viewWithTag(100) as? UIImageView
        imageView?.kf.setImage(with: URL(string: (chatGroupModel.avatar ?? "")!), placeholder: KCustomerUserHeadImage, options: nil, progressBlock: nil, completionHandler: nil)
        
        // 标题
        let label                               = cell?.contentView.viewWithTag(200) as? UILabel
        label?.text                             = chatGroupModel.groupname
        
        let desc                                = chatGroupModel.desc
        
        // 群组人数
        let groupMembersLabel                   = cell?.contentView.viewWithTag(1000) as! UILabel
        groupMembersLabel.text                  = String(format: "%d人", chatGroupModel.member_count)
        
        let subLabel                            = cell?.contentView.viewWithTag(300) as? UILabel
        subLabel?.text                          = desc
        
        // 加入的按钮
        let addGroupButton                      = cell?.contentView.viewWithTag(500) as! UIButton
        
        let isJoinGroup                         = BKRealmManager.shared().cusetomerUserIs(inChatGroup: chatGroupModel.groupid!)

        // 更新数据库信息
        BKRealmManager.beginWriteTransaction()
        chatGroupModel.isInGroup                = isJoinGroup
        BKRealmManager.commitWriteTransaction()

        if isJoinGroup {
            addGroupButton.isSelected               = false
            addGroupButton.setTitle("发消息", for: .normal)
            addGroupButton.isUserInteractionEnabled = true
        } else  {
            
            // 是否已经发送了请求
            var isSelected              = false
            if let sendListModel        = BKRealmManager.shared().querySendListModel(chatGroupModel.groupid!) {
                isSelected  = sendListModel.isSend
            }
            
            addGroupButton.isSelected   = isSelected

            if isSelected {
                addGroupButton.setTitle("已发送", for: .selected)
            } else  {
                addGroupButton.setTitle("加入", for: .normal)
            }
            
            
        }
        
        return cell!
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CYLayoutConstraintValue(67.5)
    }
    

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let  chatGroupModel : BKChatGroupModel   = self.chatgroupArray[indexPath.row]
        let isJoinGroup                          = BKRealmManager.shared().cusetomerUserIs(inChatGroup: chatGroupModel.groupid!)
        
        guard !isJoinGroup else {
            return
        }
        
        let groupDetailViewController           = BKGroupDetailsViewController()
        groupDetailViewController.groupId       = chatGroupModel.groupid
        self.navigationController?.pushViewController(groupDetailViewController, animated: true)
        
        
        
    }
}


extension BKUserChatGroupsViewController : BKMakeCallViewControllerDelegate {
    
    
    /// 加入群组的按钮点击事件
    func joinGroupClick(_ btn:UIButton,event : Any) {
        
        let indexPath = btn.indexPath(at: self.tableView, forEvent: event)
        guard indexPath != nil else {
            return
        }
        self.selectIndexPath    = indexPath
        let groupModel          = self.chatgroupArray[(indexPath?.row)!]
        self.isVerifyGroup      = (groupModel.is_approval)
        let groupid             = groupModel.groupid ?? ""
       
        // 已经加群可以聊天
        guard btn.currentTitle != "发消息" else {
            
            EMIMHelper.shared().hy_chatRoom(withConversationChatter: groupid, soureViewController: self)
            return
        }
        
        // 需要验证加群
        guard !self.isVerifyGroup else {
            self.groupName      = groupModel.groupname
            self.showAddFreinedAlertController(groupid)
            return
        }
        
        // 不需要验证即可加群
        EMClient.shared().groupManager.joinPublicGroup(groupid, completion: {[weak self] (group, error) in
            if error != nil {
                UnitTools.addLabelInWindow("发送申请失败", vc: self)
                NJLog(error?.errorDescription)
                return
            }
            UnitTools.addLabelInWindow("发送申请成功", vc: self)
            let sendListModel   = BKSendList(uid: groupid, account: easemob_username, type: .group, isSend: true)
            BKRealmManager.shared().insert(sendListModel)
            self?.tableView.reloadRows(at: [(self?.selectIndexPath!)!], with: .automatic)
        })
        
    }
    
    /// 显示说点什么
    func showAddFreinedAlertController(_ groupId : String) {
        
        self.groupId                                = groupId
        let makeCallViewController                  = BKMakeCallViewController()
        makeCallViewController.delegate             = self
        makeCallViewController.leftTitle            = "部落验证"
        if self.groupName != nil {
            makeCallViewController.placeHolderString    = "你好，我是巴爷汇的\(BK_UserInfo.name)，请求加入  \(self.groupName!)！"
        } else {
            makeCallViewController.placeHolderString    = "你好，我是巴爷汇的\(BK_UserInfo.name)，请求加入你的部落！"
        }
        
        let nav                                     = BKNavigaitonController(rootViewController: makeCallViewController)
        self.present(nav, animated: true, completion: nil)
        
        
    }
    
    /// 调用环信申请入群的接口
    
    func addApplyJoinGroupReqeust(_ uid : String,msg : String) {
        
        // 进群需要验证

        EMClient.shared().groupManager.request(toJoinPublicGroup: uid, message: msg) {[weak self] (group, error) in
            
            if group != nil {
                UnitTools.addLabelInWindow("发送加部落申请成功", vc: self)
                let sendListModel   = BKSendList(uid: uid, account: easemob_username, type: .group, isSend: true)
                BKRealmManager.shared().insert(sendListModel)
                self?.tableView.reloadRows(at: [(self?.selectIndexPath)!], with: .automatic)
                
            } else {
                UnitTools.addLabelInWindow("发送加部落申请失败", vc: self)
            }
            
        }
        
    
    }
    
    /// 打个招呼
    func makeCall(with msg: String) {
        self.addApplyJoinGroupReqeust(self.groupId ?? "", msg:msg)
    }
    
}
