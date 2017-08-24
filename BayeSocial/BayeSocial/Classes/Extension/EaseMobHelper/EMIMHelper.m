//
//  EMIMHelper.m
//  CustomerSystem-ios
//
//  Created by dhc on 15/3/28.
//  Copyright (c) 2015年 easemob. All rights reserved.
//

#import "EMIMHelper.h"
#import "NSDate+Category.h"
#import "BKChatViewController.h"
#import "BayeSocial-Swift.h"
#import "EaseConvertToCommonEmoticonsHelper.h"

static NSString *const KNotificationIdentifierNormal        = @"normal";
static NSString *const KNotificationIdentifierText          = @"textBody";
static NSString *const KNotificationIdentifierImage         = @"imageBody";
static NSString *const KNotificationIdentifierVideo         = @"videoBody";
static NSString *const KNotificationIdentifierVoice         = @"voiceBody";

static const CGFloat kDefaultPlaySoundInterval = 3.0;

static EMIMHelper *helper = nil;

@interface EMIMHelper () <EMChatManagerDelegate,EMContactManagerDelegate,EMGroupManagerDelegate>

@property (nonnull,strong,nonatomic) NSDate *lastPlaySoundDate;

@end

@implementation EMIMHelper

+ (instancetype)shared {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [[EMIMHelper alloc] init];
        [helper initHelper];
    });
    return helper;
}

- (void)setContactViewController:(BYContactViewController *)contactViewController {
    _contactViewController   = contactViewController;
    [self setupContactViewBadgeValue];
}

- (void)setMessageViewController:(BKMessageViewController *)messageViewController {
    _messageViewController  = messageViewController;
    [self setupMessageViewControllerBadgeValue];
    
}

- (void)initHelper {
    
    [[[EMClient sharedClient] chatManager] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [[[EMClient sharedClient] contactManager] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [[[EMClient sharedClient] groupManager] addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didCreatedGroup:) name:@"createGroupSuccess" object:nil];
    
}

/**
 *  登出环信 sdk
 */
- (void)loginOutEaseMobHelper {
    
    [[EMClient sharedClient] logout:YES completion:^(EMError *aError) {
        if (!aError) {
            DTLog(@"退出成功");
        } else {
            DTLog(@"%@",aError.errorDescription);
        }
    }];

}

/**
 环信登录
 */
- (void) loginInEaseMob:(BKAuthorizationToken *)authorization loginSuccessCompletion:(void(^ _Nullable)(EMError *_Nullable aError) )completion{
    
    if (!authorization) return;
    __weak typeof(self) weakself = self;
    [[EMClient sharedClient] loginWithUsername:authorization.easemob_username password:authorization.easemob_password completion:^(NSString *aUsername, EMError *aError) {
        __strong typeof(weakself)strongself = weakself;
        if (!aError) {
            DTLog(@"登录环信账号成功!");
            [strongself easeMobLoginSuccess];
        }
        if (completion) {
            completion(aError);
        }
    }];

}

/**
 登录环信账号成功
 */
- (void) easeMobLoginSuccess {
    
    __weak typeof(self) weakself        = self;
    NSBlockOperation *block1            = [NSBlockOperation blockOperationWithBlock:^{
        __strong typeof(weakself)strongself = weakself;
        [strongself asyncCustomerUserFromServer];
    }];
    
    NSBlockOperation *block2            = [NSBlockOperation blockOperationWithBlock:^{
        __strong typeof(weakself)strongself = weakself;
        [strongself asyncJoinGroupsFromServer];
    }];
    
    NSBlockOperation *block3            = [NSBlockOperation blockOperationWithBlock:^{
        __strong typeof(weakself)strongself = weakself;
        [strongself asyncUserConversations];
    }];
    
    // 用户资料
    NSBlockOperation *block4            = [NSBlockOperation blockOperationWithBlock:^{
        [[BKCacheManager shared] reqeustUserInfo:nil];
    }];
    
    // App 错误日志
    NSBlockOperation *block5            = [NSBlockOperation blockOperationWithBlock:^{
        [BKExceptions asyncUploadCrashLogs];
    }];
    
    // App 配置信息
    NSBlockOperation *block6            = [NSBlockOperation blockOperationWithBlock:^{
        [[AppDelegate appDelegate] reqeustApplicaitonConfig];
    }];
    
    [block5 addDependency:block6];
    [block4 addDependency:block5];
    [block1 addDependency:block4];
    [block2 addDependency:block1];
    [block3 addDependency:block2];
    
    
    NSOperationQueue *queue             = [[NSOperationQueue alloc] init];
    queue.maxConcurrentOperationCount   = 1;
    
    [queue addOperation:block1];
    [queue addOperation:block2];
    [queue addOperation:block3];
    [queue addOperation:block4];
    [queue addOperation:block5];
    [queue addOperation:block6];
    
    
    

    
}
/**
 设置消息控制器的 tabbar.badgeValue
 */
- (void) setupMessageViewControllerBadgeValue {
    
    __weak typeof(self)weakSelf = self;
    dispatch_async(dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf)strongself = weakSelf;
        [strongself.messageViewController setupUnreadMessageCount];
    });
    
}
- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
/**
 进入聊天室开始聊天 0单聊 1 群聊
 */
