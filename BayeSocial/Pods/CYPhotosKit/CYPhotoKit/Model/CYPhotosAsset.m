//
//  CYPhotoAsset.m
//  CYPhotoKit
//
//  Created by 董招兵 on 16/7/6.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import "CYPhotosAsset.h"

@implementation CYPhotosAsset

- (void)setAsset:(PHAsset *)asset {
    _asset  = asset;
    
    __weak typeof(self)weakSelf = self;
    
    PHImageManager *imageManager = [PHImageManager defaultManager];
    
    // 获取图片的缩略图
    [imageManager requestImageForAsset:self.asset
                            targetSize:CGSizeMake(250.0f, 250.0f)
                           contentMode:PHImageContentModeAspectFill
                               options:nil
                         resultHandler:^(UIImage *result, NSDictionary *info) {
                            _thumbnail = result;
                         }];

    // 获取图片的原图
    PHImageRequestOptions *option  = [[PHImageRequestOptions alloc] init];
    [imageManager requestImageDataForAsset:_asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        strongSelf.imageData = imageData;
        strongSelf.imageUrl = info[@"PHImageFileURLKey"];
    }];

}

- (UIImage *)originalImg {
    if (!_originalImg) {
        _originalImg = [[UIImage alloc] initWithData:self.imageData];
    }
    return _originalImg;
}

- (void)dealloc {
    
//    CYLog(@"--dealloc--\n");
    
}
@end
