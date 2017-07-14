//
//  BKMessageViewController.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/20.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON

class BKMessageNotice : NSObject {
    
    var icon : String           = ""
    var title : String          = ""
    var msg : String            = ""
    var badgeValue  : Int       = 0
    var timeInterval : Int      = 0
    convenience init(_ title : String,icon : String,msg :String) {
        self.init()
        self.icon               = icon
        self.title              = title
        self.msg                = msg
    }

}

/// 巴爷汇消息
class BKMessageViewController: BKBaseViewController {
    
    var messageHeadView : BYMessageHeadView? {
        didSet {
            tableView.backgroundColor = UIColor.RGBColor(243.0, green: 243.0, blue: 243.0)
            tableView.register(UINib(nibName: "BYMessageConversationViewCell", bundle: nil), forCellReuseIdentifier: "BYMessageConversationViewCell")
            tableView.register(UINib(nibName: "BYMessageNotificationCell", bundle: nil), forCellReuseIdentifier: "BYMessageNotificationCell")
            tableView.tableFooterView = UIView()
        }
    }
    var needRemoveLastAtMeMsg : Bool                    = false
    var lastAtMeMsgList : [String : NSAttributedString] = [String : NSAttributedString]()
    var notieceArray : [BKMessageNotice]    = [BKMessageNotice]()
    var unreadMsgCount : Int                = 0
    var dataArray : [BKConversationModel]   =  [BKConversationModel]()
    var popoverView : BYContactPopoverView?
    var tableView: UITableView              = UITableView(frame: CGRect.zero, style: .plain)
    var conversatonList : [String :BKConversationModel] = [String :BKConversationModel]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setup()
        
       
        
    }

    /// 刷新会话数据
    public func refeshConversationsData() {
        
        weak var weakSelf = self
        EMIMHelper.shared().loadConversationsCompletion { (array) in
            weakSelf?.dataArray  = array
            weakSelf?.reloadTableView()
        }

    }
    
    public func reloadTableView() {
        
        self.tableView.reloadData()
        self.setupUnreadMessageCount()
        
    }
    
    /// 未读消息提醒
    public func setupUnreadMessageCount() {
        
        let unreadGroupMsgCount = BKRealmManager.shared().queryUnreadGroupApplys().count
        let totalCount          = self.unreadMsgCount + unreadGroupMsgCount
        
        var badgeValue : String?
        if totalCount > 99 {
            badgeValue          = "99+"
        } else if totalCount == 0 {
            badgeValue          = nil
        } else {
            badgeValue          = String(format: "%d", totalCount)
        }
        
        self.tabBarItem.badgeValue = badgeValue
        if unreadGroupMsgCount != 0 {
            self.setupNoticeSection()
        }
        
    }
 
    
    /// 更新最后一条消息内容
    public func updataLastMessageStatus(_ conversation : EMConversation) -> BKConversationModel {
      
        let bk_ConversationModel                                = BKConversationModel(conversation: conversation)
        if self.needRemoveLastAtMeMsg {
            /// 查看完未读消息后移除掉@我的提醒消息
            self.lastAtMeMsgList.removeValue(forKey: conversation.conversationId)
            //  更新最新一条数据拓展内容为空 因为该`@消息已经被查看
            let lastEmmessage            = bk_ConversationModel.conversation?.latestMessage
            let ext                      = lastEmmessage?.ext
            if ext != nil {
                let json                = JSON(ext!).dictionary
                let em_at_list          = json?["em_at_list"]?.dictionary // 只删除群@消息的拓展
                if em_at_list != nil {
                    lastEmmessage?.ext.removeAll()
                    bk_ConversationModel.conversation?.updateMessageChange(lastEmmessage!, error: nil)
                }
            }
        }
        /// 如果最后一条消息是 @ me 消息那么就 给 bk_ConversationModel.message 赋值为 @xxx 改消息未读时 显示 [有人@我] xxx : @我 该消息已读时 改为 @我
        if bk_ConversationModel.lastMessageAtMe {
            bk_ConversationModel.message = bk_ConversationModel.nomalAttributedString
        }
        var count : Int = 0
        for i in 0..<self.dataArray.count {
            let model   = self.dataArray[i]
            if model.conversationId == bk_ConversationModel.conversationId {
                self.dataArray[i]   = bk_ConversationModel
                count+=Int((bk_ConversationModel.conversation?.unreadMessagesCount)!)
            } else {
                count+=Int((model.conversation?.unreadMessagesCount)!)
            }
        }
        
        self.unreadMsgCount     = count
        self.dataArray          = sortDataArray()
        self.reloadTableView()
        
        return bk_ConversationModel
    }
    
    func sortDataArray() -> [BKConversationModel] {
        
        let array   = (self.dataArray.sorted(by: { (conversation1, conversation2) -> Bool in
            
            let latestMessage1      = (conversation1.conversation?.latestMessage)
            let latestMessage2      = (conversation2.conversation?.latestMessage)
            if latestMessage1 == nil || latestMessage2 == nil {
                return false
            }
            if (latestMessage1?.timestamp)! > (latestMessage2?.timestamp)! {
                return true
            }
            return false
        }))
        
        return array
    }
 
    /// 初始化
    private func setup() {
        
        self.view.addSubview(self.tableView)
        self.tableView.delegate                     = self
        self.tableView.dataSource                   = self
        self.tableView.snp.makeConstraints {[weak self] (make) in
            make.edges.equalTo((self?.view)!).inset(UIEdgeInsetsMake(0.0, 0.0, 49.0, 0.0))
        }
        
        let headView                                = BYMessageHeadView.viewFromNib() as! BYMessageHeadView
        headView.delegate                           = self
        self.tableView.tableHeaderView              = headView
        headView.snp.makeConstraints {[unowned self] (make) in
            make.top.equalTo(self.tableView.snp.top)
            make.left.equalTo(self.tableView.snp.left)
            make.size.equalTo(CGSize(width: KScreenWidth, height: CYLayoutConstraintValue(166.0)))
        }
        self.messageHeadView                        = headView
        self.tableView.perform(#selector(UITableView.reloadData), with: nil, afterDelay: 0.01)
        
        // 请求自动登录接口
        if (userDidLogin) {
            NotificationCenter.bk_postNotication("UserDidLogin", object: KCustomAuthorizationToken)
        }
        
        NotificationCenter.bk_addObserver(self, selector: #selector(lastMessageDidChange(_:)), name: "UpdateConversationLastMessage", object: nil)
      
    }
    
    @objc func lastMessageDidChange(_ notifation : Notification) {
        guard notifation.object != nil else {
            return
        }
        let conversation : EMConversation = notifation.object as! EMConversation
        self.needRemoveLastAtMeMsg        = true
        let _ = self.updataLastMessageStatus(conversation)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    /// 设置消息提醒的内容
    public func setupNoticeSection() {
        
        self.notieceArray.removeAll()
        weak var weakSelf                = self
        
        let unreadGroupApplys = BKRealmManager.shared().queryUnreadGroupApplys()
        var groupNotice : BKMessageNotice?
        if unreadGroupApplys.count != 0  {
            
            let appForModel              = (unreadGroupApplys.last)!
            groupNotice                  = BKMessageNotice("部落通知", icon: "message_groupnotice", msg: appForModel.reason)
            groupNotice?.badgeValue      = unreadGroupApplys.count
            groupNotice?.timeInterval    = appForModel.time.intValue
            
        } else {

            groupNotice                  = BKMessageNotice("部落通知", icon: "message_groupnotice", msg:"")
            groupNotice?.badgeValue      = 0

        }
        
        weakSelf?.notieceArray.insert(groupNotice!, at: 0)
        weakSelf?.tableView.reloadData()
        
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
        self.setupNoticeSection()
        self.setupUnreadMessageCount()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.popoverView?.removeFromSuperview()
        self.popoverView        = nil
        
    }

}

// MARK: - UITableViewDataSource && UITableViewDelegate
extension BKMessageViewController : UITableViewDataSource , UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        guard self.dataArray.count != 0 else {
            return 1
        }
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
       return section == 0 ? self.notieceArray.count: self.dataArray.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            
            let cell                    = tableView.dequeueReusableCell(withIdentifier: "BYMessageNotificationCell") as! BYMessageNotificationCell
            
            let noticeModel             = self.notieceArray[indexPath.row]
           
            cell.iconView.image         = UIImage(named: noticeModel.icon)
            cell.titleLabel.text        = noticeModel.title
            cell.detailLabel.text       = noticeModel.msg

            if noticeModel.timeInterval != 0 {
                cell.timeLabel.text     = NSDate.formattedTime(fromTimeInterval: Int64(noticeModel.timeInterval))
            } else {
                cell.timeLabel.text     = ""
            }
            
            let msgCount = noticeModel.badgeValue
            if msgCount != 0 {
                cell.badgeView.isHidden = false
                cell.badgeLabel.text    = msgCount>100 ? "99+" : String(format: "%d", msgCount)
            } else {
                cell.badgeView.isHidden = true
            }
            
            cell.badgeLabel.isHidden    = cell.badgeView.isHidden

            return cell
            
        } else {
            
            let cell                             = tableView.dequeueReusableCell(withIdentifier: "BYMessageConversationViewCell") as! BYMessageConversationViewCell
            let conversationM                    = self.dataArray[indexPath.row]
            cell.conversationModel               = conversationM
            cell.avatarImageView.tag             = indexPath.row
            cell.avatarImageView.addTarget(self, action: #selector(headImageViewAction(_:)))
            // 如果有@消息存在时 显示 [有人@我] xxx : @我
            if conversationM.isChatGroupType {
                let atMeString                   = self.lastAtMeMsgList[conversationM.conversationId!]
                if atMeString != nil {
                    cell.detalLabel.attributedText = atMeString
                }
            }
            return cell
            
        }
  
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return CYLayoutConstraintValue(70.0)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
     
        if indexPath.section == 1 {
            
            let conversation        = self.dataArray[indexPath.row]
            EMIMHelper.shared().hy_chatRoom(withConversationChatter: conversation.conversationId!, soureViewController: self)

        } else if (indexPath.section == 0 && indexPath.row == 0 ){
            
            let groupApplyController                                = BKGroupApplyViewController()
            groupApplyController.hidesBottomBarWhenPushed           = true
            self.navigationController?.pushViewController(groupApplyController, animated: true)
            
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return indexPath.section == 0 ? false : true
        
    }

    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let rowAction = UITableViewRowAction(style: UITableViewRowActionStyle.destructive, title: "删除") {[unowned self] (action, indexPath) in
            
            guard indexPath.section != 0 else {
                return
            }
            guard self.dataArray.count != 0 else {
                return
            }
            
            let conversation = self.dataArray[indexPath.row]
            EMClient.shared().chatManager.deleteConversation(conversation.conversationId, isDeleteMessages: true, completion: { (string, error) in
                guard error == nil else {
                    UnitTools.addLabelInWindow((error?.errorDescription)!, vc: self)
                    return
                }
                self.dataArray.remove(at: indexPath.row)
                self.tableView.reloadData()
            })
      
        }
        
        return [rowAction]
    }
}