- (void)hy_chatRoomWithConversationChatter:(NSString *)conversatonId
                       soureViewController:(UIViewController *)viewController {
    
    
    BOOL isGroupChat                                    = [conversatonId isNumberValue];
    BKChatViewController *messageViewController         = [[BKChatViewController alloc] initWithConversationChatter:conversatonId conversationType:isGroupChat ? EMConversationTypeGroupChat : EMConversationTypeChat];

    NSString *title                                     = nil;
    if (!isGroupChat) {
        
        BKCustomersContact *customerUser                = [[BKRealmManager shared] queryCustomuserUsersIntable:conversatonId];
        title                                           = customerUser.name;
        messageViewController.userOther                 = customerUser;
        
    } else {
        
        BKChatGroupModel *groupModel                    = [[BKRealmManager shared] queryChatgroupInfo:conversatonId];
        title                                           = groupModel.groupname;
        
    }
    
    // 聊天控制器 自己资料
    BKCustomersContact *userSelf                        = [[BKRealmManager shared] queryCustomuserUsersIntable:[[BKAuthorizationToken shared] easemob_username]];
    
    messageViewController.userSelf                      = userSelf;
    messageViewController.hidesBottomBarWhenPushed      = YES;
    messageViewController.title                         = title;
    [viewController.navigationController pushViewController:messageViewController animated:YES];
    
    
}



#pragma mark - EMSetup

/**
 获取用户所在群组
 */
- (void)asyncCustomerUserFromServer {
    
    __weak typeof(self)weakSelf = self;
    if (![NSThread isMainThread]) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf getEasemobCustomUsers];
    } else {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [NSBlockOperation blockOperationWithBlock:^{
            [strongSelf getEasemobCustomUsers];
        }];
    }
    
}

/**
 根据环信服务器上的内容获取联系人资料
 */
- (void)getEasemobCustomUsers {
    

    EMError *error = nil;
    NSArray *aList = [[EMClient sharedClient].contactManager getContactsFromServerWithError:&error];
    if (error) return;
    if (!aList || aList.count == 0) return;
    
    [[BKRealmManager shared] insertEaseMobContact:aList];
    NSString *uids              = [UnitTools arrayTranstoString:aList];
    [[AppDelegate appDelegate] reqeustCustomerUserList:uids completion:^(NSArray<BKCustomersContact *> *contacts) {
    }];
    
    
}

/**
 获取环信服务器上的群组信息
 */
- (void) getEaseMobChatGroups {
    
    EMError *error          = nil;
    NSArray *aList          = [[[EMClient sharedClient]groupManager] getMyGroupsFromServerWithError:&error];
    if (error) return;
    [self reqeusetGroupInfo:aList];

}

/**
 将群组信息存入数据库
 */
- (void) reqeusetGroupInfo:(NSArray <EMGroup *>*)aGroupList {
    
    if (!aGroupList || aGroupList.count == 0) return;
    NSMutableArray <NSString *>*groupIds                        = [NSMutableArray array];
    NSMutableDictionary <NSString *,NSNumber *>*groupOptions    = [NSMutableDictionary dictionary];
    [BKCacheManager shared].easeMobGroups                       = aGroupList;
    
    
    for (EMGroup *group in aGroupList) {
        
        [groupIds addObject:group.groupId];
        
        groupOptions[group.groupId]                             = [NSNumber numberWithBool:group.isPushNotificationEnabled];

        [[BKRealmManager shared] deleteSendListModel:group.groupId];
        BKEaseMobGroup *easeMobGroup = [[BKEaseMobGroup alloc] init];
        easeMobGroup.groupId         = group.groupId;
        easeMobGroup.userAccount     = [[BKAuthorizationToken shared] easemob_username];
        
        [[BKRealmManager shared] insertEaseMobGroup:easeMobGroup];
        
    }
    
    [BKGlobalOptions curret].groupDisturbings   = groupOptions;
    [[AppDelegate appDelegate] requestChatGroupList:groupIds];

}

/**
 获取用户所在群组
 */
- (void)asyncJoinGroupsFromServer {
    
    __weak typeof(self)weakSelf = self;
    if (![NSThread isMainThread]) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf getEaseMobChatGroups];
    } else {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [NSBlockOperation blockOperationWithBlock:^{
            [strongSelf getEaseMobChatGroups];
        }];
    }
    
}

/**
 当收到消息时播放声音
 */
- (void) playSoundAndVibration {
    
    BKPrivacyOptions *privacyOptions    = [BKGlobalOptions curret].privacyOptions;
    
    NSString *remindType                = privacyOptions.typeString;
    if ([remindType isEqualToString:@"关闭"]) return;
  
    NSTimeInterval timeInterval         = [[NSDate date]
                                   timeIntervalSinceDate:self.lastPlaySoundDate];
    if (timeInterval < kDefaultPlaySoundInterval) return;
    //保存最后一次响铃时间
    self.lastPlaySoundDate              = [NSDate date];
    if ([remindType containsString:@"声音"]) {
        [self playSound];
    } else if ([remindType containsString:@"振动"]) {
        [self playVibration];
    }

}

/**
 播放声音
 */
- (void) playSound {
    // 收到消息时，播放音频
    [[EMCDDeviceManager sharedInstance] playNewMessageSoundWithSoundName:@"ye_qing.mp3"];
}

/**
 播放振动
 */
- (void) playVibration {
    // 收到消息时，震动
    [[EMCDDeviceManager sharedInstance] playVibration];
}

/**
 获取用户的所有会话
 */
- (void) asyncUserConversations {
    
    [self.messageViewController refeshConversationsData];

}

/**
 加载用户会话数据
 */
