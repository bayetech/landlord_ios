//
//  BKOptions.swift
//  BayeStyle
//
//  Created by dzb on 2016/11/24.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

/// 全局设置的模型 包含了用户隐私 通知提醒 等设置
class BKPrivacyOptions: RLMObject {
    
    
    /// 消息提醒类型 Swift 枚举类型 OC 中使用 typeString
    var remindType : RemindMode                 = .voiceAndVibrate {
        didSet {
            typeString = remindType.rawValue
        }
    }

    /// 提醒类型 声音 振动 关闭
    dynamic var typeString : String     = "声音和振动" 
    
    /// 消息免打扰类型
    dynamic var noDisturbStatus : Int   = 2
    
    /// 手机号码隐私设置
    dynamic var mobile_visible_scope : String           = "所有人可见手机号"
    
    /// 名片隐私设置
    dynamic var namecard_visible_scope : String         = "所有人可见我的资料"
    /// 用户名 标记这是哪个用户的设置信息
    dynamic var userAccount : String?
  
    override init() {
        super.init()
        
    }
    
    open override class func primaryKey() -> String? {
        return "userAccount"
    }
    
    /// 数据库忽略字段 不存入数据库中
    open override class func ignoredProperties() -> [String]? {
        return ["needUpdateApp","red_packet_show","wechatStoreIsVisible","groupDisturbings","remindType"]
    }
    
    convenience init(by userAccont : String) {
        self.init()
        self.userAccount = userAccont
    }
   
    
}
