
//  BKWebBridge.swift
//  Baye
//
//  Created by 董招兵 on 2016/9/30.
//  Copyright © 2016年 上海巴爷科技有限公司. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON

struct BKWebViewBridgeResult {
    var result : Any?
    var error : NSError?
    var errroMsg : String?
    var errorCode : Int?
    init(_ result :Any?,error : NSError?) {
        self.result         = result
        self.error          = error
        self.errroMsg       = self.error?.localizedDescription
        self.errorCode      = self.error?._code
    }
}

/// JS 调用 OC 方法回调
typealias BKWebBridgeHandle         = (_ reslut : [String :JSON]?) -> Void

/// 调用 JS 代码后的回调
typealias BKWebViewRunJSHandele     = (_ completionHandler : BKWebViewBridgeResult) -> Void

public protocol JavaScriptResource  {
    var string : String? { get }
}

extension String : JavaScriptResource {
    public var string: String? { return self}
}


/// JS 和 swift交互
class BKWebBridge: NSObject {
    
    var webView : WKWebView?
    var webHandleCache : [String : BKWebBridgeHandle] = [String : BKWebBridgeHandle]()
    private var wkConfiguretion : WKWebViewConfiguration? {
        didSet {
            wkConfiguretion!.preferences            = WKPreferences()
            wkConfiguretion!.processPool            = WKProcessPool()
            wkConfiguretion!.userContentController  = WKUserContentController()
            // 默认是不能通过JS自动打开窗口的，必须通过用户交互才能打开
            wkConfiguretion!.preferences.javaScriptCanOpenWindowsAutomatically = false;
        }
    }
    
    /// 初始化时根据一个 webView
    class func bridgeForWebView(_ webView : WKWebView) -> BKWebBridge {
        let bridge = BKWebBridge(webView: webView)
        return bridge
    }
    
    /// 遍利构造方法
    convenience init(webView : WKWebView) {
        self.init()
        self.webView            = webView
        self.wkConfiguretion    = self.webView?.configuration
    }
    
    /// 注册一个 js 桥 JS 调用 OC 代码
    public func registerHandler(_ name : String?,handle : BKWebBridgeHandle?) {
        guard name != nil else {
            return
        }
        self.webView?.configuration.userContentController.add(self, name: name!)
        guard handle != nil else {
            return
        }
        self.webHandleCache[name!] = handle
    }
    
    /// 调用 JS 代码 不需要传参数
    public func runJavaScript(_ msg : String ,completionHandler : BKWebViewRunJSHandele?) {
        self.runJavaScript(msg, data: nil, completionHandler: completionHandler)
    }
    
    
    /// 调用 JS 代码需要传参数
    public func runJavaScript(_ msg:String,data:JavaScriptResource?,completionHandler : BKWebViewRunJSHandele?) {
        
        let javaScript  : String        = msg
        NJLog(javaScript)
        
        self.webView?.evaluateJavaScript(javaScript, completionHandler: { (result, error) in
            completionHandler?(BKWebViewBridgeResult(result ,error: error as? NSError))
        })
        
        
    }
    
}

//MARK: WKScriptMessageHandler
extension BKWebBridge : WKScriptMessageHandler {
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let handle = self.webHandleCache[message.name]
        if handle != nil {
            handle!(JSON(message.body).dictionary)
        }
    }
    
}
