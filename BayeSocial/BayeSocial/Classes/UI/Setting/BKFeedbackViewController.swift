//
//  BKFeedbackViewController.swift
//  BayeStyle
//
//  Created by dzb on 2016/11/23.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON

/// 意见反馈的控制器
class BKFeedbackViewController: BKBaseViewController {

    var textView : BKTextView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title   = "意见反馈"
        self.setup()
        
    }
    
    func setup() {
        
        self.view.backgroundColor               = UIColor.RGBColor(245.0, green: 245.0, blue: 245.0)
        
        let headView                            = UIImageView()
//        headView.image                          = UIImage(named: "feedback_background")
        self.view.addSubview(headView)
        headView.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.view.snp.top)!).offset(CYLayoutConstraintValue(59.0))
            make.left.right.equalTo((self?.view)!)
            make.height.equalTo(CYLayoutConstraintValue(30.0))
        }
        
        // 反馈内容输入区的背景图
        let feedBackView : UIView               = UIView()
        feedBackView.backgroundColor            = UIColor.white
        self.view.addSubview(feedBackView)
        feedBackView.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo(headView.snp.bottom)
            make.left.right.equalTo((self?.view)!)
            make.height.equalTo(CYLayoutConstraintValue(175.0))
        }
        
        // 写意见
        let writeIcon : UIImageView = UIImageView()
        writeIcon.image = UIImage(named: "edit_feedback")
        feedBackView.addSubview(writeIcon)
        writeIcon.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo(feedBackView.snp.top).offset(CYLayoutConstraintValue(11.0))
            make.left.equalTo((self?.view.snp.left)!).offset(CYLayoutConstraintValue(16.5))
        }
        
        // 输入框
        let textView : BKTextView               = BKTextView(text: "")
        textView.placeholderColor               = UIColor.colorWithHexString("#777777")
        textView.placeholderFont                = CYLayoutConstraintFont(14.0)
        textView.font                           = CYLayoutConstraintFont(14.0)
        textView.placeholderString              = "写下你的宝贵意见和建议"
        feedBackView.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.top.equalTo(feedBackView.snp.top).offset(CYLayoutConstraintValue(6.5))
            make.left.equalTo(writeIcon.snp.right)
            make.right.equalTo(feedBackView.snp.right).offset(-CYLayoutConstraintValue(20.0))
            make.bottom.equalTo(feedBackView.snp.bottom).offset(-CYLayoutConstraintValue(10.0))
        }
        
//        // 联系方式的 view
//        let contactWayView                      =  UIView()
//        contactWayView.backgroundColor          = UIColor.white
//        self.view.addSubview(contactWayView)
//        contactWayView.snp.makeConstraints {[weak self] (make) in
//            make.top.equalTo(feedBackView.snp.bottom).offset(CYLayoutConstraintValue(17.0))
//            make.left.right.equalTo((self?.view)!)
//            make.height.equalTo(CYLayoutConstraintValue(44.0))
//        }
        
//        //  联系方式的 icon
//        let contactWayIcon                      = UIImageView()
//        contactWayIcon.image                    = UIImage(named: "email_feedback")
//        contactWayView.addSubview(contactWayIcon)
//        contactWayIcon.snp.makeConstraints { (make) in
//            make.left.equalTo(contactWayView.snp.left).offset(CYLayoutConstraintValue(17.0))
//            make.centerY.equalTo(contactWayView)
//        }
//        
//        // 输入框
//        let textField                           = UITextField()
//        let attributeds                         = [NSFontAttributeName : CYLayoutConstraintFont(14.0),NSForegroundColorAttributeName : UIColor.colorWithHexString("#777777")]
//        textField.attributedPlaceholder         = NSAttributedString(string: "联系方式（邮箱／手机号）", attributes: attributeds)
//        textField.clearButtonMode               = .always
//        textField.borderStyle                   = .none
//        contactWayView.addSubview(textField)
//        textField.snp.makeConstraints { (make) in
//            make.centerY.equalTo(contactWayView).offset(CYLayoutConstraintValue(3.0))
//            make.left.equalTo(contactWayIcon.snp.right).offset(CYLayoutConstraintValue(5.0))
//            make.right.equalTo(contactWayView.snp.right).offset(-CYLayoutConstraintValue(10.0))
//        }
//        
        // 提交按钮
        let submitButton : UIButton             = UIButton(type: .custom)
        submitButton.setTitle("提交", for: .normal)
        submitButton.setTitleColor(UIColor.white, for: .normal)
        submitButton.titleLabel?.textAlignment  = .center
        submitButton.addTarget(self, action: #selector(subButtonClick), for: .touchUpInside)
        submitButton.backgroundColor            = UIColor.colorWithHexString("#18B091")
        self.view.addSubview(submitButton)
        submitButton.snp.makeConstraints {[weak self] (make) in
            make.bottom.equalTo((self?.view.snp.bottom)!)
            make.left.right.equalTo((self?.view)!)
            make.height.equalTo(CYLayoutConstraintValue(50.0))
        }
        
        
        self.textView                           = textView
//        self.textField                          = textField
        
        
    }
    
    /// 提交意见反馈的按钮
    func subButtonClick() {
        
        self.textView?.resignFirstResponder()
        self.textView?.resignFirstResponder()
        
        if (self.textView?.text.isEmpty)! {
            UnitTools.addLabelInWindow("意见和建议不能为空", vc: self)
            return
        }
//        if (self.textField?.text?.isEmpty)! {
//            UnitTools.addLabelInWindow("联系方式不能为空", vc: self)
//            return
//        }
        
//        let contact_information                 = self.textField?.text ?? ""
        let message : String                    = self.textView?.text ?? ""
        var parmas  : [String : String]         = [String : String]()
//        parmas["contact_information"]           = contact_information
        parmas["message"]                       = message
        
        BKNetworkManager.postOperationReqeust(baseURLPath + "opinions", params:parmas, success: {[weak self] (success) in
                let json                        = success.value
                let return_code                 = json["return_code"]?.int ?? 0
                let return_message              = json["return_message"]?.string ?? "修改手机登录密码失败"
                if return_code == 201 {
                    UnitTools.addLabelInWindow("提交成功", vc: self)
                    self?.navigationController?.popViewControllerAnimated(true, delay: 1.0)
                } else {
                    UnitTools.addLabelInWindow(return_message, vc: self)
                }
            
            }) {[weak self] (failure) in
                
                UnitTools.addLabelInWindow(failure.errorMsg, vc: self)
                
        }
        
    }

    deinit {
        NJLog(self)
    }
    
    
}
