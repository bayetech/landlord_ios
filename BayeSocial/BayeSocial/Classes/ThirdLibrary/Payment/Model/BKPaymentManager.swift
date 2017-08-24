//
//  BKPaymentManager.swift
//  BayeSocial
//
//  Created by dzb on 2016/12/21.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import HandyJSON
import PKHUD

class BKPaymentManager: NSObject {
    
    static var shared : BKPaymentManager = {
        let manager = BKPaymentManager()
        return manager
    }()
    weak var topViewController : UIViewController?
    fileprivate var delegate : BKPaymentResultProtocol?
    func addDelegate(_ delegate : BKPaymentResultProtocol?) {
        self.delegate           = delegate
        self.topViewController  = delegate as! UIViewController?
    }
    /// 处理支付结果后的回调
    func handelOpenURL(_ url : URL) -> Bool {
        
        if (url.description.contains("wxc9587e307525b637://pay")) {
            
            return WXApi.handleOpen(url, delegate: BKPaymentManager.shared)
            
        } else if url.host == "safepay"  {
            
            verificationPayResult(url)
            return true
            
        }
     
        return false
        
    }
 
    /// 开始支付
    func paymentOrderReqeust(_ payOrderInfo :BKPaymentInfo) {
        
        var params                          = [String :Any]()
        params["pay_from"]                  = payOrderInfo.pay_from
        params["order_uids"]                = payOrderInfo.order_uids
        params["coupon_uid"]                = payOrderInfo.coupon_uid
        params["coin_quantity"]             = payOrderInfo.coin_quantity
        params["order_from"]                = "from_ios"
        params["free_coin_quantity"]        = payOrderInfo.free_coin_quantity
        
        BKNetworkManager.postOperationReqeust(KURL_OrderPayment, params: params, success: {[weak self] (success) in
            
            let json                        = success.value
            let return_code                 = json["return_code"]?.intValue ?? 0
            let return_message              = json["return_message"]?.string ?? "创建支付失败"
            let pay_form                    = json["pay_from"]?.stringValue ?? "WECHAT"
            
            guard return_code == 201 else {
                let error = NSError(domain: return_message, code: return_code, userInfo: nil)
                self?.delegate?.PaymentFariure?(error)
                return
            }
            
            let payType : BKPayFromType     = BKPayFromType(rawValue: pay_form)!
            switch payType {
                
            case .WeChatPay: // 微信支付
                
                let result : String         = json["result"]?.stringValue ?? ""
                let wechatPayConfig         = JSONDeserializer<WXOrderParameterModel>.deserializeFrom(json: result)
                self?.startWechatPayment(wechatPayConfig)
                
                break
            case .BankPayment : // 一网通支付
                
                let json                    = json["result"]?.stringValue
                self?.startBankOfMerchantsPayment(json)
                
                break
            case .ApplePay : // Applepay 支付
                
                let result                      = json["result"]?.stringValue
                let applePayConfig              = JSONDeserializer<BKApplepayConfig>.deserializeFrom(json: result)
                self?.startApplePayment(applePayConfig!)
                
                break
                
            case .Alipay :  // 支付宝支付
                
                let json                        = json["result"]?.stringValue
                self?.startAlipay(json)
            
                break
            
            default:
                // 默认巴金支付
                if return_message == "创建成功" && payType == .COIN {
                    self?.delegate?.PaymentSuccess?()
                }
                break
            }
            
          
        }) {[weak self] (failure) in
            self?.delegate?.PaymentFariure?(failure.error)
        }
        
    }
    
    /// 招行支付
    fileprivate func  startBankOfMerchantsPayment(_ result : String?) {
        
        HUD.hide(animated: true)
        guard result != nil else {
            let error = NSError(domain: "付款失败", code: 403, userInfo: nil)
            self.delegate?.PaymentFariure?(error)
            return
        }
        
        let CBMPay                      = CBMPayController()
        CBMPay.title                    = "一网通"
        CBMPay.delegate                 = self
        CBMPay.loadUrl(result!)
        let nav                         = BKNavigaitonController(rootViewController: CBMPay)
        self.topViewController?.present(nav, animated: true, completion: nil)
        
//        let payViewController           = BKCMBPayViewController()
//        payViewController.urlString     = result!
//        let nav                         = BKNavigaitonController.init(rootViewController: payViewController)
//        self.topViewController?.present(nav, animated: true, completion: nil)
//        
        
    }
    
    /// 微信支付
    fileprivate func startWechatPayment( _ wechatPayConfig :WXOrderParameterModel?) {
        
        let request                 = PayReq()
        request.partnerId           = wechatPayConfig?.partnerid!
        request.prepayId            = wechatPayConfig?.prepayid!
        request.package             = wechatPayConfig?.package!
        request.nonceStr            = wechatPayConfig?.noncestr!
        request.timeStamp           = (wechatPayConfig?.stamp!)!
        request.sign                = wechatPayConfig?.sign!
        guard WXApi.isWXAppSupport() else {
            let error = NSError(domain: "未安装微信应用", code: 400, userInfo: nil)
            self.delegate?.PaymentFariure?(error)
            return
        }
        
        WXApi.send(request as BaseReq)
        
    }
    
