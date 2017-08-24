//
//  BKDidOpenRedPacketCell.h
//  BayeSocial
//
//  Created by dzb on 2016/12/30.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 领取红包的 cell
 */
@interface BKDidOpenRedPacketCell : UITableViewCell

/**
 气泡的 view
 */
@property (nonatomic,nullable,strong) UIView *bubbleView;

/**
 textLabel
 */
@property (nonatomic,nullable,strong) UILabel *titleLabel;

/**
    text
 */
@property (nonatomic,nullable,copy) NSString *text;

/**
 气泡的 view
 */
@property (nonatomic,nullable,strong) UIImageView *smallRedpacketView;

@end
