//
//  BKUserAccountModule.swift
//  BayeStyle
//
//  Created by dzb on 2016/11/23.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import Foundation
import SwiftyJSON
import PKHUD

/// 显示当前绑定手机号码的控制器
class BKDispalayCurrentMobileViewController : BKBaseViewController {
    
    var mobile : String = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title                                  = "绑定手机号"
        // 标题
        let titleLabel                              = UILabel()
        titleLabel.text                             = "当前手机号"
        titleLabel.font                             = CYLayoutConstraintFont(16.0)
        titleLabel.textAlignment                    = .center
        titleLabel.textColor                        = UIColor.colorWithHexString("#777777")
        self.view.addSubview(titleLabel)
        titleLabel.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.view.snp.top)!).offset(CYLayoutConstraintValue(87.0))
            make.centerX.equalTo((self?.view)!)
        }
        
        // 输入框
        let textField                               = UITextField()
        textField.borderStyle                       = .none
        textField.text                              = mobile
        textField.textAlignment                     = .center
        textField.isUserInteractionEnabled          = false
        self.view.addSubview(textField)
        textField.snp.makeConstraints({[weak self] (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(CYLayoutConstraintValue(15.0))
            make.left.equalTo((self?.view.snp.left)!)
            make.right.equalTo((self?.view.snp.right)!)
        })
        
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
        // 更换号码button
        let changeButton                          = UIButton(type: .custom)
        changeButton.setTitle("更换号码", for: .normal)
        changeButton.setTitleColor(UIColor.white, for: .normal)
        changeButton.titleLabel?.font             = CYLayoutConstraintFont(19.0)
        changeButton.titleLabel?.textAlignment    = .center
        changeButton.backgroundColor              = UIColor.colorWithHexString("#18B091")
        changeButton.setCornerRadius(4.0)
        changeButton.addTarget(self, action: #selector(changeMobileClick), for: .touchUpInside)
        self.view.addSubview(changeButton)
        changeButton.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo(lineView.snp.bottom).offset(CYLayoutConstraintValue(31.5))
            make.left.equalTo((self?.view.snp.left)!).offset(CYLayoutConstraintValue(20.0))
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(335.0), height: CYLayoutConstraintValue(44.0)))
        }
    
    }
    
    /// 更换手机号码
    func changeMobileClick() {
        let bindingViewController       = BKBindingMobileViewController()
        self.navigationController?.pushViewController(bindingViewController, animated: true)
    }
    
}

//MARK: 用户更换绑定手机号码模块

/// 用户绑定手机号码控制器
class BKBindingMobileViewController: BKBaseViewController {
    var timer : Timer?
    var timeOut : Int = 120
    var textFields : [UITextField] = [UITextField]()
    var sendVerifyCodeButton : UIButton?
    
    /// 姓名输入框内容发送了改变
    func textDidChange(_ textField : UITextField) {
        let num = textField.tag == 100 ? 11 : 6
        var text = textField.text
        if (text?.length)! > num {
            text = text?.subString(to: num)
        }
        textField.text = text
    }
    
