//
//  CYPhotosCollectionViewCell.m
//  CYPhotoKit
//
//  Created by 董招兵 on 16/7/6.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import "CYPhotosCollectionViewCell.h"
#import "CYPhotosKit.h"

@interface CYPhotosCollectionViewCell ()
@property (nonatomic,strong) UIView *coverView;
@property (nonatomic,strong) UIButton *selectButton;
@end

@implementation CYPhotosCollectionViewCell

- (void)awakeFromNib {
    // Initialization code
    
    [super awakeFromNib];

    self.imageView.contentMode   = UIViewContentModeScaleAspectFill;
    self.imageView.clipsToBounds = YES;
    self.backgroundColor         = [UIColor whiteColor];

    [self.contentView addSubview:self.coverView];
    [self.coverView addSubview:self.selectButton];
    
    
}

- (UIView *)coverView {
    if (!_coverView) {
        _coverView                 = [[UIView alloc] init];
        _coverView.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.30f];
    }
    return _coverView;
}

- (UIButton *)selectButton {
    if (!_selectButton) {
        _selectButton                        = [UIButton buttonWithType:UIButtonTypeCustom];
        UIImage *img = [UIImage imageNamed:imageNameInBundle(@"AssetsPickerChecked") inBundle:bundleWithClass(self) compatibleWithTraitCollection:nil];
        [_selectButton setImage:img forState:UIControlStateNormal];
        _selectButton.userInteractionEnabled = NO;
    }
    return _selectButton;
}

- (void)setPhotosAsset:(PHAsset *)photosAsset {
    _photosAsset    = photosAsset;
   
    __weak typeof(self)weakSelf = self;
    
    /**
     synchronous：指定请求是否同步执行。
     resizeMode：对请求的图像怎样缩放。有三种选择：None，不缩放；Fast，尽快地提供接近或稍微大于要求的尺寸；Exact，精准提供要求的尺寸。
     deliveryMode：图像质量。有三种值：Opportunistic，在速度与质量中均衡；HighQualityFormat，不管花费多长时间，提供高质量图像；FastFormat，以最快速度提供好的质量。
     这个属性只有在 synchronous 为 true 时有效。
     
     */
    
    
    PHImageRequestOptions *option = [[PHImageRequestOptions alloc] init];
    option.synchronous  = NO;
    option.resizeMode   = PHImageRequestOptionsResizeModeFast;
    option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    
    [self.imageManager requestImageForAsset:_photosAsset
                                 targetSize:CGSizeMake(250.0f, 250.0f)
                                contentMode:PHImageContentModeAspectFill
                                    options:option
                              resultHandler:^(UIImage *result, NSDictionary *info) {
                                  __strong typeof(weakSelf)strongSelf = weakSelf;
                                  if (![NSThread mainThread]) {
                                      [[NSOperationQueue mainQueue] addOperationWithBlock:^{
                                          strongSelf.imageView.image = result;
                                      }];
                                  } else {
                                      strongSelf.imageView.image = result;
                                      
                                  }
                              }];
    
    

}

- (void)setSelectItem:(BOOL)selectItem {
    _selectItem           = selectItem;
    
    self.coverView.hidden = !_selectItem;
  
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.coverView.frame    = self.contentView.bounds;
    self.selectButton.frame = CGRectMake(self.contentView.frame.size.width-30.0f, self.contentView.frame.size.height-30.0f, 25.0f, 25.0f);
    
}

- (void)dealloc {
    
//    CYLog(@"--dealloc--\n");
    
}
@end
