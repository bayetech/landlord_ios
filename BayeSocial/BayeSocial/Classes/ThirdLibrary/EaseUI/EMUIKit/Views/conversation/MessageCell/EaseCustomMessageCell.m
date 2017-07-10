/************************************************************
 *  * Hyphenate CONFIDENTIAL
 * __________________
 * Copyright (C) 2016 Hyphenate Inc. All rights reserved.
 *
 * NOTICE: All information contained herein is, and remains
 * the property of Hyphenate Technologies.
 * Dissemination of this information or reproduction of this material
 * is strictly forbidden unless prior written permission is obtained
 * from Hyphenate Inc.
 */

#import "EaseCustomMessageCell.h"
#import "EaseBubbleView+Gif.h"
#import "IMessageModel.h"
#import <SDWebImage/UIImage+GIF.h>

@interface EaseCustomMessageCell ()

@end

@implementation EaseCustomMessageCell

+ (void)initialize
{
    // UIAppearance Proxy Defaults
}

#pragma mark - IModelCell

- (BOOL)isCustomBubbleView:(id<IMessageModel>)model
{
    return YES;
}

- (void)setCustomModel:(id<IMessageModel>)model
{
    UIImage *image = model.image;
    if (!image) {
        [self.bubbleView.imageView sd_setImageWithURL:[NSURL URLWithString:model.fileURLPath] placeholderImage:[UIImage imageNamed:model.failImageName]];
    } else {
        _bubbleView.imageView.image = image;
    }
    
    if (model.avatarURLPath) {
//        [self.avatarView setRoundImageWithURL:[NSURL URLWithString:model.avatarURLPath] placeHoder:model.avatarImage];
        [self.avatarView sd_setImageWithURL:[NSURL URLWithString:model.avatarURLPath] placeholderImage:model.avatarImage];
    } else {
        self.avatarView.image = model.avatarImage;
    }
}

- (void)setCustomBubbleView:(id<IMessageModel>)model
{
    [_bubbleView setupGifBubbleView];
    
    _bubbleView.imageView.image = [UIImage imageNamed:@"imageDownloadFail"];
}

- (void)updateCustomBubbleViewMargin:(UIEdgeInsets)bubbleMargin model:(id<IMessageModel>)model
{
    [_bubbleView updateGifMargin:bubbleMargin];
}

+ (NSString *)cellIdentifierWithModel:(id<IMessageModel>)model
{
    return model.isSender?@"EaseMessageCellSendGif":@"EaseMessageCellRecvGif";
}

+ (CGFloat)cellHeightWithModel:(id<IMessageModel>)model
{
    return 100;
}

@end