- (void) loadConversationsCompletion:(void(^)(NSArray<BKConversationModel *>*conversations))callBack {
    
    __weak typeof(self) weakself = self;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __strong typeof(weakself)strongself                 = weakself;
        NSArray *array = [[EMClient sharedClient].chatManager getAllConversations];
        NSMutableArray <BKConversationModel *>*conversations = [NSMutableArray array];
        __block NSInteger unreadMsgCount                             = 0;
        [array enumerateObjectsUsingBlock:^(EMConversation *conversation, NSUInteger idx, BOOL *stop){
            EMMessage *latestMessage        = conversation.latestMessage;
            if(latestMessage == nil){
                [[EMClient sharedClient].chatManager deleteConversation:conversation.conversationId isDeleteMessages:NO completion:nil];
            } else {
                
                [self opredPacketjsonString:conversation];
                
                [conversations addObject:[[BKConversationModel alloc] initWithConversation:conversation]];
                unreadMsgCount += conversation.unreadMessagesCount;
            }
        }];
        
        __block NSArray *sortArray  =  [conversations sortedArrayUsingComparator:^NSComparisonResult(BKConversationModel *conversationModel1, BKConversationModel *conversationModel2) {
            if (conversationModel1.conversation.latestMessage.timestamp < conversationModel2.conversation.latestMessage.timestamp) {
                return NSOrderedDescending;
            } else if (conversationModel1 > conversationModel2) {
                return NSOrderedAscending;
            } else {
                return NSOrderedSame;
            }
        }];
    
        dispatch_async(dispatch_get_main_queue(), ^{
            if (callBack) {
                NSMutableArray *tmp = [NSMutableArray array];
                [tmp addObjectsFromArray:sortArray];
                strongself.messageViewController.unreadMsgCount = unreadMsgCount;
                callBack(tmp);
            }
        });
    });
    
    
}

// 如果是打开红包的消息 不属于我的消息不显示 不提示给用户 只要我跟这个红包有联系时才会提示用户 比如是我发的红包 或我抢了这个红包
- (BOOL) opredPacketjsonString:(EMConversation *)conversation  {
    
    NSDictionary *ext               = conversation.latestMessage.ext;
    if (!ext)  return YES;
    
    conversation.latestMessage.ext  = [ext replaceJsonToObject];
    [conversation updateMessageChange:conversation.latestMessage error:nil];
    
    if (ext[@"open_red_packets"]) {
        NSDictionary *open_red_packets  = ext[@"open_red_packets"] ;
        if (![open_red_packets isKindOfClass:[NSDictionary class]]) {
            open_red_packets = [(NSString *)open_red_packets jsonStringToData];
        }
        NSDictionary *result            = [self showRedPacketMessage:open_red_packets];
        BOOL showMessage                = [result[@"showMessage"] boolValue];
        if (!showMessage) {
            [conversation deleteMessageWithId:conversation.latestMessage.messageId error:nil];
            return NO;
        }
    }
    
    return YES;
}

/**
 创建群聊成功后的通知
 */
- (void)didCreatedGroup:(NSNotification *)noti {
    
    BKChatGroupModel *group      = noti.object;
    if (!group) return;

    // 群组通知
    UserInfo *userInfo              = [[BKRealmManager shared] readUserInformation];
    
    BKCustomersContact *customer    = [[BKCustomersContact alloc] init];
    customer.uid                    = [[BKAuthorizationToken shared] easemob_username];
    customer.name                   = userInfo.name;
    customer.avatar                 = userInfo.avatar;
    
    // 创建群成功后的消息模型
    BKApplyGroupModel *applayModel  = [[BKApplyGroupModel alloc] initWithCustomer:customer groupInfo:group aplayType:GroupApplyTypeExitGroup reason:@"您已成功创建部落，去邀请好友加入吧!" time:[self currentTimeInterval] title:group.groupname];
    [[BKRealmManager shared] insertGroupApply:applayModel];

    [self setupMessageViewControllerBadgeValue];
    [self playSoundAndVibration];
    
}

#pragma mark - EMChatManagerDelegate

- (void)conversationListDidUpdate:(NSArray *)aConversationList {
    
    [self.messageViewController refeshConversationsData];

}

