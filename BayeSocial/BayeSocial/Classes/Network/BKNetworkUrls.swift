//
//  BKNetworkUrls.swift
//  Baye
//
//  Created by dzb on 16/7/26.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import Foundation
import SwiftyJSON

struct BKApiConfig {
    
     /// app APIHOST
     static var APIHOST : String {
        get {
            return "https://api.bayekeji.com/v2/"
        }
    }
    
    // 社区的 URL
    static var APIHubsHost : String {
        get {
            return  "https://wechat.bayekeji.com/hub/t"
        }
    }
    
    // 社区个人中心URL
    static var APIHubsProfile : String {
        get {
            return  "https://wechat.bayekeji.com/hubs/p"
        }
    }
    
    // 社区消息URL
    static var APIHubsMessage : String {
        get {
            return "https://wechat.bayekeji.com/hubs/m"
        }
    }
    
    static var APIHubsActivetys : String {
        get {
            return "https://wechat.bayekeji.com/hub/p/"
        }
    }
    
    static var APIStore : String {
        get {
            return "https://wechat.bayekeji.com/"
        }
    }
    
    /// 充值巴金页面
    static var KRechargeCoin : String {
        get {
            return  "https://wechat.bayekeji.com/build_recharge_coin"
        }
    }
    
    /// 是否是 debug 模式
    internal static func isDebugMode() -> Bool {
        var debug            = true
        #if !DEBUG
            debug            = false
        #endif
        return debug
    }
    
}

/// 正式环境
let baseURLPath :  String                       = BKApiConfig.APIHOST

/// 社区 webView url
let KHubsWebViewURL : String                    = BKApiConfig.APIHubsHost

/// 社区个人中心 URL
let KHubsProfileUrl : String                    = BKApiConfig.APIHubsProfile

/// 社区消息 URL
let KHubsNotication : String                    = BKApiConfig.APIHubsMessage

/// 成功的回调
typealias successBlock                          = (_ data  : BKNetworkResult) -> Void

/// 失败的回调
typealias failureBlock                          = (_ error : BKNetworkResult) -> Void

/// 请求超时时间
let RequestTimeoutInterval                      = 10.0

/// 获取阿里云上传头像的 key
let KURL_AliyunToken : String                   = baseURLPath + "hubs/token"

/// 巴一下
let KURL_PostHubs : String                      = baseURLPath + "hubs/topic"

/// 订单支付接口
let KURL_OrderPayment : String                  = baseURLPath + "payments/payment"

/// 创建订单接口
let KURL_CreateOrder : String                   = baseURLPath + "orders/order"

/// 获取巴爷好友列表
let KURL_Customer_friends : String              = baseURLPath + "customer_friends"

/// 群分类
let KURL_Chat_group_categories : String         = baseURLPath + "chat_group_categories/index"

///  创建群
let KURL_Chat_groupsCreate : String             = baseURLPath + "chat_groups/create"

/// 行业职能
let KURL_Industry_functions : String            = baseURLPath + "industry_functions"

/// 好友查询
let KURL_CustomerFriendSearch : String          = baseURLPath + "customer_friends/search"

/// 群聊的基础接口
let KURL_MineJoinChat_groupsApi  : String       = baseURLPath + "chat_groups"

/// 查看支付方式
let KURL_PaymentType : String                   = baseURLPath + "payments/pay_type"

/// 搜索群信息

let KURL_ChatGroupSearch : String               = baseURLPath + "chat_groups/search"

/// 举报选项的功能
let KURL_ReportOptions : String                 = baseURLPath + "reports/options"

/// 举报他人
let KURL_StartReportCustomer : String           = baseURLPath + "reports"

/// 新的更新用户资料接口
let KURL_CustomersProfile   : String            = baseURLPath + "customers/profile"

/// 用户登录的接口
let KURL_UserloginIn        : String            = baseURLPath + "users/sign_in"

/// 群成员列表
let KURL_GroupMembers       : String            = baseURLPath + "chat_group_customers"

/// 发送红包
let KURL_SendRedPacket      : String            = baseURLPath + "send_red_packets"



