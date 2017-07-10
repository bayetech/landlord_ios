//
//  CYPhotoPreviewCollectionViewCell.h
//  CYPhotoKit
//
//  Created by dzb on 16/9/22.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CYPhotosAsset;
@interface CYPhotoPreviewCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *imageView;

@property (nonatomic,strong) CYPhotosAsset *cyAsset;

@end
