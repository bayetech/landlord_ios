//
//  BKChatViewController.m
//  BKBayeStore
//
//  Created by 董招兵 on 2016/10/10.
//  Copyright © 2016年 大兵布莱恩特. All rights reserved.
//

#import "BKChatViewController.h"
#import "EaseCustomMessageCell.h"
#import "BayeSocial-Swift.h"
#import "EaseRedPacketMessageCell.h"
#import "BKMessageBaseFrame.h"
#import "BKDidOpenRedPacketCell.h"
#import "BKBusinessCardCell.h"

@interface BKChatViewController () <EaseMessageViewControllerDelegate, EaseMessageViewControllerDataSource,BKChatSettingViewControllerDelegate,BKGroupSettingViewControllerDelegate,BKAddGroupMemberViewControllerDelegate,BKSendRedpacketViewControllerDelegate,
    EaseRedPacketMessageCellDelegate,
    BKShowRedPacketViewDelegate
>
{
    EaseRedPacketMessageCell *_selectCell;
}
@property (nonatomic) NSMutableDictionary *emotionDic;
@property (nonatomic, copy) EaseSelectAtTargetCallback selectedCallback;
@property (nonatomic,strong) NSMutableDictionary *customerCellFrame;
@property (nonatomic,strong) BKShowRedPacketView *showPacketView;

@end

@implementation BKChatViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    self.showRefreshHeader                  = YES;
    self.delegate                           = self;
    self.dataSource                         = self;
    
    if (!self.isGoupChat) {
        
        // chat_setting
        UIButton *button                        = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"chat_setting"] forState:UIControlStateNormal];
        button.frame                            = CGRectMake(0.0f, 0.0f, 30.0f, 6.0f);
        [button addTarget:self action:@selector(groupSetting) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithCustomView:button];
        
    } else {
        
        UIButton *button                        = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"group_setting"] forState:UIControlStateNormal];
        button.frame                            = CGRectMake(0.0f, 0.0f, 30.0f, 22.0f);
        [button addTarget:self action:@selector(groupSetting) forControlEvents:UIControlEventTouchUpInside];
        self.navigationItem.rightBarButtonItem  = [[UIBarButtonItem alloc] initWithCustomView:button];
        
    }
    
    // 返回按钮
    BKAdjustButton *backButton                  = [BKAdjustButton buttonWithType:UIButtonTypeCustom];
    [backButton setImage:[UIImage imageNamed:@"black_backArrow"] forState:UIControlStateNormal];
    backButton.frame                            = CGRectMake(0.0f, 0.0f, 21.0,30.f);
    [backButton setImageViewSizeEqualToCenter:CGSizeMake(13.0f, 21.0f)];
    [backButton addTarget:self action:@selector(back)];
    
    self.navigationItem.leftBarButtonItem       = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 清除@信息标示已经查看过@我的消息
    EMConversation *conversation        = [[EMClient sharedClient].chatManager getConversation:self.conversation.conversationId type:self.conversationType createIfNotExist:YES];
    if (conversation.latestMessage != nil) {
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UpdateConversationLastMessage" object:conversation];
        
    } else if ([self.dataArray count] == 0)  {
        
        [[EMClient sharedClient].chatManager deleteConversation:conversation.conversationId isDeleteMessages:NO completion:nil];

    }
    
    [self.inputTextField                                    resignFirstResponder];
    
}
- (NSMutableDictionary *)customerCellFrame {
    if (!_customerCellFrame) {
        _customerCellFrame = [NSMutableDictionary dictionary];
    }
    return _customerCellFrame;
}

- (void)back {
    
    [[ BKRealmManager shared] insertCustomerContact:self.groupMembers.allValues];
    [self.navigationController popToRootViewControllerAnimated:YES];
    
}

/**
 群设置
 */
