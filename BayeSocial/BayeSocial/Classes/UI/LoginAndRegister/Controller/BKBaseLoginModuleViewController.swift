//
//  BKBaseLoginModuleViewController.swift
//  BayeStyle
//
//  Created by dzb on 2016/11/21.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

/// 登录注册的 baseviewController

class BKBaseLoginModuleViewController: UIViewController {

    var logoView : UIImageView?
    var baseBackgroundView : UIImageView?
    var baserAvatarImageView : UIImageView?
    var nextStepButton : UIButton?
    var backActionButton : UIButton?
    override func viewDidLoad() {
        super.viewDidLoad()

        weak var weakSelf                                   = self
        self.view.backgroundColor                           = UIColor.RGBColor(245.0, green: 245.0, blue: 245.0)
        
        // logoView
        self.logoView                                       = UIImageView()
        self.logoView?.image                                = UIImage(named: "bayekeji_logo")
        self.view.addSubview(self.logoView!)
        self.logoView?.snp.makeConstraints({ (make) in
            make.top.equalTo((weakSelf?.view)!).offset(CYLayoutConstraintValue(86.0))
            make.centerX.equalTo((weakSelf?.view)!)
        })
        
        // 中间的图片
        self.baseBackgroundView                             = UIImageView()
        self.baseBackgroundView?.isUserInteractionEnabled   = true
        self.baseBackgroundView?.image                      = UIImage(named: "loginmodule_background")
        self.view.addSubview((weakSelf?.baseBackgroundView!)!)
        self.baseBackgroundView?.snp.makeConstraints({ (make) in
            make.top.equalTo((weakSelf?.logoView?.snp.bottom)!).offset(CYLayoutConstraintValue(87.0))
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(312.0), height: CYLayoutConstraintValue(264.0)))
            make.centerX.equalTo((weakSelf?.view)!)
        })
        
        // 头像
        self.baserAvatarImageView                           = UIImageView()
        self.baserAvatarImageView?.image                    = UIImage(named: "user_unregister")
        self.view.addSubview((weakSelf?.baserAvatarImageView!)!)
        self.baserAvatarImageView?.snp.makeConstraints({ (make) in
            make.top.equalTo((weakSelf?.logoView?.snp.bottom)!).offset(CYLayoutConstraintValue(89.0))
            make.centerX.equalTo((weakSelf?.view)!)
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(75.0), height: CYLayoutConstraintValue(75.0)))
        })
        
        
        // 下一步按钮
        self.nextStepButton                                = UIButton(type: .custom)
        self.nextStepButton?.setTitleColor(UIColor.white, for: .normal)
        self.nextStepButton?.backgroundColor               = UIColor.black
        self.nextStepButton?.titleLabel?.font              = CYLayoutConstraintFont(15.0)
        self.nextStepButton?.titleLabel?.textAlignment     = .center
        self.nextStepButton?.setCornerRadius(CYLayoutConstraintValue(18.75))
        self.view.addSubview(self.nextStepButton!)
        self.nextStepButton?.snp.makeConstraints({[weak self] (make) in
            make.top.equalTo((self?.baserAvatarImageView?.snp.bottom)!).offset(CYLayoutConstraintValue(154.0))
            make.centerX.equalTo((self?.baseBackgroundView)!)
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(110.0), height: CYLayoutConstraintValue(37.5)))
         })
        
        // 返回按钮
        self.backActionButton                               = UIButton(type: .custom)
        self.backActionButton?.isHidden                     = true
        self.backActionButton?.setImage(UIImage(named : "loginmodule_back"), for: .normal)
        self.view.addSubview(self.backActionButton!)
        self.backActionButton?.snp.makeConstraints({[weak self] (make) in
            make.bottom.equalTo((self?.view.snp.bottom)!).offset(-CYLayoutConstraintValue(80.5))
            make.left.equalTo((self?.view.snp.left)!).offset(CYLayoutConstraintValue(48.0))
            make.size.equalTo(CGSize(width: 50.0, height: 50.0))
        })
        
        self.nextStepButton?.addTarget(self, action: #selector(nextStepClick), for: .touchUpInside)
        self.backActionButton?.addTarget(self, action: #selector(backAction), for: .touchUpInside)

    }
    
    /// 下一步按钮
    @objc func nextStepClick(_ btn : UIButton) {
        
    }
    
    /// 返回方法
    @objc func backAction(_ btn : UIButton) {
        
        let _ = self.navigationController?.popViewController(animated: true)
        
    }
    
}
