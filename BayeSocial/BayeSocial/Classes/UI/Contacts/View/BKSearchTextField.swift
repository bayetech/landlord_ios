//
//  BKSearchTextField.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/21.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

class BKSearchTextField: UITextField {

    convenience init(text : String) {
        self.init()
        self.setup()
        self.addLeftView()
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        self.setup()
        self.addLeftView()
    }
    
    override var placeholder : String? {
        didSet {
            guard placeholder != nil else {
                return
            }
            self.attributedPlaceholder          = NSAttributedString(string: placeholder!, attributes: [NSForegroundColorAttributeName:UIColor.colorWithHexString("#8E8E93"),NSFontAttributeName : CYLayoutConstraintFont(14.0)])
        }
    }
    
    func setup() {
     
        self.placeholder                    = "搜索"
        self.backgroundColor                = UIColor.colorWithHexString("#F3F3F3")
        
    }
    
    func addLeftView() {
        
        let leftButton                      = UIButton(type: .custom)
        leftButton.isUserInteractionEnabled = false
        leftButton.setImage(UIImage(named: "By_keyword_Search"), for: .normal)
        self.leftView                       = leftButton
        self.leftViewMode                   = .always
        self.setNeedsLayout()
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.layer.masksToBounds    = true
        self.layer.cornerRadius     = self.height * 0.5
        
        self.leftView?.frame        = CGRect(x: 0.0, y: 0.0, width: 33.0, height: self.height)
        
    }
    
}
