//
//  CYPhotoNavigationController.h
//  CYPhotoKit
// 上海触影文化传播有限公司 CY BK
//  Created by dongzb on 16/3/20.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CYPhotosAsset;
/**
 *  选取完照片的后的回调
 */
typedef void(^PhotosCompletion)(NSArray <CYPhotosAsset*> *_Nullable result);

@protocol CYPhotoNavigationControllerDelegate;
/**
 *  相册选择器的导航控制器
 */
@interface CYPhotoNavigationController : UINavigationController

/**
 *  类方法获取一个 photosNavigationController
 */
+ (_Nonnull instancetype)showPhotosViewController;

/**
 *  禁用 init 方法来生成该类的实例对象
 */
- (_Nonnull instancetype)init UNAVAILABLE_ATTRIBUTE;
/**
 *  禁用 new 方法来生成该类的实例对象
 */
+ (_Nonnull instancetype)new UNAVAILABLE_ATTRIBUTE;

/** completionBlock  */
@property (nonatomic,copy,nullable) PhotosCompletion completionBlock;

/** cyPhotosDelegate */
@property (nonatomic,weak,nullable) id <CYPhotoNavigationControllerDelegate,UINavigationControllerDelegate> delegate;
/**
 *  最大选择图片的数量
 */
@property (nonatomic,assign) NSInteger maxPickerImageCount;

@end

@protocol CYPhotoNavigationControllerDelegate <NSObject,UINavigationControllerDelegate>

@optional

/**
 *  照片选择器完成选择照片
 */
- (void)cyPhotoNavigationController:(CYPhotoNavigationController *_Nullable)controller didFinishedSelectPhotos:(NSArray <CYPhotosAsset*> *_Nullable)result;

@end
