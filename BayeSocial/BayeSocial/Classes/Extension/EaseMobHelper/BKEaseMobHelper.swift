//
//  BKEaseMobHelper.swift
//  BKBayeStore
//
//  Created by 董招兵 on 2016/10/10.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//
 
import UIKit
import UserNotifications
import SwiftyJSON
import PKHUD

extension AppDelegate {
    
    
    /// 初始化环信 SDK
    func initializeEaseMobSDKWithOptions(_ application : UIApplication ,launchOptions: [AnyHashable: Any]?) {
        
        let option                              = EMOptions(appkey: EaseMobAppKey)
        option?.apnsCertName                    = certName
        option?.usingHttpsOnly                  = true
        option?.enableConsoleLog                = false
        option?.isAutoLogin                     = false
        option?.isAutoAcceptGroupInvitation     = false
        option?.isAutoAcceptFriendInvitation    = false
        EMClient.shared().initializeSDK(with: option)
        
        // token
        NotificationCenter.bk_addObserver(self, selector: #selector(userDidLoginApp(_:)), name: "UserDidLogin", object: nil)
        EMClient.shared().add(self, delegateQueue: DispatchQueue.main)
        
        self.registerRemoteNotification()
        
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        EMClient.shared().applicationDidEnterBackground(application)
    }
    func applicationWillEnterForeground(_ application: UIApplication) {
        EMClient.shared().applicationWillEnterForeground(application)
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any]) {
        
        
        
    }
    
    /// 注册远程通知
    func registerRemoteNotification() {
        
        if #available(iOS 10.0, *) {
            
            let noticeCenter                        = UNUserNotificationCenter.current()
            noticeCenter.delegate                   = self
            noticeCenter.requestAuthorization(options: [.alert,.badge,.sound], completionHandler: { (result, error) in
                BKGlobalOptions.curret.supportUserNotifications = result
            })
            UIApplication.shared.registerForRemoteNotifications()

        } else {
            
            let notificationTypes       = UIUserNotificationType.badge.rawValue | UIUserNotificationType.sound.rawValue | UIUserNotificationType.alert.rawValue
            let setting                 = UIUserNotificationSettings(types: UIUserNotificationType(rawValue: notificationTypes), categories: nil)
            UIApplication.shared.registerUserNotificationSettings(setting)
            
        }
        
        
    }
  
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        let error = EMClient.shared().bindDeviceToken(deviceToken)
        if error != nil {
            NJLog(error?.errorDescription);
        }

    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        
            NJLog("注册远程通知失败")
    
    }
    
    
    /// 获取应用配置信息
    func reqeustApplicaitonConfig() {
     
        // 获取 app 全局设置内容
        BKNetworkManager.getOperationReqeust(baseURLPath + "app_config", params: nil, success: { (success) in
            
            if let app_config                               = success.value["app_config"]?.dictionaryValue {
                let wechat_mall_show                        = app_config["wechat_mall_show"]?.bool ?? false
                let red_packet_show                         = app_config["red_packet_show"]?.boolValue ?? false
                let version : String                        = app_config["version"]?.string ?? UnitTools.appCurrentVersion()
                let currentVersion                          = UnitTools.appCurrentVersion()
                if version.versionStringToInteger() > currentVersion.versionStringToInteger() {
                    BKGlobalOptions.curret.needUpdateApp    = true
                }
                
                BKGlobalOptions.curret.red_packet_show            = red_packet_show
                BKGlobalOptions.curret.wechatStoreIsVisible       = wechat_mall_show
                
            }
            
        }) { (faiure) in
           
            
        }
        
    }
    
    
    /// 用户一旦登录巴爷汇就会同时登录环信账号
    @objc func userDidLoginApp(_ noti : Notification) {
     
        let authorizationToken = noti.object as? BKAuthorizationToken
        if EMClient.shared().isLoggedIn {
            EMIMHelper.shared().easeMobLoginSuccess()
            return
        }
        
        EMIMHelper.shared().login(inEaseMob:  authorizationToken!, loginSuccessCompletion: nil)
        

    }
    
    /**
     请求用户联系人资料
     */
    func reqeustCustomerUserList(_ userIds :String,completion:@escaping ((_ contacts : [BKCustomersContact])-> Void)) {
        
        guard userIds.length != 0 else {
            completion([BKCustomersContact]())
            return
        }
        
        BKNetworkManager.getOperationReqeust(KURL_Customer_friends, params: ["uids" : userIds], success: { (result) in
            
            let json                = JSON(result.value).dictionaryValue
            let customers           = json["customers"]?.arrayValue
            let error_code          = json["error_code"]?.intValue
            guard error_code == nil else {
                completion([BKCustomersContact]())
                return
            }
            guard customers != nil else {
                completion([BKCustomersContact]())
                return
            }
            
            let array = BKCustomersContact.customersWithJSONArray(customers!)
            BKRealmManager.shared().insertCustomerContact(array)
            
            completion(array)
            EMIMHelper.shared().messageViewController?.refeshConversationsData()
            
        }) { (result) in
            
            
        }

    }
    
    /// 获取我的群组资料
    func requestChatGroupList(_ groupIds :[String]) {
        
        let groupIdString = UnitTools.arrayTranstoString(groupIds)
        guard groupIdString.length > 0 else {
            DispatchQueue.main.async {
                self.disMissDefultViewController()
            }
            return
        }
        
        BKNetworkManager.getOperationReqeust(KURL_MineJoinChat_groupsApi, params: ["groupids" :groupIdString], success: {(success) in

            DispatchQueue.main.async {
                self.disMissDefultViewController()
            }
            
            let json            = JSON(success.value).dictionaryValue
            let chat_groups     = json["chat_groups"]?.arrayValue
            guard chat_groups   != nil else {
                return
            }
            
            DispatchQueue.global().sync(execute: { 
                let array  = BKChatGroupModel.chatGroupsWithJSONArray(chat_groups!)
                BKRealmManager.shared().insertChatGroup(array)
            })
      
        }) { (failure) in

            DispatchQueue.main.async {
                self.disMissDefultViewController()
            }
            
        }
    
    }
    
    /// 请求群资料详情
    func reqeustGroupInfo(by groupId : String,completion : @escaping ((_ group :BKChatGroupModel?)-> Void)) {
        
        let reqeusetURL = String(format: "%@/%@", KURL_MineJoinChat_groupsApi,groupId)
        BKNetworkManager.getReqeust(reqeusetURL, params: nil, success: { (success) in
            let json        = JSON(success.value).dictionary
            let chat_group  = json?["chat_group"]?.dictionaryValue
            guard chat_group != nil else {
                return
            }
            
            let groupModel          = BKChatGroupModel(by: JSON(chat_group!))
            BKRealmManager.shared().insertChatGroup([groupModel])
            
            completion(groupModel)

        }) { (failure) in
            
        }
    }
    
    /// 获取群成员的列表
    func requestGroupMembers(by groupId : String,completion:@escaping ((_ contacts : [BKCustomersContact])-> Void)) {
        
        let urlPath : String = String(format: "%@/%@/customers", KURL_GroupMembers,groupId)
        BKNetworkManager.getOperationReqeust(urlPath, params: nil, success: { (success) in
            let json                            = success.value
            let customers                       = json["chat_group_customers"]?.arrayValue
            let error_code                      = json["return_code"]?.intValue ?? 0
            guard error_code == 200 else {
                completion([BKCustomersContact]())
                return
            }
            guard customers != nil else {
                completion([BKCustomersContact]())
                return
            }
            
            let array : [BKCustomersContact] = BKCustomersContact.customersWithJSONArray(customers!)
            completion(array)

        }) { (failure) in
            let array : [BKCustomersContact] = [BKCustomersContact]()
            completion(array)
        }
    }
    
}

