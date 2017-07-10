//
//  BKRealmManager.h
//  BayeSocial
//
//  Created by 董招兵 on 2017/2/14.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RLMRealm,BKGroupCategory,BKAuthorizationToken,RLMObject,BKIndustryMainModel,UserInfo, BKUsersContactsList ,BKPrivacyOptions,BKCustomerContactGroup,BKChatGroupModel,BKEaseMobGroup,BKEaseMobContact,BKAddFriendReqeust,BKSendList,BKApplyGroupModel;

@interface BKRealmManager : NSObject

/**
 realm数据库实例 是线程安全的
 */
@property (nonatomic,weak,nullable,readonly) RLMRealm *realmObject;

/**
 当前用户的资料信息
 */
@property (nonatomic,strong,nullable) UserInfo *currentUser;

/**
 获取 BKRealmManager实例
 */
+ (instancetype _Nonnull) shared;

/**
 配置realm数据库文件信息
 */
+ (void) realmConfiguration;

/**
 开始数据库修改的事务
 */
+ (void) beginWriteTransaction;

/**
 提交修改的事务
 */
+ (void) commitWriteTransaction;

#pragma mark BKLoginAuthorization

/**
 存储用户登录授权后信息
 */
- (void) insertLoginAuthorization:(BKAuthorizationToken *_Nonnull)authorization;

/**
 获取用户授权信息 包含 token 环信账户
 */
- (BKAuthorizationToken *_Nullable) readLoginAuthorization;

/**
 移除用户授权信息的资料
 */
- (BOOL) deleteLoginAuthorization;

#pragma mark - GroupCategory

/**
 存储群分类信息
 */
- (void) insertGroupCategory:(BKGroupCategory *_Nonnull)category;

/**
 获取群分类信息
 */
- (NSArray <BKGroupCategory *> *_Nonnull) readGroupCategorys;

#pragma mark - Industry

/**
 存储群分类信息
 */
- (void) insertIndustryModel:(NSArray <BKIndustryMainModel*> *_Nonnull) insdustryModels;

/**
 获取群分类信息
 */
- (NSArray <BKIndustryMainModel *> *_Nonnull) readInsdustryModels;


#pragma mark - UserInfo

/**
 存储用户资料的模型
 */
- (void) insertUserInfoModel:(UserInfo *_Nonnull)userInfo;

/**
 获取用户资料的模型
 */
- (UserInfo *_Nonnull) readUserInformation;

#pragma mark - BKContactGroup

/**
 存储当前用户所有人脉分组信息
 */
- (void) insertUserContacts:(NSArray <BKCustomersContact *> *_Nonnull)userContacts userId:(NSString *_Nonnull)uid;

/**
 获取当前登录用户的人脉群组信息
 */
- (NSArray <BKCustomersContact *>*_Nonnull) readUserContacts:(NSString *_Nonnull)userId;

#pragma mark - BKOptions

/**
 存储app 相关设置的内容
 */
- (void) insertApplictionOptions:(BKPrivacyOptions *_Nonnull)options;

/**
 读取 app 相关设置的内容
 */
- (BKPrivacyOptions *_Nonnull) readApplicationOptions;

#pragma mark - BlackList

/**
 插入用户黑名单数据
 */
- (void) insertUserBlackList:(NSArray <BKCustomersContact *>*_Nonnull)blackList;

/**
 获取用户黑名单
 @return 返回黑名单列表
 */
- (NSArray <BKCustomersContact *>*_Nonnull) readUserBlackList;

/**
 将用户从黑名单里移除掉
 */
- (void) removeUserFromBlacklist:(BKCustomersContact *_Nonnull) customerUser;

/**
 判断当前用户是否在黑名单列表中
 */
- (BOOL) customerInBlackList:(NSString *_Nonnull)userId;


#pragma mark - BKChatGroup

/**
 将群组的信息保存到数据库中
 */
- (void) insertChatGroup:(NSArray <BKChatGroupModel *>*_Nonnull)chatGroups;

/**
 获取单个群组的信息
 */
- (BKChatGroupModel *_Nullable) queryChatgroupInfo:(NSString *_Nonnull)gruoupId;


#pragma mark - 环信群组信息

/**
 存储环信群组的信息 用来判断当前登录用户 是否加入了环信的群
 */
- (void) insertEaseMobGroup:(BKEaseMobGroup *_Nonnull)easeMobGruop;

/**
 查询当前用户是否在某个群组里
 */
- (BOOL) cusetomerUserIsInChatGroup:(NSString *_Nonnull)groupId;

/**
 用户退出某个群组
 */
- (void) userExitGroupByGroupId:(NSString *_Nonnull)groupId;

#pragma mark - EaseMobContact

/**
 存储环信联系人列表 用来判断好友关系
 */
- (void) insertEaseMobContact:(NSArray <NSString  *>*_Nonnull)contacts;

/**
 查询人脉是否为我的好友
 */
- (BOOL) customerUserIsFriendOrderBy:(NSString *_Nonnull)userId;

/**
 删除环信好友信息
 */
- (void) deleteEaseMobContactBy:(NSString *_Nonnull)userId;


#pragma mark - BKCustomerContact

/**
 保存人脉资料信息
 */
- (void) insertCustomerContact:(NSArray <BKCustomersContact *>*_Nonnull)contacts;


/**
 查询用户资料
 */
- (BKCustomersContact *_Nullable) queryCustomuserUsersIntable:(NSString *_Nonnull)userId;

#pragma mark - 模糊搜索人脉和群组

/**
 模糊搜索群组信息 根据关键字
 */
- (NSArray <BKChatGroupModel *> *_Nonnull) queryChatgroupsOrderByKeywords:(NSString *_Nonnull)keywords;


/**
 模糊搜索人脉资料 根据关键字
 */
- (NSArray <BKCustomersContact *> *_Nonnull) queryCustomerUserByKeywords:(NSString *_Nonnull)keywords;


#pragma mark - BKAddFriendRequest

/**
 保存加好友请求的信息
 */
- (void) insertContactReqeusts:(BKAddFriendReqeust *_Nonnull)addReqeust;

/**
 删除一条加好友请求的消息
 */
- (void) deleteContactReqeust:(NSString *_Nonnull)customer_uid;

/**
 用户读取所有未读加好友请求
 */
- (void) userDidReadApplyFriendsNotice;

/**
 获取所有加好友请求/未读加好友请求
 */
- (NSArray <BKAddFriendReqeust *> *_Nonnull) queryContatctApplysInRealm:(BOOL)unreadMessages;


#pragma mark - BKSendList 发送了加人脉或群组的模型

- (void) insertSendList:(BKSendList *_Nonnull)sendModel;

/**
 获取发送加人脉 或群组的模型
 */
- (BKSendList *_Nullable) querySendListModel:(NSString *_Nonnull)uid;

/**
 删除加好友 或者群组的模型
 */
- (void) deleteSendListModel:(NSString *_Nonnull)uid;

#pragma mark - BKApplayGroupModel 

/**
 插入群组消息 根据 groupId
 */
- (void) insertGroupApply:(BKApplyGroupModel *_Nonnull)applayModel;

/**
    删除群组通知 根据 groupId
 */
- (void) deleteGroupApplay:(NSString *_Nonnull)customer_uid;


/**
 查询所有未读的群组通知
 */
- (NSArray <BKApplyGroupModel *> *_Nonnull) queryUnreadGroupApplys;


/**
 读取所有群组通知
 */
- (NSArray <BKApplyGroupModel *> *_Nonnull) queryAllGroupApplys;


/**
 读取所有群组通知
 */
- (void) readAllGroupApplays;

@end
