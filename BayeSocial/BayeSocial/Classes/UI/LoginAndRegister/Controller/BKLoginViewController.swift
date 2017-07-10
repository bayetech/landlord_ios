//
//  BKLoginViewController.swift
//  BayeStyle
//
//  Created by dzb on 2016/11/21.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD

/// 登录模块
class BKLoginViewController: BKBaseLoginModuleViewController {

    var mobileTextField : UITextField?
    var passwordTextField : UITextField?
    var lineView : UIView?
    var wechatBtn : UIButton?
    var forgetButton : UIButton?
    var registerButton : UIButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        
    }
    
    /// 输入发生了改变的事件
    func textChange() {
        var text = self.mobileTextField?.text
        if  (text?.length)! > 11 {
            text = text?.subString(to: 11)
            self.mobileTextField?.text = text
        }
       
    }
    
    /// 初始化 UI控件
    func setup() {
        

        HUD.dimsBackground                          = false
        HUD.allowsInteraction                       = false
        
        // 手机号码输入框
        self.mobileTextField                            = UITextField()
        let placeholderAttribut                         = [NSForegroundColorAttributeName : UIColor.colorWithHexString("#C8C8C8"),NSFontAttributeName : CYLayoutConstraintFont(16.0)]
        self.mobileTextField?.attributedPlaceholder     = NSAttributedString(string: "请输入手机号", attributes:placeholderAttribut)
        self.mobileTextField?.keyboardType              = .numberPad
        self.mobileTextField?.addTarget(self, action: #selector(textChange), for: .editingChanged)
        self.mobileTextField?.textAlignment             = .center
        self.mobileTextField?.borderStyle               = .none
        self.mobileTextField?.clearButtonMode           = .always
        self.baseBackgroundView?.addSubview(self.mobileTextField!)
        self.mobileTextField?.snp.makeConstraints({[weak self] (make) in
            make.top.equalTo((self?.baseBackgroundView?.snp.top)!).offset(CYLayoutConstraintFontSize(83.0))
            make.centerX.equalTo((self?.baseBackgroundView)!)
            make.width.equalTo(CYLayoutConstraintValue(200.0))
        })
        
        // 密码输入框
        self.passwordTextField                          = UITextField()
        self.passwordTextField?.attributedPlaceholder   = NSAttributedString(string: "输入密码", attributes:placeholderAttribut)
        self.passwordTextField?.textAlignment           = .center
        self.passwordTextField?.borderStyle             = .none
        self.baseBackgroundView?.addSubview(self.passwordTextField!)
        self.passwordTextField?.clearButtonMode         = .always
        self.passwordTextField?.isSecureTextEntry       = true
        self.passwordTextField?.snp.makeConstraints({[weak self] (make) in
            make.top.equalTo((self?.mobileTextField?.snp.bottom)!).offset(CYLayoutConstraintFontSize(28.0))
            make.centerX.equalTo((self?.baseBackgroundView)!)
            make.width.equalTo((self?.mobileTextField)!)
        })
        
        // 横线
        self.lineView                                   = UIView()
        self.lineView?.backgroundColor                  = UIColor.colorWithHexString("#E8E8E8")
        self.baseBackgroundView?.addSubview(self.lineView!)
        self.lineView?.snp.makeConstraints({[weak self]  (make) in
            make.top.equalTo((self?.passwordTextField?.snp.bottom)!).offset(CYLayoutConstraintValue(20.0))
            make.centerX.equalTo((self?.baseBackgroundView!)!)
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(240.0), height: CYLayoutConstraintValue(1.0)))
        })
        
        // 微信登录的按钮
        self.wechatBtn                                  = UIButton(type: .custom)
        self.wechatBtn?.setImage(UIImage(named : "login_wechat"), for: .normal)
        self.baseBackgroundView?.addSubview(self.wechatBtn!)
        self.wechatBtn?.snp.makeConstraints({[weak self]  (make) in
            make.top.equalTo((self?.lineView?.snp.bottom)!).offset(CYLayoutConstraintValue(15.5))
            make.centerX.equalTo((self?.baseBackgroundView)!)
        })
        
        // 忘记密码
        self.forgetButton                               = UIButton(type: .custom)
        self.forgetButton?.setTitle("忘记密码?", for: .normal)
        self.forgetButton?.setTitleColor(UIColor.colorWithHexString("#A2A398"), for: .normal)
        self.forgetButton?.titleLabel?.textAlignment    = .center
        self.forgetButton?.titleLabel?.font             = CYLayoutConstraintFont(13.0)
        self.baseBackgroundView?.addSubview(self.forgetButton!)
        self.forgetButton?.snp.makeConstraints({[weak self]  (make) in
            make.centerY.equalTo((self?.wechatBtn!)!)
            make.right.equalTo((self?.lineView?.snp.right)!)
        })
        
        // 登录按钮标题
        self.nextStepButton?.setTitle("登录", for: .normal)
        
        // 注册按钮
        self.registerButton                                = UIButton(type: .custom)
        self.registerButton?.setTitleColor(UIColor.black, for: .normal)
        self.registerButton?.setTitle("注册", for: .normal)
        self.registerButton?.titleLabel?.font              = CYLayoutConstraintFont(15.0)
        self.registerButton?.titleLabel?.textAlignment     = .center
        self.view.addSubview(self.registerButton!)
        self.registerButton?.snp.makeConstraints({[weak self] (make) in
            make.top.equalTo((self?.nextStepButton?.snp.bottom)!).offset(CYLayoutConstraintValue(32.0))
            make.centerX.equalTo((self?.baseBackgroundView)!)
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(50.0), height: CYLayoutConstraintValue(18.0)))
        })
        
        self.wechatBtn?.addTarget(self, action: #selector(wechatBtnClick), for: .touchUpInside)
        self.registerButton?.addTarget(self, action: #selector(registerBtnClick), for: .touchUpInside)
        self.forgetButton?.addTarget(self, action: #selector(forgetButtonClick), for: .touchUpInside)
        self.wechatBtn?.isHidden            = true
        
    }
    
    /// 登录按钮点击事件
    override func nextStepClick(_ btn: UIButton) {
        
        self.mobileTextField?.resignFirstResponder()
        self.passwordTextField?.resignFirstResponder()
        
        if (self.mobileTextField?.text?.isEmpty)! {
            UnitTools.addLabelInWindow("手机号码不能为空", vc: self)
            return
        }
        
        if (self.mobileTextField?.text?.length)! != 11 {
            UnitTools.addLabelInWindow("输入手机号码不合法", vc: self)
            return
        }
        // 验证手机号码
        if !(self.mobileTextField?.text?.isNumberValue())! {
            UnitTools.addLabelInWindow("输入手机号码不合法", vc: self)
            return
        }
        
        if (self.passwordTextField?.text?.isEmpty)! {
            UnitTools.addLabelInWindow("输入密码不能为空", vc: self)
            return
        }
        if ((self.passwordTextField?.text?.length)! < 1) {
            UnitTools.addLabelInWindow("登录密码不能少于1位", vc: self)
            return
        }
        
        userLogin(with: (self.mobileTextField?.text)!, password: (self.passwordTextField?.text!)!)
        
    }
    
    ///  请求用户登录的接口
    func userLogin(with mobile : String,password : String) {
        
        HUD.flash(.labeledRotatingImage(image: PKHUDAssets.progressCircularImage, title: nil, subtitle: "正在登录,请稍后..."), delay: 30.0)
        let parameters = ["username": mobile,"password": password, "device_token": UUID().uuidString]
        
        BKNetworkManager.postOperationReqeust(KURL_UserloginIn, params: parameters, success: {[weak self] (success) in
                let json            = JSON(success.value).dictionaryValue
                let session_id      = json["session_id"]
                if session_id != nil {
                    
                    let authorizationToken              = BKAuthorizationToken(by: json)
                    authorizationToken.userAccount      = mobile
                    // 存储用户登录授权信息
                    BKRealmManager.shared().insertLoginAuthorization(authorizationToken)
                    
                    // 登录环信
                    self?.loginEaseMob(authorizationToken)
                    
                } else {
                    
                    HUD.hide(animated: true)
                    
                    let notice = JSON(json["notice"]!).dictionaryObject
                    if let message = notice?["message"] {
                        UnitTools.addLabelInWindow(message as! String, vc: self)
                    } else {
                        UnitTools.addLabelInWindow("登录失败!", vc: self)
                    }
               
                }
            
            }) { (failure) in
                HUD.hide(animated: true)
                UnitTools.addLabelInWindow("网络请求失败", vc: self)
        }
        
        
    }
    
    /// 登录环信接口
    
    func loginEaseMob(_ authorizationToken : BKAuthorizationToken)  {
    
        EMIMHelper.shared().login(inEaseMob: authorizationToken) {[weak self] (aError) in
            NJLog(aError?.errorDescription)
            if aError == nil {
                
                UnitTools.delay(2.0, closure: {
                    HUD.hide(animated: true)
                    UnitTools.addLabelInWindow("登录成功!", vc: self)
                    AppDelegate.appDelegate().displayMainViewController()
                })
                
            } else {
                
                HUD.hide(animated: true)
                UnitTools.addLabelInWindow("登录失败, 请重试", vc: self)
            }
            
        }
        
    }

    /// 忘记密码
    func forgetButtonClick(_ sender: AnyObject) {
        
        let forgetPasswordViewController                = BKUpdatePasswordViewController()
        forgetPasswordViewController.title              = "忘记密码"
        forgetPasswordViewController.resetPasswordType  = .forget
        self.navigationController?.pushViewController(forgetPasswordViewController, animated: true)
        
    }
    
    /// 微信登录
    func wechatBtnClick(_ sender: UIButton) {
   
    }
    
    /// 注册
    func registerBtnClick(_ sender: UIButton) {
        
        let registerViewControlelr      = BKRegisterViewControlelr()
        self.navigationController?.pushViewController(registerViewControlelr, animated: true)
    
    }
    
     override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    
    deinit {
        NJLog(self)
    }
    

}
