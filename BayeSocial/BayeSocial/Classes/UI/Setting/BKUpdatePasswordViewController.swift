//
//  BKUpdatePasswordViewController.swift
//  BayeStyle
//
//  Created by dzb on 2016/11/23.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD

/// 更改密码的类型
///
/// - update: 修改密码
/// - forget: 忘记密码
enum UpdatePasswordType {
    case update
    case forget
}

/// 修改登录密码
class BKUpdatePasswordViewController: BKBaseViewController {

    var textFields : [UITextField] = [UITextField]()
    var sendVerifyCodeButton : UIButton?
    var timer : Timer?
    var timeOut : Int = 120
    var resetPasswordType : UpdatePasswordType = .update
    /// 取消按钮
    @objc func cancelClick() {
       let _ = self.navigationController?.popToRootViewController(animated: true)
    }
    
    /// 姓名输入框内容发送了改变
    @objc func textDidChange(_ textField : UITextField) {
        let num = textField.tag == 100 ? 11 : 6
        var text = textField.text
        if (text?.length)! > num {
            text = text?.subString(to: num)
        }
        textField.text = text
    }
   
     override func viewDidLoad() {
        super.viewDidLoad()
        self.title  = "修改登录密码"
        
        self.setRightBarbuttonItemWithTitles(["取消"], actions: [#selector(cancelClick)])
        let placeHolders  : [String]                = [
            "输入手机号",
            "输入验证码",
            "输入新密码",
            "再次输入新密码"
        ]
        
        self.automaticallyAdjustsScrollViewInsets   = true
        let placeAttributes : [NSAttributedStringKey : Any]  = [NSAttributedStringKey.font : CYLayoutConstraintFont(17.0),NSAttributedStringKey.foregroundColor : UIColor.colorWithHexString("#898989")]
        weak var lastLineView : UIView?
        for i in 0..<placeHolders.count {
            
            let textField                           = UITextField()
            textField.borderStyle                   = .none
            self.view.addSubview(textField)
            textField.attributedPlaceholder         = NSAttributedString(string: placeHolders[i], attributes: placeAttributes)
            textField.tag                           = i+100
            textField.snp.makeConstraints({[weak self] (make) in
                if lastLineView != nil {
                    make.top.equalTo((lastLineView?.snp.bottom)!).offset(CYLayoutConstraintValue(36.0))
                } else {
                    make.top.equalTo((self?.view.snp.top)!).offset(CYLayoutConstraintValue(107.0))
                }
                make.left.equalTo((self?.view.snp.left)!).offset(CYLayoutConstraintValue(33.0))
                make.right.equalTo((self?.view.snp.right)!).offset(-CYLayoutConstraintValue(16.5))
            })
           
            textFields.append(textField)
            // 发送验证码按钮
            if i == 1 {
                
                let verifyButton                        = UIButton(type: .custom)
                verifyButton.setTitle("发送验证码", for: .normal)
                verifyButton.setTitleColor(UIColor.colorWithHexString("#898989"), for: .selected)
                verifyButton.titleLabel?.textAlignment  = .center
                verifyButton.addTarget(self, action: #selector(sendVerifyCodeAction(_:)), for: .touchUpInside)
                verifyButton.frame                      = CGRect(x: 0.0, y: 0.0, width: CYLayoutConstraintFontSize(105.0), height: CYLayoutConstraintFontSize(22.5))
                verifyButton.setTitleColor(UIColor.colorWithHexString("#18B091"), for: .normal)
                textField.rightView                     = verifyButton
                textField.rightViewMode                 = .always
                self.sendVerifyCodeButton               = verifyButton
                
            }
            
            if i<2 {
                textField.keyboardType                     = .numberPad
                textField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
            } else {
                textField.isSecureTextEntry                = true
            }
            
            // 横线
            let lineView : UIView                       = UIView()
            lineView.backgroundColor                    = UIColor.colorWithHexString("#D9D9D9")
            self.view.addSubview(lineView)
            lineView.snp.makeConstraints({[weak self] (make) in
                make.top.equalTo(textField.snp.bottom).offset(CYLayoutConstraintValue(18.0))
                make.left.equalTo((self?.view.snp.left)!).offset(CYLayoutConstraintValue(10.0))
                make.right.equalTo((self?.view.snp.right)!).offset(-CYLayoutConstraintValue(10.0))
                make.height.equalTo(0.5)
            })
            
            lastLineView                            = lineView
        }
        
        // 完成按钮
        let finishedButton                          = UIButton(type: .custom)
        finishedButton.setTitle("完成", for: .normal)
        finishedButton.setTitleColor(UIColor.white, for: .normal)
        finishedButton.titleLabel?.font             = CYLayoutConstraintFont(19.0)
        finishedButton.titleLabel?.textAlignment    = .center
        finishedButton.backgroundColor              = UIColor.colorWithHexString("#18B091")
        finishedButton.setCornerRadius(4.0)
        finishedButton.addTarget(self, action: #selector(finishedButtonClick), for: .touchUpInside)
        self.view.addSubview(finishedButton)
        finishedButton.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((lastLineView?.snp.bottom)!).offset(CYLayoutConstraintValue(34.0))
            make.left.equalTo((self?.view.snp.left)!).offset(CYLayoutConstraintValue(20.0))
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(335.0), height: CYLayoutConstraintValue(44.0)))
        }
        

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
    }
    
    /// 完成按钮
    @objc func finishedButtonClick() {
        
        let verifyCode          = self.textFields[1].text ?? ""
        let mobile              = self.textFields[0].text ?? ""
        guard mobileVerify(mobile) else {
            return
        }
        guard verifyCodeValid(verifyCode) else {
            return
        }
        guard verifyPasswordValid(self.textFields[2].text ?? "", confirmPassword: self.textFields[3].text ?? "") else {
            return
        }
        
        self.isValidVerifyCode(verifyCode, mobile: mobile)
        
    }
    
    /// 忘记密码
    func forgetPassword() {
        
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        BKNetworkManager.putReqeust(baseURLPath + "users/reset_password", params: self.getRequstParams(), success: {[weak self] (success) in
            HUD.hide(animated: true)
            let json                        = success.value
            let notice = json["notice"]?.dictionary
            guard notice != nil else{
                UnitTools.addLabelInWindow("重置密码失败", vc: self)
                return
            }
            let code = notice?["code"]?.int ?? 0
            if code != 201 {
                let msg = notice?["message"]?.string ?? "重置密码失败"
                UnitTools.addLabelInWindow(msg, vc: self)
            } else {
                UnitTools.addLabelInWindow("修改手机登录密码成功", vc: self)
                UnitTools.delay(1.0) {
                    BKCacheManager.shared.clearUserCache()
                    let _ = self?.navigationController?.popToRootViewController(animated: true)
                }
            }
            
         }) { (failure) in
            HUD.hide(animated: true)
        }
        
    }
    
    /// 拼接请求参数
    func getRequstParams() -> [String : String] {
        
        let mobile : String                 = self.textFields[0].text ?? ""
        let verify_code : String            = self.textFields[1].text ?? ""
        let password : String               = self.textFields[2].text ?? ""
        let confirm_password : String       = self.textFields[3].text ?? ""
        var params                          = ["verify_code": verify_code, "password": password,"mobile" : mobile]
        if self.resetPasswordType == .update {
            params["confirm_password"]      = confirm_password
        }
        
        return params
        
    }
    
    /// 更新用户密码
    func updateUserPassword() {
      
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        BKNetworkManager.patchOperationReqeust(baseURLPath + "customers/password", params:self.getRequstParams(), success: { (result) in
            HUD.hide(animated: true)
            let json                        = result.value
            let return_code                 = json["return_code"]?.int ?? 0
            let return_message              = json["return_message"]?.string ?? "修改手机登录密码失败"
            if return_code == 200 {
                UnitTools.addLabelInWindow("修改手机登录密码成功", vc: self)
                UnitTools.delay(1.0) {
                   BKCacheManager.shared.clearUserCache()
                   let _ = self.navigationController?.popToRootViewController(animated: true)
                }
            } else {
                UnitTools.addLabelInWindow(return_message, vc: self)
            }
            
        }) { (error) in
            HUD.hide(animated: true)
        }
    
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.invalidateTimer()
    }
    
    /// 检查手机号码输入格式
    func mobileVerify(_ mobile : String) -> Bool {
        guard !mobile.isEmpty else {
            UnitTools.addLabelInWindow("手机号格式有误", vc: self)
            return false
        }
        guard mobile.isNumberValue() else {
            UnitTools.addLabelInWindow("手机号格式有误", vc: self)
            return false
        }
        return true
    }
    
    /// 验证码是否输入合法
    func verifyCodeValid(_ code : String) -> Bool {
        
        guard !code.isEmpty else {
            UnitTools.addLabelInWindow("验证码不能为空", vc: self)
            return false
        }
        guard code.isNumberValue() else {
            UnitTools.addLabelInWindow("验证码格式有误", vc: self)
            return false
        }
        
        return true
    }
    
    /// 检查密码输入是否合法
    func verifyPasswordValid(_ password : String,confirmPassword : String) -> Bool {
        
        guard !password.isEmpty else {
            UnitTools.addLabelInWindow("新密码不能为空", vc: self)
            return false
        }
        
        guard password.length >= 1 else {
            UnitTools.addLabelInWindow("新密码长度不能少于1位", vc: self)
            return false
        }
        
        guard password == confirmPassword else {
            UnitTools.addLabelInWindow("两次密码输入不一致,请检查", vc: self)
            return false
        }
        
        return true
    }

}

// MARK: - 验证码模块
extension BKUpdatePasswordViewController {
    
