//
//  CYPhotoPreviewCollectionViewCell.m
//  CYPhotoKit
//
//  Created by dzb on 16/9/22.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import "CYPhotoPreviewCollectionViewCell.h"
#import "CYPhotosAsset.h"

@implementation CYPhotoPreviewCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.imageView.contentMode = UIViewContentModeScaleAspectFit;
    
}

- (void)setCyAsset:(CYPhotosAsset *)cyAsset {
    
    _cyAsset    = cyAsset;
    
    self.imageView.image = _cyAsset.originalImg;
    
    
}
@end
