//
//  BKDidOpenRedPacketCell.m
//  BayeSocial
//
//  Created by dzb on 2016/12/30.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import "BKDidOpenRedPacketCell.h"
#import "BayeSocial-Swift.h"

@implementation BKDidOpenRedPacketCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        
        [self.contentView addSubview:self.bubbleView];
        [self.bubbleView addSubview:self.titleLabel];
        [self.bubbleView addSubview:self.smallRedpacketView];
        self.selectionStyle                 = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor    = [UIColor clearColor];
        self.backgroundColor                = [UIColor clearColor];
        
    }
    return self;
}
- (UIImageView *)smallRedpacketView {
    if (!_smallRedpacketView) {
        _smallRedpacketView = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 4.5f, 12.0f, 16.0f)];
        _smallRedpacketView.image = [UIImage imageNamed:@"smail_redpacket"];
    }
    return _smallRedpacketView;
}
- (void)setText:(NSString *)text {
    _text = [text copy];
    
    // 如果字符串大于20进行截取,显示不下的...代替
    NSInteger maxLength = [[CYLayoutConstraint shareInstance] getCurrentLayoutContraintValue:20.0f];
    if ([_text length] > maxLength) {
        _text = [NSString stringWithFormat:@"%@...",[_text substringToIndex:maxLength]];
    }
    
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:_text attributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    NSRange range                               = [_text rangeOfString:@"红包"];
    if (range.location != NSNotFound) {
        [attributedString setAttributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"#F1972C"]} range:range];
    }
    
    self.titleLabel.attributedText              = attributedString;
    [self.titleLabel    sizeToFit];
    [self.titleLabel    setHeight:25.0f];
    
    CGFloat bubbleWidth                         = self.titleLabel.right + 20.0f;
    CGFloat maxWidth                            = KScreenWidth - 20.0f;
    
    if (bubbleWidth > maxWidth) {
        bubbleWidth = maxWidth;
    }

    [self.bubbleView setWidth:bubbleWidth];
    
    CGFloat bubbleX                             = (KScreenWidth - bubbleWidth)/2.0f;

    [self.bubbleView setX:bubbleX];
    
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    
}

- (UIView *)bubbleView {
    if (!_bubbleView) {
        _bubbleView                     = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 153.0f, 25.0f)];
        _bubbleView.backgroundColor     = [UIColor RGBColor:205.0f green:205.0f blue:205.0f];
        _bubbleView.layer.cornerRadius  = 3.0f;
        _bubbleView.layer.masksToBounds = YES;
    }
    return _bubbleView;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel         = [[UILabel alloc] initWithFrame:CGRectMake(30.0f, 0.0f, 100.0f, 25.0f)];
        _titleLabel.font    = [UIFont systemFontOfSize:14.0f];
    }
    return _titleLabel;
}
@end
