//
//  BKMessageBaseCell.m
//  BayeSocial
//
//  Created by dzb on 2016/12/29.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import "BKMessageBaseCell.h"
#import "BKMessageBaseFrame.h"
#import "BayeSocial-Swift.h"

@implementation BKMessageBaseCell

- (UIImageView *)avatarImageView {
    if (!_avatarImageView) {
        _avatarImageView                        = [[UIImageView alloc] init];
        [_avatarImageView setImage:[UIImage imageNamed:KUserImageName]];
        _avatarImageView.layer.cornerRadius     = 20.0f;
        _avatarImageView.layer.masksToBounds    = YES;
    }
    return _avatarImageView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel              = [[UILabel alloc] init];
        _nameLabel.font         = [UIFont systemFontOfSize:10.0f];
        _nameLabel.textColor    = [UIColor grayColor];
    }
    return _nameLabel;
}

- (UIButton *)bubbleImageView {
    if (!_bubbleImageView) {
        _bubbleImageView                        = [BKAdjustButton buttonWithType:UIButtonTypeCustom];
    }
    return _bubbleImageView;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        self.selectionStyle                 = UITableViewCellSelectionStyleNone;
        
        self.backgroundColor                = [UIColor clearColor];
        
        self.contentView.backgroundColor    = [UIColor clearColor];
        
        [self.contentView addSubview:self.avatarImageView];
        
        [self.contentView addSubview:self.nameLabel];
        
        [self.contentView addSubview:self.bubbleImageView];
        
        [self.avatarImageView addTarget:self action:@selector(avatarImageViewTap:)];
        [self.bubbleImageView addTarget:self action:@selector(bubbleImageViewTap:) forControlEvents:UIControlEventTouchUpInside];
        

    }
    
    return self;
    
}

- (void)setFrameModel:(BKMessageBaseFrame *)frameModel {
    
    _frameModel                     = frameModel;
    
    // 头像
    self.avatarImageView.frame      = _frameModel.avatarImageViewFrame;
    
    
//    [self.avatarImageView setRoundImageWithURL:[NSURL URLWithString:_frameModel.avatar] placeHoder:[UIImage imageNamed:KUserImageName]];
    
    [self.avatarImageView sd_setImageWithURL:[NSURL URLWithString:_frameModel.avatar] placeholderImage:[UIImage imageNamed:KUserImageName]];
    
    // 名称
    self.nameLabel.frame            = _frameModel.nameLabelFrame;
    
    self.nameLabel.text             = _frameModel.name;

    self.nameLabel.textAlignment    = _frameModel.isSender ? NSTextAlignmentRight : NSTextAlignmentLeft;
    
}

/**
 点击了头像
 */
- (void)avatarImageViewTap:(UITapGestureRecognizer *)tap {
    DTLog(@"---%@",self.frameModel.customerUser.uid);
    if ([self.delegate respondsToSelector:@selector(bkMessageCell:didSelectUserAvatar:)]) {
        [self.delegate bkMessageCell:self didSelectUserAvatar:self.frameModel.uid];
    }
    
}

/**
 点击了气泡
 */
- (void) bubbleImageViewTap:(UIButton *)btn {
    
    if ([self.delegate respondsToSelector:@selector(bkMessageCell:didSelectBubbleImageView:)]) {
        [self.delegate bkMessageCell:(EaseRedPacketMessageCell*)self didSelectBubbleImageView:self.frameModel];
    }
    
}

/**
 长按点击气泡
 */
- (void)bubbleImageViewLongPress:(UILongPressGestureRecognizer *)tap {
  
    if ([self.delegate respondsToSelector:@selector(bkMessageCell:didLongPressBubbleImageView:frameModel:)]) {
        [self.delegate bkMessageCell:self didLongPressBubbleImageView:tap frameModel:self.frameModel];
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
//    DTLog(@"--> frame = %@",NSStringFromCGRect(self.nameLabel.frame));
    
}

@end
