//
//  BKMessageBaseFrame.m
//  BayeSocial
//
//  Created by dzb on 2016/12/29.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import "BKMessageBaseFrame.h"
#import "BayeSocial-Swift.h"

@implementation BKMessageBaseFrame

- (instancetype _Nonnull) initWithMessageModel:(id<IMessageModel> _Nonnull)messageModel customerUser:(BKCustomersContact *_Nonnull)user {
    
    
    if (self = [super init]) {

        self.messageModel               = messageModel;
        self.customerUser               = user;
        self.isSender                   = messageModel.isSender;
        self.ext                        = self.messageModel.message.ext;
        self.uid                        = self.messageModel.message.from;
        self.name                       = _customerUser.name;
        self.avatar                     = _customerUser.avatar;
        
        if (!self.customerUser) {
            
            NSDictionary *customer      = self.ext[@"customer"];
            self.name                   = customer[@"name"];
            self.avatar                 = customer[@"avatar"];
            
        }
        
        // 头像
        CGFloat avatarX             = self.isSender ? (KScreenWidth - 50.0f) : 10.0f;
        CGFloat avatarY             = 10.0f;
        CGFloat avatarW             = 40.0f;
        CGFloat avatarH             = 40.0f;
        self.avatarImageViewFrame   = CGRectMake(avatarX, avatarY, avatarW, avatarH);
        
        // 姓名
        CGFloat namelabelX          = self.isSender ? (CGRectGetMinX(self.avatarImageViewFrame) - 110.0f) : CGRectGetMaxX(self.avatarImageViewFrame) + 10.0f;
        CGFloat namelabelY          = 0.0f;
        CGFloat namelabelW          = 100.0f;
        CGFloat nameLabelH          = 15.0f;
        
        self.nameLabelFrame         = CGRectMake(namelabelX, namelabelY, namelabelW, nameLabelH);
        
        self.rowHeight              = 100.0f;
        
    }
    
    return  self;
}



@end

@implementation EaseRedPacketMessageFrame

- (instancetype)initWithMessageModel:(id<IMessageModel>)messageModel customerUser:(BKCustomersContact *)user {
    
    if (self = [super initWithMessageModel:messageModel customerUser:user]) {
        
        
        // 红包的气泡
        CGFloat bubuleImageY        = 14.0f;
        CGFloat bubbleImageW        = [[CYLayoutConstraint shareInstance] getCurrentLayoutContraintValue:240.0f];
        
        CGFloat bubbleImageH        = [[CYLayoutConstraint shareInstance] getCurrentLayoutContraintValue:94.0f];
        
        CGFloat bubbleImageX        = self.isSender ? CGRectGetMaxX(self.nameLabelFrame) - bubbleImageW + 7.0f: self.nameLabelFrame.origin.x - 7.0f;
        
        self.bubbleFrame            = CGRectMake(bubbleImageX, bubuleImageY, bubbleImageW, bubbleImageH);
        
        //  红包祝福语的 label
        CGFloat blessingsLabelX     = self.isSender ? 60.0f : 68.0f;
        CGFloat blessingsLabelY     = [[CYLayoutConstraint shareInstance] getLayoutConstraintFontSize:20.0f];
        CGFloat blessingsLabelW     = [[CYLayoutConstraint shareInstance] getLayoutConstraintFontSize:bubbleImageW - 40.0f - blessingsLabelX];
        CGFloat blessingsLabelH     = 20.0f;
        
        self.blessingsLabelFrame    = CGRectMake(blessingsLabelX, blessingsLabelY, blessingsLabelW, blessingsLabelH);
        
        // 领取红包的 label
        CGFloat getRedPacketLabelX  = blessingsLabelX;
        CGFloat getRedPacketLabelY  = CGRectGetMaxY(self.blessingsLabelFrame) + 5.0f;
        CGFloat getRedPacketLabelW  = blessingsLabelW;
        CGFloat getRedPacketLabelH  = 20.0f;
        
        self.getRedPacketLabelFrame = CGRectMake(getRedPacketLabelX, getRedPacketLabelY, getRedPacketLabelW, getRedPacketLabelH);
        
        /// 标题 label
        CGFloat titleLabelX         = self.isSender ? 12.0f : 20.0f;
        CGFloat titleLabelY         = bubbleImageH - 18.0f;
        CGFloat titleLabelW         = 100.0f;
        CGFloat titleLabelH         = 20.0f;
        
        self.titleLabelFrame        = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
        
        self.rowHeight              = CGRectGetMaxY(self.bubbleFrame) + 10.0f;
        
    }
    return self;
}


