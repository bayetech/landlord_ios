//
//  BKMessageBaseFrame.h
//  BayeSocial
//
//  Created by dzb on 2016/12/29.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 自定义消息 Cell 的 Frame 模型
 */
@interface BKMessageBaseFrame : NSObject

@property (nonatomic,assign)            CGRect avatarImageViewFrame;

@property (nonatomic,assign)            CGRect nameLabelFrame;

@property (nonatomic,assign)            CGRect bubbleFrame;

@property (nonatomic,assign)            CGRect blessingsLabelFrame;

@property (nonatomic,assign)            CGRect getRedPacketLabelFrame;

@property (nonatomic,assign)            CGRect titleLabelFrame;

@property (nonatomic,assign)            CGFloat rowHeight;

@property (nonatomic,strong,nullable)   id <IMessageModel> messageModel;

@property (nonatomic,strong,nullable)   BKCustomersContact *customerUser;

@property (nonatomic,copy,nullable)     NSString *avatar;

@property (nonatomic,copy,nullable)     NSString *name;

@property (nonatomic,copy,nullable)     NSString *uid;

@property (nonatomic,assign) BOOL       isSender;

@property (nonatomic,nullable,strong)   NSDictionary *ext;

@property (nonatomic,assign) CGRect     referrerTitleLabelFrame;
@property (nonatomic,assign) CGRect     referrerAvatarFrame;
@property (nonatomic,assign) CGRect     referrerPositionLabelFrame;
@property (nonatomic,assign) CGRect     referrerCompanyLabelFrame;


- (instancetype _Nonnull) initWithMessageModel:(id<IMessageModel> _Nonnull)messageModel customerUser:(BKCustomersContact *_Nonnull)user;

@end

/**
 红包的 frame 模型
 */
@interface EaseRedPacketMessageFrame : BKMessageBaseFrame


@end

@interface BKBusinessCardFrame : BKMessageBaseFrame


@end
