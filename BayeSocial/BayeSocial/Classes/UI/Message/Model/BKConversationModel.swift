//
//  BKConversationModel.swift
//  BayeStyle
//
//  Created by dzb on 16/11/17.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON

/// 聊天会话的模型
class BKConversationModel : NSObject {
    
    var conversation : EMConversation?
    var title  : String?
    var avaratURLPath : String      = ""
    var message : NSAttributedString? // 群聊或者单聊会话内容
    var normalMessage : String      = ""
    var name : NSAttributedString? //会话 title 群聊显示群名称,单聊显示好友名称
    var messageCount : Int = 0     // 未读消息数量
    var date : String               = ""
    var conversationId : String?
    var isChatGroupType : Bool      = false // 是否是群聊
    var isNotDisturb    : Bool      = false // 是否免打扰
    var nameString  : String        = ""
    var em_atList : [JSON]? // @消息列表
    var isEmAtMe : Bool             = false
    var atMeUsername : String       = "未知用户" // @我的人昵称
    var nomalAttributedString : NSAttributedString? // 普通@消息 如果读取了@我的消息 就用 nomalAttributedString 显示 未读的用[有人@我] xxx: @我
    var lastMessageAtMe : Bool      = false // 判断当前会话最后一条消息是否是 @我的消息 默认是 false
    var messageFromUserInfo : [String : JSON]? // 消息发送者的一些资料
    convenience init(conversation : EMConversation) {
        self.init()
        
        self.conversation                   = conversation
        self.conversationId                 = self.conversation?.conversationId
        self.messageCount                   = self.getUnreadMessageCount(by: self.conversation!)
              
        self.date                           = NSDate.formattedTime(fromTimeInterval: self.conversation!.latestMessage.timestamp)
        var chatType : Int                  = 0
        if let isGroup = self.conversationId?.isNumberValue() {
            chatType    = isGroup ? 1 : 0
            self.isChatGroupType = isGroup
        }
        var fromName : String               = ""
        var textColor : UIColor?
        switch chatType {
        case 0:
            
            let contactUser                 = BKRealmManager.shared().queryCustomuserUsersIntable(conversation.conversationId)
            
            self.avaratURLPath              = contactUser?.avatar ?? ""
            
            fromName                        = contactUser?.name ?? "未知用户"
            
            textColor                       = UIColor.colorWithHexString("#333333")

        case 1 :
            
            let groupModel                  = BKRealmManager.shared().queryChatgroupInfo(conversation.conversationId)
            
            textColor                       = UIColor.colorWithHexString("#CF5555")
            
            fromName                        = groupModel?.groupname ?? "未知部落"
            
            self.avaratURLPath              = groupModel?.avatar ?? ""
            
            self.isNotDisturb               = BKGlobalOptions.curret.groupDisturbings[conversation.conversationId] ?? false
            
            break
            
        default:
            break
        }
        
        // 查看拓展消息中是否有@我的内容
        let ext                             = self.conversation?.latestMessage.ext
        guard ext != nil else {
            setupLastMessageContent(fromName,color:textColor!)
            return
        }
        let extDict                         = JSON(ext!).dictionary
        guard extDict != nil else {
            setupLastMessageContent(fromName,color:textColor!)
            return
        }
        self.em_atList                      = extDict?["em_at_list"]?.arrayValue
        guard self.em_atList != nil else {
            setupLastMessageContent(fromName,color:textColor!)
            return
        }
        
        for item in self.em_atList! {
            if (item.stringValue == easemob_username) {
                self.isEmAtMe    = true
                break
            }
        }
        
        if self.conversation?.latestMessage.from == easemob_username {
            self.isEmAtMe                   = false
        }
        
        if let profile = extDict?["customer"]?.dictionary {
            self.messageFromUserInfo = profile
        }
        
        setupLastMessageContent(fromName,color:textColor!)

    }
    
    func setupLastMessageContent(_ fromName :String,color : UIColor) {
        
        self.nameString                     = fromName
        self.message                        = self.lastMessageTitle(by: self.conversation!)
        self.name                           = NSAttributedString(string: fromName, attributes: [NSAttributedStringKey.font : CYLayoutConstraintFont(16.0),NSAttributedStringKey.foregroundColor : color])
        
    }
    