/// 收到消息
- (void)messagesDidReceive:(NSArray *)aMessages {
    
    EMMessage *lastMessage          = aMessages.lastObject;
    if (!lastMessage) return;
    // 替换某个会话的最后一条信息 即最新一条消息内容 并更新数据源
    BOOL hasThisConversation        = NO;
    for (BKConversationModel *model in self.messageViewController.dataArray) {
        if ([model.conversationId isEqualToString:lastMessage.conversationId]) {
            hasThisConversation     = YES;
        }
    }
    
    if (!hasThisConversation) {
        NSLog(@"找不到这个会话");
        return;
    }
    
    BOOL isGroupChat                                = [lastMessage.conversationId isNumberValue];
    
    EMConversationType  chatType                    = isGroupChat ? EMConversationTypeGroupChat : EMConversationTypeChat;
    
    // 获取当前最新消息所在的会话对象
    EMConversation *conversation                     = [[EMClient sharedClient].chatManager getConversation:lastMessage.conversationId type:chatType createIfNotExist:YES];
    self.messageViewController.needRemoveLastAtMeMsg = NO;
  
    // 红包打开的消息与自己无关不需要显示
    if (![self opredPacketjsonString:conversation]) return;
    
    /// 更新最后一条消息 并刷新 TableView
    BKConversationModel *conversationModel           =  [self.messageViewController updataLastMessageStatus:conversation];
    NSString *groupName;
    
    //  消息发送者的资料新
    BKCustomersContact *user = [[BKRealmManager shared] queryCustomuserUsersIntable:lastMessage.from];
    NSString *cusetomer_name = user.name;

    // 如果应用在后台可以发送本地通知
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateBackground) {
        NSString *title                         = nil;

        if (!isGroupChat) {
            title                               = cusetomer_name;
        } else  {
            BKChatGroupModel *groupModel        = [[BKRealmManager shared] queryChatgroupInfo:lastMessage.conversationId];
            groupName                           = groupModel.groupname;
            title                               = groupName;
        }
        
        NSString *alert                         = @"";
        NSString *notificationIdentifier        = KNotificationIdentifierNormal;
        NSString *filePath                      = nil;
        switch (lastMessage.body.type) {
            case EMMessageBodyTypeText:
            {
                EMTextMessageBody *textBody = (EMTextMessageBody *)lastMessage.body;
                if ([textBody.text containsString:@"示例"]||[textBody.text containsString:@"人脉"]) {
                    alert = isGroupChat ? [NSString stringWithFormat:@"%@: %@",cusetomer_name,@"发来一个消息"] : [NSString stringWithFormat:@"%@",@"你收到了一条消息"];
                } else {
                    alert = isGroupChat ? [NSString stringWithFormat:@"%@: %@",cusetomer_name,[EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:textBody.text]] :[NSString stringWithFormat:@"%@",[EaseConvertToCommonEmoticonsHelper convertToSystemEmoticons:textBody.text]];
                }
                // 拆开红包的消息
                if (lastMessage.ext[@"open_red_packets"]) {
                    NSDictionary *dict              = [self showRedPacketMessage:lastMessage.ext[@"open_red_packets"]];
                    alert                           = isGroupChat ?  [NSString stringWithFormat:@"%@: %@",cusetomer_name,dict[@"message"]] : [NSString stringWithFormat:@"%@",dict[@"message"]];
                }
                notificationIdentifier              = @"textBody";
            }
                break;
            case  EMMessageBodyTypeImage:
            {
                alert = isGroupChat ? [NSString stringWithFormat:@"%@: %@",cusetomer_name,@"发来一张图片"] : [NSString stringWithFormat:@"%@",@"发来一张图片"];
                EMImageMessageBody *body    = ((EMImageMessageBody *)lastMessage.body);
                filePath                    = body.thumbnailRemotePath;
            }
                break;
            case EMMessageBodyTypeVoice:
            {
                alert = isGroupChat ? [NSString stringWithFormat:@"%@: %@",cusetomer_name,@"发来一段语音"] : [NSString stringWithFormat:@"%@",@"发来一段语音"];
                EMVoiceMessageBody *body = (EMVoiceMessageBody *)lastMessage.body;
                filePath                    = body.remotePath;
            }
                break;
            case EMMessageBodyTypeVideo :
            {
                alert = isGroupChat ? [NSString stringWithFormat:@"%@: %@",cusetomer_name,@"发来一段视频"] : [NSString stringWithFormat:@"%@",@"发来一段视频"];
                EMVideoMessageBody *video   = ((EMVideoMessageBody *)lastMessage.body);
                filePath                    = video.remotePath;
            }
                break;
            default:
                alert = @"你收到了一条消息";
                break;
        }
        
        // @我的消息提醒内容
//        NSString *atMeString = [NSString stringWithFormat:@"@%@",[BKRealmManager shared].currentUser.name];
        if (conversationModel.isEmAtMe) {
            if ([conversationModel.atMeUsername isEqualToString:@"未知用户"]) {
                alert = [NSString stringWithFormat:@"[有人@我] %@",alert];
            } else {
                alert = [NSString stringWithFormat:@"[有人@我] %@",alert];
            }
        }

        // iOS10 发送本地通知
        BKNotifications *notification = [[BKNotifications alloc] initWithTitle:title alert:alert identifier:notificationIdentifier bodyType:lastMessage.body.type];
        notification.filePath         = filePath;
        notification.from             = isGroupChat ? lastMessage.conversationId : lastMessage.from;
        [self sendLocalNoticationWithNotification:notification];

    } else  {
        
        [self playSoundAndVibration];
        
    }
  
    
}

/**
 接受的透传消息
 */
- (void)cmdMessagesDidReceive:(NSArray *)aCmdMessages {
    
    if (aCmdMessages.count == 0) return;

    for (EMMessage *message in aCmdMessages) {
        
        // 获得透传消息实体类
        BKCMDMessage *cmdMessage = [[BKCMDMessage alloc] initWithMsg:message];
        NSString *userId         = cmdMessage.extDictionary[@"customer_uid"];
        switch (cmdMessage.actionType) {
            case BKCMDActionTypeAddFriend:
            {
                BKAddFriendReqeust *addFriendReqesut = [[BKAddFriendReqeust alloc] initWithDictionary:cmdMessage.extDictionary action:cmdMessage.action];
                [[BKRealmManager shared] insertContactReqeusts:addFriendReqesut];
                [self setupContactViewBadgeValue];
                [self.contactViewController updateHeadView];
                [self playSoundAndVibration];
                
                BKNotifications *notification = [[BKNotifications alloc] initWithTitle:addFriendReqesut.customer_name alert:@"申请添加你为好友" identifier:KNotificationIdentifierNormal bodyType:EMMessageBodyTypeText];
                [self sendLocalNoticationWithNotification:notification];
                
            }
                break;
            case BKCMDActionTypeNewChatGroup : // 新的群组
                
                break;
 
            case BKCMDActionTypeAcceptedFriend: // 同意加好友申请
            {
                
                BKCustomersContact *customer            = [[BKRealmManager shared] queryCustomuserUsersIntable:userId];
                if (!customer)  return;
                
                NSString *action                        = @"accepted_customer_friend";
                NSMutableDictionary *params             = [NSMutableDictionary dictionary];
                
                params[@"customer_uid"]                 = customer.uid;
                params[@"customer_company"]             = customer.company ? customer.company : @"";
                params[@"customer_company_position"]    = customer.company_position ? customer.company_position : @"";
                params[@"customer_avatar"]              = customer.avatar ? customer.avatar : @"";
                params[@"customer_name"]                = customer.name ? customer.name : @"";
                params[@"message"]                      = [NSString stringWithFormat:@"%@同意了你的加好友申请",customer.name];
                
                BKAddFriendReqeust *addFriendReqesut    = [[BKAddFriendReqeust alloc] initWithDictionary:params action:action];
                
                // 数据库的操作相关
                [[BKRealmManager shared] insertContactReqeusts:addFriendReqesut];
                [[BKRealmManager shared] insertEaseMobContact:@[addFriendReqesut.customer_uid]];
                [[BKRealmManager shared] deleteSendListModel:addFriendReqesut.customer_uid];
                // UI 相关
                [self setupContactViewBadgeValue];
                [self.contactViewController updateHeadView];
                [self playSoundAndVibration];
                
                // 通知相关
                [[NSNotificationCenter defaultCenter] postNotificationName:@"ContactDidChange" object:nil];
                
                BKNotifications *notification = [[BKNotifications alloc] initWithTitle:addFriendReqesut.customer_name alert:@"同意了你的加好友申请" identifier:KNotificationIdentifierNormal bodyType:EMMessageBodyTypeText];
                [self sendLocalNoticationWithNotification:notification];
                

            }
                break;
            default:
                break;
        }
        
        
    }
    
}

