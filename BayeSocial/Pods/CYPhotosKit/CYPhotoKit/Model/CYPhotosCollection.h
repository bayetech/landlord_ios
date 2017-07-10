//
//  CYPhotosAsset.h
//  CYPhotoKit
//
//  Created by 董招兵 on 16/7/5.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
/**
 *  代表一个集合可能是一个相册组也可能是所有 PHAsset 的集合
 */
@interface CYPhotosCollection : NSObject

/**
 *  集合里边放的是 PHAsset 对象
 */
@property (nonatomic,strong,nullable) PHFetchResult *fetchResult;
/**
 *  相册名称
 */
@property (nonatomic,copy,nullable  ) NSString      *localizedTitle;
/**
 *  相册里照片/视频的熟练
 */
@property (nonatomic,nullable,copy  ) NSString      *count;
/**
 *  相册封面取最新的一张照片作为封面
 */
@property (nonatomic,strong,nullable) UIImage       *thumbnail;

@end
