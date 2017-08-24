//
//  BKSearchGroupViewController.swift
//  BayeStyle
//
//  Created by dzb on 2016/11/28.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD

/// 搜索部落 分本地和网络搜索两种

class BKSearchGroupViewController : BKBaseSearchViewController {

    var isVerifyGroup : Bool = false
    var localGroups : [BKChatGroupModel] = [BKChatGroupModel]()
    var recommendGroups : [BKChatGroupModel] = [BKChatGroupModel]()
    var selectIndexPath : IndexPath?
    var groupId : String?
    fileprivate var groupName : String?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate         = self
        self.tableView.dataSource       = self
        if self.searchType == .searchRemoteGroup {
            self.reqeustRecommendChatGroups()
        }
        
    }
    
    
    /// 获取推荐的群组
    func reqeustRecommendChatGroups() {
        
        self.showHUD()
        BKNetworkManager.getOperationReqeust(baseURLPath + "recommendation/groups", params: nil, success: {[weak self] (success) in
            self?.hiddenHUD()
            let json                        = success.value
            let chat_groups                 = json["chat_groups"]?.arrayValue
            guard chat_groups != nil else {
                return
            }
            self?.recommendGroups   = BKChatGroupModel.chatGroupsWithJSONArray(chat_groups!)
            self?.tableView.reloadData()
            
            }) { (failure) in
                
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        self.tableView.reloadData()
    }
  
    
   
}

// MARK: - 搜索群组相关
extension BKSearchGroupViewController {
    
    /// 开始搜索的页面
    override func startSeachText(_ text: String) {
        super.startSeachText(text)
        
    }
    
    /// 搜索内容发生了改变
    override func setupTextfieldInputText(_ string: String) {
        super.setupTextfieldInputText(string)
        
        guard string.length != 0 else {
            self.localGroups.removeAll()
            self.tableView.reloadData()
            return
        }
        
        // 本地搜索模糊查询
        if self.searchType == .searchLocalGroup {
            self.searchLocalChatGroups(string)
        } else {
            self.searchRemoteChatGroups(string)
        }
        
    }
    
    /// 搜索远程服务器上的群组信息
    func searchRemoteChatGroups(_ keywords : String) {
        
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        BKNetworkManager.postReqeust( KURL_ChatGroupSearch, params: ["groupname":keywords], success: {[unowned self] (success) in
            HUD.hide(animated: true)
            let json                        = success.value
            let chat_groups                 = json["chat_groups"]?.arrayValue
            guard chat_groups != nil else {
                return
            }
            
            let groups               = BKChatGroupModel.chatGroupsWithJSONArray(chat_groups!)
            self.localGroups         = groups
            self.tableView.reloadData()
            
        }) { (failure) in
            HUD.hide(animated: true)
        }
        
    }
    
    /// 搜索本地群组
    func searchLocalChatGroups(_ keywords : String) {
        
       self.localGroups = BKRealmManager.shared().queryChatgroupsOrder(byKeywords: keywords)
        self.tableView.reloadData()

    }
    
}

//MARK : 加群的一些操作
extension BKSearchGroupViewController {
    
