//
//  BKMineDynamicStateViewController.swift
//  BayeStyle
//
//  Created by dzb on 2016/11/30.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import WebKit
import SwiftyJSON
import PKHUD

/// 我的动态
class BKMineDynamicStateViewController: BKBaseViewController {
    
    lazy var wkWebView : WKWebView = {
        let configuretion                               = WKWebViewConfiguration()
        var webView                                     = WKWebView(frame: CGRect.zero, configuration: configuretion)
        webView.scrollView.showsVerticalScrollIndicator = false
        return webView
    }()
    
    let KHeadViewHeight : CGFloat                   = 228.0
    private var nameLabel : UILabel                 = UILabel()
    private var titleLabel : UILabel                = UILabel()
    private var companyLabel : UILabel              = UILabel()
    private var avatarImageView : UIImageView       = UIImageView()
    private lazy var progressView : UIProgressView  = {
        let progressView                            = UIProgressView()
        progressView.progress                       = 0.0
        progressView.backgroundColor                = UIColor.clear
        progressView.trackTintColor                 = UIColor.clear
        progressView.progressTintColor              = UIColor.colorWithHexString("FF8C00")
        return progressView
    }()
    var webViewHeight : CGFloat                     = 0.0
    var userId : String = "" {
        didSet {
            userSelf = (userId == easemob_username)
        }
    }
    fileprivate var userInfo : UserInfo?
    private var brgidge : BKWebBridge?
    fileprivate var userSelf : Bool                 = false
    fileprivate var  scrollView : UIScrollView      = UIScrollView()
    var headView : UIView                           = UIView()
    var navBar : UIView                             = UIView(frame: CGRect(x: 0.0, y: -228.0, width: KScreenWidth, height: 64.0))
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setup()
        setNav()
        setupHeadView()
        setupWebView()
        addObserver()
        reqeustUserInfo()

    }
    
    private func setup() {
    
        self.view.backgroundColor                   = UIColor.white
        self.automaticallyAdjustsScrollViewInsets   = false
        gestureRecognizerShouldBegin                = false
       
    }
    
    private func setNav() {
        
        self.wkWebView.scrollView.addSubview(navBar)
        navBar.backgroundColor                      = UIColor.white
        
        // 返回
        let leftButton                              = BKAdjustButton(type: .custom)
        leftButton.frame                            = CGRect(x: 10.0, y: 25.0, width: 25.0, height: 25.0)
        leftButton.setImageViewSizeEqualToCenter(CGSize(width: 13.0, height: 21.0))
        leftButton.setImage(UIImage(named: "black_backArrow"), for: .normal)
        navBar.addSubview(leftButton)
        
        // 标题Label
        let titleLabel                              = UILabel(frame: CGRect(x: leftButton.right, y: leftButton.top, width: 100, height: leftButton.height))
        titleLabel.text                             = "他的动态"
        titleLabel.font                             = UIFont.systemFont(ofSize: 17.0)
        titleLabel.textColor                        = UIColor.colorWithHexString("#172434")
        navBar.addSubview(titleLabel)
        
        leftButton.addTarget(self, action: #selector(webViewBack), for: .touchUpInside)
        titleLabel.addTarget(self, action: #selector(webViewBack))

    }
    
    /**
     是否显示 leftButtonItem
     */
    @objc private func webViewBack() {
        guard self.wkWebView.canGoBack  else {
            let _ = self.navigationController?.popViewController(animated: true)
            return
        }
        let _ =  self.wkWebView.goBack()
    }
    
    /// 退出我的巴圈
    @objc private func close() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    /// 初始化头部视图
    private func setupHeadView() {
        
        // 头部视图背景 View
        headView.frame                  = CGRect(x: 0.0, y : navBar.bottom, width: KScreenWidth, height: 152.5)
        headView.backgroundColor        = UIColor.white
        headView.addTarget(self, action: #selector(tapAvatar))
        self.wkWebView.scrollView.addSubview(headView)
        
        // 姓名
        self.nameLabel.font             = CYLayoutConstraintFont(30.0)
        self.headView.addSubview(self.nameLabel)
        self.nameLabel.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.headView.snp.top)!).offset(CYLayoutConstraintValue(20.0))
            make.left.equalTo((self?.headView.snp.left)!).offset(CYLayoutConstraintValue(20.0))
        }

        // 头像
        self.headView.addSubview(self.avatarImageView)
        self.avatarImageView.image      = KCustomerUserHeadImage
        self.avatarImageView.setCornerRadius(60.0)
        self.avatarImageView.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.nameLabel)!)
            make.right.equalTo((self?.headView.snp.right)!).offset(-CYLayoutConstraintValue(12.0))
            make.size.equalTo(CGSize(width: 120.0, height: 120.0))
        }
        
        // 职称
        self.titleLabel.font            = CYLayoutConstraintFont(15.5)
        self.titleLabel.textColor       = UIColor.colorWithHexString("#666666")
        self.headView.addSubview(self.titleLabel)
        self.titleLabel.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.nameLabel.snp.bottom)!).offset(CYLayoutConstraintValue(4.0))
             make.left.equalTo((self?.nameLabel)!)
        }
        
        // 公司名称
        self.companyLabel.font            = CYLayoutConstraintFont(15.5)
        self.companyLabel.textColor       = UIColor.colorWithHexString("#666666")
        self.headView.addSubview(self.companyLabel)
        self.companyLabel.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.titleLabel.snp.bottom)!).offset(CYLayoutConstraintValue(4.0))
            make.left.equalTo((self?.nameLabel)!)
        }
        
        
    }
    
    @objc func tapAvatar() {
    
        openImage(with: [self.userInfo?.avatar ?? ""], position: 0)
        
    }
    /// 请求用户资料的信息
    func reqeustUserInfo() {
                
        BKNetworkManager.getOperationReqeust(baseURLPath + "customers/profile", params: ["customer_uid" : self.userId], success: {[weak self] (success) in
            
            let json                        = success.value
            let profile                     = json["profile"]?.dictionaryValue
            guard profile                   != nil else {
                UnitTools.addLabelInWindow("获取用户资料失败", vc: self)
                self?.navigationController?.popViewControllerAnimated(true, delay: 0.5)
                return
            }

            self?.userInfo                  = UserInfo(with: profile!)
            self?.update()
            
            updateUserInfo((self?.userInfo)!)
            
        }) { (failure) in
            
            NJLog(failure.error)
            
        }
        
    }
    
    func update() {
        
        self.nameLabel.text             = userInfo?.name
        self.titleLabel.text            = userInfo?.company_position
        self.companyLabel.text          = userInfo?.company
        let avatar                      = userInfo?.avatar ?? ""
        self.avatarImageView.kf.setImage(with: URL(string:avatar), placeholder: KCustomerUserHeadImage, options: nil, progressBlock: nil, completionHandler: nil)
        
    }
    
    /// 初始化 webView
    private func setupWebView() {
        
        self.view.addSubview(self.wkWebView)
        self.webViewHeight                          = KScreenHeight
        self.wkWebView.frame                        = CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: self.webViewHeight)
        wkWebView.scrollView.contentInset           = UIEdgeInsets(top: KHeadViewHeight, left: 0, bottom: 0, right: 0)
        
        let reqeustURL : String                     = String(format:"%@%@",BKApiConfig.APIHubsActivetys,self.userId)
        let url : URL                               = URL(string :reqeustURL)!
        let urlReqeust                              = self.getReqeust(url)
        let _                                       = self.wkWebView.load(urlReqeust as URLRequest)
        
        self.wkWebView.scrollView.delegate          = self
        
    }
    
    /**
     拼接一个带有用户 token的请求头信息的 Request
     */
    private func getReqeust(_ url : URL) -> NSMutableURLRequest {
        
        let mutalbeReqeuset                 = NSMutableURLRequest(url: url, cachePolicy: NSURLRequest.CachePolicy.useProtocolCachePolicy, timeoutInterval: 15.0)
        var reqesutHeader                   = "bayekeji"
        if userDidLogin {
            reqesutHeader                   = "\(userToken!)"
        }
        mutalbeReqeuset.timeoutInterval     = 10.0
        mutalbeReqeuset.allHTTPHeaderFields = ["Authorization" : reqesutHeader]
        return mutalbeReqeuset
        
    }
    
    /// 打开图片浏览器
    func openImage(with urls:[String] ,position : Int) {
        
        let vc                  = CommodityImagesDetailViewController()
        vc.commodityImageArray  = urls
        vc.currentPage          = position
        self.present(vc, animated: true, completion: nil)
        
    }
    
    /// 左边按钮点击事件
    private func clickLeftBtn() {
        
        if (self.wkWebView.canGoBack) {
           let _ = self.wkWebView.goBack()
        } else {
           let _ = self.navigationController?.popViewController(animated: true)
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    fileprivate func addObserver() {
    
        self.wkWebView.addObserver(self, forKeyPath: "estimatedProgress", options: NSKeyValueObservingOptions.new, context: nil)
        self.wkWebView.navigationDelegate           = self
        
        self.brgidge                                = BKWebBridge(webView: self.wkWebView)
        self.brgidge?.registerHandler("DisplayPicture", handle: {[weak self] (json) in
            guard json != nil else {
                return
            }
            let current_position                    = json!["current_position"]?.int ?? 0
            let images                              = json!["images"]?.arrayObject
            guard images                            != nil else {
                return
            }
            self?.openImage(with: images as! [String], position: current_position)
        })
        

    }
    
    deinit {
        self.wkWebView.removeObserver(self, forKeyPath: "estimatedProgress")
        NJLog(self)
    }
    
    /**
     视图将要消失
     */
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.progressView.isHidden  = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    /**
     监听 webView 加载进度
     */
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        if keyPath == "estimatedProgress" {
            weak var weakSelf                   = self
            OperationQueue.main.addOperation {
                let newProgressView             = self.wkWebView.estimatedProgress
                weakSelf?.progressView.progress = Float((newProgressView == 1.0) ? 0.0 : newProgressView)
            }
            
        }
       
    }
    
    

}

// MARK: - WKNavigationDelegate
extension BKMineDynamicStateViewController : WKNavigationDelegate , UIScrollViewDelegate {
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        HUD.hide(animated: true)
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        HUD.hide(animated: true)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        HUD.hide(animated: true)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse, decisionHandler: @escaping (WKNavigationResponsePolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(.allow)
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
    }
    
    /// 监听webview滑动
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let pt_Y = scrollView.contentOffset.y
        navBar.removeFromSuperview()

        if pt_Y > -KHeadViewHeight {
            
            navBar.frame   = CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: 64.0)
            view.addSubview(navBar)
            
        } else  {
            
            navBar.frame = CGRect(x: 0.0, y: -228.0, width: KScreenWidth, height: 64.0)
            wkWebView.scrollView.addSubview(navBar)
            
        }
        
    }
    
  
    
}


