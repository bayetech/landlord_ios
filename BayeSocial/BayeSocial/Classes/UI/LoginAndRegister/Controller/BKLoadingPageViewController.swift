//
//  BKLoadingPageViewController.swift
//  BayeSocial
//
//  Created by dzb on 2017/1/13.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

import UIKit

/// 轮播图

class BKLoadingPageViewController: UIViewController , UIScrollViewDelegate {

    var scrollView : UIScrollView = UIScrollView(frame: UIScreen.main.bounds)
    var pageControl : UIPageControl = UIPageControl()
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(scrollView)
        scrollView.isPagingEnabled                  = true
        scrollView.bounces                          = false
        scrollView.showsHorizontalScrollIndicator   = false
        let imageArray : [String]                   = ["loadingPage1","loadingPage2","loadingPage3"]

        for i in 0..<imageArray.count {
            
            // 背景图片
            let imageView                           = UIImageView()
            imageView.frame                         = CGRect(x: CGFloat(i)*KScreenWidth, y: 0.0, width: KScreenWidth, height: KScreenHeight)
            imageView.image                         = UIImage(named: imageArray[i])
            scrollView.addSubview(imageView)
            
        }

        scrollView.contentSize                      = CGSize(width: CGFloat(imageArray.count)*KScreenWidth, height: KScreenHeight)
        scrollView.delegate                         = self
        self.view.addSubview(pageControl)
        
        // pageControl
        pageControl.numberOfPages                   = 3
        pageControl.currentPage                     = 0
        pageControl.pageIndicatorTintColor          = UIColor.RGBColor(146.0, green: 157.0, blue: 170.0)
        pageControl.addTarget(self, action: #selector(pageControlValue(_:)), for: .valueChanged)
        pageControl.snp.makeConstraints {[weak self] (make) in
            make.bottom.equalTo((self?.view.snp.bottom)!).offset(-CYLayoutConstraintValue(128.0))
            make.centerX.equalTo((self?.scrollView)!)
        }
        
        // 登录按钮
        let loginButton : UIButton                  = UIButton(type: .custom)
        loginButton.backgroundColor                 = UIColor.colorWithHexString("#359476")
        loginButton.setTitle("登录", for: .normal)
        loginButton.setTitleColor(UIColor.white, for: .normal)
        loginButton.titleLabel?.textAlignment       = .center
        loginButton.titleLabel?.font                = UIFont.systemFont(ofSize: 15.0)
        self.view.addSubview(loginButton)
        
        // 注册按钮
        let registButton : UIButton                  = UIButton(type: .custom)
        registButton.backgroundColor                 = UIColor.colorWithHexString("#42C099")
        registButton.setTitle("注册", for: .normal)
        registButton.setTitleColor(UIColor.white, for: .normal)
        registButton.titleLabel?.textAlignment       = .center
        registButton.titleLabel?.font                = UIFont.systemFont(ofSize: 15.0)
        self.view.addSubview(registButton)
        
        loginButton.snp.makeConstraints { (make) in
            make.bottom.left.equalTo(self.view)
            make.height.equalTo(CYLayoutConstraintValue(60.0))
            make.right.equalTo(registButton.snp.left)
        }
        
        registButton.snp.makeConstraints { (make) in
            make.bottom.right.equalTo(self.view)
            make.height.equalTo(CYLayoutConstraintValue(60.0))
            make.left.equalTo(loginButton.snp.right)
            make.width.equalTo(loginButton)
        }
        
        loginButton.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)
        registButton.addTarget(self, action: #selector(buttonClick(_:)), for: .touchUpInside)

    }
    
    @objc func buttonClick(_ btn : UIButton) {
        
        AppDelegate.appDelegate().displayLoginViewController()
        
    }

    @objc func pageControlValue(_ pageControl : UIPageControl) {
    
        let offSetX  = CGFloat(pageControl.currentPage) * KScreenWidth
        scrollView.setContentOffset(CGPoint(x:offSetX,y:0), animated: true)
        
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let index               = scrollView.contentOffset.x / KScreenWidth
        pageControl.currentPage = Int(index)
        
    }
    
    override var prefersStatusBarHidden: Bool {
        return false
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
}