// MARK: - EMClientDelegate
extension AppDelegate  : EMClientDelegate {
    
    /// 发生自动登录后的回调
 
    /// - parameter aError: 错误信息
    func autoLoginDidCompleteWithError(_ aError: EMError!) {
        
        guard aError != nil else {
            NJLog("自动登录成功")
//            self.setupEasemob()
             return
        }
        
        NJLog("自动登录失败: error\(aError.errorDescription)")
        BKNetworkManager.showLoginView()
    }
    
    /// 用户环信账号在其他设备登录
    func userAccountDidLoginFromOtherDevice() {
        
        NJLog("账号在其他设备登录")
        BKNetworkManager.showLoginView()

    }
    
    /// 环信连接断开重连后的回调
    func connectionStateDidChange(_ aConnectionState: EMConnectionState) {
//        if (aConnectionState.rawValue == 0) {
//           NotificationCenter.bk_postNotication("ContactDidChange")
//        }
    }
    
    /// 用户账号被服务器删除了
    func userAccountDidRemoveFromServer() {
        NJLog("用户账号被服务器删除了")
        BKNetworkManager.showLoginView()
    }
    
    
}

// MARK: - UNUserNotificationCenterDelegate
extension AppDelegate : UNUserNotificationCenterDelegate {
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        EMClient.shared().application(UIApplication.shared, didReceiveRemoteNotification:response.notification.request.content.userInfo)
        
        // 快速回复他人消息
        if response.isKind(of: UNTextInputNotificationResponse.self) {
            let uid  = response.notification.request.content.userInfo["uid"] as? String
            let text = (response as! UNTextInputNotificationResponse).userText;
            EMIMHelper.shared().sendText(text, toBody:uid, ext: nil)
        }
        
        UIApplication.shared.applicationIconBadgeNumber = 0;

        completionHandler()
        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert,.badge,.sound])
    }
    
}

