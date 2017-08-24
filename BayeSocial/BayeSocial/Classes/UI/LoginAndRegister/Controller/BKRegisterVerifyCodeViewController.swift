//
//  BKRegisterVerifyCodeViewController.swift
//  BayeStyle
//
//  Created by dzb on 2016/11/21.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD

/// 注册输入验证码的控制器
class BKRegisterVerifyCodeViewController: BKBaseLoginModuleViewController {

    var verifyCodeTextField : UITextField?
    var verifyCodeButton : UIButton?
    var timer : Timer?
    var timeOut : Int = 120
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.invalidateTimer()
        
    }
    
    func setup() {
        
        // 手机号输入框
        self.verifyCodeTextField                                = UITextField()
        let placeholderAttribut                                 = [NSAttributedStringKey.foregroundColor : UIColor.colorWithHexString("#C8C8C8"),NSAttributedStringKey.font : CYLayoutConstraintFont(16.0)]
        self.verifyCodeTextField?.attributedPlaceholder         = NSAttributedString(string: "请输入验证码", attributes:placeholderAttribut)
        self.verifyCodeTextField?.textAlignment                 = .left
        self.verifyCodeTextField?.borderStyle                   = .none
        self.baseBackgroundView?.addSubview(self.verifyCodeTextField!)
        self.verifyCodeTextField?.keyboardType                  = .numberPad
        self.verifyCodeTextField?.snp.makeConstraints({[weak self] (make) in
            make.top.equalTo((self?.baseBackgroundView?.snp.top)!).offset(CYLayoutConstraintFontSize(128.0))
            make.left.equalTo((self?.baseBackgroundView?.snp.left)!).offset(CYLayoutConstraintValue(30.0))
            make.width.equalTo(CYLayoutConstraintValue(120.0))
        })
        
        // 横线
        let linView : UIView                                    = UIView()
        linView.backgroundColor                                 = UIColor.colorWithHexString("#E8E8E8")
        self.baseBackgroundView?.addSubview(linView)
        linView.snp.makeConstraints({[weak self]  (make) in
            make.top.equalTo((self?.verifyCodeTextField?.snp.bottom)!).offset(CYLayoutConstraintValue(23.0))
            make.centerX.equalTo((self?.baseBackgroundView!)!)
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(240.0), height: CYLayoutConstraintValue(1.0)))
        })
        
        self.backActionButton?.isHidden                         = false
        // 登录按钮标题
        self.nextStepButton?.setTitle("下一步", for: .normal)

        // 获取验证码的按钮
        self.verifyCodeButton                                   = UIButton(type: .custom)
        self.verifyCodeButton?.setTitleColor(UIColor.white, for: .normal)
        self.verifyCodeButton?.setTitle("获取验证码", for: .normal)
        self.verifyCodeButton?.titleLabel?.font                 = CYLayoutConstraintFont(14.0)
        self.verifyCodeButton?.setBackgroundColor(backgroundColor: UIColor.black, forState: .normal)
        self.verifyCodeButton?.setBackgroundColor(backgroundColor: UIColor.colorWithHexString("#A1A1A1"), forState: .selected)

        self.verifyCodeButton?.titleLabel?.textAlignment        = .center
        self.verifyCodeButton?.setCornerRadius(CYLayoutConstraintValue(18.75))
        self.view.addSubview(self.verifyCodeButton!)
        self.verifyCodeButton?.snp.makeConstraints({[weak self] (make) in
            make.right.equalTo(linView.snp.right)
            make.centerY.equalTo((self?.verifyCodeTextField)!)
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(87.5), height: CYLayoutConstraintValue(37.5)))
        })
        
        
        self.verifyCodeButton?.addTarget(self, action: #selector(getVerifyCode), for: .touchUpInside)

    }
    
    /// 下一步点击事件
    override func nextStepClick(_ btn: UIButton) {
        self.isValidVerifyCode((self.verifyCodeTextField?.text)!)
    }
    
    deinit {
        NJLog(self)
    }
    
}