    @objc func sendVerifyCodeAction(_ btn : UIButton) {
    
        self.hiddenKeyboard()
        let mobile                          = self.textFields[0].text ?? ""
        if !mobileVerify(mobile) {
            return
        }
        
        btn.isUserInteractionEnabled        = false
        btn.isSelected                      = true
        self.sendVerfiyCode(mobile)
    }
    
    
    /// 获得验证码失败
    func sendVerifyCodeFailure() {
        self.sendVerifyCodeButton?.setTitle("获取验证码", for: .normal)
        self.sendVerifyCodeButton?.isUserInteractionEnabled = true
        self.sendVerifyCodeButton?.isSelected               = false
        self.timeOut                                        = 120
    }
    /// 开启定时器
    func startTimer() {
        
        guard self.timer == nil else {
            self.invalidateTimer()
            return
        }
        
        let timer               = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTime), userInfo: nil, repeats: true)
        timer.fire()
        RunLoop.main.add(timer, forMode: .defaultRunLoopMode)
        self.timer              = timer
        
    }
    
    /// 更新倒计时提示语
    @objc func updateTime() {
        
        if self.timeOut <= 0 {
            self.invalidateTimer()
            self.sendVerifyCodeFailure()
            return
        }
        self.sendVerifyCodeButton?.setTitle("\(self.timeOut)s后获取", for: .normal)
        self.timeOut-=1
        
    }
    /// 销毁定时器
    func invalidateTimer() {
        if self.timer != nil {
            self.timer!.invalidate()
            self.timer  = nil
        }
    }
    
    func hiddenKeyboard() {
        for tf in textFields {
            let _ = tf.resignFirstResponder()
        }
    }
    /// 检查验证码是否有效
    func isValidVerifyCode(_ code : String ,mobile : String) {
        
        let params   : [String : String]    = ["mobile" : mobile,"verify_code" :code]
        
        BKNetworkManager.postOperationReqeust(baseURLPath + "verifications/validate", params: params, success: {[weak self] (success) in
            
            let json                        = success.value
            let return_code : Int           = json["return_code"]?.intValue ?? 0
            let return_message : String     = json["return_message"]?.string ?? "验证码无效"
            if return_code != 200 {
                UnitTools.addLabelInWindow(return_message, vc: self)
            } else {
                
                let _ = YepAlertKit.showAlertView(in: self!, title: nil, message: "你的密码即将更新，请确认！", titles: nil, cancelTitle: "取消", destructive: "确定", callBack: { (index) in
                    if index == 1000 {
                        if self?.resetPasswordType == .update {
                            self?.updateUserPassword()
                        } else {
                            self?.forgetPassword()
                        }
                    }
                })
            }
            
        }) { (failure) in
            UnitTools.addLabelInWindow("网络错误", vc: self)
        }
        
    }
    
    /// 获取验证码
    func sendVerfiyCode(_ mobile : String) {
        
        weak var weakSelf           = self
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        let parameters              = ["mobile": mobile, "exist" : true] as [String : Any]
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
                UnitTools.addLabelInWindow(msg, vc: weakSelf)
                weakSelf?.sendVerifyCodeFailure()
                return
            }
            
            UnitTools.addLabelInWindow("验证码已发送到你手机,请注意查收", vc: weakSelf)
            weakSelf?.startTimer()
            
        }) { (filure) in
            
            HUD.hide(animated: true)
            UnitTools.addLabelInWindow("获取验证码失败", vc: weakSelf)
            
        }
        
    }

    
}