#pragma mark - EMContactManagerDelegate

/**
 用户 B  拒绝用户 A的加好友申请后 用户 A 会收到这个回调
 */
- (void) friendRequestDidDeclineByUser:(NSString *)aUsername {
    
    BKCustomersContact *customer = [[BKRealmManager shared] queryCustomuserUsersIntable:aUsername];
    
    if (!customer)  return;
    
    NSString *action                        = @"decline_friend";
    NSMutableDictionary *params             = [NSMutableDictionary dictionary];
    
    params[@"customer_uid"]                 = customer.uid;
    params[@"customer_company"]             = customer.company ? customer.company : @"";
    params[@"customer_company_position"]    = customer.company_position ? customer.company_position : @"";
    params[@"customer_avatar"]              = customer.avatar ? customer.avatar : @"";
    params[@"customer_name"]                = customer.name ? customer.name : @"";
    params[@"message"]                      = [NSString stringWithFormat:@"%@拒绝了你的加好友申请",customer.name];

    BKAddFriendReqeust *addFriendReqesut    = [[BKAddFriendReqeust alloc] initWithDictionary:params action:action];
    
    [[BKRealmManager shared] insertContactReqeusts:addFriendReqesut];

    [self setupContactViewBadgeValue];
    [self.contactViewController updateHeadView];
    [self playSoundAndVibration];
    
    BKNotifications *notification = [[BKNotifications alloc] initWithTitle:addFriendReqesut.customer_name alert:@"拒绝了你的加好友申请" identifier:KNotificationIdentifierNormal bodyType:EMMessageBodyTypeText];
    [self sendLocalNoticationWithNotification:notification];
    
    [[BKRealmManager shared] deleteSendListModel:addFriendReqesut.customer_uid];

}

/**
 当 B 删除 A 后. A 回收到这个回调
 */
- (void)friendshipDidRemoveByUser:(NSString *)aUsername {
    
    // 当用户 B 把用户 A 删除后 用户 A收到这个回调后 删除本地数据库内容
    [[BKRealmManager shared] deleteEaseMobContactBy:aUsername];
    [NSNotificationCenter bk_postNotication:@"ContactDidChange" object:aUsername];
    [[BKRealmManager shared] deleteSendListModel:aUsername];
    [[BKRealmManager shared] deleteContactReqeust:aUsername];

    // 当被别人从联系人中删除时就移除之前的会话
    [[[EMClient sharedClient] chatManager] deleteConversation:aUsername isDeleteMessages:YES completion:nil];
    
}

/**
 设置人脉tabbarItem.badgeValue
 */
- (void)setupContactViewBadgeValue {
    
    NSArray *applays                = [[BKRealmManager shared] queryContatctApplysInRealm:YES];
    
    NSString *badgeValue            = applays.count == 0 ? nil : [NSString stringWithFormat:@"%@",@(applays.count)];
    [EMIMHelper shared].contactViewController.tabBarItem.badgeValue = badgeValue;

}

/**
 发送本地通知,加好友 聊天会话 程序进入后台时提醒用户
 */
