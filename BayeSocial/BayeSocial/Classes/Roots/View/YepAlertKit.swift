//
//  YepAlertKit.swift
//  BayeSocial
//
//  Created by dzb on 2016/12/19.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit


typealias YepAlertCompletion = (_ index : Int) -> Void

enum YepAlertStyle : Int {
    case yep_alert
    case yep_actionSheet
}

/// 自定义 alertView
class YepAlertKit: NSObject {

    
    /// alertView

    /// - Returns:  返回一个 UIAlertViewController 实例 方便后边拓展其他功能
    public class func showAlertView(in viewController : UIViewController,title : String?,message : String?,titles:[String]?,cancelTitle : String?,destructive : String?,callBack:YepAlertCompletion?) -> UIAlertController {
        return self.baseAlertViewController(in: viewController, title: title, message: message, titles: titles, cancelTitle: cancelTitle, destructive: destructive, callBack: callBack, alertType: .yep_alert)
    }
    /// actionsheet

    /// - Returns:  返回一个 UIAlertViewController 实例 方便后边拓展其他功能
    public class func showActionSheet(in viewController : UIViewController,title : String?,message : String?,titles:[String]?,cancelTitle : String?,destructive : String?,callBack:YepAlertCompletion?) -> UIAlertController {
        return self.baseAlertViewController(in: viewController, title: title, message: message, titles: titles, cancelTitle: cancelTitle, destructive: destructive, callBack: callBack, alertType: .yep_actionSheet)
    }
    /// 私有方法 对于 UIAlertViewController 简单封装 提供了 alertView 和 actionsheet 两种样式 模态视图 包含了具体的实现部分代码

    /// - Returns:  返回一个 UIAlertViewController 实例 方便后边拓展其他功能
    private class func baseAlertViewController(in viewController : UIViewController,title : String?,message : String?,titles:[String]?,cancelTitle : String?,destructive : String?,callBack:YepAlertCompletion?,alertType : YepAlertStyle) -> UIAlertController {
        
        let style               = (alertType == .yep_alert) ? UIAlertControllerStyle.alert : UIAlertControllerStyle.actionSheet
        
        let alertController     = UIAlertController(title: title, message: message, preferredStyle: style)
        
        if titles != nil {
          
            for (index,item) in titles!.enumerated() {
                let selectIndex = index+1
                let alertAction = UIAlertAction(title: item, style: .default, handler: { (action) in
                    callBack?(selectIndex)
                })
                alertController.addAction(alertAction)
            }
            
        }
        
        if cancelTitle != nil {
            
            let alertAction = UIAlertAction(title: cancelTitle!, style: .cancel, handler: { (action) in
                callBack?(0)
            })
            alertController.addAction(alertAction)
            
        }
        
        if destructive != nil {
            
            let alertAction = UIAlertAction(title: destructive!, style: .destructive, handler: { (action) in
                callBack?(1000)
            })
            alertController.addAction(alertAction)
            
        }
        
        viewController.present(alertController, animated: true, completion: nil)
        
        return alertController
    }
    
    
}
