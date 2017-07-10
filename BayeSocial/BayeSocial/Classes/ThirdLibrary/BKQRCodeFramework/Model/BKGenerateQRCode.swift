//
//  BKGenerateQRCode.swift
//  BKQRCodeDemo
//
//  Created by 董招兵 on 2016/10/5.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import UIKit
import CoreImage

class BKGenerateQRCode: NSObject {
    
    /// 通过一个字符串生成一张二维码图片
    class func createQRCodeByString(_ string : String)  -> UIImage {
        
        let filter          = CIFilter(name: "CIQRCodeGenerator")
        filter?.setDefaults()
        
        let data            = string.data(using: String.Encoding.utf8)
        
        filter?.setValue(data, forKey: "inputMessage")
        filter?.setValue("H", forKey: "inputCorrectionLevel")
        
        var image           = filter?.outputImage
        
        let transform       = CGAffineTransform(scaleX: 15, y: 15)
        
        image               = image?.applying(transform)
        
        let resutlImage     = UIImage(ciImage: image!)

        return resutlImage
    }
    
    /// 通过一个字符串创建一个二维码 并设置二维码的前景图片
    class func createQRCodeByString(_ string : String,foregroundImage : UIImage) -> UIImage {
        
        let sourceImage          = BKGenerateQRCode.createQRCodeByString(string)
        let size = sourceImage.size
        
        UIGraphicsBeginImageContext(size)
        sourceImage.draw(in: CGRect(x: 0.0, y: 0.0, width: size.width, height: size.height))
        
        let width : CGFloat     = sourceImage.size.width * 0.4
        let height : CGFloat    = width
        let x : CGFloat         = (size.width - width) * 0.5
        let y : CGFloat         = (size.height - height) * 0.5
        foregroundImage.draw(in: CGRect(x: x, y: y, width: width, height: height))
        let resultImage         = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resultImage!
    }
    
    /// 中心前景图片
    class func centerImage(_ img : UIImage) -> UIImage {
        
        let sourceImage = UIImage(named: "BKScanQRCode.bundle/background")?.circleImage()
        let size = sourceImage?.size
        UIGraphicsBeginImageContext(size!)
        sourceImage?.draw(in: CGRect(x: 0.0, y: 0.0, width: (size?.width)!, height: (size?.height)!))
        let foregroundImage     = img.circleImage()
        
        let width : CGFloat     = sourceImage!.size.width * 0.90
        let height : CGFloat    = width
        let x : CGFloat         = (size!.width - width) * 0.5
        let y : CGFloat         = (size!.height - height) * 0.5
        foregroundImage.draw(in: CGRect(x: x, y: y, width: width, height: height))
        let resultImage         = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return resultImage!
    }
}

extension UIImage {
    
     func circleImage()-> UIImage {
        
        // NO代表透明
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        // 获得上下文
        let  ctx = UIGraphicsGetCurrentContext()
        
        // 添加一个圆
        let  rect = CGRect(x: 0, y : 0, width : self.size.width, height: self.size.height);
        ctx!.addEllipse(in: rect);
        
        UIColor.red.setFill()
        // 裁剪
        ctx?.clip();
        
        // 将图片画上去
        self.draw(in: rect)
        
        let cirleImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return cirleImage!

    }
}
