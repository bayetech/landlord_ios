//
//  RegisertPasswordViewController.swift
//  BayeStyle
//
//  Created by dzb on 2016/11/21.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

/// 注册输入密码的控制器
class RegisertPasswordViewController: BKBaseLoginModuleViewController {

    var passwordTextField : UITextField?
    var passwordConfirmTextField : UITextField?
    var verifyCode : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()

    }
    
    func setup() {
        
        self.backActionButton?.isHidden                         = false
        self.nextStepButton?.setTitle("下一步", for: .normal)
        
        // 手机号码输入框
        self.passwordTextField                                  = UITextField()
        self.passwordTextField?.isSecureTextEntry               = true
        let placeholderAttribut                                 = [NSAttributedStringKey.foregroundColor : UIColor.colorWithHexString("#C8C8C8"),NSAttributedStringKey.font : CYLayoutConstraintFont(16.0)]
        self.passwordTextField?.attributedPlaceholder           = NSAttributedString(string: "请输入密码", attributes:placeholderAttribut)
        self.passwordTextField?.clearButtonMode                 = .always
        self.passwordTextField?.textAlignment                   = .center
        self.passwordTextField?.borderStyle                     = .none
        self.passwordTextField?.isSelected                      = false
        self.baseBackgroundView?.addSubview(self.passwordTextField!)
        self.passwordTextField?.snp.makeConstraints({[weak self] (make) in
            make.top.equalTo((self?.baseBackgroundView?.snp.top)!).offset(CYLayoutConstraintFontSize(90.0))
            make.centerX.equalTo((self?.baseBackgroundView)!)
            make.width.equalTo(CYLayoutConstraintValue(240.0))
        })
        
        // 密码输入框
        self.passwordConfirmTextField                           = UITextField()
        self.passwordConfirmTextField?.attributedPlaceholder    = NSAttributedString(string: "请确认密码", attributes:placeholderAttribut)
        self.passwordConfirmTextField?.clearButtonMode          = .always
        self.passwordConfirmTextField?.isSecureTextEntry        = true
        self.passwordConfirmTextField?.isSelected               = false
        self.passwordConfirmTextField?.textAlignment            = .center
        self.passwordConfirmTextField?.borderStyle              = .none
        self.baseBackgroundView?.addSubview(self.passwordConfirmTextField!)
        self.passwordConfirmTextField?.snp.makeConstraints({[weak self] (make) in
            make.top.equalTo((self?.passwordTextField?.snp.bottom)!).offset(CYLayoutConstraintFontSize(28.0))
            make.centerX.equalTo((self?.baseBackgroundView)!)
            make.width.equalTo((self?.passwordTextField)!)
        })
        
        // 查看密码的按钮
        let confirmRightButton                                  = UIButton(type :.custom)
        confirmRightButton.setImage(UIImage(named :"password_ secure_nor"), for: .normal)
        confirmRightButton.setImage(UIImage(named :"password_ secure_sel"), for: .selected)
        confirmRightButton.isSelected                           = false
        confirmRightButton.tag                                  = 200
        confirmRightButton.frame                                = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 15.0)
        self.passwordConfirmTextField?.rightView                = confirmRightButton
        self.passwordConfirmTextField?.rightViewMode            = .always
        
        // 确认密码右边查看密码的按钮
        let passwordRightButton                                 = UIButton(type :.custom)
        passwordRightButton.setImage(UIImage(named :"password_ secure_nor"), for: .normal)
        passwordRightButton.setImage(UIImage(named :"password_ secure_sel"), for: .selected)
        passwordRightButton.tag                                 = 100
        passwordRightButton.isSelected                          = false
        passwordRightButton.frame                               = CGRect(x: 0.0, y: 0.0, width: 30.0, height: 15.0)
        self.passwordTextField?.rightView                       = passwordRightButton
        self.passwordTextField?.rightViewMode                   = .always
        
        // 横线
        let  lineView                                           = UIView()
        lineView.backgroundColor                                = UIColor.colorWithHexString("#E8E8E8")
        self.baseBackgroundView?.addSubview(lineView)
        lineView.snp.makeConstraints({[weak self]  (make) in
            make.top.equalTo((self?.passwordConfirmTextField?.snp.bottom)!).offset(CYLayoutConstraintValue(20.0))
            make.centerX.equalTo((self?.baseBackgroundView!)!)
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(240.0), height: CYLayoutConstraintValue(1.0)))
        })
        
        confirmRightButton.addTarget(self, action: #selector(passwordSecureButtonClick(_:)), for: .touchUpInside)
        passwordRightButton.addTarget(self, action: #selector(passwordSecureButtonClick(_:)), for: .touchUpInside)


    }
    
    /// 查看密码的按钮
    @objc func passwordSecureButtonClick(_ btn : UIButton) {
        
        btn.isSelected      = !btn.isSelected
        if btn.tag         == 100 {
            self.passwordTextField?.isSecureTextEntry        = !btn.isSelected
        } else {
            self.passwordConfirmTextField?.isSecureTextEntry = !btn.isSelected
        }
        
    }
    
    override func nextStepClick(_ btn: UIButton) {

        if (self.passwordTextField?.text?.isEmpty)! {
            UnitTools.addLabelInWindow("输入密码不能为空", vc:  self)
            return
        }
        
        if ((self.passwordTextField?.text?.length)! < 1) {
            UnitTools.addLabelInWindow("登录密码不能少于1位", vc: self)
            return
        }
        
        if self.passwordTextField?.text != self.passwordConfirmTextField?.text {
            UnitTools.addLabelInWindow("两次输入的密码不一致,请重新输入", vc: self)
            return
        }
        
        // 去完善资料的控制器
        let fullInfoViewController              = RegiserFullUserInfoViewController()
        fullInfoViewController.password         = (self.passwordTextField?.text)!
        fullInfoViewController.verifyCode       = self.verifyCode
        self.navigationController?.pushViewController(fullInfoViewController, animated: true)

    }

    
    deinit {
        NJLog(self)
    }
    
    
}
