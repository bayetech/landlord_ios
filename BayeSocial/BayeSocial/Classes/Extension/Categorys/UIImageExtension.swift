//
//  UIImageExtension.swift
//  Baye
//
//  Created by dzb on 16/7/23.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

import Foundation
import UIKit

let KProductPlaceholderImage    = UIImage(named: "placeholderImage")
let KCustomerUserHeadImage      = UIImage(named: "user_unregister")
let KChatGroupPlaceholderImage  = UIImage(named: "search_customuser_icon")

extension UIImage {
    
    /**
     *  给图片进行等比例缩放 知道宽度 去计算等比例后的高度
     */
    class func getScaleImageFromSize(sourceSize size : CGSize, fromWidth fromW : CGFloat) -> CGSize {
        let width           = size.width
        var height          = size.height
        let heightIsBig     = (width < height)
        let scale           = heightIsBig ? (width/height): (height / width)
        height              = heightIsBig ? CGFloat(fromW/scale) : CGFloat(fromW*scale)
        return CGSize(width: fromW, height: height);

    }
    
    /**
     *  根据高度 自适应宽度
     */
    class func getScaleImageFromSize(sourceSize size : CGSize, fromHeight fromH : CGFloat) -> CGSize {
        
        var width       = size.width
        let height      = size.height
        let heightIsBig = (width < height)
        let scale       = heightIsBig ? (width/height): (height / width)
        width           = heightIsBig ? CGFloat(fromH * scale) : CGFloat(fromH/scale)
        return CGSize(width: width, height: fromH);

    }

    /**
     等比例缩放图片 并居中显示图片
     */
    func getScaleImageToCenter(_ sourceImage : UIImage?,targetSize: CGSize) -> UIImage?{
        
        // 创建一个bitmap的context
        // 并把它设置成为当前正在使用的context
        UIGraphicsBeginImageContext(size);

        let centerX      = (self.size.width  -  targetSize.width) / 2.0

        let centerY      = (self.size.height  -  targetSize.height) / 2.0

        let pt           = CGPoint(x: centerX, y: centerY)

        sourceImage?.draw(in: CGRect(x: pt.x,y: pt.y, width: targetSize.width, height: targetSize.height))

        // 绘制改变大小的图片
        //        [img drawInRect:CGRectMake(0,0, size.width, size.height)];
        // 从当前context中创建一个改变大小后的图片
        let  scaledImage = UIGraphicsGetImageFromCurrentImageContext();

        // 使当前的context出堆栈
        UIGraphicsEndImageContext();

        //返回新的改变大小后的图片
        return scaledImage;
        
    }
    
    func getScaleImage(_ sourceImage : UIImage?,targetSize: CGSize) -> UIImage? {

        // 创建一个bitmap的context
        // 并把它设置成为当前正在使用的context
        UIGraphicsBeginImageContext(size);

        sourceImage?.draw(in: CGRect(x: 0,y: 0, width: targetSize.width, height: targetSize.height))
        // 绘制改变大小的图片
//        [img drawInRect:CGRectMake(0,0, size.width, size.height)];
        // 从当前context中创建一个改变大小后的图片
        let  scaledImage = UIGraphicsGetImageFromCurrentImageContext();
        // 使当前的context出堆栈
        UIGraphicsEndImageContext();
        //返回新的改变大小后的图片
        return scaledImage;

    }
    
    /// 调整图片的方向
    func normalizedImage() -> UIImage {
     
        if self.imageOrientation == UIImageOrientation.up {
            return self
        }
        
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale);
        self.draw(in: CGRect(x: 0.0, y: 0.0, width: self.size.width, height: self.size.height))
        let img = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return img!
    }
    
    func cirleImage() -> UIImage {
        
        // NO代表透明
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        // 获得上下文
        let  ctx = UIGraphicsGetCurrentContext()
        
        // 添加一个圆
        let  rect = CGRect(x: 0, y : 0, width : self.size.width, height: self.size.height);
        ctx!.addEllipse(in: rect);
        
        // 裁剪
        ctx?.clip();
        
        // 将图片画上去
        self.draw(in: rect)
        
        let cirleImage = UIGraphicsGetImageFromCurrentImageContext();
        
        UIGraphicsEndImageContext();
        
        return cirleImage!

        
    }
    
    /// 通过一个 UIColor 生成一个 UIImage
    class func imageWithColor(_ color: UIColor) -> UIImage
    {
        let rect:CGRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context:CGContext = UIGraphicsGetCurrentContext()!
        context.setFillColor(color.cgColor)
        context.fill(rect)
        let image:UIImage = UIGraphicsGetImageFromCurrentImageContext()!;
        UIGraphicsEndImageContext()
        return image
        
    }
    
}
