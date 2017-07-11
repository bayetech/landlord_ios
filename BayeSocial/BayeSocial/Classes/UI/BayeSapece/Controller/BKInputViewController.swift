//
//  BKInputViewController.swift
//  BayeStyle
//
//  Created by dzb on 2016/11/22.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

/// 修改资料的控制器

class BKInputViewController: UIViewController {

    var navTitle : String = "" {
        didSet {
            self.title = navTitle
        }
    }
    var content     : String?
    var indexPath   : IndexPath?
    var textField   : UITextField?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor                   = UIColor.RGBColor(245.0, green: 245.0, blue: 245.0)
        self.textField                              = UITextField()
        self.textField?.borderStyle                 = .none
        self.textField?.attributedText              = NSAttributedString(string: "", attributes: [NSAttributedStringKey.font : UIFont.systemFont(ofSize: 14.0),NSAttributedStringKey.foregroundColor : UIColor.colorWithHexString("#C8C8C8")])
        self.textField?.font                        = UIFont.systemFont(ofSize: 14.0)
        self.textField?.clearButtonMode             = .always
        self.textField?.backgroundColor             = UIColor.white
        self.view.addSubview(self.textField!)
        self.textField?.snp.makeConstraints({[weak self] (make) in
            make.top.equalTo((self?.view.snp.top)!).offset(CYLayoutConstraintValue(5.0))
            make.left.equalTo((self?.view.snp.left)!).offset(CYLayoutConstraintValue(10.0))
            make.right.equalTo((self?.view.snp.right)!).offset(-CYLayoutConstraintValue(10.0))
        })
        
        
    }

    
}