- (void)groupSetting {
    
    if (!self.isGoupChat) { // 个人聊天设置
        
        BKChatSettingViewController *chatSettingVC = [[BKChatSettingViewController alloc] init];
        chatSettingVC.delegate                      = self;
        chatSettingVC.userId                        = self.userOther.uid;
        chatSettingVC.leftTitle                     = @"聊天设置";
        chatSettingVC.needCleanChatHistory          = YES;
        [self.navigationController pushViewController:chatSettingVC animated:YES];

    } else { // 群聊天设置
        
        BKGroupSettingViewController *settingVC = [[BKGroupSettingViewController alloc] init];
        settingVC.group_id                      = self.conversation.conversationId;
        settingVC.delegate                      = self;
        NSArray *groupCustomers                 = [self sortingGroupmembers];
        settingVC.groupMembers                  = groupCustomers;
        settingVC.isNotdisturbing               = self.group.isPushNotificationEnabled;
        [self.navigationController pushViewController:settingVC animated:YES];
        
    }
    
}

- (void)setUserInfo:(Userinfo *)userInfo {
    _userInfo   = userInfo;
    
}

#pragma mark - EaseMessageViewControllerDataSource

- (NSArray*)emotionFormessageViewController:(EaseMessageViewController *)viewController
{
    NSMutableArray *emotions = [NSMutableArray array];
    for (NSString *name in [EaseEmoji allEmoji]) {
        EaseEmotion *emotion = [[EaseEmotion alloc] initWithName:@"" emotionId:name emotionThumbnail:name emotionOriginal:name emotionOriginalURL:@"" emotionType:EMEmotionDefault];
        [emotions addObject:emotion];
    }
    EaseEmotion *temp                   = [emotions objectAtIndex:0];
    EaseEmotionManager *managerDefault  = [[EaseEmotionManager alloc] initWithType:EMEmotionDefault emotionRow:3 emotionCol:7 emotions:emotions tagImage:[UIImage imageNamed:temp.emotionId]];

    return @[managerDefault];
}

- (BOOL)isEmotionMessageFormessageViewController:(EaseMessageViewController *)viewController
                                    messageModel:(id<IMessageModel>)messageModel
{
    BOOL flag = NO;
    if ([messageModel.message.ext objectForKey:MESSAGE_ATTR_IS_BIG_EXPRESSION]) {
        return YES;
    }
    return flag;
}

- (EaseEmotion*)emotionURLFormessageViewController:(EaseMessageViewController *)viewController
                                      messageModel:(id<IMessageModel>)messageModel
{
    NSString *emotionId         = [messageModel.message.ext objectForKey:MESSAGE_ATTR_EXPRESSION_ID];
    EaseEmotion *emotion        = [_emotionDic objectForKey:emotionId];
    if (emotion == nil) {
        emotion                 = [[EaseEmotion alloc] initWithName:@"" emotionId:emotionId emotionThumbnail:@"" emotionOriginal:@"" emotionOriginalURL:@"" emotionType:EMEmotionGif];
    }
    return emotion;
}

- (NSDictionary*)emotionExtFormessageViewController:(EaseMessageViewController *)viewController easeEmotion:(EaseEmotion*)easeEmotion
{
    return @{MESSAGE_ATTR_EXPRESSION_ID:easeEmotion.emotionId,MESSAGE_ATTR_IS_BIG_EXPRESSION:@(YES)};
}

#pragma mark - EaseRedPacketMessageCell 抢红包的 cell 和 高度 delegate

/**
 抢红包的 cell
 */
