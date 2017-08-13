//
//  BKWebViewController.swift
//  BayeStyle
//
//  Created by dzb on 2016/12/8.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import WebKit
import PKHUD

class BKBaseWebViewController: BKBaseViewController {

    var suppotApplePay : Bool?
    var showPKHUD : Bool           = true
    lazy var wkWebView : WKWebView = {
        let configuretion               = WKWebViewConfiguration()
        var webView                     = WKWebView(frame: CGRect.zero, configuration: configuretion)
        return webView
    }()
    lazy var progressView : UIProgressView = {
        let progressView                = UIProgressView()
        progressView.progress           = 0.0
        progressView.backgroundColor    = UIColor.clear
        progressView.trackTintColor     = UIColor.clear
        progressView.progressTintColor  = UIColor.colorWithHexString("FF8C00")
        return progressView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets       = true
        self.view.addSubview(self.wkWebView)
        self.wkWebView.navigationDelegate               = self
        
        self.wkWebView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
        
        // 添加一个进度条显示加载进度
        self.navigationController?.navigationBar.addSubview(self.progressView)
        
        self.progressView.snp.makeConstraints {[weak self]  (make) in
            make.bottom.equalTo((self?.navigationController?.navigationBar.snp.bottom)!)
            make.left.equalTo((self?.navigationController?.navigationBar.snp.left)!).offset(-1.0)
            make.size.equalTo(CGSize(width :KScreenWidth + 2.0,  height:2.0))
        }
        
        
        self.addObserver()
        
    }
    
    /**
     拼接一个带有用户 token的请求头信息的 Request
     */
    func getReqeust(_ url : URL) -> NSMutableURLRequest {
        
        let mutalbeReqeuset                 = NSMutableURLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 15.0)
        var reqesutHeader                   = "bayekeji"
        if userDidLogin {
            reqesutHeader                   = "\(userToken!)"
        }
        mutalbeReqeuset.timeoutInterval     = 10.0
        var appInfo : String                = "AppVersion:\(UnitTools.appCurrentVersion())"
        if let applePay = self.suppotApplePay {
            appInfo+=",ApplePay:\(applePay)"
        }
        let httpHeaderFields = ["Authorization" : reqesutHeader,"AppInfo" :appInfo]
        mutalbeReqeuset.allHTTPHeaderFields = httpHeaderFields
//        NJLog(httpHeaderFields)
        return mutalbeReqeuset
    }
    
    func addObserver() {
        self.wkWebView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
    }

    deinit {
        self.wkWebView.removeObserver(self, forKeyPath: "estimatedProgress")
    }
    /**
     视图将要消失
     */
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.progressView.isHidden = true
    }
    /**
     监听 webView 加载进度
     */
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        weak var weakSelf = self
        OperationQueue.main.addOperation {
            let newProgressView = self.wkWebView.estimatedProgress
            weakSelf?.progressView.progress = Float((newProgressView == 1.0) ? 0.0 : newProgressView)
        }
        
    }
    

}

// MARK: - WKNavigationDelegate
extension BKBaseWebViewController : WKNavigationDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if self.showPKHUD {
            HUD.hide(animated: true)
        }
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
    }
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        if self.showPKHUD {
            HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        }
    }
    
}