// MARK: - BYMessageHeadViewDelegate
extension BKMessageViewController : BYMessageHeadViewDelegate {
    
    func by_MessageHeadHeadView(_ didSelectAddBtn: BYMessageHeadView) {
        
        guard self.popoverView == nil else {
            return
        }
        
        let popoverView         = BYContactPopoverView.viewFromNib() as! BYContactPopoverView
        self.view.addSubview(popoverView)
        popoverView.delegate    = self
        popoverView.snp.makeConstraints {[unowned self] (make) in
            make.edges.equalTo(self.view)
        }
        self.popoverView        = popoverView
        
    }
    
    /// 点击搜索的时候
    func by_MessageHeadHeadViewDidSelectSearchTextField(_ headView: BYMessageHeadView) {
        
        let searchViewController                        = BKSearchResultViewController()
        searchViewController.hidesBottomBarWhenPushed   = true
        self.navigationController?.pushViewController(searchViewController, animated: false)
        
    }
    
}

// MARK: - BYContactPopoverViewDelegate
extension BKMessageViewController : BYContactPopoverViewDelegate {
    
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
        default:
            
            break
        }
        
    }
    
    func didDismissPopoverView(_ popoverView: BYContactPopoverView) {
        self.popoverView = nil
        
    }
    
    /// 点击头像查看个人资料
    @objc func headImageViewAction(_ tap:UITapGestureRecognizer) {
        
        let tapView             = tap.view
        guard tapView != nil else {
            return
        }
        let conversation        = self.dataArray[(tapView!.tag)]
        if !conversation.isChatGroupType {
            
            let userDetailViewController    = BKUserDetailViewController()
            userDetailViewController.userId = conversation.conversationId!
            userDetailViewController.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(userDetailViewController, animated: true)
        }
        
        
    }
}