- (UITableViewCell *_Nonnull)messageViewController:(UITableView *)tableView cellForRedPacketMessageModel:(id<IMessageModel>)messageModel {
    
    EaseRedPacketMessageCell *redPacketCell = [[EaseRedPacketMessageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"EaseRedPacketMessageCell"];
    
    EaseRedPacketMessageFrame *frameModel   = [self.customerCellFrame objectForKey:messageModel.message.messageId];
    
    redPacketCell.frameModel                = frameModel;
    
    redPacketCell.delegate                  = self;

    return redPacketCell;
}


/**
 抢红包的 cellHeight
 */
- (CGFloat)messageViewController:(EaseMessageViewController *)viewController
  heightForRedPacketMessageModel:(id<IMessageModel>)messageModel {
    
    EaseRedPacketMessageFrame *frame = [self.customerCellFrame objectForKey:messageModel.message.messageId];
    if (!frame) {
        frame                                               = [[EaseRedPacketMessageFrame alloc]initWithMessageModel:messageModel customerUser:[super getCustomerModel:messageModel]];
        self.customerCellFrame[messageModel.message.messageId] = frame;
    }
    return frame.rowHeight;
}


#pragma mark - EaseRedPacketMessageCellDelegate 红包 cell 的代理

/**
 点击了红包视图
 */
- (void)bkMessageCell:(EaseRedPacketMessageCell *)cell didSelectBubbleImageView:(BKMessageBaseFrame *)farmeModel {
    
    if (self.showPacketView) return;
    
    _selectCell                                        = cell;
    _selectCell.bubbleImageView.userInteractionEnabled = NO;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    
    __weak typeof(self) weakself = self;
    [BKNetworkManager getOperationReqeust:[NSString stringWithFormat:@"%@send_red_packets/%@/prepare",[UnitTools ApiHost],cell.redpacketId] params:nil success:^(BKNetworkResult * success) {
        __strong typeof(weakself)strongself = weakself;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [strongself showRedPacketView:success.data tableViewCell:cell];
        });
       
    } failure:^(BKNetworkResult *failure) {
        
        __strong typeof(weakself)strongself = weakself;
        [MBProgressHUD hideHUDForView:strongself.view animated:YES];
        [UnitTools addLabelInWindow:failure.errorMsg vc:self];
        [strongself recoverBubbleViewAction];
        
    }];
    
    
}

/**
 恢复红包气泡的点击功能
 */
- (void)recoverBubbleViewAction {
    
    self.showPacketView                                 = nil;
    _selectCell.bubbleImageView.userInteractionEnabled  = YES;
    _selectCell                                         = nil;
    
}

- (void) showRedPacketView:(id)data tableViewCell:(EaseRedPacketMessageCell *)cell {
    
    [MBProgressHUD hideHUDForView:self.view animated:YES];
    
    NSDictionary *dict                  = data;
    NSString *returnMessage             = dict[@"return_message"];
    NSNumber *return_code               = dict[@"return_code"];
    if (return_code.integerValue != 200) {
        [UnitTools addLabelInWindow:returnMessage vc:self];
        [self recoverBubbleViewAction];
        return;
    }
    
    NSString *message                   = dict[@"message"];
    NSNumber *expired                   = dict[@"expired"];
    NSString *open_state                = stringEmpty(dict[@"open_state"]) ? @"unknow" : dict[@"open_state"];
    NSString *redPacketType             = stringEmpty(dict[@"category"]) ? @"" : dict[@"category"];
    NSDictionary *customer              = dict[@"customer"];
    NSString *redPacket_ownerId         = customer[@"uid"];
    // 判断是否拆开过红包,已拆过进红包详情页面,未拆过判断红包其他状态
    // 个人红包不支持自己领取
   if ([open_state isEqualToString:@"opened"]) {
        
        [self showRedPacketViewLucklabelClick:cell.redpacketId  didOpenRedPacket:YES];

    } else {
        
        // 是否是个人红包 和红包的发起者
        BOOL persionlRedPacket  = [redPacketType isEqualToString:@"individual_red_packet"];
        BOOL isRedPacketOwner   = [redPacket_ownerId isEqualToString:[[BKAuthorizationToken shared] easemob_username]];
        // 个人红包并且发送是自己发的红包不支持领取
        if (persionlRedPacket && isRedPacketOwner) {
            [self showRedPacketViewLucklabelClick:cell.redpacketId  didOpenRedPacket:NO];
            return;
        }
        
        // 判断是否为过期
        self.showPacketView                             = [[BKShowRedPacketView alloc] initWithFrame:CGRectMake(0.0, 0.0, KScreenWidth, KScreenHeight)];
        if (expired.boolValue) { // 红包过期
            self.showPacketView.showType                = BKShowRedPacketTypeTimeOut;
        } else if ([open_state isEqualToString:@"opened_all"]) { // 红包领取完了
            self.showPacketView.showType                = BKShowRedPacketTypeComplete;
        } else if ([open_state isEqualToString:@"can_open"]) { // 红包可以拆开
            self.showPacketView.showType                = BKShowRedPacketTypeOpen;
        }
        
        self.showPacketView.customer                    = customer;
        self.showPacketView.delegate                    = self;
        self.showPacketView.message                     = message;
        self.showPacketView.redPacketId                 = cell.redpacketId;
        self.showPacketView.showLuckLabel               = persionlRedPacket;
        
        [[AppDelegate appDelegate].window addSubview:self.showPacketView];
        
    }
}
/**
 点击了用户头像
 */
