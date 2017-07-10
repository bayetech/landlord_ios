//
//  BKTabBarViewController.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/20.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import PKHUD

class BKTabBarViewController: UITabBarController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bkTabbar                        = BKTabBar()
        bkTabbar.frame                      = self.tabBar.frame
        self.setValue(bkTabbar, forKey: "tabBar")

        self.setup()
    }
    
    
    func setup() {
        
        HUD.dimsBackground                          = false
        HUD.allowsInteraction                       = true
        
        let messageViewController                   = BKMessageViewController()
        
        let contactViewController                   = BYContactViewController()
        
        let discoverViewController                  = BKDiscoverViewController()
        
        let userSpaceViewController                 = BYUserSpaceViewController()
        
      
        setupViewController(from: messageViewController, norImage: "tabbar_message_nor", selectImage: "tabbar_message_sel", title: "消息")
        setupViewController(from: contactViewController, norImage: "tabbar_contact_nor", selectImage: "tabbar_contact_sel", title: "人脉")
        setupViewController(from: discoverViewController, norImage: "tabbar_discover_nor", selectImage: "tabbar_discover_sel", title: "发现")
        setupViewController(from: userSpaceViewController, norImage: "tabbar_profile_nor", selectImage: "tabbar_profile_sel", title: "爷")

        EMIMHelper.shared().mainTabBarController    = self
        EMIMHelper.shared().contactViewController   = contactViewController
        EMIMHelper.shared().messageViewController   = messageViewController
        
        
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.colorWithHexString("#333333"),NSFontAttributeName : CYLayoutConstraintFont(11.0)], for: .selected)
        UITabBarItem.appearance().setTitleTextAttributes([NSForegroundColorAttributeName : UIColor.colorWithHexString("#333333"),NSFontAttributeName : CYLayoutConstraintFont(11.0)], for: .normal )
        
        UITextField.appearance().tintColor     = UIColor.colorWithHexString("#FFC800")
        UITextView.appearance().tintColor      = UIColor.colorWithHexString("#FFC800")
        

        
    }
    
    /// 设置 tabBar 子控制器内容
    func setupViewController(from viewController : UIViewController,norImage : String,selectImage : String,title : String) {
        
        viewController.tabBarItem.image             = UIImage(named : norImage)
        viewController.tabBarItem.selectedImage     = UIImage(named :selectImage)
        viewController.tabBarItem.title             = title
        
        let baseNav         = BKNavigaitonController(rootViewController: viewController);
        addChildViewController(baseNav)
        
    }
    
}
