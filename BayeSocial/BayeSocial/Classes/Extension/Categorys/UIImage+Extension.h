//
//  UIImage+Extension.h
//  BayeStyle
//
//  Created by dzb on 2016/12/9.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Extension)
/**
 *  获取系统启动页图片
 */
+ (UIImage *_Nullable)getLauchImage;

/**
 根据gif图片名生成一个image
 */
+ (UIImage *_Nullable)sd_animatedGIFNamed:(NSString *_Nullable)name;


// 保持原始图片的长宽比，生成需要尺寸的图片
-(UIImage*_Nonnull)imageWithImage:(UIImage*_Nonnull)image scaledToSize:(CGSize)newSize;

@end


@interface NSDictionary (Extension)

/**
 把字典中的键值对 如果是字符串的替换成字典或者数组
 */
- (NSDictionary *_Nonnull) replaceJsonToObject;

/**
 把字典转成 json 字符串
 */
@property (nonatomic,nullable,copy) NSString *jsonString;

@end




