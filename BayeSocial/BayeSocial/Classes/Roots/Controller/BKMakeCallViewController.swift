//
//  BKMakeCallViewController.swift
//  BayeStyle
//
//  Created by dzb on 2016/12/2.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

protocol BKMakeCallViewControllerDelegate : NSObjectProtocol {
    /// 打招呼
    func makeCall(with msg : String)
}

/// 打招呼
class BKMakeCallViewController: BKBaseViewController {
    
    var numberLabel : UILabel?
    var delegate : BKMakeCallViewControllerDelegate?
    var textView : BKTextView       = BKTextView(text: "")
    var placeHolderString : String?
    var inputTextLength : Int       = 38 {
        didSet {
            numberLabel?.text = "\(inputTextLength)"
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor           = UIColor.RGBColor(243.0, green: 243.0, blue: 243.0)
        self.setRightBarbuttonItemWithTitles(["发送"], actions: [#selector(sendMsg)])
        
        // 标题
        let label                           = UILabel()
        label.text                          = "你需要发送验证申请，等待对方通过"
        label.textColor                     = UIColor.colorWithHexString("#777777")
        label.font                          = CYLayoutConstraintFont(13.0)
        self.view.addSubview(label)
        label.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo((self?.view.snp.top)!).offset(CYLayoutConstraintValue(80.0))
            make.left.equalTo((self?.view.snp.left)!).offset(CYLayoutConstraintValue(20.0))
        }
        
        let textbackgroundView              = UIView()
        textbackgroundView.backgroundColor  = UIColor.white
        self.view.addSubview(textbackgroundView)
        textbackgroundView.snp.makeConstraints {[weak self] (make) in
            make.top.equalTo(label.snp.bottom).offset(CYLayoutConstraintValue(10.0))
            make.left.right.equalTo((self?.view)!)
            make.height.equalTo(CYLayoutConstraintValue(100.0))
        }
        
        // 输入框
        textbackgroundView.addSubview(self.textView)
        textView.text                           = self.placeHolderString
        textView.placeholderFont                = CYLayoutConstraintFont(15.0)
        textView.font                           = CYLayoutConstraintFont(15.0)
        textView.delegate                       = self
        textView.backgroundColor                = UIColor.white
        textView.snp.makeConstraints { (make) in
           make.edges.equalTo(textbackgroundView).inset(UIEdgeInsetsMake(CYLayoutConstraintValue(10.0), CYLayoutConstraintValue(20.0), CYLayoutConstraintValue(30.0), CYLayoutConstraintValue(20.0)))
        }
        
        // 剩余输入文字数量
        numberLabel                        = UILabel()
        numberLabel?.textColor                   = UIColor.colorWithHexString("#777777")
        numberLabel?.font                        = CYLayoutConstraintFont(13.0)
        numberLabel?.text                        = "38"
        textbackgroundView.addSubview(numberLabel!)
        numberLabel?.snp.makeConstraints { (make) in
            make.bottom.equalTo(textbackgroundView.snp.bottom).offset(-CYLayoutConstraintValue(10.0))
            make.right.equalTo(textbackgroundView.snp.right).offset(-CYLayoutConstraintValue(15.0))
        }
        
        textViewDidChange(textView)
        
    }
    
    override func popToBack() {
        self.dismiss(animated: true, completion: nil)
    }
    
    /// 发送按钮
    func sendMsg() {
    
        view.endEditing(true)
        delegate?.makeCall(with: (self.textView.text)!)
        popToBack()
        
    }


}

//MARK: UITextViewDelegate
extension BKMakeCallViewController : UITextViewDelegate {
    
    
    func textViewDidChange(_ textView: UITextView) {
        
        var surplusLength       = 38
        let length              = textView.text.length
        surplusLength-=length
        if length > 38 {
            UnitTools.addLabelInWindow("打招呼内容不能超过38字", vc:  self)
            textView.text       = (textView.text as NSString).substring(to: 38)
            surplusLength       = 0
        }
        
        self.inputTextLength    = surplusLength
        
    }
    
    
}
