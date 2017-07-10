//
//  CYPhotoListViewController.h
//  CYPhotoKit
//
//  Created by 董招兵 on 16/7/5.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
@class CYPhotosAsset;
/**
 *  单个相册下的详情控制器
 */
@interface CYPhotoListViewController : UIViewController

NS_ASSUME_NONNULL_BEGIN

/** PHFetchResult  */
@property (nonatomic,strong,nullable) PHFetchResult <PHAsset *> *fetchResult;

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
/**
 *  预览按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *previewButton;
/**
 *  完成按钮
 */
@property (weak, nonatomic) IBOutlet UIButton *finishedButton;
/**
 *  数字 label
 */
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
/**
 *  最大选取照片数量
 */
@property (weak, nonatomic) IBOutlet UILabel *maxImageLabel;

/**
 *  预览按钮点击
 */
- (IBAction)previewButtonClick:(id)sender;
/**
 *  完成按钮点击
 */
- (IBAction)finishedButtonClick:(id)sender;



NS_ASSUME_NONNULL_END

@end