- (void)sendLocalNoticationWithNotification:(BKNotifications *_Nonnull)noti {
    
    // 应用在前台不提醒
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) return;
    
    if ([[UIDevice currentDevice].systemVersion floatValue] >= 10.0) { // iOS10 本地通知
        
        UNMutableNotificationContent *content       = [[UNMutableNotificationContent alloc] init];
        content.badge                               = [NSNumber numberWithInteger:1];
        content.body                                = noti.alert;
        content.sound                               = [UNNotificationSound soundNamed:@"in.caf"];
        content.title                               = noti.title;
        content.categoryIdentifier                  = noti.identifier;
        if (noti.from) {
            content.userInfo                            = @{@"uid" : noti.from};
        }
        if (noti.bodyType == EMMessageBodyTypeImage || noti.bodyType == EMMessageBodyTypeVideo || noti.bodyType == EMMessageBodyTypeVoice) {
            
            content.subtitle        = noti.alert;
            content.body            = noti.bodyType == EMMessageBodyTypeImage ? @"下拉查看图片" : (noti.bodyType == EMMessageBodyTypeVideo ? @"下拉播放视频" : @"下拉播放语音");
            NSURL *url              = [NSURL URLWithString:noti.filePath];
            NSError *error          = nil;
            NSData *data            = [NSData dataWithContentsOfURL:url];
            NSString *fileName      = @"image.png";
            if (noti.bodyType == EMMessageBodyTypeVideo) {
                fileName            = @"video.mp4";
            } else if (noti.bodyType == EMMessageBodyTypeVoice) {
                fileName            = @"voice.caf";
            }
            
            NSString *filePath = [NSString stringWithFormat:@"%@/%@",[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"],fileName];

            BOOL success = [data writeToFile:filePath atomically:YES];
            if (success) {
                UNNotificationAttachment *attachment = [UNNotificationAttachment attachmentWithIdentifier:@"image" URL:[NSURL fileURLWithPath:filePath] options:nil error:&error];
                if (error) {
                    DTLog(@"error = %@",error.localizedDescription);
                }
                content.attachments = @[attachment];
            }
            
        }
        

        UNNotificationAction *cancel                = [UNNotificationAction actionWithIdentifier:@"cancel" title:@"收到了" options:UNNotificationActionOptionAuthenticationRequired];

        NSMutableArray *actions                     = [NSMutableArray array];
        [actions addObject:cancel];

        if ([noti.identifier isEqualToString:@"textBody"]) {
            
            UNTextInputNotificationAction *inputAction = [UNTextInputNotificationAction actionWithIdentifier:noti.identifier title:@"我想说两句" options:UNNotificationActionOptionDestructive textInputButtonTitle:@"发送" textInputPlaceholder:@"在此快速回复消息"];
            [actions addObject:inputAction];
        }

        UNNotificationCategory *category = [UNNotificationCategory categoryWithIdentifier:noti.identifier actions:actions intentIdentifiers:@[] options:UNNotificationCategoryOptionCustomDismissAction];
        
        [[UNUserNotificationCenter currentNotificationCenter] setNotificationCategories:[NSSet setWithObject:category]];
        
        UNTimeIntervalNotificationTrigger *trige    = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:0.1 repeats:NO];
        
        UNNotificationRequest *request              = [UNNotificationRequest requestWithIdentifier:noti.identifier content:content trigger:trige];
        

        [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
            if (error) {
                DTLog(@"---> %@",error.localizedDescription);
            }
        }];
        
        NSInteger currentValue                      = [UIApplication sharedApplication].applicationIconBadgeNumber;
        currentValue                                += 1;
        [UIApplication sharedApplication].applicationIconBadgeNumber = currentValue;
        
    } else { // iOS 10之前的本地通知
        
        UILocalNotification *localNoti              = [[UILocalNotification alloc] init];
        localNoti.alertBody                         = noti.alert;
        localNoti.fireDate                          = [NSDate dateWithTimeIntervalSinceNow:0.5];
        localNoti.category                          = noti.identifier;
        localNoti.applicationIconBadgeNumber        = 1;
        localNoti.soundName                         = @"in.caf";
        
        [[UIApplication sharedApplication] scheduleLocalNotification:localNoti];
        
        
    }
 
}

#pragma mark - EMGroup 


/**
 群组列表发生了改变时代理
 */
- (void)groupListDidUpdate:(NSArray *)aGroupList {
    
    if ([AppDelegate appDelegate].displayImageView != nil) return;
    UIViewController *viewController =  [[AppDelegate appDelegate] rootViewControlller].currentShowViewController;
    if (![viewController isKindOfClass:[BKMyJoinGroupViewController class]]) {
        [self reqeusetGroupInfo:aGroupList];
    }
    
}

/**
 当前登录用户收到群邀请消息
 */
- (void) customerUserDidReceiveGruopInvitation:(BKChatGroupModel *)groupInfo {
    
    
    BKCustomersContact *groupOwner = [[BKRealmManager shared] queryCustomuserUsersIntable:groupInfo.owner_uid];

    BKApplyGroupModel *applayModel = [[BKApplyGroupModel alloc] initWithCustomer:groupOwner groupInfo:groupInfo aplayType:GroupApplyTypeInviteGroup reason:[NSString stringWithFormat:@"%@ 邀请你加入 “%@” ",groupOwner.name,groupInfo.groupname] time:[self currentTimeInterval] title:groupInfo.groupname];
    
    [[BKRealmManager shared] insertGroupApply:applayModel];

    [self setupMessageViewControllerBadgeValue];
    [self playSoundAndVibration];
    
}
/*!
 *  \~chinese
 *  用户A邀请用户B入群,用户B接收到该回调
 */
- (void)groupInvitationDidReceive:(NSString *)aGroupId
                          inviter:(NSString *)aInviter
                          message:(NSString *)aMessage {
    
    __weak typeof(self)weakSelf              = self;
    
    // 获取群资料
    [[AppDelegate appDelegate] reqeustGroupInfoBy:aGroupId completion:^(BKChatGroupModel * group) {
        if (!group) return ;
        __strong typeof(weakSelf)strongSelf = weakSelf;
        [strongSelf customerUserDidReceiveGruopInvitation:group];
    }];
    
}

/**
 用户同意入群邀请
 */
- (void) customerAcceptGruopInvitation:(BKCustomersContact *_Nullable)customer groupId:(NSString *)aGroupId isAccept:(BOOL)aAccept {
    
    if (!customer) return;
    
    __weak typeof(self)weakSelf              = self;

    // 获取群资料
    [[AppDelegate appDelegate] reqeustGroupInfoBy:aGroupId completion:^(BKChatGroupModel * group) {
        if (!group) return ;
        NSString *reason = !aAccept ? @"拒绝了你的加部落邀请" : @"同意了你的邀请加入部落";
        __strong typeof(weakSelf)strongSelf = weakSelf;
        BKApplyGroupModel *applayModel = [[BKApplyGroupModel alloc] initWithCustomer:customer groupInfo:group aplayType:(aAccept ? GroupApplyTypeAcceptGroup : GroupApplyTypeDeclineGroup) reason:reason time:[strongSelf currentTimeInterval] title:customer.name];
        [[BKRealmManager shared] insertGroupApply:applayModel];
        [strongSelf setupMessageViewControllerBadgeValue];
        [strongSelf playSoundAndVibration];
        
    }];
    
}