    /// 支付宝支付
    fileprivate func startAlipay(_ result : String?) {
        
        let appScheme = "bayealipay"

        AlipaySDK.defaultService().payOrder(result, fromScheme: appScheme) {[weak self] (data) in
            self?.alipayResult(data)
        }
        
    }
    
    
    /// 调起 ApplePay 支付
    fileprivate func startApplePayment(_ payConfig : BKApplepayConfig) {
        
        LLAPPaySDK.shared().sdkDelegate     = self
        var params                          = [String : Any]()
        
        params["oid_partner"]               = payConfig.oid_partner
        params["dt_order"]                  = payConfig.dt_order
        params["no_order"]                  = payConfig.no_order
        params["busi_partner"]              = payConfig.busi_partner
        params["name_goods"]                = payConfig.name_goods?.stringValue
        params["info_order"]                = payConfig.info_order?.stringValue
        params["money_order"]               = payConfig.money_order
        params["sign_type"]                 = payConfig.sign_type
        params["notify_url"]                = payConfig.notify_url
        params["risk_item"]                 = payConfig.risk_item
        params["user_id"]                   = payConfig.user_id
        params["ap_merchant_id"]            = payConfig.ap_merchant_id
        params["valid_order"]               = payConfig.valid_order?.stringValue
        params["sign"]                      = payConfig.sign
        
        LLAPPaySDK.shared().pay(withTraderInfo: params, in: self.topViewController!)
        
    }
    
    /// 验证支付宝支付结果
    fileprivate func verificationPayResult(_  url : URL) {
        
        AlipaySDK.defaultService().processOrder(withPaymentResult: url , standbyCallback: {[weak self] (result) -> Void in
            self?.alipayResult(result)
        })
        
    }
    
    /// 解析支付宝回调结果的 json 数据
    
    fileprivate func alipayResult(_ result : [AnyHashable :Any]?) {
        
        guard result != nil else {
            self.delegate?.PaymentFariure?(NSError(domain: "付款失败,未知错误", code: 403, userInfo: nil))
            return
        }
        NJLog(result)
        let json            = JSON(result!).dictionary
        let resultStatus    = json!["resultStatus"]?.intValue ?? 0
        let memo            = json!["memo"]?.string ?? "付款失败"
        if resultStatus == 9000 {
            self.delegate?.PaymentSuccess?()
        } else {
            self.delegate?.PaymentFariure?(NSError(domain: memo.isEmpty ? "付款失败" : memo, code: 403, userInfo: nil))
        }
        
    }
    
}

// MARK: - WXApiDelegate
extension BKPaymentManager : WXApiDelegate {
    
    func onReq(_ req: BaseReq!) {
        NJLog(req)
    }
    
    func onResp(_ resp: BaseResp!) {
        if resp.isKind(of: PayResp.self) {
            switch resp.errCode {
            case WXSuccess.rawValue:
                self.delegate?.PaymentSuccess?()
                break
            default:
                self.delegate?.PaymentFariure?(NSError(domain: "微信付款失败", code: 403, userInfo: nil))
                break
            }
        }
    }
    
}

// MARK: - 招行一网通的代理
extension BKPaymentManager : CBMPayControllerDelegate {
    
    func goOrderVC(_ vc: CBMPayController!) {
        self.delegate?.PaymentSuccess?()
    }
    
    func cancelPay(_ vc: CBMPayController!) {
        self.delegate?.PaymentFariure?(NSError(domain: "一网通付款失败", code: 403, userInfo: nil))
    }
    
}

//// MARK: - 连连支付的代理
extension BKPaymentManager : LLPaySdkDelegate {

    func paymentSucceeded(withShippingMessages shippingMessages: [AnyHashable : Any]!) {
        // NJLog(shippingMessages)
    }
    
    func paymentEnd(_ resultCode: LLPayResult, withResultDic dic: [AnyHashable : Any]!) {
        
        let json               = JSON(dic).dictionaryValue
        let code               = json["ret_msg"]?.intValue ?? 0
        let msg                = json["ret_msg"]?.stringValue ?? "未知结果"
        
        if resultCode.rawValue == 0 {
            self.delegate?.PaymentSuccess?()
        } else if resultCode.rawValue == 2 {
            self.delegate?.PaymentFariure?(NSError(domain: msg, code: code, userInfo: nil))
        } else {
            self.delegate?.PaymentFariure?(NSError(domain: msg, code: code, userInfo: nil))
        }
        
    }

}
