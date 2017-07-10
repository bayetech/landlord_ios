//
//  BKStoreViewController.swift
//  BayeStyle
//
//  Created by dzb on 2016/12/1.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON
import HandyJSON
import PKHUD

/// 商城
class BKStoreViewController: BKBaseWebViewController  {

    var bridge : BKWebBridge?
    var reqeustURL : String = BKApiConfig.APIStore
    var wkShareView : BKWebViewShareView?
    var shareModel : ShareViewModel?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.showPKHUD                              = false
        
        // 是否支持 ApplePay 支付
        let status                                  =  LLAPPaySDK.canDeviceSupportApplePayPayments()
        self.suppotApplePay                         = (status.rawValue == 0)
        
        let url : URL                               = URL(string :reqeustURL)!
        let urlReqeust                              = self.getReqeust(url)
        let _                                       = self.wkWebView.load(urlReqeust as URLRequest)
        
        self.setNav()

    }
    
   
    func setNav() {
          
        self.setLeftBarbuttonItemWithTitles(["返回","关闭"], actions: [#selector(webViewBack),#selector(clickRightBtn)])
        self.setRightBarbuttonItemWithImages(["chat_setting"], actions: [#selector(webViewTool)])
      
    }
    
    /// 打开右侧的工具条
    func webViewTool() {
    
        if wkShareView != nil {
            wkShareView?.removeFromSuperview()
            wkShareView = nil
        }
        
        wkShareView             = BKWebViewShareView(frame: CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: KScreenHeight))
        wkShareView?.delegate   = self
        AppDelegate.appDelegate().window?.addSubview(wkShareView!)
        
    }
    
    /**
     是否显示 leftButtonItem
     */
    func webViewBack() {
        
        guard self.wkWebView.canGoBack  else {
            let _ = self.navigationController?.popViewController(animated: true)
            return
        }
        let _ =  self.wkWebView.goBack()

    }
    
    /// 查看社区消息
    func clickRightBtn() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    /// 刷新视图
    func reloadWebView() {
        let _ = self.wkWebView.reload()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    override func addObserver() {
        super.addObserver()
        
        // 初始化 JSBridge
        self.bridge                                 = BKWebBridge.bridgeForWebView(self.wkWebView)
        
        // js 调用 Swift 监听网页去支付按钮事件
        self.bridge?.registerHandler("createPayment", handle: {[weak self] (result) in
            self?.startPayment(result)
        })
    
        self.bridge?.registerHandler("mallShare", handle: {[weak self]  (result) in
            
            let imgUrl          = result?["imgUrl"]?.string
            let title           = result?["title"]?.string
            let desc            = result?["desc"]?.string
            let link            = result?["link"]?.string
            self?.shareModel    = ShareViewModel(title: title, url: link, image: imgUrl, desc: desc)
            
        })
        
        // 监听支付结果
        BKPaymentManager.shared.addDelegate(self)
        
    }
    
    override func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        
        NJLog(webView.url?.absoluteString)
        super.webView(webView, decidePolicyFor: navigationAction, decisionHandler: decisionHandler)
        
    }
    
  
}


// MARK: - BKPaymentResultProtocol

extension BKStoreViewController : BKPaymentResultProtocol , BKWebViewShareViewDelegate {
    
    /// 开始创建支付
    func startPayment(_ json : [String : JSON]?) {
        
        guard json != nil else {
            UnitTools.addLabelInWindow("支付失败", vc: self)
            return;
        }
        
        HUD.flash(.labeledRotatingImage(image: PKHUDAssets.progressCircularImage, title: nil, subtitle: "准备付款"), delay: 30.0)
        let paymentInfo : BKPaymentInfo  = BKPaymentInfo(json)        
        BKPaymentManager.shared.paymentOrderReqeust(paymentInfo)
        
    }
    
    /// 付款成功
    func PaymentSuccess() {
        
        HUD.hide(animated: true)
        self.bridge?.runJavaScript("redirect_to_order_success(201,'付款成功')", completionHandler: { (result) in
            NJLog(result.errroMsg)
        })
        
    }
    
    /// 付款失败
    func PaymentFariure(_ error: NSError) {
        
        HUD.hide(animated: true)
        let errorMsg : String   = error.domain
        self.bridge?.runJavaScript("redirect_to_order_failue(403,'\(errorMsg)')", completionHandler: { (result) in
            NJLog(result.errroMsg)
        })
        
    }
    
    /// 点击了分享的按钮
    func webviewShareViewDidSelectAtIndex(_ index: Int) {
        
        switch index {
        case 0:
            YepShareModule.wechatShare(.subTypeWechatSession, shareModel: self.shareModel!)

            break
            
        case 1 :
            YepShareModule.wechatShare(.subTypeWechatTimeline, shareModel: self.shareModel!)
            break
//        case 2 :
//            YepShareModule.wechatShare(.subTypeWechatTimeline, shareModel: self.shareModel!)
//            break
        default:
            reloadWebView()
        }
        
    }

    
}
