//
//  BKRealmManager.m
//  BayeSocial
//
//  Created by 董招兵 on 2017/2/14.
//  Copyright © 2017年 大兵布莱恩特. All rights reserved.
//

#import "BKRealmManager.h"
#import <Realm/Realm.h>
#import "BayeSocial-Swift.h"

@interface BKRealmManager ()

@property (nonatomic,strong,nullable) NSString *userAccount;

@end

@implementation BKRealmManager

- (UserInfo *)currentUser {
    if (!_currentUser) {
        _currentUser = [self readUserInformation];
    }
    return _currentUser;
}

- (NSString *)userAccount {
    return [[BKAuthorizationToken shared] easemob_username];
}

+ (instancetype)shared {
    return [[super alloc] init];
}

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    static BKRealmManager *_dataManager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _dataManager = [super allocWithZone:zone];
    });
    return _dataManager;
}

/**
 获取Realm数据库文件配置信息
 */
+ (void )realmConfiguration {
    
    NSString *cachePath                             = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES)[0];
    NSString *filePath                              = [cachePath stringByAppendingPathComponent:@"mydatabase.realm"];
    
    NSLog(@"\n%@\n",cachePath);
    
    NSError *error                                  = nil;
    
    RLMRealmConfiguration *realmConfiguration       = [[RLMRealmConfiguration alloc] init];
    realmConfiguration.fileURL                      = [NSURL fileURLWithPath:filePath];
    realmConfiguration.schemaVersion                = 30;
    realmConfiguration.migrationBlock               = ^(RLMMigration *migration, uint64_t oldSchemaVersion) {
//        NSLog(@"--%llu",oldSchemaVersion);
    };
    
    [RLMRealm performMigrationForConfiguration:realmConfiguration error:&error];
    
    [RLMRealmConfiguration setDefaultConfiguration:realmConfiguration];
}

/**
 realm数据库对象
 */
- (RLMRealm *)realmObject {
    return [RLMRealm defaultRealm];
}

/**
 开始数据库修改的事务
 */
+ (void) beginWriteTransaction {
    [[[self shared] realmObject] beginWriteTransaction];
}

/**
 提交修改的事务
 */
+ (void) commitWriteTransaction {
    
    [[[self shared] realmObject]  commitWriteTransaction];
}

#pragma mark BKLoginAuthorization
/**
 存储用户登录授权后信息
 */
- (void) insertLoginAuthorization:(BKAuthorizationToken *_Nonnull)authorization {
    
    [self.realmObject beginWriteTransaction];
    
    [self.realmObject addOrUpdateObject:authorization];
    
    [self.realmObject commitWriteTransaction];
    
}

/**
 获取用户授权信息 包含 token 环信账户
 */
- (BKAuthorizationToken *_Nullable) readLoginAuthorization {
    
    RLMResults <BKAuthorizationToken *> *results    = [BKAuthorizationToken allObjects];
    BKAuthorizationToken *authorization             = [results lastObject];
    
    return authorization;
}

/**
 移除用户授权信息的资料
 */
- (BOOL) deleteLoginAuthorization {
    
    BKAuthorizationToken *authorization = [self readLoginAuthorization];
    if (!authorization) return NO;
    [self.realmObject beginWriteTransaction];
    [self.realmObject deleteObject:authorization];
    [self.realmObject commitWriteTransaction];
    
    return YES;
}

#pragma mark - GroupCategory

/**
 存储群分类信息
 */
- (void) insertGroupCategory:(BKGroupCategory *_Nonnull)category {
    

    [self.realmObject beginWriteTransaction];

    [self.realmObject addOrUpdateObject:category];

    [self.realmObject commitWriteTransaction];
    
}

/**
 获取群分类信息
 */
- (NSArray <BKGroupCategory *> *_Nonnull) readGroupCategorys {
    NSMutableArray *categorys = [NSMutableArray array];
    for (RLMObject *object in [BKGroupCategory allObjects]) {
        [categorys addObject:object];
    }
    return categorys;
}

#pragma mark - Industry

/**
 存储群分类信息
 */
