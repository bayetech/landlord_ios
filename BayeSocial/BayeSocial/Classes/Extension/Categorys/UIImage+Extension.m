//
//  UIImage+Extension.m
//  BayeStyle
//
//  Created by dzb on 2016/12/9.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import "UIImage+Extension.h"
#import <SDWebImage/UIImage+GIF.h>

@implementation UIImage (Extension)

/**
 *  获取系统启动页图片
 */
+ (UIImage *_Nullable)getLauchImage
{
    CGSize viewSize = [UIScreen mainScreen].bounds.size;
    NSString *viewOrientation = @"Portrait";    //横屏请设置成 @"Landscape"
    NSString *launchImage = nil;
    NSArray* imagesDict = [[[NSBundle mainBundle] infoDictionary] valueForKey:@"UILaunchImages"];
    for (NSDictionary* dict in imagesDict)
    {
        CGSize imageSize = CGSizeFromString(dict[@"UILaunchImageSize"]);
        if (CGSizeEqualToSize(imageSize, viewSize) && [viewOrientation isEqualToString:dict[@"UILaunchImageOrientation"]])
        {
            launchImage = dict[@"UILaunchImageName"];
            break;
        }
    }
    return [UIImage imageNamed:launchImage];
}

+ (UIImage *)sd_animatedGIFNamed:(NSString *)name {
    CGFloat scale = [UIScreen mainScreen].scale;
    
    if (scale > 1.0f) {
        NSString *retinaPath = [[NSBundle mainBundle] pathForResource:[name stringByAppendingString:@"@2x"] ofType:@"gif"];
        
        NSData *data = [NSData dataWithContentsOfFile:retinaPath];
        
        if (data) {
            return [UIImage sd_animatedGIFWithData:data];
        }
        
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
        
        data = [NSData dataWithContentsOfFile:path];
        
        if (data) {
            return [UIImage sd_animatedGIFWithData:data];
        }
        
        return [UIImage imageNamed:name];
    }
    else {
        NSString *path = [[NSBundle mainBundle] pathForResource:name ofType:@"gif"];
        
        NSData *data = [NSData dataWithContentsOfFile:path];
        
        if (data) {
            return [UIImage sd_animatedGIFWithData:data];
        }
        
        return [UIImage imageNamed:name];
    }
}

//2.保持原来的长宽比，生成一个缩略图

-(UIImage*_Nonnull)imageWithImage:(UIImage*_Nonnull)image scaledToSize:(CGSize)newSize
{
    
    int tempWidth               = image.size.width;
    int tempHeight              = image.size.height;
    
    UIImage *resultImg=nil;
    
    if(tempWidth <= newSize.width && tempHeight <= newSize.height)
        resultImg=image;
    else
    {
        float tempRate          = (float)newSize.width/tempWidth < (float)newSize.height/tempHeight ? (float)newSize.width/tempWidth : (float)newSize.height/tempHeight;
        CGSize itemSize         = CGSizeMake(tempRate*tempWidth, tempRate*tempHeight);
        UIGraphicsBeginImageContext(itemSize);
        CGRect imageRect        = CGRectMake(0, 0,itemSize.width,itemSize.height);
        [image drawInRect:imageRect];
        resultImg= UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    }
    
    
    float scale                 = resultImg.size.width/KScreenWidth;
    
    CGRect rect                 =  CGRectMake(5.0f*scale, 5.0f*scale,500.0f*scale, 500.0f*scale); //要裁剪的图片区域，按照原图的像素大小来，超过原图大小的边自动适配
    
    CGImageRef cgimg            = CGImageCreateWithImageInRect([resultImg CGImage], rect);
    
    resultImg                   = [UIImage imageWithCGImage:cgimg];
    
    CGImageRelease(cgimg);//用完一定要释放，否则内存泄露
    
    return resultImg;
    
}


@end


@implementation NSDictionary (Extension)
@dynamic jsonString;
/**
 把字典中的键值对 如果是字符串的替换成字典或者数组
 */
- (NSDictionary *_Nonnull) replaceJsonToObject {
    
    __block NSMutableDictionary *result      = [NSMutableDictionary dictionaryWithDictionary:self];
    [result enumerateKeysAndObjectsUsingBlock:^(NSString *key,id value, BOOL * _Nonnull stop) {
        if ([value isKindOfClass:[NSString class]]) {
            NSDictionary *dic = [(NSString *)value jsonStringToData];
            result[key]       = dic;
        }
    }];
    return result;
}

/**
 把字典转成 json 字符串
 */
- (NSString *_Nullable)jsonString {
    NSData *data = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
    return [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
}



@end


