//
//  BKNetworkManager.swift
//  Baye
//
//  Created by dzb on 16/7/25.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

/// 网络请求的类型
enum HTTPRequestMethod : String {
    case GET        = "GET"
    case POST       = "POST"
    case DELETE     = "DELETE"
    case PUT        = "PUT"
    case PATCH      = "PATCH"
    case OPTIONS    = "OPTIONS"
    case HEAD       = "HEAD"
    case CONNECT    = "CONNECT"
    case TRACE      = "TRACE"
}

/// 网络请求管理者
class BKNetworkManager: NSObject {

    lazy var operationQueue : OperationQueue = {
        let queue                            = OperationQueue()
        queue.maxConcurrentOperationCount    = 3
        return queue
    }()
    
    /// 缓存正在请求的任务
    lazy var bufferOperation : NSMutableArray = {
        let array = NSMutableArray()
        return array
    }()
    
    static var shared : BKNetworkManager = {
        let manager = BKNetworkManager()
        return manager;
    }()
    
    lazy var bufferDataTasks : [DataRequest] = {
        let tasks = [DataRequest]()
        return tasks
    }()
    
    /// 线程资源锁
    lazy var networkLock : NSLock =  {
        let lock = NSLock()
        return lock
    }()
    
    //MARK:网络请求一些异常 判断方法
    
    private func httpReqeustHeaders() ->[String: String] {
        var headers:[String: String]!
        if let sessionID = userToken {
            headers       = ["Authorization": "Token token=\(sessionID)"]
            NJLog("已登录,Token token=\(userToken!)")
        } else {
            headers = [:]
        }
        return headers
    }
    
    /**
     如果另一台设备登录,之前登录会失效弹出提示登录的提示框
     */
    class func showLoginView() {
        
        AppDelegate.appDelegate().displayLoginViewController()
        UnitTools.addLabelInWindow("登录失效,请重新登录", vc:  AppDelegate.appDelegate().rootViewControlller)
        
        
    }
    
    private class func jsonLoginStatus(_ json : [String : JSON],_ responseCode : Int) -> (reslut : Bool ,errorMsg : String) {
        
        let return_message      = json["return_message"]?.string ?? "服务器错误"
        let return_code         = json["return_code"]?.intValue ??  0
        if return_code == 401 || return_message == "请登录" {
            //未登录
            BKCacheManager.shared.clearUserCache()
            return (false,"请登录")
        } else if responseCode == 500 {
            //未登录
            UnitTools.addLabelInWindow("服务器错误", vc: nil)
            return (false,"服务器错误")
        }
        
        return (true , "请求成功")
    }
    
    //MARK: POST_REQEUST

    /**
     发送一个 post 请求
     */
    open class func postReqeust(_ path : String,params : [String : Any]?, success : successBlock?,failure : failureBlock?) {

        let option              = self.shared.publicReqeust(.POST, path: path, params: params, success: success, failure: failure);
        
        option.start()
        
    }
    
    /**
     POST请求方法 每个请求之间设置依赖关系
     */
    open class func postOperationReqeust(_ path : String,params : [String : Any]?, success : successBlock?,failure : failureBlock?) {
       
        self.publicReqeustOperation(.POST, path: path, params: params, success: success, failure: failure)
        
    }
    
    //MARK: PUT 请求
    /**
     发送一个 PUT 请求
     */
   open class func putReqeust(_ path : String,params : [String : Any]?, success : successBlock?,failure : failureBlock?) {
    
        let option                  = self.shared.publicReqeust(.PUT, path: path, params: params, success: success, failure: failure);
        option.start()
        
    }
    
    //MARK: DELETE请求
    open class func deleteRequst(_ path : String,params : [String : Any]?, success : successBlock?,failure : failureBlock?) {
        
        let option              = self.shared.publicReqeust(.DELETE, path: path, params: params, success: success, failure: failure);
        
        option.start()
        
    }
    
    //MARK: GET_REQUEST
    /**
     GET 请求不设置请求之间的依赖关系
     */
    class func getReqeust(_ path : String,params : [String : Any]?, success : successBlock?,failure : failureBlock?) {
        

        let option          = self.shared.publicReqeust(.GET, path: path, params: params, success: success, failure: failure);

        option.start()
        
    }
    /**
     GET 请求可以设置请求之间的依赖关系
     */
    class func getOperationReqeust(_ path : String,params : [String : Any]?, success : successBlock?,failure : failureBlock?) {
    
        self.publicReqeustOperation(.GET, path: path, params: params, success: success, failure: failure)

    }
    //MARK:PATCH
    /// 支持 patch 请求方式
     class func patchOperationReqeust(_ path : String,params : [String : Any]?, success : successBlock?,failure : failureBlock?) {
        