- (void) insertIndustryModel:(NSArray <BKIndustryMainModel*> *_Nonnull) insdustryModels {
    
    [self.realmObject beginWriteTransaction];
    [self.realmObject addOrUpdateObjectsFromArray:insdustryModels];
    [self.realmObject commitWriteTransaction];
    
}

/**
 获取群分类信息
 */
- (NSArray <BKIndustryMainModel *> *_Nonnull) readInsdustryModels {
    
    NSMutableArray *insdustryModels = [NSMutableArray array];
    for (RLMObject *object in [BKIndustryMainModel allObjects]) {
        [insdustryModels addObject:object];
    }
    return insdustryModels;
    
}

#pragma mark - UserInfo

/**
 存储群分类信息
 */
- (void) insertUserInfoModel:(UserInfo *_Nonnull)userInfo {
    
    [self.realmObject beginWriteTransaction];
    
    [self.realmObject addOrUpdateObject:userInfo];
    
    [self.realmObject commitWriteTransaction];

}
/**
 获取群分类信息
 */
- (UserInfo *_Nonnull) readUserInformation {

    RLMResults <UserInfo *> *results    = [UserInfo objectsWhere:@"userAccount = %@",self.userAccount];
    UserInfo *userInfo                  = [results lastObject];
    if (!userInfo) {
        return [[UserInfo alloc] init];
    } else {
        return userInfo;
    }
    
}

#pragma mark - BKContactGroup

/**
 存储当前用户所有人脉分组信息
 */
- (void) insertUserContacts:(NSArray <BKCustomersContact *> *_Nonnull)userContacts userId:(NSString *_Nonnull)uid {

    // 新的人脉列表
    BKUsersContactsList *newUserContacts = [[BKUsersContactsList alloc] init];
    newUserContacts.userAccount          = uid;
    
    for (BKCustomersContact *contact in userContacts) {
        [newUserContacts.contacts addObject:contact];
    }

    [self.realmObject beginWriteTransaction];
    
    [self.realmObject addOrUpdateObject:newUserContacts];
    
    [self.realmObject commitWriteTransaction];
    

}

/**
 获取当前登录用户的人脉群组信息
 */
- (NSArray <BKCustomersContact *>*_Nonnull) readUserContacts:(NSString *_Nonnull)userId {
    
    BKUsersContactsList *userContactList = [self userContactList:userId];
    if (!userContactList) {
        return [NSMutableArray array];
    }
    
    NSMutableArray <BKCustomersContact *>*contacts = [NSMutableArray array];
    
    for (BKCustomersContact *contact in userContactList.contacts) {
        [contacts addObject:contact];
    }
    
    return contacts;
}

- (BKUsersContactsList *_Nullable)userContactList:(NSString *)userId {
    
    BKUsersContactsList *userContactList = [[BKUsersContactsList objectsWhere:@"userAccount = %@",userId] lastObject];
    
    return userContactList;
    
}

#pragma mark - BKOptions

/**
 存储app 相关设置的内容
 */
- (void) insertApplictionOptions:(BKPrivacyOptions *_Nonnull)options {
    
    if (!options.userAccount) return;
  
    [self.realmObject beginWriteTransaction];
    [self.realmObject addOrUpdateObject:options];
    [self.realmObject commitWriteTransaction];
    
}

/**
 读取 app 相关设置的内容
 */
- (BKPrivacyOptions *_Nonnull) readApplicationOptions {
    
    RLMResults *results         = [BKPrivacyOptions objectsWhere:@"userAccount = %@",[self userAccount]];
    
    BKPrivacyOptions *options   = [results lastObject];
    
    if (!options) {
        
        options = [[BKPrivacyOptions alloc] initBy:[self userAccount]];
        
        [self.realmObject beginWriteTransaction];
        
        [self.realmObject addOrUpdateObject:options];
        
        [self.realmObject commitWriteTransaction];
        
    }
    
    
    return options;
}


#pragma mark - BlackList

/**
 插入用户黑名单数据
 */
