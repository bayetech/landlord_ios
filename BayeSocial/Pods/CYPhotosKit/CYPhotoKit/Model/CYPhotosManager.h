//
//  CYPhotosManager.h
//  CYPhotoKit
//
//  Created by 董招兵 on 16/7/5.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
@class CYPhotosCollection;

/**
 *  照片资源获取的管理者
 */
@interface CYPhotosManager : NSObject

/**
 *  获取图片资源管理者实例
 */
+ (_Nullable instancetype)defaultManager;

/**
 *  所有照片的集合
 */
- (NSMutableArray <CYPhotosCollection *>*_Nullable)requestAllPhotosOptions;

/**
 *  系统创建的一些相册
 */
- (NSMutableArray <CYPhotosCollection *>*_Nullable)requestSmartAlbums;

/**
 *  用户自己创建的相册
 */
- (NSMutableArray <CYPhotosCollection *>*_Nullable)requestTopLevelUserCollections;


@end
