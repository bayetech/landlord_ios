//
//  BKAddFriendReqeust.swift
//  BayeSocial
//
//  Created by 董招兵 on 2017/7/10.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit

/// 加好友请求的类型
@objc enum BKAddFriendActionType : Int {
    case add                = 0 // 加好友
    case accept             = 1 //同意添加好友
    case decline            = 2 // 拒绝添加好友
}


/// 加好友人脉的请求消息模型
class BKAddFriendReqeust : RLMObject {

    dynamic  var customer_uid : String?
    dynamic  var userAccount : String?
    dynamic  var resion : String?
    dynamic  var customer_avatar : String?
    dynamic  var customer_name : String?
    dynamic  var actionType : BKAddFriendActionType = .add
    dynamic  var customer_company :String?
    dynamic  var customer_company_position : String?
    dynamic  var isRead : Bool = false
    convenience init(dictionary :[AnyHashable :Any],action : String) {
        self.init()

        self.customer_uid               = dictionary["customer_uid"] as? String
        self.userAccount                = easemob_username
        self.actionType                 = action == "add_customer_friend" ? .add : (action == "decline_friend" ? .decline : .accept)
        self.customer_name              = dictionary["customer_name"] as? String
        self.customer_avatar            = dictionary["customer_avatar"] as? String
        self.customer_company           = dictionary["customer_company"] as? String
        self.customer_company_position  = dictionary["customer_company_position"] as? String

        self.resion                 = dictionary["message"] as? String

    }

    open override class func primaryKey() -> String? {
        return "customer_uid"
    }


}