/*!
 *  \~chinese
 *  用户B同意用户A的入群邀请后，用户A接收到该回调
 */
- (void) groupInvitationDidAccept:(EMGroup *)aGroup
                         invitee:(NSString *)aInvitee {
    
    __weak typeof(self)weakSelf              = self;
    [[AppDelegate appDelegate] reqeustCustomerUserList:aInvitee completion:^(NSArray<BKCustomersContact *> *users) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        BKCustomersContact *customer        = [users lastObject];
        [strongSelf customerAcceptGruopInvitation:customer groupId:aGroup.groupId isAccept:YES];
    }];

}

/*!
 *  \~chinese
 *  用户B拒绝用户A的入群邀请后，用户A接收到该回调
 */
- (void) groupInvitationDidDecline:(EMGroup *)aGroup
                          invitee:(NSString *)aInvitee
                           reason:(NSString *)aReason {
    
    __weak typeof(self)weakSelf              = self;
    [[AppDelegate appDelegate] reqeustCustomerUserList:aInvitee completion:^(NSArray<BKCustomersContact *> *users) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        BKCustomersContact *customer        = [users lastObject];
        [strongSelf customerAcceptGruopInvitation:customer groupId:aGroup.groupId isAccept:NO];
    }];
    
}


/*!
 *  \~chinese
 *  离开群组回调
 */
- (void) didLeaveGroup:(EMGroup *)aGroup
               reason:(EMGroupLeaveReason)aReason {
    
    if ([aGroup.owner isEqualToString:[BKAuthorizationToken shared].easemob_username]) return ;
    
    // 被移除退群
    __block NSString *applyReason = @"";
    BKChatGroupModel *group = [[BKRealmManager shared] queryChatgroupInfo:aGroup.groupId];
    if (aReason == EMGroupLeaveReasonBeRemoved) {
        applyReason         = @"你已经被部落管理员移除部落";
    } else if (aReason == EMGroupLeaveReasonDestroyed) {
        applyReason = @"该群组已经被部落管理员解散";
    } else {
        applyReason = [NSString stringWithFormat:@"你已经退出部落 %@",group.groupname];
    }
    
    BKCustomersContact *groupOwner = [[BKRealmManager shared] queryCustomuserUsersIntable:aGroup.owner];
    
    BKApplyGroupModel *applayModel = [[BKApplyGroupModel alloc] initWithCustomer:groupOwner groupInfo:group aplayType:GroupApplyTypeExitGroup reason:applyReason time:[self currentTimeInterval] title:group.groupname];
    [[BKRealmManager shared] insertGroupApply:applayModel];
    
    
    // 用户离开群组后删除本地数据内容
    [[BKRealmManager shared] userExitGroupByGroupId:aGroup.groupId];
    
    [self setupMessageViewControllerBadgeValue];
    
    [self playSoundAndVibration];

}

/**
 当前时间戳
 */
- (NSString *)currentTimeInterval {
    NSDate *date                        = [NSDate date];
    long long timeInterval              = (long long) [date timeIntervalSince1970];
    return [NSString stringWithFormat:@"%lld",timeInterval];
}


/*!
 *  群主收到加群申请
 */
- (void)joinGroupRequestDidReceive:(EMGroup *)aGroup
                              user:(NSString *)aUsername
                            reason:(NSString *)aReason {

//    __weak typeof(self)weakify              = self;
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        __strong typeof(weakify)strongify   = weakify;
//        BKApplyForModel *applyModel         = [[BKApplyForModel alloc] init:aUsername groupId:aGroup.groupId reason:aReason type : GroupApplyTypeJoinGroup];
//        applyModel.time                     = [strongify currentTimeInterval];
//        [[BKDatabaseManager shared] insertUserApplyJoinGroupWith:applyModel isReadMsg:NO];
//        BKCustomersContact *user            = [[BKRealmManager shared] queryCustomuserUsersIntable:applyModel.uid];
//        if (!user) {
//            [[AppDelegate appDelegate] reqeustCustomerUserList:applyModel.uid completion:^(NSArray<BKCustomersContact *> *contacts) {
//            }];
//        }
//        [strongify setupMessageViewControllerBadgeValue];
//        [strongify playSoundAndVibration];
//    });
    

}


/*!
 *  \~chinese
 *  群主拒绝用户A的入群申请后，用户A会接收到该回调，群的类型是EMGroupStylePublicJoinNeedApproval

 */
- (void)joinGroupRequestDidDecline:(NSString *)aGroupId
                            reason:(NSString *)aReason {
    
//    __weak typeof(self)weakSelf = self;
//    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
//        __strong typeof(weakSelf)strongSelf = weakSelf;
//        
//        BKChatGroupModel *groupModel    = [[BKRealmManager shared] queryChatgroupInfo:aGroupId];
//
//        BKApplyForModel *applyModel = [[BKApplyForModel alloc] init:[BKAuthorizationToken shared].easemob_username groupId:aGroupId reason:@"部落管理员拒绝了你的加部落申请" type:GroupApplyTypeExitGroup];
//        applyModel.groupAvatar      = groupModel.avatar;
//        applyModel.groupName        = groupModel.groupname;
//        applyModel.applyType        = GroupApplyTypeDeclineGroup;
//        applyModel.time             = [strongSelf currentTimeInterval];
//
//        [[BKDatabaseManager shared] insertUserApplyJoinGroupWith:applyModel isReadMsg:NO];
//        
//        [[BKRealmManager shared] deleteSendListModel:aGroupId];
//
//        [strongSelf setupMessageViewControllerBadgeValue];
//        [strongSelf playSoundAndVibration];
//
//    }];
//    [operation start];
    
}