- (void)bkMessageCell:(BKMessageBaseCell *)cell didSelectUserAvatar:(NSString *)userId {

    [self messageViewController:self didSelectAvatarUserid:userId];
    
}

#pragma mark - BKChatSettingViewControllerDelegate

/**
 清除聊天历史记录
 */
- (void)chatSettingViewControllerDidCleanHistroy:(BKChatSettingViewController * _Nonnull)viewController {
    
    [self cleanChatMessage];
    
}

/**
 清除聊天记录
 */
- (void)cleanChatMessage {
    
    EMError *error                  = nil;
    
    self.messageTimeIntervalTag     = -1;
    [self.conversation deleteAllMessages:&error];
    [self.dataArray removeAllObjects];
    [self.messsagesSource removeAllObjects];
    
    [self.tableView reloadData];
    
    [UnitTools addLabelInWindow:@"清除聊天记录成功" vc:nil];
    
}



#pragma mark -  EaseUIDelegate 

/**
 点击了用户头像
 */
- (void)messageViewController:(EaseMessageViewController *)viewController didSelectAvatarUserid:(NSString *)userId {
    
    BKUserDetailViewController *detailViewController = [[BKUserDetailViewController alloc] init];
    detailViewController.userId                      = userId;
    [self.navigationController pushViewController:detailViewController animated:YES];
    
}
#pragma mark - BKGroupSettingViewControllerDelegate

/**
 清除聊天群设置里边点击了清除聊天记录
 */
- (void)groupSettingViewControllerWithCleanChatMessage:(BKGroupSettingViewController *)viewController {
    
    [self cleanChatMessage];
    
}

/**
 选择了群@功能
 */
- (void)messageViewController:(EaseMessageViewController *)viewController selectAtTarget:(EaseSelectAtTargetCallback)selectedCallback {
    
    _selectedCallback                                       = selectedCallback;
    [self.inputTextField                                    resignFirstResponder];

    [self showGroupMembers:@"选择提醒的人" displayType:SelectMembersTypeRemind];
    
}

/**
  长按点击头像@某人
 */
- (void)didLongPressAvatar:(NSString *)userId {
    [super didLongPressAvatar:userId];

    if (!self.isGoupChat) return;
    
    [self.inputTextField becomeFirstResponder];
    
    NSString *uid                               = [userId copy];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:stringEmpty(self.inputTextField.text) ? @"" : self.inputTextField.text];
    BKCustomersContact *contact                 = [self.groupMembers objectForKey:uid];
    [attributedString appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"@%@ ",contact.name]]];
    
    self.inputTextField.attributedText          = attributedString;
    
    // @别人的消息
    EaseAtTarget *target                        = [[EaseAtTarget alloc] init];
    target.userId                               = uid;
    target.nickname                             = contact.name != nil ? contact.name : uid;
    
    [self.atTargets addObject:target];
    
}

