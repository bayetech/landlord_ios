//
//  BKPayMethod.swift
//  BayeSocial
//
//  Created by dzb on 2016/12/21.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON


@objc protocol BKPaymentResultProtocol {

    /// 创建支付订单成功
    @objc optional func PaymentSuccess()
    /// 创建支付订单失败
    @objc optional func PaymentFariure(_ error : NSError)
    
}

/// 支付方式
///
/// - ApplePay:    苹果的 applePay 支付
/// - WeChatPay:   微信支付
/// - Alipay:      支付宝支付
/// - BankPayment: 招商银行一网支付
enum BKPayFromType : String {
    /// 苹果的 applePay 支付
    case ApplePay       = "LLPAY"
    /// 微信支付
    case WeChatPay      = "WECHAT"
    /// 支付宝支付
    case Alipay         = "ALIPAY"
    /// 招商银行一网支付
    case BankPayment    = "YWT"
    /// 巴金支付
    case COIN           = "COIN"
}

/// 获取页面信息用来生成订单
class BKPaymentInfo : NSObject {
    
    var coin_quantity : Int         = 0
    var coupon_uid : String?
    var pay_from : String           = "WECHAT"
    var payType : BKPayFromType     = .WeChatPay
    var order_uids : String?
    var free_coin_quantity : Int    = 0
    convenience init(_ json:[String : JSON]?) {
        self.init()
        
        if  let dict = json {
            
            self.coin_quantity          = dict["coin_quantity"]?.intValue ?? 0
            self.coupon_uid             = dict["coupon_uid"]?.stringValue
            self.pay_from               = dict["pay_from"]?.stringValue ?? "WECHAT"
            self.payType                = BKPayFromType(rawValue: self.pay_from)!
            self.order_uids             = dict["order_uids"]?.string
            self.free_coin_quantity     = dict["BKPaymentInfo"]?.intValue ?? 0
        }
        
    }
}

/// 生成订单的一些信息用来支付
class BKPayOrder : NSObject  {
  
    var amount : Double = 0.0
    var uid : String?
    var created_at : Double = 0
    var memo : String?
    var no : String?
    var updated_at : Int = 0
    var state : String?
    var order_items : [Any]?
    
   
}


/// 微信支付需要的一些参数
class WXOrderParameterModel: HandyJSON {
    var appid: String?
    var partnerid: String?
    var prepayid: String?
    var noncestr: String!
    var stamp: UInt32? {
        get {
            return UInt32(timestamp)
        }
    }
    var package: String?
    var sign: String?
    var timestamp : String = "0"
    required init() {
        
    }
}


/// 封装了 apple pay 签名 加密 等信息的模型 用来给连连支付支付传参数
class BKApplepayConfig: HandyJSON {
    
    var oid_partner :String?
    var user_id :  String?
    var no_order : String?
    var dt_order : String?
    var busi_partner : String?
    var money_order : String?
    var user_info_mercht_userno : String?
    var user_info_dt_register : String?
    var notify_url : String?
    var sign_type : String?
    var sign : String?
    var name_goods : NSNumber?
    var info_order : NSNumber?
    var valid_order : NSNumber?
    var risk_item : String?
    var ap_merchant_id : String?
    var params : [String : AnyObject]?
    
    
    required init() {
        
    }
    
}

