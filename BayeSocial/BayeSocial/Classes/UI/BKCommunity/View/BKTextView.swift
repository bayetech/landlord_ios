//
//  BKTextView.swift
//  Baye
//
//  Created by 董招兵 on 16/9/7.
//  Copyright © 2016年 上海巴爷科技有限公司. All rights reserved.
//

import UIKit

class BKTextView: UITextView {
    
    convenience init(text : String) {
        self.init()
        
        self.setup()
        
    }
    
    func setup() {
        
        self.addSubview(placeHoderLabel)
        placeHoderLabel.textColor       = self.placeholderColor
        placeHoderLabel.font            = placeholderFont
        placeHoderLabel.snp.makeConstraints { (make) in
            make.edges.equalTo(self.snp.edges).inset(UIEdgeInsetsMake(6.0, 2.0, 0.0, 0.0))
        }
        NotificationCenter.default.addObserver(self, selector: #selector(BKTextView.textDidChange(_:)), name: NSNotification.Name.UITextViewTextDidChange, object: self);
    }
    
    /// 占位文字颜色
    var placeholderColor = UIColor.black  {
        didSet {
            self.placeHoderLabel.textColor = placeholderColor
        }
    }
    
    /// 占位文字内容
    var placeholderString: String? {
        didSet {
            self.placeHoderLabel.text = placeholderString
        }
    }
    
    /// 占位文字大小
    var placeholderFont : UIFont = UIFont.systemFont(ofSize: 15.0) {
        didSet {
            self.placeHoderLabel.font = placeholderFont
        }
    }
    
    /// 占位文字的 label
    fileprivate lazy var placeHoderLabel : UILabel = {
        let label             = UILabel()
        return label
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
    }
    
    /**
     输入文字发生改变的通知
     */
    @objc func textDidChange(_ noti:Notification) {
        self.placeHoderLabel.isHidden = self.text.length != 0
    }

}