- (NSArray *)sortingGroupmembers {
    
    NSMutableArray *groupCustomers          = [NSMutableArray arrayWithArray:self.groupMembers.allValues];
    for (int i=0; i<groupCustomers.count; i++) {
        BKCustomersContact *contact = groupCustomers[i];
        if ([contact.uid isEqualToString:self.group.owner]) {
            [groupCustomers exchangeObjectAtIndex:i withObjectAtIndex:0];
            break;
        }
    }
    return groupCustomers;
}

- (void) showGroupMembers:(NSString *)title displayType: (SelectMembersType)type {
    
    
    BKAddGroupMemberViewController *membersViewController       = [[BKAddGroupMemberViewController alloc] init];
    if (type == SelectMembersTypeRemind) {
        
        if (self.groupMembers.count<1) return;
        membersViewController.userContacts                      = self.groupMembers.allValues;
        
    } else {
        membersViewController.userId                            = [[BKAuthorizationToken shared] easemob_username];
    }
    membersViewController.displayType                       = type;
    membersViewController.delegate                          = self;
    membersViewController.title                             = title;
    BKNavigaitonController *nav                             = [[BKNavigaitonController alloc] initWithRootViewController:membersViewController];
    [self presentViewController:nav animated:YES completion:nil];
    
}

#pragma mark - BKAddGroupMemberViewControllerDelegate

/**
 群聊@选择群成员后的代理
 */
- (void)didFinishedGroupMembers:(NSDictionary<NSString *,NSString *> *)contacts viewController:(BKAddGroupMemberViewController * _Nonnull)viewController {
    
    [self.inputTextField becomeFirstResponder];

    NSArray *userIds         = contacts.allKeys;
    // 群@某人
    if (viewController.displayType == SelectMembersTypeRemind) {
        
        EaseAtTarget *target    = [[EaseAtTarget alloc] init];
        NSString *userId        = userIds.firstObject;
        NSString *userName      = contacts[userId];
        
        target.userId           = userId;
        target.nickname         = userName != nil ? userName : userId;;
        _selectedCallback(target);
        _selectedCallback       = nil;
        
    }  else if (viewController.displayType == SelectMembersTypeTransmit) { // 转发给某人
        
        for (NSString *userId in userIds) {
            
            EMTextMessageBody *body         = [[EMTextMessageBody alloc] initWithText:self.transmitMsg];
            NSString *from                  = [[EMClient sharedClient] currentUsername];
            EMConversation *conversation    = [[[EMClient sharedClient]chatManager] getConversation:userId type:EMConversationTypeChat createIfNotExist:YES];
            //生成Message
            EMMessage *message              = [[EMMessage alloc] initWithConversationID:conversation.conversationId from:from to:userId body:body ext:nil];
            message.chatType                = EMChatTypeChat;// 设置为单聊消息
            
            [[EMClient sharedClient].chatManager sendMessage:message progress:nil completion:^(EMMessage *message, EMError *error) {
                
            }];
            
        }
        
    }
    
    
}

/**
 选择完用户详情后的代理
 */
- (void) userDetail:(BKCustomersContact *)customer viewController:(BKAddGroupMemberViewController *)viewController {
    

//    NSMutableDictionary *ext        = [NSMutableDictionary dictionary];
//    ext[@"referrerUserCard"]        = customer.mj_keyValues;
//    // 发送@消息的时候附带个人资料
//    NSDictionary *user              = self.userSelf.mj_keyValues;
//    ext[@"customer"]                = user;
//    
//    [self sendTextMessage:[NSString stringWithFormat:@"你推荐了%@",customer.name] withExt:@{@"userCard" : ext}];
//    
}
//长按收拾回调样例：
- (BOOL)messageViewController:(EaseMessageViewController *)viewController
   canLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    //样例给出的逻辑是所有cell都允许长按
    return YES;
}