    /// 加入群组的按钮点击事件
    @objc func joinGroupClick(_ btn:UIButton,event : Any) {
        
        self.textField.resignFirstResponder()
        let indexPath = btn.indexPath(at: self.tableView, forEvent: event)
        guard indexPath != nil else {
            return
        }
        self.selectIndexPath    = indexPath
        let array               = indexPath?.section == 0 ? self.localGroups : self.recommendGroups
        let groupModel          = array[(indexPath?.row)!]
        
        self.isVerifyGroup      = (groupModel.is_approval)
        let groupid             = groupModel.groupid ?? ""
    
        guard btn.currentTitle != "发消息" else {
            EMIMHelper.shared().hy_chatRoom(withConversationChatter: groupid,soureViewController: self)
            return
        }
        
        if self.isVerifyGroup {
            
            self.groupName      = groupModel.groupname
            self.showAddFreinedAlertController(groupid)
            
        } else {
            
            EMClient.shared().groupManager.joinPublicGroup(groupid, completion: {[weak self] (group, error) in
                if error != nil {
                    UnitTools.addLabelInWindow("发送申请失败", vc: self)
                    NJLog(error?.errorDescription)
                    return
                }

                let sendRequestModel = BKSendList(uid: groupid, account: easemob_username, type: .group, isSend: true)
                BKRealmManager.shared().insert(sendRequestModel)
                self?.tableView.reloadRows(at: [(self?.selectIndexPath!)!], with: .automatic)
                UnitTools.addLabelInWindow("发送加部落申请成功", vc: self)
                
            })
        }
        
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
                
                let sendListModel       = BKSendList(uid: uid, account: easemob_username, type: .group, isSend: true)
                
                BKRealmManager.shared().insert(sendListModel)
                
                self?.tableView.reloadRows(at: [(self?.selectIndexPath)!], with: .automatic)
                
                UnitTools.delay(0.3, closure: { () in
                    UnitTools.addLabelInWindow("发送加部落申请成功", vc: self)
                })
                
            } else {
                
                UnitTools.addLabelInWindow("发送加部落申请失败", vc: self)
                
            }

            
        }
        
        
    }

    
}
// MARK: - UITableViewDataSource , UITableViewDelegate
extension BKSearchGroupViewController : UITableViewDelegate, UITableViewDataSource  {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return self.localGroups.count
        } else {
            return self.recommendGroups.count
        }
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
//            addGroupButton.setTitle("加入", for: .normal)
//            addGroupButton.setTitle("已发送", for: .selected)
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
//            groupMembersLabel.text          = "300人"
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
        
        let chatGroupModel                      = indexPath.section == 0 ? self.localGroups[indexPath.row] : self.recommendGroups[indexPath.row]
        
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
        
        BKRealmManager.beginWriteTransaction()
        chatGroupModel.isInGroup                = isJoinGroup
        BKRealmManager.commitWriteTransaction()
      
        if isJoinGroup {
            addGroupButton.isSelected               = false
            addGroupButton.setTitle("发消息", for: .normal)
            addGroupButton.isUserInteractionEnabled = true
        } else  {
            // 是否已经发送了请求
            var isSendReqeust           = false
            
            if let sendListModel        = BKRealmManager.shared().querySendListModel(chatGroupModel.groupid!) {
                isSendReqeust           = sendListModel.isSend
            }
            
            if isSendReqeust {
                addGroupButton.setTitle("已发送", for: .selected)
            } else {
                addGroupButton.setTitle("加入", for: .normal)
            }
            
            addGroupButton.isSelected   = isSendReqeust

            
        }
       
        return cell!

    }
    
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CYLayoutConstraintValue(67.5)
    }
    
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        
        return 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        if section == 0 && self.localGroups.count == 0 {
            return 0.0
        } else if (section == 1 && self.recommendGroups.count == 0) {
            return 0.0
        }
        return CYLayoutConstraintValue(40.0)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 0 && self.localGroups.count == 0 {
            return nil
        } else if (section == 1 && self.recommendGroups.count == 0) {
            return nil
        }
        
        var headView            = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headView")
        if (nil == headView) {
            
            headView            = UITableViewHeaderFooterView(reuseIdentifier: "headView")
            let label           = UILabel()
            label.textColor     = UIColor.colorWithHexString("#8E8E93")
            label.font          = CYLayoutConstraintFont(14.0)
            label.tag           = 100
            headView?.contentView.addSubview(label)
            label.snp.makeConstraints({ (make) in
                make.left.equalTo((headView?.contentView.snp.left)!).offset(CYLayoutConstraintValue(15.0))
                make.top.bottom.right.equalTo((headView?.contentView)!)
            })
            
        }
        
        let label               = headView?.contentView.viewWithTag(100) as! UILabel
        label.text              = section == 0 ? (self.searchType == .searchLocalContact ? "我的部落" : "搜索部落结果") : "可能感兴趣的群"
        label.textColor         = UIColor.gray
        
        return headView
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.tableView.separatorInset = UIEdgeInsets.zero
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.separatorInset = UIEdgeInsets.zero
        
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.textField.resignFirstResponder()
        var chatGroupModel : BKChatGroupModel?
        if self.searchType == .searchLocalContact {
            chatGroupModel = self.localGroups[indexPath.row]
        } else {
            chatGroupModel = indexPath.section == 0 ? self.localGroups[indexPath.row] : self.recommendGroups[indexPath.row]
        }
        
        if !(chatGroupModel?.isInGroup)! {
            let groupDetailViewController           = BKGroupDetailsViewController()
            groupDetailViewController.groupModel    = chatGroupModel
            self.navigationController?.pushViewController(groupDetailViewController, animated: true)
        }
        
        
    }


    
}

// MARK: - BKMakeCallViewControllerDelegate

extension BKSearchGroupViewController : BKMakeCallViewControllerDelegate {
    
    func makeCall(with msg: String) {
        self.addApplyJoinGroupReqeust(self.groupId ?? "", msg:msg)
    }
}
