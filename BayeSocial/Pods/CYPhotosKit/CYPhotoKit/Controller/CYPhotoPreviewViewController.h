//
//  CYPhotoPreviewViewController.h
//  CYPhotoKit
//
//  Created by dzb on 16/9/22.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CYPhotosAsset;
/**
 *  照片预览的控制器
 */
@interface CYPhotoPreviewViewController : UIViewController

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (nonatomic,strong) NSMutableArray <CYPhotosAsset *> *soureImages;

@end
