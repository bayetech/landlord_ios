//
//  BKNavigaitonController.swift
//  Baye
//
//  Created by 董招兵 on 16/7/20.
//  Copyright © 2016年 Bayekeji. All rights reserved.
//

import UIKit
import PKHUD

/// 基类导航控制器 提供了全局统一的样式

class BKNavigaitonController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let navBar                       = UINavigationBar.appearance();
        navBar.titleTextAttributes      = [NSForegroundColorAttributeName : UIColor.colorWithHexString("#333333"),NSFontAttributeName : UIFont.systemFont(ofSize: 18.0)];
        navBar.tintColor                = UIColor.colorWithHexString("#1E3044")
        UIBarButtonItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.colorWithHexString("#1E3044")], for: .normal)
    }
    

    override func pushViewController(_ viewController: UIViewController, animated: Bool) {        
        super.pushViewController(viewController, animated: animated)
        NJLog("\n\n \(viewController.classType) \n\n")
    }
    
    override func popViewController(animated: Bool) -> UIViewController? {
        HUD.hide(animated: true)
        BKNetworkManager.cancelAllTasks()
        return super.popViewController(animated: animated)
    }
    
    override func popToRootViewController(animated: Bool) -> [UIViewController]? {
        HUD.hide(animated: true)
        return super.popToRootViewController(animated: animated)
    }
    
    override func popToViewController(_ viewController: UIViewController, animated: Bool) -> [UIViewController]? {
        HUD.hide(animated: true)
        return super.popToViewController(viewController, animated: animated)
    }
}
