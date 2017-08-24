//
//  CYLayoutConstraint.swift
//  Baye
//
//  Created by 董招兵 on 16/7/20.
//  Copyright © 2016年 Bayekeji. All rights reserved.
//

import Foundation

/**
 传入一个约束值 获取不同屏幕下的约束
 */
func CYLayoutConstraintValue(_ value : CGFloat) -> CGFloat {
    return CYLayoutConstraint.shareInstance.getCurrentLayoutContraintValue(value);
}

/**
 获取一个自适应字体
 */
func CYLayoutConstraintFont(_ fontSize : CGFloat) -> UIFont {
    return CYLayoutConstraint.shareInstance.getLayoutContraintFont(fontSize);
}

/**
 获取一个自适应字体的大小
 */
func CYLayoutConstraintFontSize(_ fontSize : CGFloat) -> CGFloat {
    return CYLayoutConstraint.shareInstance.getLayoutConstraintFontSize(fontSize);
}

/**
 当前的设备型号
 */
enum iOSDeviceType {
    case iPhone5s
    case iPhone6s
    case iPhone6SP
}

/// autoLayout 约束辅助类
class CYLayoutConstraint: NSObject {
    
    var deviceType : iOSDeviceType?
    static var shareInstance : CYLayoutConstraint = {
        let layoutInstrance        = CYLayoutConstraint();
        layoutInstrance.deviceType = layoutInstrance.currenDeviceType();
        return layoutInstrance;
    }();
    
    /**
     获取当前设备的机型
     */
    func currenDeviceType() -> iOSDeviceType {
        switch KScreenWidth {
        case 0..<321.0 :
            return .iPhone5s
        case 321.0..<376.0 :
            return .iPhone6s
        default :
            return .iPhone6SP
        }
        
    }
    
    /**
     根据屏幕比例算出不同的约束值确定约束值
     */
    func getCurrentLayoutContraintValue(_ value : CGFloat) -> CGFloat {
        
        let iosDeviceType = self.deviceType!;
        switch iosDeviceType {
        case .iPhone5s :
            return CGFloat(value * 0.90);
        case .iPhone6s :
            return value;
        default:
            return CGFloat(value * 1.104);
        }
        
    }
    
    /**
     得到一个根据屏幕自适应的字体
     */
    func getLayoutContraintFont(_ fontNumber : CGFloat) -> UIFont {
        let size = self.getLayoutConstraintFontSize(fontNumber);
        return UIFont.systemFont(ofSize: size);
    }
    
    /**
     根据传入的字号获取不同屏幕下的字号
     */
    func getLayoutConstraintFontSize(_ fontSzie : CGFloat) -> CGFloat {
        
        var size : CGFloat;
        let iosDeviceType = self.deviceType!;
        switch iosDeviceType {
        case .iPhone5s :
            size = CGFloat(fontSzie);
        case .iPhone6s :
            size = fontSzie;
        default:
            size = CGFloat(fontSzie * 1.104);
        }
        return size;
    }
    
    func fontWithPX(_ px : CGFloat) -> UIFont {
        
        return UIFont.systemFont(ofSize:px*0.91*0.50)
    }
}
