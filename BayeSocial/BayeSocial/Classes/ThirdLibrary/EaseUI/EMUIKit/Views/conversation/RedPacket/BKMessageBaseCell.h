//
//  BKMessageBaseCell.h
//  BayeSocial
//
//  Created by dzb on 2016/12/29.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BKMessageBaseFrame , EaseRedPacketMessageCell,BKAdjustButton;

@protocol EaseRedPacketMessageCellDelegate;

/**
 消息的basecell
 */
@interface BKMessageBaseCell : UITableViewCell

/**
 头像
 */
@property (nonatomic,nullable,strong) UIImageView *avatarImageView;

/**
 名称
 */
@property (nonatomic,nullable,strong) UILabel *nameLabel;

/**
 气泡
 */
@property (nonatomic,nullable,strong) BKAdjustButton *bubbleImageView;

/**
 frame 模型
 */
@property (nonatomic,nullable,strong) BKMessageBaseFrame *frameModel;


/**
 delegate
 */
@property (nonatomic,weak,nullable) id <EaseRedPacketMessageCellDelegate> delegate;

/**
 点击了气泡
 */
- (void) bubbleImageViewTap:(UITapGestureRecognizer *_Nullable)tap;

@end


@protocol EaseRedPacketMessageCellDelegate <NSObject>

@optional

/**
 点击了用户头像
 */
- (void) bkMessageCell:(BKMessageBaseCell *_Nullable)cell
   didSelectUserAvatar:(NSString *_Nullable)userId;

/**
 点击了红包视图
 */
- (void)        bkMessageCell:(EaseRedPacketMessageCell *_Nullable)cell
     didSelectBubbleImageView:(BKMessageBaseFrame *_Nullable)farmeModel;

/**
 点击长按气泡 
 */
- (void)        bkMessageCell:(BKMessageBaseCell *_Nullable)cell
  didLongPressBubbleImageView:(UILongPressGestureRecognizer *_Nullable)longPress
                   frameModel:(BKMessageBaseFrame *_Nullable)aFrameModel;

/**
 点击了用户名片的气泡
 */
- (void) bkUserCardCell:(BKMessageBaseCell *_Nullable)cell didSelectBubbleImageView:(BKCustomersContact *_Nullable)user;

@end