/*!
 *  \~chinese
 *  群主同意用户A的入群申请后，用户A会接收到该回调，群的类型是EMGroupStylePublicJoinNeedApproval
 */
- (void)joinGroupRequestDidApprove:(EMGroup *)aGroup {
    
//    __weak typeof(self)weakSelf = self;
//    NSBlockOperation *operation = [NSBlockOperation blockOperationWithBlock:^{
//        __strong typeof(weakSelf)strongSelf = weakSelf;
//        
//        BKChatGroupModel *groupModel    = [[BKRealmManager shared] queryChatgroupInfo:aGroup.groupId];
//        
//        BKApplyForModel *applyModel     = [[BKApplyForModel alloc] init:[BKAuthorizationToken shared].easemob_username groupId:aGroup.groupId reason:@"部落管理员同意了你的加部落申请" type:GroupApplyTypeExitGroup];
//        applyModel.time                 = [strongSelf currentTimeInterval];
//        applyModel.groupAvatar          = groupModel.avatar;
//        applyModel.groupName            = groupModel.groupname;
//        applyModel.applyType            = GroupApplyTypeExitGroup;
//        // 群组通知
//        [[BKDatabaseManager shared] insertUserApplyJoinGroupWith:applyModel isReadMsg:NO];
//        // 删除本地添加该群组的记录 搜索该群组来判断是否发生加群组请求 已发送/加入
//        [[BKRealmManager shared] deleteSendListModel:aGroup.groupId];
//        [strongSelf setupMessageViewControllerBadgeValue];
//        [strongSelf playSoundAndVibration];
//
//    }];
//    [operation start];
    
}

#pragma mark - RedPacket

/**
 显示红包现象
 */
- (NSDictionary *)showRedPacketMessage:(NSDictionary *)data {
    
    NSDictionary *newDict           = data;
    if ([newDict isKindOfClass:[NSString class]]) {
        newDict = [(NSString *)newDict jsonStringToData];
    }
    
    NSString *easemobId             = [BKAuthorizationToken shared].easemob_username;
    BOOL canShowMessage             = NO;
    NSString *owner_customer_uid    = newDict[@"owner_customer_uid"];
    NSString *owner_customer_name   = newDict[@"owner_customer_name"];
    NSString *open_customer_name    = newDict[@"open_customer_name"];
    NSString *open_customer_uid     = newDict[@"open_customer_uid"];
    BOOL opened_all                 = [(NSNumber *)newDict[@"opened_all"] boolValue];
    NSString *message               = @"";
    
    // 自己发送的红包 自己抢了
    if ([owner_customer_uid isEqualToString:easemobId] && [open_customer_uid isEqualToString:easemobId]) {
        message                     = [NSString stringWithFormat:@"%@%@",@"你领取了自己发的红包",(opened_all ? @",你的红包已被领完" : @"")];
        canShowMessage              = YES;
    }
    
    // 不是我的红包 但是被我抢到了
    if (![owner_customer_uid isEqualToString:easemobId] && [open_customer_uid isEqualToString:easemobId]) {         message             = [NSString stringWithFormat:@"你领取了%@的红包",owner_customer_name];
        canShowMessage      = YES;
    }
    // 不是我发送的红包 但是我也没有去抢 这个红包与我没有任何关系,可能被别人抢到了
    if ((![easemobId isEqualToString:owner_customer_uid]) && (![easemobId isEqualToString:open_customer_uid])) {
        canShowMessage      = NO;
        message             = @"";
    }
    // 是我发的红包 但是我没有抢 可能被别人给抢了
    if ([owner_customer_uid isEqualToString:easemobId] && ![open_customer_uid isEqualToString:easemobId]) {         canShowMessage      = YES;
        message             = [NSString stringWithFormat:@"%@领取了你的红包%@",open_customer_name,(opened_all ? @",你的红包已被领完" : @"")];
    }

    return @{@"showMessage" : [NSNumber numberWithBool:canShowMessage],@"message" : message};
}


/**
 发送一个文本消息

 @param text 文字
 @param to 接收者
 @param ext 拓展内容
 */
- (void) sendText:(NSString *_Nonnull)text toBody:(NSString *_Nullable)to ext:(NSDictionary *_Nullable)ext {
    
    if (!to) return;
    
    NSString *willSendText          = [EaseConvertToCommonEmoticonsHelper convertToCommonEmoticons:text];
    EMTextMessageBody *textBody     = [[EMTextMessageBody alloc] initWithText:willSendText];
    NSString *from                  = [[EMClient sharedClient] currentUsername];
    EMMessage *message              = [[EMMessage alloc] initWithConversationID:to from:from to:to body:textBody ext:ext];
    message.chatType                = [to isNumberValue] ? EMChatTypeGroupChat : EMChatTypeChat;

    [[[EMClient sharedClient] chatManager] sendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
        if (error) {
            DTLog(@"--> error %@",error.errorDescription);
        }
    }];
    
}

@end



@implementation BKNotifications

- (instancetype _Nonnull) initWithTitle:(NSString *_Nullable)aTitle
                                  alert:(NSString *_Nullable)aAlert identifier:(NSString *_Nonnull)aIdentifier
                               bodyType:(EMMessageBodyType)type {
    
    if (self = [super init]) {
        
        self.title          = aTitle;
        self.alert          = aAlert;
        self.identifier     = aIdentifier;
        self.bodyType       = type;
        
    }
    
    return self;
}

@end
