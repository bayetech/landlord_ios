//
//  BKExceptions.swift
//  BayeStyle
//
//  Created by dzb on 2016/12/9.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import SwiftyJSON

/// 异常信息收集类 收集 crash 日志 reason
class BKExceptions : RLMObject {
    
    dynamic var exceptionInfo : String?
    dynamic var stackArray : String = ""
    dynamic var id : String = "exceptions"
    open override class func primaryKey() -> String?   {
        return "id"
    }
    
    /// 开始监控并收集程序异常日志信息
    class func startCollectionCrashLogs() {
        
        NSSetUncaughtExceptionHandler { (exception:NSException) in
            
            //异常的堆栈信息
            let stackArray                    = exception.callStackSymbols.jsonString

            //出现异常的原因
            let reason : String         = exception.reason ?? "未知原因出现的异常"
            
            //异常名称
            let name : NSString         = exception.name._rawValue
            
            let exceptionInfo : String  = String(format:"Exceptionreason：%@ Exceptionname：%@",name,reason)

            let bkExceptions            = BKExceptions()
            bkExceptions.exceptionInfo  = exceptionInfo
            bkExceptions.stackArray     = stackArray
            
            BKRealmManager.beginWriteTransaction()
            
            BKRealmManager.shared().realmObject?.addOrUpdate(bkExceptions)
            
            BKRealmManager.commitWriteTransaction()
            
        }
        
    }
    
    /// 上传异常日志
    class func asyncUploadCrashLogs() {
        
        let results : RLMResults  = BKExceptions.objects(with: NSPredicate(format: "id = %@", "exceptions"))
        let bkExceptions = results.lastObject() as? BKExceptions
        guard bkExceptions != nil else {
            return
        }

        let platform                        = "ios"
        let token                           = userToken ?? ""
        let exception                       = bkExceptions?.exceptionInfo ?? "错误信息"
        let backtrace                       = UnitTools.arrayTranstoString((bkExceptions!.stackArray.arrayValue()) as! [String])
        var params  : [String : Any]        = [String : Any]()
        params["exception"]                 = exception
        params["token"]                     = token
        params["platform"]                  = platform
        params["backtrace"]                 = backtrace
        
        // 移除错误信息
        BKRealmManager.beginWriteTransaction()
        BKRealmManager.shared().realmObject?.delete(bkExceptions!)
        BKRealmManager.commitWriteTransaction()
        
        BKNetworkManager.postReqeust(baseURLPath + "app_exception_notifier", params: params, success: { (result) in
            let return_code = result.value["return_code"]?.intValue
            if return_code == 201 {
                NJLog("上传异常日志成功")
            }
        }) { (failure) in
            
            NJLog(failure.errorMsg)
            
        }
        
    }
    
}
