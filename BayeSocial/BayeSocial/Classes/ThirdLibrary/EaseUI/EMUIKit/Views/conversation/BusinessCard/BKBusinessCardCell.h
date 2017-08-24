//
//  BKBusinessCardCell.h
//  BayeSocial
//
//  Created by dzb on 2017/1/5.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

#import "BKMessageBaseCell.h"

/**
 用户名片的 cell
 */
@interface BKBusinessCardCell : BKMessageBaseCell

/**
 当前用户的名片气泡图片
 */
@property (nonatomic,nullable,strong) UIImage *bubbleUserImg;

/**
 其他用户的名片气泡图片
 */
@property (nonatomic,nullable,strong) UIImage *bubbleOtherImg;

/**
 被推荐用户的姓名
 */
@property (nonatomic,nullable,strong) UILabel *referrerTitleLabel;

/**
 被推荐用户的头像
 */
@property (nonatomic,nullable,strong) UIImageView *referrerAvatarImageView;

/**
 被推荐用户的职务
 */
@property (nonatomic,nullable,strong) UILabel *referrerPositionLabel;

/**
 被推荐用户的公司
 */
@property (nonatomic,nullable,strong) UILabel *referrerCompanyLabel;


@end
