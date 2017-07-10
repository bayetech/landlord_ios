//
//  UnitTools.swift
//  Baye
//
//  Created by 孙磊 on 15/9/22.
//  Copyright © 2015年 Bayekeji. All rights reserved.
//
import Foundation
import Spring
import SwiftyJSON


class UnitTools : NSObject {
    
    open class var ApiHost : String {
        return baseURLPath
    }
    /// 判断是否第一次打开这个版本使用
    class func firstUseVersion() -> Bool {
        let lastVersion : String? = bk_GetNSUserDefaultsForkey("version") as? String
        let currentVersion = self.appCurrentVersion()
        if lastVersion != nil {
            if lastVersion! == currentVersion {
                return false
            } else {
                bk_SetNSUserDefaultsForkey(currentVersion, key: "version")
                return true
            }
        } else {
            bk_SetNSUserDefaultsForkey(currentVersion, key: "version")
            return true
        }
    }
    
    /// 当前应用版本号
    class func appCurrentVersion() -> String {
        let bundleDictionary                  = Bundle.main.infoDictionary
        guard bundleDictionary != nil else {
            return appVersion
        }
        let dict                                = JSON(bundleDictionary!).dictionaryValue
        let version                             = dict["CFBundleShortVersionString"]?.string ?? appVersion
        return version
    }
    
    class func viewControllerFromStoryboard(_ storyboardName : String,viewStorybaordId : String) -> UIViewController {
        let storyboard      = UIStoryboard(name: storyboardName, bundle: nil)
        let viewController  = storyboard.instantiateViewController(withIdentifier: viewStorybaordId)
        return viewController
    }
    
    /// 是否安装了微信
    class func isHaveWechatApp() ->Bool{
        if WXApi.isWXAppInstalled() {
            return true
        }else{
            return false
        }
    }
    
    class func delay(_ delay:Double, closure:@escaping ()->()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }

    
    class func addLabelInWindow(_ string:String,vc:UIViewController?) {
        
        var viewController = vc
        if viewController == nil {
            viewController = AppDelegate.appDelegate().rootViewControlller
        }
        
        BKApplicationHelper.shareInstance.operationSynLock.lock()
        var lastLabel = BKApplicationHelper.shareInstance.labelsSet.firstObject as? SpringLabel
        
        if lastLabel == nil {
            lastLabel = viewController?.view.viewWithTag(1000) as? SpringLabel
        }
        
        if lastLabel != nil  {
            UnitTools.removeSpringLabel(lastLabel!);
        }
        
        let label                           = SpringLabel()
        label.tag                           = 1000
        label.text                          = string
        label.font                          = UIFont.systemFont(ofSize: 14)
        label.textAlignment                 = NSTextAlignment.center
        label.textColor                     = UIColor.colorWithHexString("#F2F2F2")
        label.backgroundColor               = UIColor.colorWithHexString("#666666")
        label.alpha                         = 0.6
        label.layer.cornerRadius            = 5
        label.layer.masksToBounds           = true
        label.numberOfLines                 = 2
        label.frame                         = CGRect(x: (KScreenWidth-label.displaySize.width-30)/2, y: (viewController?.view.frame.height)!-label.displaySize.height-98, width: label.displaySize.width+30, height: label.displaySize.height+10)
        viewController?.view.addSubview(label)
        label.animation                     = "slideUp"
        label.curve                         = "spring"
        label.duration                      = 0.5
        label.animate()
        label.animation                     = "fall"
        label.curve                         = "spring"
        label.duration                      = 0.5
        label.delay                         = 2
        label.animate()
        
        BKApplicationHelper.shareInstance.labelsSet.add(label)
        
        self.delay(2, closure: {
            UnitTools.removeSpringLabel(label);
        })
        
        BKApplicationHelper.shareInstance.operationSynLock.unlock()
        
    }
    
    /// 字符串数组转成一个字符串
    class func arrayTranstoString(_ array : [String]) -> String {
        var mutableString = ""
        for str in array {
            mutableString.append(str)
            mutableString.append(",")
        }
        if mutableString.contains(",") {
            mutableString = (mutableString as NSString).substring(to: mutableString.length-1)
        }
        return mutableString
    }
    
    /**
     移除 SpringLabel
     */
    class func removeSpringLabel(_ label : SpringLabel?) {
        
        guard label != nil else {
            return
        }
        
        label!.removeFromSuperview()
        BKApplicationHelper.shareInstance.labelsSet.remove(label!)
    }
    
    
    /// 获取 RLMArray 集合里的每一个元素
    class func bk_RlmArrayAllObjects<T>(rlmArray : RLMArray<RLMObject>,ojbType : T) -> [T] {

        var array                       = [T]()
        for i in 0..<rlmArray.count {
            let item = rlmArray.object(at: i)
            array.append(item as! T)
        }
        
        return array
        
    }


}


