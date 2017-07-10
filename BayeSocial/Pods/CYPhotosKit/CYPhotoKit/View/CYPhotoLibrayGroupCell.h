//
//  CYPhotoLibrayGroupCell.h
//  CYPhotoKit
//
//  Created by 董招兵 on 16/7/5.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import <UIKit/UIKit.h>
/**
 *  相册分组的 cell
 */
@interface CYPhotoLibrayGroupCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *photoImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@end
