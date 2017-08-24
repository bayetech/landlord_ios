//
//  EMIMHelper.h
//  CustomerSystem-ios
//
//  Created by dhc on 15/3/28.
//  Copyright (c) 2015年 easemob. All rights reserved.
//


#import <Foundation/Foundation.h>
#import <HyphenateLite/HyphenateLite.h>

@class Userinfo;
@class BKTabBarViewController;
@class BYContactViewController;
@class BKMessageViewController;
@class BKConversationModel;
@class BKAuthorizationToken;

@interface EMIMHelper : NSObject

NS_ASSUME_NONNULL_BEGIN

@property (weak,nonatomic) BKMessageViewController *messageViewController;

@property (weak,nonatomic) BKTabBarViewController *mainTabBarController;
/** contactViewController  */
@property (nonatomic,weak,nullable) BYContactViewController *contactViewController;

+ (instancetype) shared;

/**
 *  登出环信 sdk
 */
- (void) loginOutEaseMobHelper;

/**
 环信登录
 */
- (void) loginInEaseMob:(BKAuthorizationToken *)authorization loginSuccessCompletion:(void(^ _Nullable)(EMError *_Nullable aError) )completion;

/**
 登录环信账号成功
 */
- (void) easeMobLoginSuccess;


/**
 进入聊天室开始聊天 0单聊 1 群聊
 */
- (void)hy_chatRoomWithConversationChatter:(NSString *)conversatonId
                       soureViewController:(UIViewController *)viewController;

/**
 加载用户会话数据
 */
- (void) loadConversationsCompletion:(void(^)(NSArray<BKConversationModel *>*conversations))callBack;

#pragma mark - EMSetup
/**
 获取用户所在群组
 */
- (void)asyncJoinGroupsFromServer;

/**
 获取用户所在群组
 */
- (void)asyncCustomerUserFromServer;
/**
 获取用户的所有会话
 */
- (void) asyncUserConversations;

/**
 获取环信服务器上的群组信息
 */
- (void) getEaseMobChatGroups;

/**
 当收到消息时播放声音
 */
- (void)playSoundAndVibration;


/**
 设置人脉tabbarItem.badgeValue
 */
- (void)setupContactViewBadgeValue;

/**
 设置消息页面未读消息的提示数字
 */
- (void) setupMessageViewControllerBadgeValue;


/**
 显示红包现象
 */
- (NSDictionary *)showRedPacketMessage:(NSDictionary *)data;

/**
 发送一个文本消息
 
 @param text 文字
 @param to 接收者
 @param ext 拓展内容
 */
- (void) sendText:(NSString *_Nonnull)text toBody:(NSString *_Nullable)to ext:(NSDictionary *_Nullable)ext;



@end


NS_ASSUME_NONNULL_END


@interface BKNotifications : NSObject

@property (nonatomic,copy,nullable) NSString *title;

@property (nonatomic,copy,nullable) NSString *alert;

@property (nonatomic,copy,nullable) NSString *identifier;

@property (nonatomic,assign) EMMessageBodyType bodyType;

@property (nonatomic,nullable) NSString *filePath;

@property (nonatomic,nullable,copy) NSString *from;

- (instancetype _Nonnull) initWithTitle:(NSString *_Nullable)aTitle
                         alert:(NSString *_Nullable)aAlert identifier:(NSString *_Nonnull)aIdentifier
                      bodyType:(EMMessageBodyType)type;
@end
