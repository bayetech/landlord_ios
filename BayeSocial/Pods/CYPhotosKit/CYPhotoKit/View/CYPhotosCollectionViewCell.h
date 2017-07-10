//
//  CYPhotosCollectionViewCell.h
//  CYPhotoKit
//
//  Created by 董招兵 on 16/7/6.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>


/**
 *  单个相片的 collectionView
 */
@interface CYPhotosCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic,nullable) IBOutlet UIImageView *imageView;

/** photosAsset  */
@property (nonatomic,strong,nullable) PHAsset *photosAsset;

/** imageManager  */
@property (nonatomic, weak,nullable) PHCachingImageManager *imageManager;

/** selectItem */
@property (nonatomic,assign,getter=isSelectItem) BOOL selectItem;


@end
