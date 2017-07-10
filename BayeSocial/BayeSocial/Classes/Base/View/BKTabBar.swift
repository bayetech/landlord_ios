//
//  BKCustomTabBar.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/20.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

class BKTabBar: UITabBar {

    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

typealias BKNavBarBckAction = (_ navBar : BKNavigaitonBar) -> Void

/// 自定义 NavigationBar
class BKNavigaitonBar: UIView {
    
    public  var navTitle : String? {
        didSet {
            navTitleLabel?.text = navTitle
        }
    }
    private var navTitleLabel : UILabel?
    private var navBackButton : BKAdjustButton?
    public  var backAction : BKNavBarBckAction?
    class func shared() -> BKNavigaitonBar {
        return BKNavigaitonBar(frame:CGRect(x:0.0,y:0.0,width:KScreenWidth,height:64.0))
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        
        // 返回按钮
        navBackButton = BKAdjustButton(type: .custom)
        addSubview(navBackButton!)
        navBackButton?.setImage(UIImage(named : "back_white"), for: .normal)
        navBackButton?.frame = CGRect(x: CYLayoutConstraintValue(7.0), y: CYLayoutConstraintValue(30.0), width: CYLayoutConstraintValue(30.0), height: CYLayoutConstraintValue(23.0))
        navBackButton?.setImageViewSizeEqualToCenter(CGSize(width: CYLayoutConstraintValue(15.0), height: CYLayoutConstraintValue(23.0)))
        
        // 标题
        navTitleLabel                                           = UILabel()
        navTitleLabel?.textColor                                = UIColor.white
        navTitleLabel?.font                                     = CYLayoutConstraintFont(17.0)
        addSubview(navTitleLabel!)
        navTitleLabel?.snp.makeConstraints {[weak self] (make) in
            make.centerY.equalTo((self?.navBackButton)!)
            make.left.equalTo((self?.navBackButton?.snp.right)!)
        }
        
        navBackButton?.addTarget(self, action: #selector(back), for: .touchUpInside)
        navTitleLabel?.addTarget(self, action: #selector(back))
        
        
    }
    
    @objc private func back() {
        
        backAction?(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
}