        self.publicReqeustOperation(.PATCH, path: path, params: params, success: success, failure: failure)
        
    }
    
    //MARK:网络请求任务相关
    
    // 公共的请求方法
    /**
     公共的请求方法 返回一个 NSOperation
     */
     func publicReqeust(_ reqeustMethod : HTTPRequestMethod ,path : String,params : [String : Any]?, success : successBlock?,  failure : failureBlock?) -> BlockOperation {
        
        let operation           = BlockOperation {[weak self] () in
            self?.initNetworkOpeation(reqeustMethod.rawValue, path: path, params: params, success: success, failure: failure)
        }
        return operation
    
    }
    
    /// 公共的线程同步执行网络请求任务
    private class func publicReqeustOperation(_ reqeustMethod : HTTPRequestMethod ,path : String,params : [String : Any]?, success : successBlock?,  failure : failureBlock?) {
        
        let bkManager                       = self.shared;
        
        bkManager.networkLock.lock()
        
        let operation : BlockOperation      = bkManager.publicReqeust(reqeustMethod, path: path, params: params, success: success, failure: failure)
        
        operation.completionBlock           = {[weak bkManager] () in
            bkManager!.bufferOperation.remove(operation)
        }
        
        if let lastOperation = bkManager.bufferOperation.lastObject as? BlockOperation {
            operation.addDependency(lastOperation)
        }
        
        bkManager.operationQueue.addOperation(operation)
        bkManager.bufferOperation.add(operation)
        bkManager.networkLock.unlock()
        
        
    }
    
    /// 实例化一个网络请求的任务Operation对象
    private func initNetworkOpeation(_ reqeustMethod : String ,path : String,params : [String : Any]?, success : successBlock?,  failure : failureBlock?) {
        
        let headerDict = self.httpReqeustHeaders()
        NJLog("请求URL : \n \(JSON(path))")
        if params != nil {
            NJLog("请求参数 : \n \(JSON(params!))")
        }
        
        let httpMethod = HTTPMethod(rawValue: reqeustMethod)
        var encodingType =  URLEncoding.default as ParameterEncoding
        if reqeustMethod != "GET" {
            encodingType = JSONEncoding.default as ParameterEncoding
        }
        
        // 设置超时时间
        SessionManager.default.session.configuration.timeoutIntervalForRequest = RequestTimeoutInterval
        let dataTask = Alamofire.request(path, method: httpMethod!, parameters: params, encoding: encodingType, headers: headerDict).responseJSON(completionHandler: { (response) in
            
            let responseResult : BKNetworkResult = BKNetworkResult()
            responseResult.statusCode            = response.response?.statusCode ?? 0
            
            if response.result.isSuccess {
                if success != nil {
                    guard response.result.value != nil else {
                        responseResult.value = [String : JSON]()
                        success!(responseResult)
                        return
                    }
                    let json             = JSON(response.result.value!).dictionaryValue
                    responseResult.value = json
                    responseResult.data  = response.result.value
                    let tuple            = BKNetworkManager.jsonLoginStatus(json, responseResult.statusCode)
                    let flag             = tuple.reslut
                    let error            = tuple.errorMsg
                    if  flag {
                        OperationQueue.main.addOperation({
                            NJLog(JSON(responseResult.value))
                            success?(responseResult)
                        })
                    } else {
                        
                        responseResult.error = NSError(domain: tuple.errorMsg, code: 0, userInfo: nil)
                        OperationQueue.main.addOperation({
                            failure?(responseResult)
                            NJLog(JSON(responseResult.errorMsg))
                            if error == "请登录" {
                                BKNetworkManager.showLoginView()
                            }
                        })
                        
                    }
                    
                }
                
            } else {
                
                if failure != nil {
                    
                    guard response.result.error != nil else {
                        responseResult.error = NSError(domain: "未知错误", code: 505, userInfo: nil)
                        failure?(responseResult)
                        return
                    }
                    
                    responseResult.error = (response.result.error as NSError?)!
                    OperationQueue.main.addOperation({
                        NJLog(responseResult.errorMsg)
                        failure?(responseResult)
                    })
                    
                }
                
            }
            
        })
        
        // 缓存网络请求的Task
        self.bufferDataTasks.append(dataTask)
        
    }
   
    /// 取消所有网络请求
    open class func cancelAllTasks() {
    
        for task in self.shared.bufferDataTasks {
            task.cancel()
        }

        BKNetworkManager.shared.bufferDataTasks.removeAll()
        BKNetworkManager.shared.operationQueue.cancelAllOperations()
        
    }
    
    
}