    /// 取消
    func cancelClick() {
        
        let _ = YepAlertKit.showAlertView(in: self, title: nil, message: "你确定要取消本次绑定？", titles: nil, cancelTitle: "取消", destructive: "确定") {[weak self]  (index) in
            if index == 1000 {
                let _ = self?.navigationController?.popToRootViewController(animated: true)
            }
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setRightBarbuttonItemWithTitles(["取消"], actions: [#selector(cancelClick)])
        let placeHolders  : [String]                = [
            "绑定手机号",
            "输入验证码"
        ]
    
        self.automaticallyAdjustsScrollViewInsets   = true
        let placeAttributes : [String : AnyObject]  = [NSFontAttributeName : CYLayoutConstraintFont(17.0),NSForegroundColorAttributeName : UIColor.colorWithHexString("#898989")]
        weak var lastLineView : UIView?
        for i in 0..<2 {
            
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
            textField.keyboardType                    = .numberPad
            textFields.append(textField)
            textField.addTarget(self, action: #selector(textDidChange(_:)), for: .editingChanged)
            
            // 发送验证码按钮
            if i != 0 {
                
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
    
    /// 完成按钮点击事件
    func finishedButtonClick() {
        
        if !mobileVerify() {
            return
        }
        
        let code : String   = self.textFields[1].text!
        guard !code.isEmpty else {
            UnitTools.addLabelInWindow("验证码不能为空", vc: self)
            return
        }
        guard code.isNumberValue() else {
            UnitTools.addLabelInWindow("验证码无效", vc: self)
            return
        }
        
        self.isValidVerifyCode(code)
        
    }
    // 检查手机号输入格式
    func mobileVerify() -> Bool {
        
        let mobile      = self.textFields[0].text
        guard !(mobile?.isEmpty)! else {
            UnitTools.addLabelInWindow("手机号格式有误", vc: self)
            return false
        }
        guard (mobile?.isNumberValue())! else {
            UnitTools.addLabelInWindow("手机号格式有误", vc: self)
            return false
        }
        return true
    }
    
    /// 发送验证码
    func sendVerifyCodeAction(_ btn : UIButton) {
        
        self.hiddenKeyboard()
        
        if !mobileVerify() {
            return
        }
        let mobile                          = self.textFields[0].text
        btn.isUserInteractionEnabled        = false
        btn.isSelected                      = true
        self.sendVerfiyCode(mobile ?? "")
        
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.invalidateTimer()
    }
    
    /// 用户更换手机号码
    func  userChageMobile() {
    
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        let mobile   : String               = (self.textFields[0].text)!
        let verify_code : String            = (self.textFields[1].text)!
        var params : [String : String]      = [String : String]()
        params["mobile"]                    = mobile
        params["verify_code"]               = verify_code
        
        BKNetworkManager.patchOperationReqeust(baseURLPath + "customers/mobile", params: params, success: {[weak self] (success) in
            HUD.hide(animated: true)
            let json                        = success.value
            let return_code                 = json["return_code"]?.int ?? 0
            let return_message              = json["return_message"]?.string ?? "修改手机号失败"
            if return_code == 200 {
                UnitTools.addLabelInWindow("修改手机号码成功", vc: self)
                UnitTools.delay(1.0) {
                    BKCacheManager.shared.clearUserCache()
                    BKNetworkManager.showLoginView()
                }
            } else {
                UnitTools.addLabelInWindow(return_message, vc: self)
            }
            
            }) {[weak self] (failure) in
                HUD.hide(animated: true)
                UnitTools.addLabelInWindow(failure.errorMsg, vc: self)
        }
        
        
    }
    
    deinit {
        NJLog(self)
    }
    
}

// MARK: - 发送验证码
extension BKBindingMobileViewController {
    
    
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
    func updateTime() {
        
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
    func isValidVerifyCode(_ code : String) {
        
        guard !code.isEmpty else {
            UnitTools.addLabelInWindow("验证码无效", vc: self)
            return
        }
        guard code.isNumberValue() else {
            UnitTools.addLabelInWindow("验证码无效", vc: self)
            return
        }
        
        let mobile   : String               =  BKCacheManager.shared.userRegisterMobile ?? ""
        let params   : [String : String]    = ["mobile" : mobile,"verify_code" :code]
        BKNetworkManager.postOperationReqeust(baseURLPath + "verifications/validate", params: params, success: {[weak self] (success) in
            
            let json                        = success.value
            let return_code : Int           = json["return_code"]?.intValue ?? 0
            let return_message : String     = json["return_message"]?.string ?? "验证码无效"
            if return_code != 200 {
                UnitTools.addLabelInWindow(return_message, vc: self)
            } else {
                self?.userChageMobile()
            }
            
        }) { (failure) in
            UnitTools.addLabelInWindow("网络错误", vc: self)
        }
        
    }
    
    /// 获取验证码
    func sendVerfiyCode(_ mobile : String) {
        
        weak var weakSelf           = self
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        let parameters              = ["mobile": mobile, "exist" : false] as [String : Any]
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

//MARK: 账号信息的控制器
/// 账号信息的控制器
class BKAccountViewController : BKBaseTableViewController {
    var dataArray : [[String : String]] = [[String : String]]()
    var mobile : String = "" {
        didSet {
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title                                  = "账号信息"
        self.dataArray                              = [
            ["title" : "手机号","subTitle" :mobile],
            ["title" : "修改登录密码","subTitle" :""]
        ]

        self.tableView.reloadData()
        
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataArray.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell                                = tableView.dequeueReusableCell(withIdentifier: "Cell")
        if cell == nil {
            cell                                = UITableViewCell(style: .value1, reuseIdentifier: "Cell")
            cell?.selectionStyle                = .none
            cell?.accessoryType                 = .disclosureIndicator
        }
        let dict                                = self.dataArray[indexPath.row]
        cell?.textLabel?.text                   = dict["title"]
        cell?.detailTextLabel?.text             = dict["subTitle"]
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return CYLayoutConstraintValue(17.5)
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.row == 0 {
            // 更换绑定手机号码
            let displayMobileViewController         = BKDispalayCurrentMobileViewController()
            displayMobileViewController.mobile      = self.dataArray[indexPath.row]["subTitle"] ?? ""
            self.navigationController?.pushViewController(displayMobileViewController, animated: true)
            
        } else {
            // 修改密码
            let updatePasswordViewController = BKUpdatePasswordViewController()
            updatePasswordViewController.resetPasswordType = .update
            self.navigationController?.pushViewController(updatePasswordViewController, animated: true)
            
        }
    }
    
}

