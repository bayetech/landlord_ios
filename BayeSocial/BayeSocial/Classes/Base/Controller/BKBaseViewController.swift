//
//  BKBaseViewController.swift
//  BayeStyle
//
//  Created by 董招兵 on 2016/10/28.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import PKHUD
import SnapKit

class BKBaseViewController: UIViewController {

    var leftTitle : String  = "" {
        
        didSet {
            
            // 返回
            let leftButton                              = UIButton(type: .custom)
            leftButton.frame                            = CGRect(x: 0, y: 0, width: 13, height: 21)
            leftButton.setImage(UIImage(named: "black_backArrow"), for: .normal)
            leftButton.addTarget(self, action: #selector(popToBack), for: .touchUpInside)
            let backItem                                = UIBarButtonItem(customView: leftButton)
            let titleItem                               = UIBarButtonItem(title:leftTitle, style: .done, target: self, action: #selector(popToBack))
            self.navigationItem.leftBarButtonItems      = [backItem,titleItem]
            
        }
        
    }
    
    var gestureRecognizerShouldBegin : Bool             = true
    @objc public func popToBack() {
        let _ = self.navigationController?.popViewController(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
     
        self.view.backgroundColor                                               = UIColor.white
        self.automaticallyAdjustsScrollViewInsets                               = false
        self.navigationController?.interactivePopGestureRecognizer!.delegate    = self

    }
    
    func showHUD() {
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
    }
    
    func hiddenHUD() {
        HUD.hide(animated: true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        hiddenHUD()
        super.dismiss(animated: flag, completion: completion)
    }
    
}

// MARK: - 导航左右侧barbuttonItem 拓展的方法
extension BKBaseViewController {
    
    /// 设置导航条右侧的barbuttonItems
    private func setRightBarbuttonItem(_ titles :[String]?,images : [String]?,actions : [Selector]) {
        self.navigationItem.rightBarButtonItems = self.getBarbuttonItems(titles: titles, images: images, actions: actions)
    }
    
    /// 导航右侧items 全部为 title类型
    public func setRightBarbuttonItemWithTitles(_ titles :[String],actions : [Selector]) {
        self.setRightBarbuttonItem(titles, images: nil, actions: actions)
    }
    public func setRightBarbuttonItemWithImages(_ images : [String]?,actions : [Selector]) {
        self.setRightBarbuttonItem(nil, images: images, actions: actions)
    }
    
    /// 设置导航条左侧的barbuttonItems
    private func setLeftBarbuttonItem(_ titles :[String]? , images: [String]?,actions : [Selector]) {
        
        self.navigationItem.leftBarButtonItems = self.getBarbuttonItems(titles: titles, images: images, actions: actions)
    }
    /// 导航右侧items 全部为 title类型
    public func setLeftBarbuttonItemWithTitles(_ titles :[String],actions : [Selector]) {
        self.setLeftBarbuttonItem(titles, images: nil, actions: actions)
    }
    /// 导航右侧items 全部为 image类型
    
    public func setLeftBarbuttonItemWithImages(_ images : [String]?,actions : [Selector]) {
        self.setLeftBarbuttonItem(nil, images: images, actions: actions)
    }
    
    /// 公共部分 返回导航左侧 或者右侧的 barbuttonitems
    private func getBarbuttonItems(titles :[String]?,images : [String]?,actions : [Selector]) -> [UIBarButtonItem] {
        
        var index = 0
        var barbuttonItems = [UIBarButtonItem]()
        if titles != nil {
            for title in titles! {
                let barbuttonItem = UIBarButtonItem(title: title, style: .done, target: self, action: actions[index])
                barbuttonItems.append(barbuttonItem)
                index+=1
            }
            
        } else if images != nil {
            
            for image in images! {
                let barbuttonItem = UIBarButtonItem(image: UIImage(named: image), style: .done, target: self, action: actions[index])
                barbuttonItems.append(barbuttonItem)
                index+=1
            }
        }
        
        return barbuttonItems
    }

}

// MARK: - 控制器左侧滑动返回的代理

extension BKBaseViewController : UIGestureRecognizerDelegate {
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if self.navigationController?.viewControllers.count == 1 {
            return false
        }else{
            return self.gestureRecognizerShouldBegin
        }
    }
    
}

