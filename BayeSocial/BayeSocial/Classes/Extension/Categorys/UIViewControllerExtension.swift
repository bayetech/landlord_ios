//
//  UIViewControllerExtension.swift
//  Baye
//
//  Created by dzb on 16/7/30.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    
 
    /**
     获取导航控制器当前正在显示的控制器
     */
    func currentShowViewController() -> UIViewController {
        
        let tabbarController             = AppDelegate.appDelegate().rootViewControlller as? BKTabBarViewController
        guard tabbarController != nil else {
            return UIViewController()
        }
        let nav : BKNavigaitonController = tabbarController!.viewControllers![tabbarController!.selectedIndex] as! BKNavigaitonController
        let currentViewController        = nav.viewControllers.last
        return currentViewController!
    
    }
    
    func isRooViewController() -> Bool {
        
        let parentVC    = self.parent
        guard parentVC != nil else {
            return false
        }
        let index = parentVC?.childViewControllers.index(of: self)
        guard index != 0 else {
            return false
        }
        return true
    }
    
    
}

extension UINavigationController {
    

    /**
     延迟几秒后执行 pop 操作
     
     - parameter animated: 是否需要动画
     - parameter delay:    延时时间
     */
    func popViewControllerAnimated(_ animated : Bool ,delay : Double) {
        self.perform(#selector(popViewController(animated:)), with: nil, afterDelay: delay)
    }
    /**
     延时时间调用 pop 方法到指定控制器
     */
    func popToViewController(_ viewController: UIViewController, animated: Bool ,delay : Double){
        self.perform(#selector(popToViewController(_:animated:)), with: nil, afterDelay: delay)
    }
    
    /**
     延时方法 pop 到根控制器
     */
     func popToRootViewControllerAnimated(_ animated: Bool ,delay : Double) {
        self.perform(#selector(popToRootViewController(animated:)), with: nil, afterDelay: delay)
     }
    
    
}




