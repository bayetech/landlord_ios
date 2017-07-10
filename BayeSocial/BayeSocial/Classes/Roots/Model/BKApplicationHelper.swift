 //
//  BKApplicationHelper.swift
//  Baye
//
//  Created by 董招兵 on 16/9/2.
//  Copyright © 2016年 上海巴爷科技有限公司. All rights reserved.
//

import UIKit
 
@objc protocol BKApplicationHelperDelegate : NSObjectProtocol {
    
    /**
     程序开始活跃的通知
     */
    @objc optional func bk_ApplicationDidBecomeActiveNotification(_ application : UIApplication)
    /**
     程序已经进入后台通知
     */
    @objc optional func bk_ApplicationDidEnterBackgroundNotificationno(_ application : UIApplication)
    /**
     程序失去响应的通知
     */
    @objc optional func bk_ApplicationWillTerminateNotification(_ application : UIApplication)
    
 }
 

/// 监听程序运行状态
class BKApplicationHelper: NSObject {
    
    static var shareInstance : BKApplicationHelper = {
        let applicationHelper = BKApplicationHelper()
        applicationHelper.addObserverApplicationState()
        return applicationHelper
    }()
    
    lazy var labelsSet : NSMutableArray = {
        let set = NSMutableArray()
        return set
    }()
    
    lazy var operationSynLock : NSLock = {
        let lock = NSLock()
        return lock;
    }()
    
    weak var delegate : BKApplicationHelperDelegate?
    
    /**
     监听程序运行状态
     */
    fileprivate func addObserverApplicationState()  {
        
        NotificationCenter.bk_addObserver(self, selector:  #selector(BKApplicationHelper.bk_ApplicationDidBecomeActiveNotification(_:)), name: NSNotification.Name.UIApplicationDidBecomeActive.rawValue, object: UIApplication.shared)
        
        NotificationCenter.bk_addObserver(self, selector:  #selector(BKApplicationHelper.bk_ApplicationDidEnterBackgroundNotificationno(_:)), name: NSNotification.Name.UIApplicationDidEnterBackground.rawValue, object: UIApplication.shared)
        
        NotificationCenter.bk_addObserver(self, selector: #selector(BKApplicationHelper.bk_ApplicationWillTerminateNotification(_:)), name: NSNotification.Name.UIApplicationWillTerminate.rawValue, object: UIApplication.shared)

    }
    /**
     监听代理,供其他对象使用
     */
    class func addDelegate(_ delegate : BKApplicationHelperDelegate?) {
        self.shareInstance.delegate = delegate
    }
    
    /**
     程序开始活跃的通知
     */
    func bk_ApplicationDidBecomeActiveNotification(_ noti : Notification) {
        let applicaion = noti.object as! UIApplication
        self.delegate?.bk_ApplicationDidBecomeActiveNotification?(applicaion)
    }
    
    /**
     程序已经进入后台通知
     */
    func bk_ApplicationDidEnterBackgroundNotificationno(_ noti : Notification) {
        
        let applicaion = noti.object as! UIApplication
        
        self.delegate?.bk_ApplicationDidEnterBackgroundNotificationno?(applicaion)
        
    }   
    /**
     程序失去响应的通知
     */
    func bk_ApplicationWillTerminateNotification(_ noti : Notification) {
        
        let applicaion = noti.object as! UIApplication
        self.delegate?.bk_ApplicationWillTerminateNotification?(applicaion)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