- (BOOL)messageViewController:(EaseMessageViewController *)viewController
   didLongPressRowAtIndexPath:(NSIndexPath *)indexPath
{
    //样例给出的逻辑是长按cell之后显示menu视图
    id object = [self.dataArray objectAtIndex:indexPath.row];
    if (![object isKindOfClass:[NSString class]]) {
        id  cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [cell becomeFirstResponder];
        self.menuIndexPath = indexPath;
        if ([cell isKindOfClass:[BKMessageBaseCell class]]) {
            EaseRedPacketMessageCell *customerCell = (EaseRedPacketMessageCell*)cell;
            [self showMenuViewController:customerCell.bubbleImageView andIndexPath:indexPath messageType:EMMessageBodyTypeImage];
            return YES;
        } else if ([cell isKindOfClass:[BKDidOpenRedPacketCell class]]) {
            BKDidOpenRedPacketCell *openCell = (BKDidOpenRedPacketCell*)cell;
            [self showMenuViewController:openCell.bubbleView andIndexPath:indexPath messageType:EMMessageBodyTypeImage];
            return YES;
        }
        
        EaseMessageCell *messageCell = (EaseMessageCell*)cell;
        [self showMenuViewController:messageCell.bubbleView andIndexPath:indexPath messageType:messageCell.model.bodyType];
        
    }
    return YES;
}

#pragma mark - EMChatBarMoreViewDelegate

/**
 转发的功能
 */
- (void)transmitMsgAction:(id)target {
    [super transmitMsgAction:target];
    
    [self showGroupMembers:@"我的人脉" displayType:SelectMembersTypeInvitation];
    
}
/**
 名片
 */
- (void)moreViewBusinessCardAction:(EaseChatBarMoreView *)moreView {
    [super moreViewBusinessCardAction:moreView];
    [self showGroupMembers:@"选择朋友" displayType:SelectMembersTypeBusinessCard];
}
/**
 红包功能
 */
- (void)moreViewRedPacketAction:(EaseChatBarMoreView *)moreView {
    [super moreViewRedPacketAction:moreView];

    BKSendRedpacketViewController *sendRedPacketViewController = [[BKSendRedpacketViewController alloc] init];
    sendRedPacketViewController.redPacketType                  = self.isGoupChat ? RedPacketTypeGroup : RedPacketTypePersonal;
    sendRedPacketViewController.title                          = self.title;
    sendRedPacketViewController.delegate                       = self;
    [self.navigationController pushViewController:sendRedPacketViewController animated:YES];
    
}

#pragma mark - BKSendRedpacketViewControllerDelegate


- (void)didSendPacket:(NSString *)msg ext:(NSDictionary<NSString *,id> *)ext {
    
    [self sendTextMessage:msg withExt:ext];
}

#pragma mark BKShowRedPacketViewDelegate

/**
 视图已经消失
 */
- (void)showRedPacketViewDismiss:(BKShowRedPacketView * _Nonnull)view {
    
    [self recoverBubbleViewAction];
}
/**
 拆红包
 */
- (void)showRedPacketViewSeparateButtonClick:(BKShowRedPacketView * _Nonnull)showRedPacketView {

    [self recoverBubbleViewAction];
    
    __weak typeof(self) weakself = self;
    [BKNetworkManager getOperationReqeust:[NSString stringWithFormat:@"%@send_red_packets/%@/open",[UnitTools ApiHost],showRedPacketView.redPacketId] params:nil success:^(BKNetworkResult *success) {
        __strong typeof(weakself)strongself = weakself;
        NSString *redpacketId               = [showRedPacketView.redPacketId copy];
        [showRedPacketView removeFromSuperview];
        
        NSNumber *return_code               = (NSNumber *)success.data[@"return_code"];
        NSString *return_message            = success.data[@"return_message"];
        // 打开红包失败
        if (return_code.integerValue != 200) {
            [UnitTools addLabelInWindow:return_message vc:strongself];
            return ;
        }
        
        // 发送领取的拓展消息
        NSDictionary *open_red_packets          = success.data[@"open_red_packets"];
        NSDictionary *dictionary                = [[EMIMHelper shared] showRedPacketMessage:open_red_packets];

        NSString *message                       = dictionary[@"message"];
        
        NSDictionary *dict                      = [NSDictionary dictionaryWithObjectsAndKeys:[open_red_packets jsonString],@"open_red_packets",[NSNumber numberWithBool:YES],@"is_open_money_msg", nil];
        
        NSMutableDictionary *ext                       = [NSMutableDictionary dictionaryWithDictionary:dict];
        
        [strongself sendTextMessage:message withExt:ext];
        
        [[EMCDDeviceManager sharedInstance] playNewMessageSoundWithSoundName:@"sound_redpacket_open.wav"];
        
        // 查看红包领取详情
        [strongself showRedPacketViewLucklabelClick:redpacketId didOpenRedPacket:YES];
        
    } failure:^(BKNetworkResult *failure)   {
        __strong typeof(weakself)strongself = weakself;
        [UnitTools addLabelInWindow:failure.errorMsg vc:strongself];
    }];
    
    
    

}
/**
 看看大家手气
 */
