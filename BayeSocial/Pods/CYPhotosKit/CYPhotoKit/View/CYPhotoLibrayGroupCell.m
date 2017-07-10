//
//  CYPhotoLibrayGroupCell.m
//  CYPhotoKit
//
//  Created by 董招兵 on 16/7/5.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import "CYPhotoLibrayGroupCell.h"
#import "CYPhotosKit.h"

@implementation CYPhotoLibrayGroupCell

- (void)awakeFromNib {
    // Initialization code
    [super awakeFromNib];
    self.accessoryType                = UITableViewCellAccessoryDisclosureIndicator;
    self.photoImageView.contentMode   = UIViewContentModeScaleAspectFill;
    self.photoImageView.clipsToBounds = YES;
    UIImage *img = [UIImage imageNamed:imageNameInBundle(@"xiangqing_add2") inBundle:bundleWithClass(self) compatibleWithTraitCollection:nil];
    
    [self.photoImageView setImage:img];
    
}

- (void)dealloc {
    
//    CYLog(@"--dealloc--\n");

}

@end
