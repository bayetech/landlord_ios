//
//  BKCacheManager.swift
//  Baye
//
//  Created by 董招兵 on 16/9/1.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import Foundation
import WebKit
import SwiftyJSON
import Kingfisher
import PKHUD

let appVersion : String = "3.3.2"

/// 代表一个 UserInfo 类型对象
var BK_UserInfo : UserInfo {
    get {
        return BKRealmManager.shared().currentUser!
    }
}

/// 用户授权后的信息
var KCustomAuthorizationToken : BKAuthorizationToken {
    get {
        return BKAuthorizationToken.shared()
    }
}

/// 用户是否登录
var userDidLogin : Bool {
    get {
        return (userToken != nil)
    }
}

/// 用户 token
var userToken :String? {
    get {
        return KCustomAuthorizationToken.session_id
    }
}

/// 用户巴金
var userCoinbalance : String {
    get {
        return BK_UserInfo.coin_balance
    }
}

/// 环信用户注册的账号
var easemob_username : String {
    get {
        return KCustomAuthorizationToken.easemob_username
    }
}

/// 环信注册用户的密码
var easemob_password : String {
    get {
        return KCustomAuthorizationToken.easemob_password
    }
}

func  removeWebviewCookies() {
    BKCacheManager.removeWebViewCookies()
}

/**
 更新用户信息
 */
func updateUserInfo(_ user : UserInfo)  {
    BKCacheManager.bk_updateUserInfo(user)
}

/**
 将数据存储到 NSUserDefalults
 */
func bk_SetNSUserDefaultsForkey(_ obj : Any? ,key : String?) {
    BKCacheManager.bk_userdefalults(setOject: obj as AnyObject?, forKey: key)
}

/**
 通过一个 key 从 NSUserDefalults 读取数据
 
 */
func bk_GetNSUserDefaultsForkey(_ key : String?) -> AnyObject? {
    return BKCacheManager.bk_userdefalults(valueForkey: key)
}

/**
 从 NSUserDefalults 删除一个数据
 */
func bk_RemoveNSUserDefaultsForKey(_ key : String?) {
    BKCacheManager.bk_userdefalults(removeObjectForkey: key)
}

/**
 批量删除 NSUserDefalults 中的数据
 */
func bk_RemoveNSUserDefaultsInkeys(_ keys : [String]?) {
    BKCacheManager.bk_userdefalults(removeObjectsForKeys: keys);
}

/**
 *  缓存管理者 是一个结构体
 */
class BKCacheManager : NSObject {

    static var shared : BKCacheManager = {
        let manager = BKCacheManager()
        return manager
    }()
    
    /// 存储用户所有群组信息
    var easeMobGroups : [EMGroup]   = [EMGroup]()
    var cacheData : [String : Bool] = [String : Bool]()
    /// 获取图片缓存的数量
    func imageCahceSize(closure : @escaping (_ cacheSize : String)-> Void) {
        let cache = KingfisherManager.shared.cache
        var string : String = "0.0 MB"
        cache.calculateDiskCacheSize { (size) in
            string = String(format: "%.2f MB", Double(size)/1024.0/1024.0)
            closure(string)
        }
    }
    // 临时存用户注册手机号码 注册完成后 置为 nil
    var userRegisterMobile : String?
    
    /**
     请求个人资料的信息
     */
    func reqeustUserInfo(_ callBack : ((_ user : UserInfo?) ->())? )  {
        
        BKNetworkManager.getOperationReqeust(KURL_CustomersProfile, params: nil, success: { (data) in
            
            let json            = JSON(data.value).dictionaryValue
            let dic             =  json["profile"]?.dictionary
            guard dic           != nil else {
                callBack?(nil)
                return
            }
            
            let currenUser      = UserInfo(with: dic!)
            
            // 保存用户资料
            let customer        = BKCustomersContact(withUser: currenUser)
            
            BKRealmManager.shared().insertUserInfoModel(currenUser)
            BKRealmManager.shared().insertCustomerContact([customer])

            callBack?(currenUser)

        }) { (error) in
            
            UnitTools.addLabelInWindow(error.errorMsg, vc: nil)
            
            callBack?(nil)
            
        }
        
        
    }
    