- (void)showRedPacketViewLucklabelClick:(NSString *)redpacketId didOpenRedPacket:(BOOL)didOpenRedPacket {
    
    [self recoverBubbleViewAction];
    
    BKRedPacketDetailsViewController *redpacketDetailsViewController                            = [[BKRedPacketDetailsViewController alloc] init];
    redpacketDetailsViewController.redPacketId          = redpacketId;
    redpacketDetailsViewController.detailsType          = didOpenRedPacket ? PacketDetailsTypeDidSeparate : PacketDetailsTypeNoSeparate;
    [self.navigationController pushViewController:redpacketDetailsViewController animated:YES];
    
}


#pragma mark - OpenRedPacketMessageCell

- (UITableViewCell *)messageViewController:(UITableView *)tableView cellForDidOpenRedPacketMessageModel:(id<IMessageModel>)messageModel {
    
    BKDidOpenRedPacketCell *openCell   = [tableView dequeueReusableCellWithIdentifier:@"OpenRedPacketCell"];
    
    if (!openCell) {
        openCell            = [[BKDidOpenRedPacketCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"OpenRedPacketCell"];
    }
    

    NSDictionary *ext       = messageModel.message.ext[@"open_red_packets"];
    NSString *message       = [[EMIMHelper shared] showRedPacketMessage:ext][@"message"];

    openCell.text           = message;
    
 
    return openCell;
    
}

#pragma mark - UserCard 用户个人名片

- (UITableViewCell *)messageViewController:(UITableView *)tableView cellForUserCardWithMessageModel:(id<IMessageModel>)messageModel {
    
    BKBusinessCardCell *userCardCell = [tableView dequeueReusableCellWithIdentifier:@"UserCardCell"];
    
    if (!userCardCell) {
        userCardCell                            = [[BKBusinessCardCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"UserCardCell"];
        userCardCell.delegate                   = self;
    }
    
    userCardCell.frameModel                     = [self getUserBusinessCardFrame:messageModel];
    
    return userCardCell;
}

- (BKMessageBaseFrame *)getUserBusinessCardFrame:(id<IMessageModel>)messageModel {
    
    BKBusinessCardFrame *cardFrame                              = self.customerCellFrame[messageModel.message.messageId];
    if (!cardFrame) {
        cardFrame                                               = [[BKBusinessCardFrame alloc] initWithMessageModel:messageModel customerUser:[super getCustomerModel:messageModel]];
        self.customerCellFrame[messageModel.message.messageId]  = cardFrame;
    }
    
    return cardFrame;
}

- (CGFloat)messageViewController:(EaseMessageViewController *)viewController heightForUserCardMessageModel:(id<IMessageModel>)messageModel {
    
    return [self getUserBusinessCardFrame:messageModel].rowHeight;
}

/**
 点击查看名片
 */
- (void) bkUserCardCell:(BKMessageBaseCell *)cell didSelectBubbleImageView:(BKCustomersContact *)user {
    
    BKUserDetailViewController *userDetailViewController    = [[BKUserDetailViewController alloc] init];
    userDetailViewController.userId                         = user.uid;
    [self.navigationController pushViewController:userDetailViewController animated:YES];
    
}


@end
