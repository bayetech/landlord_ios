//
//  BKAliCloudUploadOperation.swift
//  Baye
//
//  Created by 董招兵 on 2016/9/8.
//  Copyright © 2016年 上海巴爷科技有限公司. All rights reserved.
//

import UIKit
import AliyunOSSiOS


/// 阿里云上传的 opeartion
class BKAliCloudUploadOperation: Operation {
    
    override func main() {
        super.main()

        let put               = OSSPutObjectRequest()
        put.bucketName        = self.aliCloudConfig?.bucketName
        put.objectKey         = self.aliCloudConfig?.fileName
        put.uploadingData     = UIImageJPEGRepresentation((self.aliCloudConfig?.image)!,0.5)

        let putTask : OSSTask = self.client!.putObject(put)
        putTask.waitUntilFinished()
        
        if putTask.error == nil {
            NJLog("上传成功");
            self.uploadImageSuccess = true
        } else {
            NJLog(putTask.error?.localizedDescription)
            self.uploadImageSuccess = false
            NJLog("上传失败");
        }
    
    }
    var aliCloudConfig : BKAliCloudUploadConfig?
    var client :OSSClient?
    var fileName : String           = ""
    var uploadImageSuccess : Bool   = true
    convenience init(aliCloudConfig : BKAliCloudUploadConfig,client : OSSClient) {
        self.init()
        self.client             = client
        self.aliCloudConfig     = aliCloudConfig
        self.fileName           = (self.aliCloudConfig?.fileName)!
    }
    
    deinit {
        
        NJLog("上传完成后销毁")
        
    }
}
