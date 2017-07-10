//
//  EseeRedPacketMessageCell.h
//  BayeSocial
//
//  Created by dzb on 2016/12/28.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import "BKMessageBaseCell.h"
@class BKMessageBaseFrame , BKCustomersContact;

/**
 抢红包的 cell
 */
@interface EaseRedPacketMessageCell : BKMessageBaseCell

/**
 祝福语的 label
 */
@property (nonatomic,strong,nullable) UILabel *blessingsLabel;

/**
 领取红包的 label
 */
@property (nonatomic,strong,nullable) UILabel *getRedPacketLabel;

/**
 巴金红包的 label
 */
@property (nonatomic,strong,nullable) UILabel *titleLabel;


/**
 红包的 id
 */
@property (nonatomic,copy,nullable) NSString *redpacketId;


@end



