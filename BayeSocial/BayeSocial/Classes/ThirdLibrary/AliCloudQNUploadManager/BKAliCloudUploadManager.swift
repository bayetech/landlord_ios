//
//  BKAliCloudUploadManager.swift
//  Baye
//
//  Created by 董招兵 on 2016/9/8.
//  Copyright © 2016年 上海巴爷科技有限公司. All rights reserved.
//

import UIKit
import AliyunOSSiOS

typealias AlicloudUploadCompletion = (_ imageFileNames : [String], _ isFinished : Bool) -> Void

/// 阿里云上传图片的管理者
class BKAliCloudUploadManager: NSObject {

    static var manager : BKAliCloudUploadManager = {
        let mgr = BKAliCloudUploadManager()
        return mgr
    }()
    
    var operationQueque = OperationQueue()
    var bufferOperation = NSMutableArray()
    var imageNames      = [String]()
    
    /// 异步上传图片的接口
    ///
    /// - parameter image:      图片
    /// - parameter reslut:     服务器返回的临时 token 信息又来 ATS 上传使用
    /// - parameter completion: 上传结束后的回调结果
    func asyncUploadImage(_ image : UIImage,completion : AlicloudUploadCompletion?) {

        // 这个方法是将服务器返回的临时 token 信息的字典转成一个模型 ,字典中 有 access_key_id , access_key_secret 等几个 key 具体的可以参照 BKAliCloudUploadConfig的属性名
        let config          = BKAliCloudUploadConfig() // 这个是直接将 access_key_secret 写死的方式去上传图片,存在一定的安全性不推荐使用

        config.image        = image;
        let accessKey       = config.access_key_id
        let accessSecrteKey = config.access_key_secret
        // 临时 token 上传时有效
//        let accessToken     = config.security_token
//        let expiration      = config.expiration
        let apiHost         = config.aliCloudApiHost
        
        // 这个是临时授权 token 时 需要打开这段代码,创建一个 credential 对象
//        let credential            = OSSFederationCredentialProvider.init { () -> OSSFederationToken! in
//            let token                       = OSSFederationToken()
//            token.tAccessKey                = accessKey
//            token.tSecretKey                = accessSecrteKey
//            token.tToken                    = accessToken
//            token.expirationTimeInGMTFormat = expiration
//            return token
//        }

        // 这个是利用永久性的 access_key_secret 和 access_key_id 去上传
        let credential                                      = OSSPlainTextAKSKPairCredentialProvider(plainTextAccessKey: accessKey, secretKey: accessSecrteKey);
        
        let aliCloudUploadConfig                            = OSSClientConfiguration()
        aliCloudUploadConfig.maxRetryCount                  = 3
        aliCloudUploadConfig.timeoutIntervalForRequest      = 30
        aliCloudUploadConfig.timeoutIntervalForResource     = TimeInterval(24 * 60 * 60);
        aliCloudUploadConfig.maxConcurrentRequestCount      = 3

        let client                                          = OSSClient(endpoint: apiHost, credentialProvider: credential!)
        let operation                                       = BKAliCloudUploadOperation(aliCloudConfig: config, client: client)

        if let lastOperation      = bufferOperation.lastObject {
            operation.addDependency(lastOperation as! BKAliCloudUploadOperation)
        }

        operation.completionBlock = {[weak self] () in
            
            OperationQueue.main.addOperation({
                
                self!.bufferOperation.remove(operation);
                let finished = self!.bufferOperation.count == 0
                if (operation.uploadImageSuccess) {
                    self!.imageNames.append(operation.fileName)
                }
                if finished {
                    completion!(self!.imageNames,finished)
                    self?.imageNames.removeAll()
                }
                
            })
        }

        operationQueque.addOperation(operation)
        bufferOperation.add(operation)
        
    }
    
}