@end

@implementation BKBusinessCardFrame


- (instancetype)initWithMessageModel:(id<IMessageModel>)messageModel customerUser:(BKCustomersContact *)user {
    
    if (self = [super initWithMessageModel:messageModel customerUser:user]) {
                
        
        // 红包的气泡
        CGFloat bubuleImageY                = 0.0f;
        CGFloat bubbleImageW                = [[CYLayoutConstraint shareInstance] getCurrentLayoutContraintValue:250.0f];
        
        CGFloat bubbleImageH                = [[CYLayoutConstraint shareInstance] getCurrentLayoutContraintValue:73.5f];
        
        CGFloat bubbleImageX                = self.isSender ? CGRectGetMaxX(self.nameLabelFrame) - bubbleImageW + 7.0f: self.nameLabelFrame.origin.x - 7.0f;
        
        self.bubbleFrame                    = CGRectMake(bubbleImageX, bubuleImageY, bubbleImageW, bubbleImageH);
        
        CGFloat titleLabelX                 = self.isSender ? [[CYLayoutConstraint shareInstance] getCurrentLayoutContraintValue:8.0f] : [[CYLayoutConstraint shareInstance] getCurrentLayoutContraintValue:12.0f];
        
        CGFloat titleLabelY                 = [[CYLayoutConstraint shareInstance] getCurrentLayoutContraintValue:8.0f];
        
        CGFloat titleLabelW                 = CGRectGetWidth(self.bubbleFrame) - 20.0f;
        
        CGFloat titleLabelH                 = [[CYLayoutConstraint shareInstance] getCurrentLayoutContraintValue:15.0f];
        
        self.referrerTitleLabelFrame        = CGRectMake(titleLabelX, titleLabelY, titleLabelW, titleLabelH);
        
        
        CGFloat referrerImageViewX          = titleLabelX;
        
        CGFloat referrerImageViewY          = CGRectGetMaxY(self.referrerTitleLabelFrame) + [[CYLayoutConstraint shareInstance] getCurrentLayoutContraintValue:4.0f];
        
        CGFloat referrerImageViewW          = [[CYLayoutConstraint shareInstance] getCurrentLayoutContraintValue:40.0f];
        
        CGFloat referrerImageViewH          = [[CYLayoutConstraint shareInstance] getCurrentLayoutContraintValue:40.0f];
        
        self.referrerAvatarFrame            = CGRectMake(referrerImageViewX, referrerImageViewY, referrerImageViewW, referrerImageViewH);
        
        
        CGFloat companyLabelX               = CGRectGetMaxX(self.referrerAvatarFrame) + [[CYLayoutConstraint shareInstance] getCurrentLayoutContraintValue:5.0f];
        CGFloat companyLabelY               = referrerImageViewY;
        CGFloat companyLabelW               = CGRectGetWidth(self.bubbleFrame) - [[CYLayoutConstraint shareInstance] getCurrentLayoutContraintValue:65.0f];
        CGFloat companyLabelH               = [[CYLayoutConstraint shareInstance] getCurrentLayoutContraintValue:15.0f];
        
        self.referrerCompanyLabelFrame      = CGRectMake(companyLabelX, companyLabelY, companyLabelW, companyLabelH);
        
        CGFloat positionLabelX              = companyLabelX;
        CGFloat positionLabelY              = CGRectGetMaxY(self.referrerCompanyLabelFrame) + [[CYLayoutConstraint shareInstance] getCurrentLayoutContraintValue:3.5f];
        CGFloat positionLabelW              = companyLabelW;
        CGFloat positionLabelH              = companyLabelH;
        
        self.referrerPositionLabelFrame     = CGRectMake(positionLabelX, positionLabelY, positionLabelW, positionLabelH);
        
        self.rowHeight                      = CGRectGetMaxY(self.bubbleFrame) + 10.0f;
        
    }
    return self;
}

@end
