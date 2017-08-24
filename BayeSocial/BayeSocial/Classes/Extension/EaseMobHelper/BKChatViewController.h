//
//  BKChatViewController.h
//  BKBayeStore
//
//  Created by 董招兵 on 2016/10/10.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import "EaseMessageViewController.h"
@class Userinfo,BKCustomersContact;

/**
 环信云通讯的聊天页面 分单聊 群聊
 */
@interface BKChatViewController : EaseMessageViewController
NS_ASSUME_NONNULL_BEGIN

/**
    用户资料信息用来显示头像 等一些信息
 */
@property (nonatomic,strong) Userinfo *userInfo;

/**
  会话类型  , 单聊 群聊 聊天室 环信移动客服
 */
@property (nonatomic,assign) EMConversationType conversationType;

NS_ASSUME_NONNULL_END

@end