    /// 最后一条消息的title
    private func lastMessageTitle(by converationModel : EMConversation) -> NSAttributedString {
        var lastMessageTitle            = ""
        if let lsatMesageModel          = converationModel.latestMessage {
            let messageobody            = lsatMesageModel.body
            let bodyType                = Int((messageobody?.type.rawValue)!)
            switch bodyType {
            case 1 : //文字
                
                var msg            = (messageobody as! EMTextMessageBody).text
                let ext            = lsatMesageModel.ext
                // 拆取红包的消息
                if (ext != nil && ext?["open_red_packets"]  != nil) {
                    
                    let open_red_packets    = ext?["open_red_packets"]
                    let result              = EMIMHelper.shared().showRedPacketMessage(open_red_packets as! [AnyHashable : Any])
                    msg                     = result["message"] as! String?
                }
                
                let didReceiveText = EaseConvertToCommonEmoticonsHelper.convert(toSystemEmoticons:msg)
                lastMessageTitle   = didReceiveText!
                break
            case 2 : // 图片
                lastMessageTitle = "[图片]"
                break
            case 5 : // 语音
                lastMessageTitle = "[语音]"
                break
            case 4 :
                lastMessageTitle = "[位置信息]"
                break
            case 3:
                lastMessageTitle = "[视频]"
                break
            default:
                lastMessageTitle = ""
                break
            }
            
        }
        
        
        var attributedString : NSAttributedString?
        let font : UIFont = CYLayoutConstraintFont(14.5)
        let defaultAttributeds : [NSAttributedStringKey : Any] = [ NSAttributedStringKey.font : font, NSAttributedStringKey.foregroundColor : UIColor.colorWithHexString("#777777")]
        
        if self.isChatGroupType {
            
            if self.isEmAtMe {
                
                let mutableString       = NSMutableAttributedString(string: "")
                let atString            = NSAttributedString(string: "[有人@我] ", attributes: [NSAttributedStringKey.foregroundColor : UIColor.colorWithHexString("#CF5555"),NSAttributedStringKey.font : font])
                mutableString.append(atString)
                
                if self.messageFromUserInfo != nil {
                    let username        = self.messageFromUserInfo?["name"]?.string
                    self.atMeUsername   = username ?? "未知用户"
                } else {
                    
                    // 获取@我的人的资料
                    let atMeCustomer    = BKRealmManager.shared().queryCustomuserUsersIntable(converationModel.latestMessage.from)
                    self.atMeUsername   = atMeCustomer?.name ?? "未知用户"
                }
               
                // 拼接 xxx: @我 内容
                let textString                              = NSAttributedString(string: self.atMeUsername + ": \(lastMessageTitle)", attributes: defaultAttributeds)
                mutableString.append(textString)
                
                attributedString                            = mutableString
                // 拼接一个普通的@我的消息 用来显示读取后@我的消息后的显示
                self.nomalAttributedString                  = NSAttributedString(string: lastMessageTitle, attributes: defaultAttributeds)
                
                // 记录最后一条@我的消息
                EMIMHelper.shared().messageViewController?.lastAtMeMsgList[converationModel.conversationId]                         = attributedString
                self.lastMessageAtMe                        = true
                
            } else {
                
                // 群消息有未读消息时
                if self.messageCount != 0 {
                    attributedString = NSAttributedString(string: "[\(self.messageCount)条] " + lastMessageTitle, attributes: defaultAttributeds)
                } else {
                    attributedString = NSAttributedString(string: lastMessageTitle, attributes: defaultAttributeds)
                }
                
                self.lastMessageAtMe                      = false

            }

        } else {
            
            attributedString    = NSAttributedString(string: lastMessageTitle, attributes: defaultAttributeds)
        }
        
        normalMessage           = lastMessageTitle

        return attributedString!
    }
    
    /// 最后一条消息的时间
    private func lastMessageTime(by converationModel : EMConversation) -> String {
        var latestMessageTime  = ""
        let lastMessage        = converationModel.latestMessage
        if lastMessage != nil {
            var timeInterval = lastMessage!.timestamp
            if timeInterval > 140000000000 {
                timeInterval = timeInterval / 1000;
            }

            let time            = Date.dateFormatterTimeInterval(TimeInterval(timeInterval), tiemFormatter: "YYYY-MM-dd")
            latestMessageTime   = time
            
        }
        return latestMessageTime
    }
    
    /// 返回未读消息的数量
    private func getUnreadMessageCount(by converationModel : EMConversation) -> Int {
        return Int(converationModel.unreadMessagesCount)
    }
}

/// 透传消息内容的类型 
@objc enum BKCMDActionType : Int {
    
    /* 未知状态 */
    case unknown                    = 0
    /* 创建群组成功后透传消息 */
    case newChatGroup
    /* 区消息透传内容 */
    case hubsNotification
    /*添加好友的请求*/
    case addFriend
    /*移除好友的请求*/
    case removeFriend
    /* 同意添加好友 */
    case acceptedFriend
    
}

/// 环信透传消息
class BKCMDMessage: NSObject {
    
    private var message : EMMessage = EMMessage()
    var actionType : BKCMDActionType = .unknown
    var action : String = "unknown"
    var ext : [String : JSON]?
    var extDictionary : [AnyHashable : Any]? // 拓展消息内容  OC 专用
    var title : String  = ""
    var reason : String = ""
    convenience  init(msg : EMMessage) {
        self.init()
        
        self.message                        = msg
        let body                            = message.body as! EMCmdMessageBody
        self.action                         = body.action
        self.actionType = actionType(with:self.action)

        if let dict = message.ext {
            self.extDictionary           = dict
            self.ext                     = JSON(dict).dictionary
        }
        
    }
    
    /// 获取透传消息的 action 类型
    private func actionType(with action : String) -> BKCMDActionType {
        
        switch action {
        case "new_chat_group" :
            return .newChatGroup
        case "hubs_notification" :
            return .hubsNotification
        case "add_customer_friend":
            return .addFriend
        case "removed_customer_friend" :
            return .removeFriend
        case "accepted_customer_friend" :
            return .acceptedFriend
        default:
            
            return .unknown
        }
        

    }
    
}

