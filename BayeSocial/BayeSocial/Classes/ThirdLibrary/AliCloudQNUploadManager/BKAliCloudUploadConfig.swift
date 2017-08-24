//
//  BKAliCloudUploadConfig.swift
//  Baye
//
//  Created by 董招兵 on 2016/9/8.
//  Copyright © 2016年 上海巴爷科技有限公司. All rights reserved.
//

import UIKit

/// 上传内容的 config
class BKAliCloudUploadConfig: NSObject {
    
     var access_key_id : String         = "LTAIlt0d4hgfBlWv"
     var access_key_secret : String     = "YkHd4i35xR7D7SIkm2TuxYuWSsK65V"
     var expiration : String            = ""
     var security_token : String        = ""
     var session_name :String?
     var image : UIImage?
     var aliCloudApiHost : String       = "https://oss-cn-shanghai.aliyuncs.com"
     var bucketName : String            = "hubs"
     lazy var fileName : String = {

        let date        = Date()
        let time        = date.timeIntervalSince1970
        let token       = userToken ?? "xxxx"
        let count       = arc4random_uniform(100000000)
        let name        = (String(format: "%f%@%d", time,token,count) as NSString).md5()
        let tempName    = String(format: "%@.png", name)

        return tempName
        
    }()
    
    
    
}
