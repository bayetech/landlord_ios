//
//  BKBusinessCardCell.m
//  BayeSocial
//
//  Created by dzb on 2017/1/5.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

#import "BKBusinessCardCell.h"
#import "BKMessageBaseFrame.h"
#import "BayeSocial-Swift.h"

@interface BKBusinessCardCell ()
{
    BKCustomersContact *_referrerUser;
}
@end

@implementation BKBusinessCardCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {

        UIImage *otherBubble        = [UIImage imageNamed:@"bubbleOther"];
        self.bubbleOtherImg         = [[UIImage imageNamed:@"bubbleOther"] stretchableImageWithLeftCapWidth:otherBubble.size.width *0.5f topCapHeight:otherBubble.size.height *0.7f];
        self.bubbleUserImg          = [[UIImage imageNamed:@"EaseUIResource.bundle/chat_sender_bg"] stretchableImageWithLeftCapWidth:5 topCapHeight:35];
    
        [self.bubbleImageView addSubview:self.referrerTitleLabel];
        [self.bubbleImageView addSubview:self.referrerAvatarImageView];
        [self.bubbleImageView addSubview:self.referrerCompanyLabel];
        [self.bubbleImageView addSubview:self.referrerPositionLabel];

    }
    
    return self;
    
}

- (void)setFrameModel:(BKMessageBaseFrame *)frameModel {
    
    [super setFrameModel:frameModel];
    
    self.bubbleImageView.frame          = frameModel.bubbleFrame;
    [self.bubbleImageView setBackgroundImage:frameModel.isSender ? self.bubbleUserImg : self.bubbleOtherImg forState:UIControlStateNormal];
    
//    NSDictionary *referrerUserCard      = self.frameModel.ext[@"userCard"][@"referrerUserCard"];
    _referrerUser                       = [[BKCustomersContact alloc] init];
    NSString *title                     = [NSString stringWithFormat:@"%@的名片",_referrerUser.name];
//    NSString *referrerAvatar            = _referrerUser.avatar;
    NSString *company                   = stringEmpty(_referrerUser.company) ? @"暂无" :_referrerUser.company;
    NSString *postion                   = stringEmpty(_referrerUser.company_position) ?  @"暂无" : _referrerUser.company_position;
    
    // 标题
    self.referrerTitleLabel.text        = title;
    self.referrerTitleLabel.frame       = self.frameModel.referrerTitleLabelFrame;
    
    // 被推荐人的头像
    self.referrerAvatarImageView.frame  = self.frameModel.referrerAvatarFrame;
    //MARK://
//    [self.referrerAvatarImageView setRoundImageWithURL:[NSURL URLWithString:referrerAvatar] placeHoder:[UIImage imageNamed:KUserImageName]];
    
    // 被推荐人的公司
    self.referrerCompanyLabel.frame     = self.frameModel.referrerCompanyLabelFrame;
    self.referrerCompanyLabel.text      = [NSString stringWithFormat:@"公司：%@",company];
    
    // 被推荐人的职务
    self.referrerPositionLabel.frame    = self.frameModel.referrerPositionLabelFrame;
    self.referrerPositionLabel.text     = [NSString stringWithFormat:@"职位：%@",postion];
    
    
}

- (void)bubbleImageViewTap:(UITapGestureRecognizer *)tap {
    if ([self.delegate respondsToSelector:@selector(bkUserCardCell:didSelectBubbleImageView:)]) {
        [self.delegate bkUserCardCell:self didSelectBubbleImageView:_referrerUser];
    }
}

- (UILabel *)referrerTitleLabel {
    if (!_referrerTitleLabel) {
        _referrerTitleLabel         = [[UILabel alloc] init];
        _referrerTitleLabel.font    = [[CYLayoutConstraint shareInstance] getLayoutContraintFont:12.0f];
    }
    return _referrerTitleLabel;
}
- (UILabel *)referrerCompanyLabel {
    if (!_referrerCompanyLabel) {
        _referrerCompanyLabel                   = [[UILabel alloc] init];
        _referrerCompanyLabel.font              = [[CYLayoutConstraint shareInstance] getLayoutContraintFont:11.0f];
        _referrerCompanyLabel.textColor         = [UIColor colorWithHexString:@"#858585"];
    }
    return _referrerCompanyLabel;
}
- (UILabel *)referrerPositionLabel {
    if (!_referrerPositionLabel) {
        _referrerPositionLabel                   = [[UILabel alloc] init];
        _referrerPositionLabel.font              = [[CYLayoutConstraint shareInstance] getLayoutContraintFont:11.0f];
        _referrerPositionLabel.textColor         = [UIColor colorWithHexString:@"#858585"];
    }
    return _referrerPositionLabel;
}
- (UIImageView *)referrerAvatarImageView {
    if (!_referrerAvatarImageView) {
        _referrerAvatarImageView = [[UIImageView alloc] init];
    }
    return _referrerAvatarImageView;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    
//    DTLog(@"---%@",NSStringFromCGRect(self.referrerTitleLabel.frame));
    
    
}
@end
