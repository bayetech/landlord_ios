//
//  EseeRedPacketMessageCell.m
//  BayeSocial
//
//  Created by dzb on 2016/12/28.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import "EaseRedPacketMessageCell.h"
#import "BKMessageBaseFrame.h"
#import "BayeSocial-Swift.h"

@implementation EaseRedPacketMessageCell

- (UILabel *)blessingsLabel {
    if (!_blessingsLabel) {
        _blessingsLabel             = [[UILabel alloc] init];
//        _blessingsLabel.text        = @"恭喜发财,大吉大利";
        _blessingsLabel.font        = [UIFont systemFontOfSize:15.0f];
        _blessingsLabel.textColor   = [UIColor whiteColor];
    }
    return _blessingsLabel;
}

- (UILabel *)getRedPacketLabel {
    if (!_getRedPacketLabel) {
        _getRedPacketLabel             = [[UILabel alloc] init];
        _getRedPacketLabel.text        = @"领取红包";
        _getRedPacketLabel.font        = [UIFont systemFontOfSize:13.0f];
        _getRedPacketLabel.textColor   = [UIColor whiteColor];
    }
    return _getRedPacketLabel;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel             = [[UILabel alloc] init];
        _titleLabel.text        = @"巴爷汇红包";
        _titleLabel.font        = [UIFont systemFontOfSize:10.0f];
        _titleLabel.textColor   = [UIColor colorWithHexString:@"#ACACAC"];
    }
    return _titleLabel;
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.bubbleImageView addSubview:self.blessingsLabel];
        [self.bubbleImageView addSubview:self.getRedPacketLabel];
        [self.bubbleImageView addSubview:self.titleLabel];
        
    }
    
    return self;
    
}

- (void)setFrameModel:(EaseRedPacketMessageFrame *)frameModel {
    
    [super setFrameModel:frameModel];
    
    self.bubbleImageView.frame      = self.frameModel.bubbleFrame;
    
    UIImage *bubbleImage            = self.frameModel.isSender ? [UIImage imageNamed:@"redpacket_bubble"] : [UIImage imageNamed:@"redpacket_other"];
    
    [self.bubbleImageView setBackgroundImage:bubbleImage forState:UIControlStateNormal];
    
    self.blessingsLabel.frame       = self.frameModel.blessingsLabelFrame;
    
    self.getRedPacketLabel.frame    = self.frameModel.getRedPacketLabelFrame;

    self.titleLabel.frame           = self.frameModel.titleLabelFrame;
    
    // 获取红包内容详情
    NSDictionary *send_red_packets  = self.frameModel.ext[@"send_red_packets"];
    NSString *redPacketMessage      = send_red_packets[@"message"];
    self.redpacketId                = send_red_packets[@"uid"];
    
    self.blessingsLabel.text        = redPacketMessage;

}


@end



