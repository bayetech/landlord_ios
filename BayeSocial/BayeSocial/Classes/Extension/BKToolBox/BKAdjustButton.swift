//
//  BKAdjustButton.swift
//  Baye
//
//  Created by 董招兵 on 16/7/21.
//  Copyright © 2016年 Bayekeji. All rights reserved.
//

import UIKit

/// 一个可以调整 button imageView 和 titleLabel 任意位置的控件
class BKAdjustButton: UIButton {

    var textAlignment : NSTextAlignment = NSTextAlignment.left {
        didSet {
            self.titleLabel?.textAlignment = textAlignment
        }
    }
    
    var titleFont : UIFont = UIFont.systemFont(ofSize: 15.0) {
        didSet {
            self.titleLabel?.font = titleFont
        }
    }
    
    var titleLabelFrame : CGRect = CGRect(x: 0.0, y: 0.0, width: 10.0, height: 10.0) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var imageViewFrame : CGRect = CGRect(x: 10.0, y: 0.0, width: 10.0, height: 10.0) {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    var highLightEnable : Bool  = true {
        didSet {
            self.isHighlighted = highLightEnable
        }
    }
    
    /**
     等比例缩放图片 并居中显示图片
     */
    func setImageViewSizeEqualToCenter(_ size : CGSize) {
        self.imageViewFrame             = CGRect(x: (self.frame.size.width-size.width)/2,y: ( self.frame.size.height-size.height)/2, width: size.width, height: size.height);
        self.titleLabelFrame            = CGRect.zero
        self.setNeedsDisplay()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        self.imageView?.frame  = self.imageViewFrame
        self.titleLabel?.frame = self.titleLabelFrame
    }
    
    
}
