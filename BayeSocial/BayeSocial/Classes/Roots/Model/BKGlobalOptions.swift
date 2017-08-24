//
//  BKGlobalOptions.swift
//  BayeSocial
//
//  Created by 董招兵 on 2017/2/17.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit

/// Application全局设置信息

class BKGlobalOptions: NSObject {
    
    static var curret : BKGlobalOptions = {
        let options = BKGlobalOptions()
        return options
    }()
    
    // 是否支持新消息提醒 开启了系统通知功能
    var supportUserNotifications : Bool         = false
    
    // 群组是否免打扰是否开启
    var groupDisturbings : [String : Bool] = [String : Bool]()
    
    /// 是否显示微信商城
    var wechatStoreIsVisible : Bool             = false
    var red_packet_show : Bool                  = false
    var needUpdateApp : Bool                    = false
    
    /// 用户隐私设置
    var privacyOptions : BKPrivacyOptions {
        get {
            return BKRealmManager.shared().readApplicationOptions()
        }
    }
    
}
