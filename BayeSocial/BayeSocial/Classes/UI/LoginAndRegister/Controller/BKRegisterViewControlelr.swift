//
//  BKRegisterViewControlelr.swift
//  BayeStyle
//
//  Created by dzb on 2016/11/21.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON
import PKHUD

/// 用户注册的控制器
class BKRegisterViewControlelr : BKBaseLoginModuleViewController {

    var registerProtocolButton : UIButton?
    var checkBoxButton : UIButton?
    var mobileTextField : UITextField?
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
        
    }
    
    @objc func textDidChange() {
        var text = self.mobileTextField?.text
        if  (text?.length)! > 11 {
            text = text?.subString(to: 11)
            self.mobileTextField?.text = text
        }
    }
     func setup() {
        
        // 手机号输入框
        self.mobileTextField                            = UITextField()
        let placeholderAttribut                         = [NSAttributedStringKey.foregroundColor : UIColor.colorWithHexString("#C8C8C8"),NSAttributedStringKey.font : CYLayoutConstraintFont(16.0)]
        self.mobileTextField?.attributedPlaceholder     = NSAttributedString(string: "请输入手机号", attributes:placeholderAttribut)
        self.mobileTextField?.textAlignment             = .center
        self.mobileTextField?.borderStyle               = .none
        self.mobileTextField?.keyboardType              = .numberPad
        self.mobileTextField?.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        self.baseBackgroundView?.addSubview(self.mobileTextField!)
        self.mobileTextField?.snp.makeConstraints({[weak self] (make) in
            make.top.equalTo((self?.baseBackgroundView?.snp.top)!).offset(CYLayoutConstraintFontSize(128.0))
            make.centerX.equalTo((self?.baseBackgroundView)!)
            make.width.equalTo(CYLayoutConstraintValue(200.0))
        })
        
        // 横线
        let linView : UIView                            = UIView()
        linView.backgroundColor                  = UIColor.colorWithHexString("#E8E8E8")
        self.baseBackgroundView?.addSubview(linView)
        linView.snp.makeConstraints({[weak self]  (make) in
            make.top.equalTo((self?.mobileTextField?.snp.bottom)!).offset(CYLayoutConstraintValue(23.0))
            make.centerX.equalTo((self?.baseBackgroundView!)!)
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(240.0), height: CYLayoutConstraintValue(1.0)))
        })
        
        self.backActionButton?.isHidden             = false
        // 登录按钮标题
        self.nextStepButton?.setTitle("下一步", for: .normal)
        // checkBox
        self.checkBoxButton                         = UIButton(type: .custom)
        self.checkBoxButton?.setBackgroundImage(UIImage(named : "register_checkbox_nor"), for: .normal)
        self.checkBoxButton?.setBackgroundImage(UIImage(named : "register_checkbox_sel"), for: .selected)
        self.view.addSubview(self.checkBoxButton!)
        self.checkBoxButton?.snp.makeConstraints({[weak self] (make) in
            make.bottom.equalTo((self?.view.snp.bottom)!).offset(-CYLayoutConstraintValue(22.5))
            make.left.equalTo((self?.view.snp.left)!).offset(CYLayoutConstraintValue(105.5))
            make.size.equalTo(CGSize(width: CYLayoutConstraintValue(21.0), height: CYLayoutConstraintValue(21.0)))
        })
        
        // 查看注册协议按钮
        self.registerProtocolButton                         = UIButton(type: .custom)
        self.registerProtocolButton?.setTitle("《巴爷汇用户协议》", for: .normal)
        self.registerProtocolButton?.titleLabel?.font       = CYLayoutConstraintFont(15.0)
        self.registerProtocolButton?.setTitleColor(UIColor.colorWithHexString("#898989"), for: .normal)
        self.view.addSubview(self.registerProtocolButton!)
        self.registerProtocolButton?.snp.makeConstraints({[weak self] (make) in
            make.top.bottom.equalTo((self?.checkBoxButton!)!)
            make.left.equalTo((self?.checkBoxButton?.snp.right)!).offset(CYLayoutConstraintValue(3.0))
        })
        
        self.registerProtocolButton?.addTarget(self, action: #selector(registerSeeProtocolClick), for: .touchUpInside)
        self.checkBoxButton?.addTarget(self, action: #selector(checkBoxButtonClick), for: .touchUpInside)

    }
    
    /// 下一步点击事件
    override func nextStepClick(_ btn: UIButton) {

        self.mobileTextField?.resignFirstResponder()
        
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
        
        if self.checkBoxButton?.isSelected == false {
            UnitTools.addLabelInWindow("请同意巴爷汇用户协议", vc: self)
            return
        }
        
        BKCacheManager.shared.userRegisterMobile = self.mobileTextField?.text
        self.verifyCustomerUserIsExist((self.mobileTextField?.text)!)

    }
    
    /// 检查用户是否存在
    func verifyCustomerUserIsExist(_ moblie : String) {
        
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        BKNetworkManager.getReqeust(baseURLPath + "customers/search_customer", params: ["mobile" : moblie], success: {[weak self] (success) in
            
                HUD.hide(animated: true)
                let json                = success.value
                let return_code         = json["return_code"]?.int ?? 0
                let return_message      = json["return_message"]?.stringValue
                if return_code != 403 { // 用户存在 或者其他错误情况
                    UnitTools.addLabelInWindow(return_message!, vc: self)
                } else {
                    let verifyCodeViewController = BKRegisterVerifyCodeViewController()
                    self?.navigationController?.pushViewController(verifyCodeViewController, animated: true)
                }
            
            }) { (failure) in
                
                HUD.hide(animated: true)
                UnitTools.addLabelInWindow(failure.errorMsg, vc: self)
                
        }
        
        
    }
    
    /// 查看注册协议
    @objc func registerSeeProtocolClick(_ btn : UIButton) {
        
        let legalViewController : LegalViewController   = LegalViewController()
        let nav : BKNavigaitonController                = BKNavigaitonController(rootViewController: legalViewController)
        self.present(nav, animated: true, completion: nil)
        
    }
    
    /// checkbox 点击
    @objc func checkBoxButtonClick(_ btn : UIButton) {
        btn.isSelected      = !btn.isSelected
    }
    
    deinit {
        NJLog(self)
    }
    

}
