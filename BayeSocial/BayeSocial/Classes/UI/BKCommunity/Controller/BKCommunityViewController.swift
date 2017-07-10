//
//  BKCommunityViewController.swift
//  Baye
//
//  Created by 董招兵 on 16/9/7.
//  Copyright © 2016年 上海巴爷科技有限公司. All rights reserved.
//

import UIKit
import Alamofire
import WebKit
import SwiftyJSON

/// 社区首页的控制器
class BKCommunityViewController: BKBaseWebViewController , UIScrollViewDelegate , BKExchangeCoverViewControllerDelegate {

    var brgidge : BKWebBridge?
    var headView : UIView                   = UIView(frame: CGRect(x: 0.0, y: -255.0, width: KScreenWidth, height:255.0))
    var navBar : UIView                     = UIView(frame: CGRect(x: 0.0, y: 0.0, width: KScreenWidth, height: 64.0))
    var leftButton : BKAdjustButton?
    var rightBtn : UIButton?
    var backgroundImageView : UIImageView?
    var nameLabel : UILabel?
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setNav()
        self.setup()
        self.reloadHome()
        
    }
        
    func setNav() {
        
        
        self.wkWebView.scrollView.addSubview(headView)
        headView.backgroundColor                = UIColor.RandomColor()
        self.wkWebView.scrollView.contentInset = UIEdgeInsetsMake(255.0, 0.0, 0.0, 0.0)
        // 背景封面
        backgroundImageView                 = UIImageView()
        backgroundImageView?.contentMode    = .scaleAspectFill
        backgroundImageView?.clipsToBounds  = true
        headView.addSubview(backgroundImageView!)
        backgroundImageView?.snp.makeConstraints {[weak self] (make) in
            make.edges.equalTo((self?.headView)!)
        }
        
        // 自定义导航条
        headView.addSubview(navBar)
        
        // 返回
        leftButton                           = BKAdjustButton(type: .custom)
        leftButton?.frame                    = CGRect(x: 11.5, y:31.0, width: 30, height: 21.0)
        leftButton?.setImage(UIImage(named: "back_white"), for: .normal)
        leftButton?.setImage(UIImage(named: "black_backArrow"), for: .selected)
        leftButton?.setImageViewSizeEqualToCenter(CGSize(width: 13.0, height: 21.0))
        leftButton?.addTarget(self, action: #selector(BKCommunityViewController.webViewBack), for: .touchUpInside)
        navBar.addSubview(leftButton!)
        
        // 发帖
        rightBtn                            = UIButton(type: .custom)
        rightBtn?.frame                     = CGRect(x: KScreenWidth - 44.0, y: 31.0, width: 28.0, height: 21.0)
        rightBtn?.addTarget(self, action: #selector(BKCommunityViewController.clickRightBtn), for: .touchUpInside)
        rightBtn?.setBackgroundImage(UIImage(named: "send_ community"), for: .normal)
        rightBtn?.setBackgroundImage(UIImage(named: "send_community_sel"), for: .selected)

        navBar.addSubview(rightBtn!)
        
        // 姓名的label
        nameLabel                   = UILabel()
        nameLabel?.textColor        = UIColor.white
        nameLabel?.font             = UIFont.systemFont(ofSize: 30.0)
        headView.addSubview(nameLabel!)
        nameLabel?.snp.makeConstraints({[weak self] (make) in
            make.bottom.equalTo((self?.headView)!).offset(-15.0)
            make.left.equalTo((self?.headView.snp.left)!).offset(20.0)
            make.right.equalTo((self?.headView.snp.right)!).offset(-20.0)
        })
        
        // 设置初始值
        nameLabel?.text             = BK_UserInfo.name
        backgroundImageView?.kf.setImage(with: URL(string:BK_UserInfo.hub_background_image), placeholder:UIImage(named:"chatgroup_background"), options: nil, progressBlock: nil, completionHandler: nil)
        backgroundImageView?.addTarget(self, action: #selector(backgroundClick(_:)))
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hiddenHUD()
    }
    /// 初始化UI
    func setup() {
        
        self.view.addSubview(self.wkWebView)
        self.wkWebView.navigationDelegate   = self
        self.wkWebView.snp.makeConstraints { (make) in
            make.edges.equalTo(self.view)
        }
    
        self.automaticallyAdjustsScrollViewInsets = false
        self.title                                = "巴圈"
    
    }
    
    
    /// 点击封面更换封面
    func backgroundClick(_ tap : UITapGestureRecognizer)  {
        
        let changeCoverViewController       = BKExchangeCoverViewController()
        changeCoverViewController.delegate  = self
        navigationController?.pushViewController(changeCoverViewController, animated: true)
        
    }

    /// 监听通知
    override func addObserver() {
        super.addObserver()
        seeFullPictures()
        wkWebView.scrollView.delegate = self
    }
    
    /// 全屏查看图片
    func seeFullPictures() {
        
        self.brgidge                    = BKWebBridge(webView: self.wkWebView)
        self.brgidge?.registerHandler("DisplayPicture", handle: {[weak self] (json) in
            if json != nil {
                
                let vc                  = CommodityImagesDetailViewController()
                let current_position    = json!["current_position"]?.int ?? 0
                let images              = json!["images"]?.arrayObject
                guard images            != nil else {
                    return
                }
                vc.commodityImageArray  = images as! [String]
                let index               = current_position
                vc.currentPage          = index
                self?.present(vc, animated: true, completion: nil)
                
            }
        })

        
    }

    /// 查看社区消息
    func clickRightBtn() {
        
        let  composeViewController                 = BKComposeViewController()
        let nav                                    = BKNavigaitonController(rootViewController: composeViewController)
        composeViewController.sourceViewController = self
        self.present(nav, animated: true, completion: nil)
        
    }
    
    /**
     刷新首页数据,适用于每次切换到社区页面时
     */
    func reloadHome() {
        
        removeWebViewCaches()
        let mutableReqeust = getReqeust(URL(string: KHubsWebViewURL)!)
        self.wkWebView.load(mutableReqeust as URLRequest)
        
        
    }

    /**
     刷新 WebView
     */
    func reloadWebView() {
        self.wkWebView.reload()
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

    /**
     清除 webView 的缓存和 cookie
     */
    func removeWebViewCaches() {
        removeWebviewCookies()
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let pt_Y            = scrollView.contentOffset.y
        navBar.removeFromSuperview()
        var alpha : CGFloat = 0.0
        
        switch pt_Y {
        case -255.0..<0.0:
            
            let currentOffsetY : Double = Double(abs(pt_Y))
            let originalValue           = 255.0
            let differenceValue         = Double(abs(currentOffsetY-originalValue))
            if differenceValue >= 50.0 {
                alpha                       = CGFloat((differenceValue-50.0)*0.05)
            } else {
                alpha                       = 0.0
            }
            
            view.addSubview(navBar)
            
            break
        case 0..<CGFloat(MAXFLOAT):
            
            alpha       = 1.0
            view.addSubview(navBar)

            break
        default:
            
            alpha       = 0.0
            headView.addSubview(navBar)

            break
        }
        
        let buttonSelected          = (alpha > 0.3)
        leftButton?.isSelected      = buttonSelected
        rightBtn?.isSelected        = buttonSelected

        alpha                       =   min(1.0, alpha)
        self.navBar.backgroundColor = UIColor.white.withAlphaComponent(alpha)
        
    }
    
    /// 更改封面成功
    func changeBackgroundImageSuccess(_ imageUrl: String) {
        
        self.backgroundImageView?.kf.setImage(with: URL(string :imageUrl), placeholder: UIImage(named:"chatgroup_background"), options: nil, progressBlock: nil, completionHandler: nil)
        
        BKRealmManager.beginWriteTransaction()
        
        BKRealmManager.shared().currentUser?.hub_background_image = imageUrl
        
        BKRealmManager.commitWriteTransaction()
        
        
    }
    
}



