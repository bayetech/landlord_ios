//
//  BKDetectorQRCode.swift
//  BKQRCodeDemo
//
//  Created by 董招兵 on 2016/11/19.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit

/// 识别二维码
class BKDetectorQRCode: NSObject {

    class func detectorQRCode(with soureImage : UIImage) -> String? {
        
        // 获取要识别二维码的图片
        let ciImage = CIImage(image: soureImage)
        
        // 开始识别
        // 创建二维码扫描识别器
        let dector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy : CIDetectorAccuracyHigh])
        // 识别到的结果
        if let features = dector?.features(in: ciImage!) {
            
            guard features.count != 0 else {
                return nil
            }
            let qrFeatrue = features.last as! CIQRCodeFeature
            
            return qrFeatrue.messageString
        }
        
        return nil
    }
    
}