    /// 登出应用
    func loginOutApplication() {
        
        HUD.flash(.rotatingImage(PKHUDAssets.progressCircularImage), delay:30.0)
        BKNetworkManager.deleteRequst(baseURLPath + "customers/sign_out", params: nil, success: {[weak self] (success) in
            HUD.hide(animated: true)
            let json                = JSON(success.value).dictionaryValue
            let return_code         = json["return_code"]?.int ?? 0
            let return_message      = json["return_message"]?.string ?? "退出账号失败"
            if return_code != 200 {
                UnitTools.addLabelInWindow(return_message, vc: nil)
                return
            }
            self?.clearUserCache()
            
            AppDelegate.appDelegate().displayLoginViewController()
            
        }) { (faiure) in
            HUD.hide(animated: true)
            UnitTools.addLabelInWindow(faiure.errorMsg, vc:nil)
        }
        
    }
    
    /// 清除用户缓存,当注销 或者账户异常退出时调用
    func clearUserCache() {
        
        EMIMHelper.shared().loginOutEaseMobHelper()
        let _ = BKRealmManager.shared().deleteLoginAuthorization()
        BKCacheManager.removeWebViewCookies()
        
    }
    
    /// 清除图片缓存
    func clearImageCache() {
        
        let cache = KingfisherManager.shared.cache
        cache.clearMemoryCache()
        cache.clearDiskCache()
        cache.cleanExpiredDiskCache()
        
    }

    /**
     存储多个对象到 NSUserDefaults
    */
    class func bk_userdefalults(setOjects objects : [String : NSObject]?) {
        
        guard (objects != nil) else {
            NJLog("传入的 objects 为空")
            return
        }
        let userDefaults = UserDefaults.standard
        for (objectKey,obj) in objects! {
            userDefaults.set(obj, forKey: objectKey)
        }
        userDefaults.synchronize()
    }
    /**
     将数据存储到 NSUserDefalults

     */
   class  func bk_userdefalults(setOject obj : AnyObject?,forKey key : String?) {
        
        guard (key != nil || obj != nil) else {
            NJLog("传入的 key, 或者 obj 为空")
            return
        }
        let params = [key! : obj as! NSObject]
        self.bk_userdefalults(setOjects: params)
        
    }
    
    /**
     通过一个 key 从 NSUserDefalults 读取数据

     */
   class func bk_userdefalults(valueForkey key : String?) -> AnyObject? {
        
        guard (key != nil) else {
            NJLog("传入的 key为空")
            return nil
        }

        let userDefaults            = UserDefaults.standard
        let obj                     = userDefaults.object(forKey: key!)
        if obj != nil {
            return obj as AnyObject
        }
        return nil
    }
    
    /**
     从 NSUserDefalults 删除一个数据
 
     */
     class func bk_userdefalults(removeObjectForkey key : String?) {
        guard (key != nil) else {
            NJLog("传入的 key为空")
            return
        }
        self.bk_userdefalults(removeObjectsForKeys: [key!])
    }

    /**
     批量删除 NSUserDefalults 中的数据
     */
    class func bk_userdefalults(removeObjectsForKeys keys:[String]?) {
        
        guard (keys != nil) else {
            NJLog("传入的 keyValues 为空")
            return
        }

        let userDefaults = UserDefaults.standard
        for key in keys! {
            userDefaults.removeObject(forKey: key)
        }
        userDefaults.synchronize()
    }
    /**
     更新用户信息
     */
    class func bk_updateUserInfo(_ userInfo : UserInfo) {       
        BKRealmManager.shared().insertUserInfoModel(userInfo)
    }

    /**
     清理 webview 缓存
     */
    class func removeWebViewCookies() {
        let dateStore = WKWebsiteDataStore.default()
        dateStore.fetchDataRecords(ofTypes: WKWebsiteDataStore.allWebsiteDataTypes()) { (records) in
            for record in records {
                WKWebsiteDataStore.default().removeData(ofTypes: record.dataTypes, for: [record], completionHandler: {
                })
            }
        }
    }

}