- (void) insertUserBlackList:(NSArray <BKCustomersContact *>*_Nonnull)blackList {
    
    // 新的黑名单列表
    BKBlackListModel *newBlacklistModel = [[BKBlackListModel alloc] init];
    newBlacklistModel.userAccount       = self.userAccount;
    
    // 数据库已经存在的黑名单列表
    BKBlackListModel *oldBlacklistModel                    = [self readUserBlackListModel];
    
    if (oldBlacklistModel) {
        newBlacklistModel.blackLists = oldBlacklistModel.blackLists;
    }
    
    // 通过遍历数组 取出每一个元素 如果该用户不在黑名单列表中就添加到黑名单列表中
    for (BKCustomersContact *contact in blackList) {
        // 判断用户是否在黑名单列表中
        if (![self customerInBlackList:contact.uid]) {
            [newBlacklistModel.blackLists addObject:contact];
        }
    }
    
    
    [self.realmObject beginWriteTransaction];
    
    [self.realmObject addOrUpdateObject:newBlacklistModel];
    
    [self.realmObject commitWriteTransaction];
    
}

/**
 判断当前用户是否在黑名单列表中
 */
- (BOOL) customerInBlackList:(NSString *_Nonnull)userId {
    
    BKBlackListModel *oldBlacklistModel                    = [self readUserBlackListModel];
    RLMResults *oldContacts = [oldBlacklistModel.blackLists objectsWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@",userId]];

    return [oldContacts lastObject] != nil;
}

/**
 获取用户黑名单
 @return 返回黑名单列表
 */
- (NSArray <BKCustomersContact *>*_Nonnull) readUserBlackList {
    
    BKBlackListModel *blackModel                    = [self readUserBlackListModel];
    NSMutableArray <BKCustomersContact *>*contacts  = [NSMutableArray array];
    if (blackModel) {
        RLMArray *array     = blackModel.blackLists;
        for (BKCustomersContact *contact in array) {
            [contacts addObject:contact];
        }
    }
    return contacts;
}

/**
 读取用户黑名单的模型
 */
- (BKBlackListModel *_Nullable) readUserBlackListModel {
    
    RLMResults *results                             = [BKBlackListModel objectsWhere:@"userAccount = %@",self.userAccount];
    
    BKBlackListModel *blackModel                    = [results lastObject];
    
    return blackModel;
    
}
/**
 将用户从黑名单里移除掉
 */
- (void) removeUserFromBlacklist:(BKCustomersContact *_Nonnull) customerUser {
    
    // 获取数据库黑名单对象
    BKBlackListModel *oldBlacklistModel                    = [self readUserBlackListModel];
    
    // 某个联系人在黑名单列表的索引 可能为 NSNotFound 代表不存在这个用户
    NSInteger index         = [oldBlacklistModel.blackLists indexOfObjectWithPredicate:[NSPredicate predicateWithFormat:@"uid = %@",customerUser.uid]];

    if (index != NSNotFound) {
        
        [self.realmObject beginWriteTransaction];
        
        [oldBlacklistModel.blackLists removeObjectAtIndex:index];
        
        [self.realmObject commitWriteTransaction];
        
    }

    
}

#pragma mark - BKChatGroup

/**
 将群组的信息保存到数据库中
 */
- (void) insertChatGroup:(NSArray <BKChatGroupModel *>*_Nonnull)chatGroups {
    
    [self.realmObject beginWriteTransaction];

    for (BKChatGroupModel *group in chatGroups) {
        BOOL isInGroup      = [self cusetomerUserIsInChatGroup:group.groupid];
        group.isInGroup     = isInGroup;
        [self.realmObject addOrUpdateObject:group];
    }
    
    [self.realmObject commitWriteTransaction];
    
}

/**
 获取单个群组的信息
 */
- (BKChatGroupModel *_Nullable) queryChatgroupInfo:(NSString *_Nonnull)gruoupId {
    
    RLMResults *resutls          = [BKChatGroupModel objectsWhere:@"groupid = %@",gruoupId];
    
    BKChatGroupModel *groupModel = [resutls lastObject];

    if (groupModel) {
        
        BOOL isInGroup          = [self cusetomerUserIsInChatGroup:gruoupId];
        
        [self.realmObject beginWriteTransaction];
        
        groupModel.isInGroup    = isInGroup;
        
        [self.realmObject commitWriteTransaction];
        
    }
    
    return groupModel;
}

#pragma mark - 环信群组信息

/**
 存储环信群组的信息 用来判断当前登录用户 是否加入了环信的群
 */
- (void) insertEaseMobGroup:(BKEaseMobGroup *_Nonnull)easeMobGruop {
    
    [self.realmObject beginWriteTransaction];
    
    [self.realmObject addOrUpdateObject:easeMobGruop];
    
    [self.realmObject commitWriteTransaction];
    
}

/**
 查询当前用户是否在某个群组里
 */
- (BOOL) cusetomerUserIsInChatGroup:(NSString *_Nonnull)groupId {
    
    RLMResults *resutls     = [BKEaseMobGroup objectsWhere:@"groupId = %@",groupId];
    
    BKEaseMobGroup *gruop   = [resutls lastObject];
    
    
    return (gruop != nil);
    
}

/**
 用户退出某个群组
 */
- (void) userExitGroupByGroupId:(NSString *_Nonnull)groupId {
    
    RLMResults *resutls = [BKEaseMobGroup objectsWhere:@"groupId = %@",groupId];
    BKEaseMobGroup *easeMobGroup = [resutls lastObject];
    
    if (!easeMobGroup) return;
    
    [self.realmObject beginWriteTransaction];
    [self.realmObject deleteObject:easeMobGroup];
    [self.realmObject commitWriteTransaction];
}

#pragma mark - EaseMobContact

/**
 存储环信联系人列表 用来判断好友关系
 */
- (void) insertEaseMobContact:(NSArray <NSString *>*_Nonnull)contacts {
    
    
    for (NSString *userId in contacts) {
        
        BKEaseMobContact *contact = [[BKEaseMobContact alloc] init];
        
        contact.userId            = userId;
        
        contact.userAccount       = [[BKAuthorizationToken shared] easemob_username];

        [self.realmObject beginWriteTransaction];

        [self.realmObject addOrUpdateObject:contact];

        [self.realmObject commitWriteTransaction];
        
    }
    
    
}

/**
 查询人脉是否为我的好友
 */
- (BOOL) customerUserIsFriendOrderBy:(NSString *_Nonnull)userId {
    return ([self readEaseMobContact:userId] != nil);
}

/**
 获取环信联系人信息 返回 nil 代表该人脉不是我的好友
 */
- (BKEaseMobContact *_Nullable) readEaseMobContact:(NSString *)userId {
    
    RLMResults *results         = [BKEaseMobContact objectsWhere:@"userId = %@ AND userAccount = %@",userId,self.userAccount];
    BKEaseMobContact *contact   = [results lastObject];

    return contact;
}

/**
 删除环信好友信息
 */
- (void) deleteEaseMobContactBy:(NSString *_Nonnull)userId {
    
    BKEaseMobContact *contact   = [self readEaseMobContact:userId];
    
    if (!contact) return;
    
    [self.realmObject beginWriteTransaction];
    
    [self.realmObject deleteObject:contact];
    
    [self.realmObject commitWriteTransaction];
    
}

#pragma mark - BKCustomerContact

/**
 保存人脉资料信息
 */
- (void) insertCustomerContact:(NSArray <BKCustomersContact *>*_Nonnull)contacts {
    
    
    for (BKCustomersContact *contact in contacts) {
        
        BOOL isFriend       = [self customerUserIsFriendOrderBy:contact.uid];
        [self.realmObject beginWriteTransaction];

        contact.isFriend    = isFriend;
        [self.realmObject addOrUpdateObject:contact];
        
        [self.realmObject commitWriteTransaction];
        

    }
    
    
    
}

/**
 查询用户资料
 */
- (BKCustomersContact *_Nullable) queryCustomuserUsersIntable:(NSString *_Nonnull)userId {
    
    RLMResults *results         = [BKCustomersContact objectsWhere:@" uid = %@",userId];
    BKCustomersContact *contact = [results lastObject];
    
    if (contact) {
        BOOL isFriend           = [self customerUserIsFriendOrderBy:userId];
        [self.realmObject beginWriteTransaction];
        contact.isFriend        = isFriend;
        [self.realmObject commitWriteTransaction];
    }
    
    return contact;
}

#pragma mark - 模糊搜索人脉和群组

/**
 模糊搜索群组信息 根据关键字
 */
- (NSArray <BKChatGroupModel *> *_Nonnull) queryChatgroupsOrderByKeywords:(NSString *_Nonnull)keywords {
    
    RLMResults *results                         = [BKChatGroupModel objectsWithPredicate:[self serarchPredicateWith:keywords]];

    NSMutableArray <BKChatGroupModel *>*groups  = [NSMutableArray array];
    
    for (BKChatGroupModel *group in results) {

        BOOL isInGroup          = [self cusetomerUserIsInChatGroup:group.groupid];
        if (isInGroup) {
            [self.realmObject beginWriteTransaction];
            group.isInGroup     = isInGroup;
            [self.realmObject commitWriteTransaction];
            [groups addObject:group];
            continue;
        }
    
    }
    
    return groups;
}

/**
 模糊搜索人脉资料 根据关键字
 */
- (NSArray <BKCustomersContact *> *_Nonnull) queryCustomerUserByKeywords:(NSString *_Nonnull)keywords {
    
    RLMResults *results                            = [BKCustomersContact objectsWithPredicate:[self serarchPredicateWith:keywords]];

    NSMutableArray <BKCustomersContact *>*contacts = [NSMutableArray array];
    
    for (BKCustomersContact *contact in results) {
        
        BOOL isFriend          = [self customerUserIsFriendOrderBy:contact.uid];
        if (isFriend) {
            [self.realmObject beginWriteTransaction];
            contact.isFriend   = isFriend;
            [self.realmObject commitWriteTransaction];
            [contacts addObject:contact];
            continue;
        }
        
    }
    
    return contacts;
    
}

/**
 获取搜索关键字的谓词
 */
- (NSPredicate *) serarchPredicateWith:(NSString *)keywords {
    
    NSString *pinyinLetter                        = [NSString chineseTransformLetter:keywords];
    NSPredicate *predicte                         = [NSPredicate predicateWithFormat:@"pinyin_letter like %@ ",[NSString stringWithFormat:@"*%@*",pinyinLetter]];
    
    return predicte;
}


#pragma mark - BKAddFriendRequest

/**
 保存加好友请求的信息
 */
- (void) insertContactReqeusts:(BKAddFriendReqeust *_Nonnull)addReqeust {
    
    [self.realmObject beginWriteTransaction];

    [self.realmObject addOrUpdateObject:addReqeust];
    
    [self.realmObject commitWriteTransaction];
    
}


/**
 删除一条加好友请求的消息
 */
- (void) deleteContactReqeust:(NSString *_Nonnull)customer_uid {
    
    BKAddFriendReqeust *applyRequest = [[BKAddFriendReqeust objectsWhere:@"userAccount = %@ AND customer_uid = %@",self.userAccount,customer_uid] lastObject];
    
    if (!applyRequest) return;
    
    [self.realmObject beginWriteTransaction];
    
    [self.realmObject deleteObject:applyRequest];
    
    [self.realmObject commitWriteTransaction];
    
}

/**
 获取所有加好友请求/未读加好友请求
 */
- (NSArray <BKAddFriendReqeust *> *_Nonnull) queryContatctApplysInRealm:(BOOL)unreadMessages {
    
    NSPredicate *pre                                =  unreadMessages ? [NSPredicate predicateWithFormat:@"userAccount = %@ AND isRead = %d ",self.userAccount,NO] : [NSPredicate predicateWithFormat:@"userAccount = %@",self.userAccount];
    RLMResults *resutls                             = [BKAddFriendReqeust objectsWithPredicate:pre];
    NSMutableArray <BKAddFriendReqeust *>*applays   = [NSMutableArray array];
    for (BKAddFriendReqeust *request in resutls) {
        [applays addObject:request];
    }
    
    return applays;
}

/**
 用户读取所有未读加好友请求
 */
- (void) userDidReadApplyFriendsNotice {
    
    NSArray *applays = [self queryContatctApplysInRealm:YES];
   
    if ([applays count] == 0) return;
    
    for (BKAddFriendReqeust *request in applays) {
        [self.realmObject beginWriteTransaction];
        request.isRead = YES;
        [self.realmObject commitWriteTransaction];
    }
    
}


#pragma mark - BKSendList 发送了加人脉或群组的模型

- (void) insertSendList:(BKSendList *_Nonnull)sendModel {
    
    [self.realmObject beginWriteTransaction];
    
    [self.realmObject addOrUpdateObject:sendModel];
    
    [self.realmObject commitWriteTransaction];
    
}

/**
 获取发送加人脉 或群组的模型 */
- (BKSendList *_Nullable) querySendListModel:(NSString *_Nonnull)uid {
    
    RLMResults *results     = [BKSendList objectsWhere:@"userAccount = %@ AND uid = %@",self.userAccount,uid];
    BKSendList *sendModel   = [results lastObject];
    
    return sendModel;
}

/**
 删除加好友 或者群组的模型
 */
- (void) deleteSendListModel:(NSString *_Nonnull)uid {
    
    BKSendList *sendModel = [self querySendListModel:uid];
    
    if (!sendModel) return;
    
    [self.realmObject beginWriteTransaction];
    
    [self.realmObject deleteObject:sendModel];
    
    [self.realmObject commitWriteTransaction];
    

}

/**
 插入群组消息 根据 groupId
 */
- (void) insertGroupApply:(BKApplyGroupModel *_Nonnull)applayModel {
    
    [self.realmObject beginWriteTransaction];
    
    [self.realmObject addOrUpdateObject:applayModel];
    
    [self.realmObject commitWriteTransaction];
    
}

/**
 获取群组通知 根据 groupId
 */
- (BKApplyGroupModel *_Nullable) queryGroupApplay:(NSString *_Nonnull)customer_uid {
    
    BKApplyGroupModel *applayModel = [[BKApplyGroupModel objectsWhere:@"userAccount = %@ AND  customer_uid = %@",self.userAccount,customer_uid] lastObject];
    
    return applayModel;
}

/**
 删除群组通知 根据 groupId
 */
- (void) deleteGroupApplay:(NSString *_Nonnull)customer_uid {
    
    BKApplyGroupModel *applyModel = [self queryGroupApplay:customer_uid];
    
    if (!applyModel) return;
    
    [self.realmObject beginWriteTransaction];
    
    [self.realmObject deleteObject:applyModel];
    
    [self.realmObject commitWriteTransaction];
    
    
}

/**
 查询所有未读的群组通知
 */
- (NSArray <BKApplyGroupModel *>*_Nonnull) queryUnreadGroupApplys {
    
    RLMResults *results = [BKApplyGroupModel objectsWhere:@"userAccount = %@ AND isRead = %d",self.userAccount,NO];

    NSMutableArray <BKApplyGroupModel *>*array = [NSMutableArray array];
    
    for (BKApplyGroupModel *applayModel in results) {
        [array addObject:applayModel];
    }
    
    return array;
    
}


/**
 读取所有群组通知
 */
- (NSArray <BKApplyGroupModel *>*_Nonnull) queryAllGroupApplys {
    
    RLMResults *results = [BKApplyGroupModel objectsWhere:@"userAccount = %@",self.userAccount];
    NSMutableArray <BKApplyGroupModel *>*array = [NSMutableArray array];
    for (BKApplyGroupModel *applayModel in results) {
        [array addObject:applayModel];
    }
    return array;
}


/**
 读取所有群组通知
 */
- (void) readAllGroupApplays {

    NSArray *applays = [self queryAllGroupApplys];
    
    for (BKApplyGroupModel *applyModel in applays) {
        
        [self.realmObject beginWriteTransaction];
        applyModel.isRead   = YES;
        [self.realmObject commitWriteTransaction];

    }
    
}


@end
