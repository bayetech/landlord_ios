//
//  BKApplyGroupModel.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/11/11.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

/// 群组通知的类型  包括了 群主收到加群申请    群组同意你加群申请 群组拒绝你加群申请 收到群成员退群的申请

@objc enum GroupApplyType : Int {
    case joinGroup      = 0 // 加群申请
    case acceptGroup        // 同意用户加群
    case declineGroup       // 拒绝用户加入群组
    case exitGroup          // 退出群聊 分主动 被动 群聊解散 退群
    case InviteGroup        // 邀请入群
}

/// 申请加好友 建群的模型
class BKApplyGroupModel: RLMObject {
    
    @objc dynamic var userAccount : String?
    @objc dynamic var customer_uid : String           = ""
    @objc dynamic var reason : String                 = ""
    @objc dynamic var isRead : Bool                   = false
    @objc dynamic var groupId : String                = ""
    @objc dynamic var groupAvatar :String             = ""
    @objc dynamic var title : String?
    @objc dynamic var groupName : String?
    @objc dynamic var userName : String               = ""
    @objc dynamic var userAvatar : String             = ""
    @objc dynamic var applyType : GroupApplyType      = .joinGroup
    @objc dynamic var time : String                   = ""

    open override class func primaryKey() -> String? {
        return "customer_uid"
    }
    
    convenience init(customer : BKCustomersContact?,groupInfo : BKChatGroupModel?,aplayType : GroupApplyType,reason : String,time : String,title : String) {
        self.init()
        
        self.userAccount        = easemob_username
        self.customer_uid       = customer?.uid ?? ""
        self.userName           = customer?.name ?? ""
        self.userAvatar         = customer?.avatar ?? ""
        self.applyType          = aplayType
        self.groupId            = groupInfo?.groupid ?? ""
        self.groupName          = groupInfo?.groupname
        self.groupAvatar        = groupInfo?.avatar ?? ""
        self.time               = time
        self.reason             = reason
        self.title              = title
        
    }
    
    
    
}
