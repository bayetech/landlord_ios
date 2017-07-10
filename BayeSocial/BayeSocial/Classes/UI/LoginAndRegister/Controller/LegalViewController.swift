//
//  LegalViewController.swift
//  Baye
//
//  Created by 张少康 on 15/10/15.
//  Copyright © 2015年 Bayekeji. All rights reserved.
//

import UIKit

class LegalViewController: UIViewController {

      var LegalWebView: UIWebView? {
        didSet {
            
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor               = UIColor.white
        
        self.title                              = "巴爷汇用户协议"
        self.LegalWebView                       = UIWebView()
        self.LegalWebView?.backgroundColor      = UIColor.clear
        self.LegalWebView?.isOpaque             = false
        self.LegalWebView?.scalesPageToFit      = true
        
        self.view.addSubview(self.LegalWebView!)
        self.LegalWebView?.snp.makeConstraints({[weak self] (make) in
            make.edges.equalTo((self?.view)!)
        })
        
        let url                                 = URL(string: "https://wechat.bayekeji.com/activity/facha_app/license")
        self.LegalWebView?.loadRequest(URLRequest(url:url!))
        
        let button                              = BKAdjustButton(type: .custom)
        button.setImage(UIImage(named:"black_backArrow"), for: .normal)
        button.addTarget(self, action: #selector(back), for: .touchUpInside)
        button.frame                            = CGRect(x:0.0,y:0.0,width : 30.0,height : 21.0)
        button.setImageViewSizeEqualToCenter(CGSize(width : 13.0,height : 21.0))
        self.navigationItem.leftBarButtonItem   = UIBarButtonItem(customView: button)
        
       
    }
    
    func back() {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
}