// MARK: - GetVerifyCode 获取验证码
extension BKRegisterVerifyCodeViewController  {
    
    
    /// 获取短信验证码
    @objc func getVerifyCode(_ btn : UIButton) {
        
        btn.isSelected                          = true
        btn.isUserInteractionEnabled            = false
        
        self.sendVerfiyCode(BKCacheManager.shared.userRegisterMobile ?? "")
        
    }
    
    /// 获得验证码失败
    func sendVerifyCodeFailure() {
        
        self.verifyCodeButton?.setTitle("获取验证码", for: .normal)
        self.verifyCodeButton?.isUserInteractionEnabled = true
        self.verifyCodeButton?.isSelected               = false
        self.timeOut = 120
        
    }
    
    /// 开启定时器
    func startTimer() {
        
        guard self.timer == nil else {
            self.invalidateTimer()
            return
        }
        
        self.timer = Timer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        self.timer?.fire()
        RunLoop.current.add(self.timer!, forMode:.defaultRunLoopMode)
        
    }
    
    /// 更新倒计时提示语
    @objc func updateTime() {
        
        if self.timeOut <= 0 {
            self.invalidateTimer()
            self.sendVerifyCodeFailure()
            return
        }
        self.verifyCodeButton?.setTitle("\(self.timeOut)s后获取", for: .normal)
        self.timeOut-=1
        
    }
    /// 销毁定时器
    func invalidateTimer() {
        self.timer?.invalidate()
        self.timer  = nil
    }
    
    /// 检查验证码是否有效
    func isValidVerifyCode(_ code : String) {
        
        guard !code.isEmpty else {
            UnitTools.addLabelInWindow("验证码无效", vc: self)
            return
        }
        guard code.isNumberValue() else {
            UnitTools.addLabelInWindow("验证码无效", vc: self)
            return
        }
        
        let mobile   : String               = BKCacheManager.shared.userRegisterMobile ?? ""
        let params   : [String : String]    = ["mobile" : mobile,"verify_code" :code]
        
        BKNetworkManager.postOperationReqeust(baseURLPath + "verifications/validate", params: params, success: {[weak self] (success) in
            
                let json                        = success.value
                let return_code : Int           = json["return_code"]?.intValue ?? 0
                let return_message : String     = json["return_message"]?.string ?? "验证码无效"
                if return_code != 200 {
                    UnitTools.addLabelInWindow(return_message, vc: self)
                } else {
                    let passwordViewController              = RegisertPasswordViewController()
                    passwordViewController.verifyCode       = code
                    self?.navigationController?.pushViewController(passwordViewController, animated: true)
                }
            
            }) { (failure) in
                UnitTools.addLabelInWindow("网络错误", vc: self)
        }
        
    }
    
    
    /// 获取验证码
    func sendVerfiyCode(_ mobile : String) {
        
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)

        let parameters              = ["mobile": mobile, "exist":false] as [String : Any]
        
        BKNetworkManager.postOperationReqeust(baseURLPath + "verifications", params: parameters, success: {[weak self] (success) in
            HUD.hide(animated: true)
            let json                        = success.value
            let notice                      = json["notice"]?.dictionaryValue
            guard notice != nil else {
                UnitTools.addLabelInWindow("获取验证码失败", vc: self)
                self?.sendVerifyCodeFailure()
                return
            }
            let code                    = notice!["code"]?.intValue ?? 0
            let msg                     = notice!["message"]?.string ?? "获取验证码失败"
            guard code == 201 else {
                UnitTools.addLabelInWindow(msg, vc: self)
                self?.sendVerifyCodeFailure()
                return
            }
            
            UnitTools.addLabelInWindow("验证码已发送到你手机,请注意查收", vc: self)
            self?.startTimer()
            
        }) { (filure) in
            HUD.hide(animated: true)
            UnitTools.addLabelInWindow("获取验证码失败", vc: self)
        }
        
    }

    
}
