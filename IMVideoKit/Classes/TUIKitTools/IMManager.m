//
//  IMManager.m
//  LiveFuller
//
//  Created by kerwin Zhang on 2020/4/22.
//  Copyright © 2020 Fullerton. All rights reserved.
//

#import "IMManager.h"
#import "TCUtil.h"
#import <ImSDK/ImSDK.h>
#import "IMCustomMessageModel.h"
#import "VideoCallUserModel.h"
#import "VideoCallViewController.h"
#import "TRTCCloud.h"
#import "TUIKit.h"
#import <IMVideoKit/IMVideoKit-Swift.h>
#import "TUIConversationCellData.h"
#import "IMVideoKit-umbrella.h"
//#import "CustomAlertView.h"
#import "TeleMedicineAlertView.h"
//#import "TMCompleteViewController.h"
//#import "ConsultationDetailViewController.h"
//#import "WaitingDoctorsViewController.h"
//#import "OnDemandReviewViewController.h"
#define Key_UserInfo_User  @"Key_UserInfo_User"



@interface IMManager()<TRTCVideoCallDelegate>

@property(nonatomic,copy)NSString *usersig;
@property(nonatomic,strong)VideoCallViewController *videoCallVC;
@property(nonatomic,strong)TeleMedicineAlertView *alertView;
@end
@implementation IMManager
-(void)dealloc{
    [[NSNotificationCenter defaultCenter]removeObserver:self];
    [[TRTCVideoCall shared] destroy];
}

+(IMManager *)shareManager{
    
    static IMManager *manager =nil;
    
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        
        if (manager == nil) {
            
            manager = [[self alloc]init];
        }
    });
    
    return manager;
    
}
- (instancetype)init
{
    self = [super init];
    if (self) {
        
        self.alreadyHasAGroup = NO;
        //注册监听
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(onUserStatus:) name:TUIKitNotification_TIMUserStatusListener object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(onNewMessageNotification:) name:TUIKitNotification_TIMMessageListener object:nil];
    }
    return self;
}

-(NSString *)conversationId{
    if ([_conversationId isKindOfClass:[NSNull class]]) {
        return @"";
    }
    return _conversationId;
}
-(void)setImAppId:(NSString *)ImAppId{
    _ImAppId = ImAppId;
    
    [[TUIKit sharedInstance]setupWithAppId:[ImAppId integerValue]];
    //初始化TUIkit
    TUIKitConfig *uiconfig = [TUIKitConfig defaultConfig];
    uiconfig.avatarType = TAvatarTypeRounded;
    [[TRTCVideoCall shared] setup];
    [TRTCVideoCall shared].delegate = self;
}
-(void)loginIMWithAppId:(NSString *)appId UserId:(NSString *)userid userSig:(NSString *)userSig deviceToken:(NSData * _Nullable)deviceToken success:(void(^)(void))success fail:(void(^)(NSInteger code,NSString *msg))fail{
    [[TIMManager sharedInstance]unInit];
    
    self.ImAppId = appId;
    NSInteger sdkid = [self.ImAppId integerValue];
    uint32_t sdkcode = (uint32_t)sdkid;
   
    self.userid = userid;
    self.usersig = userSig;
    //登录IM(视频通话,IM)
    [[TRTCVideoCall shared]loginWithSdkAppID:sdkcode user:userid userSig:userSig success:^{
        
        //设置 APNS
        
        if (deviceToken) {
            TIMTokenParam *param = [[TIMTokenParam alloc]init];
            NSInteger CertIDStr = [self.ImCertID integerValue];
            uint32_t CertID = (uint32_t)CertIDStr;
            param.busiId = CertID;
            param.token = deviceToken;
            
            [[TIMManager sharedInstance]setToken:param succ:^{
                NSLog(@"-----> 上传 token 成功 ");
                //推送声音的自定义化设置
                TIMAPNSConfig *config = [[TIMAPNSConfig alloc]init];
                config.openPush = 1;
                [[TIMManager sharedInstance]setAPNS:config succ:^{
                    NSLog(@"-----> 设置 APNS 成功");
                } fail:^(int code, NSString *msg) {
                    NSLog(@"-----> 设置 APNS 失败");
                }];
            } fail:^(int code, NSString *msg) {
                NSLog(@"-----> 上传 token 失败 ");
            }];
        }
        success();
        
    } failed:^(NSInteger code, NSString * _Nonnull msg) {
        fail(code,msg);
    }];
    
}
-(void)setToken:(NSData *)deviceToken{
    //设置 APNS
    if (deviceToken) {
        TIMTokenParam *param = [[TIMTokenParam alloc]init];
        NSInteger CertIDStr = [self.ImCertID integerValue];
        uint32_t CertID = (uint32_t)CertIDStr;
        param.busiId = CertID;
        param.token = deviceToken;
        [[TIMManager sharedInstance]setToken:param succ:^{
            NSLog(@"-----> 上传 token 成功 ");
            //推送声音的自定义化设置
            TIMAPNSConfig *config = [[TIMAPNSConfig alloc]init];
            config.openPush = 0;
            [[TIMManager sharedInstance]setAPNS:config succ:^{
                NSLog(@"-----> 设置 APNS 成功");
            } fail:^(int code, NSString *msg) {
                NSLog(@"-----> 设置 APNS 失败");
            }];
        } fail:^(int code, NSString *msg) {
            NSLog(@"-----> 上传 token 失败 ");
        }];
    }
}
-(void)isAllMute:(IMManagerMuteBlock)result{
    
    [[TIMGroupManager sharedInstance]getGroupInfo:@[self.conversationId] succ:^(NSArray *groupList) {
        TIMGroupInfo *groupInfo = groupList[0];
        if (groupInfo.allShutup) {
            
            result(YES);
        }
    } fail:^(int code, NSString *msg) {
        
    }];
    
}
-(TUIConversationCellData *)conversationData{
    TUIConversationCellData *data = [[TUIConversationCellData alloc] init];
    data.convId = self.conversationId;
    data.convType = self.isGroup?TIM_GROUP:TIM_C2C;
    return data;
}
-(NSInteger)unreadNum{
    if ([NSString strIsEmpty:self.conversationId]) {
        return 0;
    }
    TIMConversation *conv = [[TIMManager sharedInstance]getConversation:self.isGroup?TIM_GROUP:TIM_C2C receiver:self.conversationId];
    return conv.getUnReadMessageNum;
    
}
-(NSString *)groupName{
    if ([NSString strIsEmpty:self.conversationId]) {
        return @"";
    }
    TIMConversation *conv = [[TIMManager sharedInstance]getConversation:self.isGroup?TIM_GROUP:TIM_C2C receiver:self.conversationId];
    return conv.getGroupName;
}
-(BOOL)lastMsgIsEnd{
    
    TIMConversation *conv = [[TIMManager sharedInstance]getConversation:TIM_GROUP receiver:self.conversationId];
    TIMMessage *msg = [conv getLastMsg];
    TIMElem *elem = [msg getElem:0];
    
    if([elem isKindOfClass:[TIMCustomElem class]]) {
        NSDictionary *param = [TCUtil jsonData2Dictionary:[(TIMCustomElem *)elem data]];
        IMCustomMessageModel *model = [IMCustomMessageModel initWithDictionary:param];
        if (param != nil && [model.MsgType isEqualToString:@"SYSMuteElem"]) {
        
            return YES;
        }
    }
    return NO;

}
-(void)setAllRead{
    
    TIMConversation *conv = [[TIMManager sharedInstance]getConversation:TIM_GROUP receiver:self.conversationId];
    [conv setReadMessage:nil succ:^{
        
    } fail:^(int code, NSString *msg) {
        
    }];
        
}
+(void)getUsersProfile:(NSArray<NSString*>*)users successBlock:(void(^)(NSArray<TIMUserProfile *> *))success failBlock:(void(^)(int code, NSString *msg))fail{
    [[TIMFriendshipManager sharedInstance]getUsersProfile:users forceUpdate:YES succ:^(NSArray<TIMUserProfile *> *profiles) {
        success(profiles);
    } fail:^(int code, NSString *msg) {
        fail(code,msg);
    }];
}

- (void)onUserStatus:(NSNotification *)notification
{
    TUIUserStatus status = [notification.object integerValue];
    if ([self.delegate respondsToSelector:@selector(UserStatusChange:)]) {
        [self.delegate UserStatusChange:status];
    }
    
}

- (void)onNewMessageNotification:(NSNotification *)no
{
    
    NSArray<TIMMessage *> *msgs = no.object;
    if ([self.conversationId isEqualToString:[[msgs.firstObject getConversation]getReceiver]]) {
        [[NSNotificationCenter defaultCenter]postNotificationName:IMNewMessageNotification object:nil];
    }
    
    TIMMessage *msg = msgs.firstObject;
    TIMElem *elem = [msg getElem:0];
    if ([elem isKindOfClass: [TIMCustomElem class]]) {
        TIMCustomElem *cus = (TIMCustomElem *)elem;
        NSString *str = [[NSString alloc] initWithData:cus.data encoding:NSUTF8StringEncoding];
        NSLog(@"📳📳📳📳📳📳%@",str);
        VideoCallModel *model = [[VideoCallUtils shared]data2CallModelWithData:cus.data];
        if (msg&&elem&&cus&&model){
            if (model.calltype !=  VideoCallTypeVideo){
                return;
            }
            [[NSNotificationCenter defaultCenter]postNotificationName:VideoMessageNotification object:msgs];
        }
    }
}
-(BOOL )checkCallTimeOut:(TIMMessage *)msg{
    
    if (msg.timestamp.timeIntervalSinceNow > 60) {
        return YES;
    }
    return NO;
}


-(void)IMLogout{
    
    [[TIMManager sharedInstance] logout:^{
        NSLog(@"******** im log out success ********");
    } fail:^(int code, NSString *msg) {
        NSLog(@"******** im log out fail code: %d msg: %@ ********",code,msg);
    }];
}

#pragma -mark - trtcdelegate
-(void)onErrorWithCode:(int32_t)code msg:(NSString *)msg{
    
    NSLog(@"error code : %d",code);
    NSLog(@"error msg : %@",msg);
}

-(void)onInvitedWithSponsor:(NSString *)sponsor isFromGroup:(BOOL)isFromGroup userModel:(VideoCallModel *)userModel{
    NSLog(@"📳 onInvited sponsor:%@ userIds:%@" ,sponsor,userModel.invitedList);
//    if ([[UIViewController currentViewController]isKindOfClass:[WaitingDoctorsViewController class]]) {
//        WaitingDoctorsViewController *vc = (WaitingDoctorsViewController *)[UIViewController currentViewController];
//        [vc stopWaiting];
//    }
    NSMutableArray *list = [NSMutableArray array];
    for (NSString *user in userModel.invitedList) {
        [list addObject:[self convertUser:user isEnter:NO]];
    }
    
    
    [self showCallVCWithInvitedList:list appointmentId:userModel.appointmentId  sponsor:[self convertUser:sponsor isEnter:YES] sponsorPorait:userModel.providerPortrait sponsorName:userModel.providerName doctorProfession:userModel.doctorProfession clinicName:userModel.clinicName];
}
-(void)onGroupCallInviteeListUpdateWithUserIds:(NSArray<NSString *> *)userIds{
    
    NSLog(@"📳 onGroupCallInviteeListUpdate userIds:%@",userIds);
}
-(void)onUserEnterWithUid:(NSString *)uid{
    
    NSLog(@"📳 onUserEnter: %@",uid);
    if (self.videoCallVC) {
            [self.videoCallVC enterUser:[self convertUser:uid isEnter:YES]];
    }
}
-(void)onUserLeaveWithUid:(NSString *)uid{
    NSLog(@"📳 onUserLeave: %@",uid);
    [self removeUserFromCallVC:uid reason:(VideoUserRemoveReasonLeave)];
    
}
-(void)onRejectWithUid:(NSString *)uid{
     NSLog(@"📳 onReject: %@",uid);
    [self removeUserFromCallVC:uid reason:(VideoUserRemoveReasonReject)];
}
-(void)onNoRespWithUid:(NSString *)uid{
    NSLog(@"📳 onNoResp: %@",uid);
    [self removeUserFromCallVC:uid reason:(VideoUserRemoveReasonNoresp)];
}
-(void)onCallingCancel{
    
    NSLog(@"📳 oncancel");
    if (self.videoCallVC) {
        [self.videoCallVC disMiss];
    }
    
}
-(void)onNetworkQualityWithIsSelf:(BOOL)isSelf poorNetwork:(BOOL)poorNetwork{
    if (isSelf) {
        self.videoCallVC.networkStr = poorNetwork ? @"Currently, the network signal is poor" : @"";
    }else{
        self.videoCallVC.networkStr = poorNetwork ? @"The network signal in the other side is unstable" : @"";
    }
    
}


/// 挂断类型
/// @param uid <#uid description#>
/// @param hangUpType <#hangUpType description#>
-(void)onDoctorLeaveWithUid:(NSString *)uid hangUpType:(NSInteger)hangUpType userModel:(VideoCallModel * _Nonnull)userModel{

     NSLog(@"📳 hangup");
    VideoRenderView *view = [VideoCallViewController getRenderView:uid];
    UIImage *igm = [UIImage getImageViewWithView:view];
    [self.alertView.backImage setImage:igm];
    
    switch (hangUpType) {
        case 1:// end 挂断
//            self.alertView.type = TeleMedicineAlertTypeEnd;
        {
            [self.videoCallVC disMiss];
            if ([self.delegate respondsToSelector:@selector(onDoctorLeaveWithHangUpType:appointmentId:)]) {
                [self.delegate onDoctorLeaveWithHangUpType:1 appointmentId:userModel.appointmentId];
            }
            break;
        }
        case 2:// reject 挂断
        {
            self.alertView.type = TeleMedicineAlertTypeReject;
            kWeakSelf(self)
            _alertView.teleMedicineDissmissBlock = ^{
                if ([weakself.delegate respondsToSelector:@selector(onDoctorLeaveWithHangUpType:appointmentId:)]) {
                    [weakself.delegate onDoctorLeaveWithHangUpType:2 appointmentId:userModel.appointmentId];
                }
            };
            break;
        }
        case 3:// complete 挂断
        {
            [self.videoCallVC disMiss];
            if ([self.delegate respondsToSelector:@selector(onDoctorLeaveWithHangUpType:appointmentId:)]) {
                [self.delegate onDoctorLeaveWithHangUpType:3 appointmentId:userModel.appointmentId];
            }
            break;
        }
        default:
            break;
    }
}
-(void)onCallingTimeOut{
    
    if (self.videoCallVC) {
        [self.videoCallVC disMiss];
    }
    
}
- (void)onCallEndWithErrorCode:(TXLiteAVError)errorCode{
    for (UIView *view in KEY_WINDOW.subviews) {
        if ([view isKindOfClass:[VideoRenderView class]]) {
            [view removeFromSuperview];
            self.videoCallVC = nil;
            break;
        }
    }
    if (self.videoCallVC) {
        [self.videoCallVC disMiss];
    }
}
-(void)onUserVideoAvailableWithUid:(NSString *)uid available:(BOOL)available{
    NSLog(@"📳 onUserVideoAvailable,uid:%@ available:%d",uid,available);
    if (self.videoCallVC) {
        VideoCallUserModel *model = [self.videoCallVC getUserById:uid];
        if (model) {
            model.isEnter = YES;
            model.isVideoAvaliable = available;
            [self.videoCallVC updateUser:model animate:NO];
        }else{
            VideoCallUserModel *newUser = [self convertUser:uid isEnter:YES];
            newUser.isVideoAvaliable = available;
            [self.videoCallVC enterUser:newUser];
        }
    }
}
-(void)removeUserFromCallVC:(NSString *)uid reason:(VideoUserRemoveReason)reason{
    
    if (self.videoCallVC) {
        VideoCallUserModel *userInfo = [self convertUser:uid isEnter:NO];
        [self.videoCallVC leaveUser:userInfo];
        NSLog(@"reason : %ld",(long)reason);
    }
    
}
-(void)onCustomMessageWithUid:(NSString *)uid customMessage:(NSString *)customMessage userModel:(VideoCallModel *)userModel{
    
    if (self.videoCallVC) {
        [self.videoCallVC loadPrescriptionList];
    }
    
}
-(VideoCallUserModel *)convertUser:(NSString *)user isEnter:(BOOL)isEnter{
    
    VideoCallUserModel *model = [[VideoCallUserModel alloc]init];
    model.name = user;
    model.userId = user;
    model.isEnter = isEnter;
    if (self.videoCallVC) {
        VideoCallUserModel *oldUser = [self.videoCallVC getUserById:model.userId];
        if (oldUser) {
            model.isVideoAvaliable = oldUser.isVideoAvaliable;
        }
    }
    return model;
    
}
-(void)showCallVCWithInvitedList:(NSArray<VideoCallUserModel*>*)invitedList appointmentId:(NSString *)appointmentId sponsor:(VideoCallUserModel *)sponsor sponsorPorait:(NSString *)sponsorPorait sponsorName:(NSString *)sponsorName doctorProfession:(NSString *)doctorProfession clinicName:(NSString *)clinicName{
    
    self.videoCallVC = [[VideoCallViewController alloc] initWithSponsor:sponsor];
    kWeakSelf(self)
    self.videoCallVC.dissmissBlock = ^{
        weakself.videoCallVC = nil;
        [UIApplication sharedApplication].statusBarHidden = NO;
    };
    self.videoCallVC.hangUpBlock = ^{
        if ([weakself.delegate respondsToSelector:@selector(userHangUp)]) {
            [weakself.delegate userHangUp];
        }
    };
    if (self.videoCallVC) {
        self.videoCallVC.modalPresentationStyle = UIModalPresentationFullScreen;
        [self.videoCallVC resetWithUserList:invitedList isInit:YES];
        self.videoCallVC.doctorProfession = doctorProfession;
        self.videoCallVC.clinicName = clinicName;
        self.videoCallVC.sponserName = sponsorName;
        self.videoCallVC.sponserPortrait = sponsorPorait;
        self.videoCallVC.appointmentId = appointmentId;
        [KEY_WINDOW.rootViewController presentViewController:self.videoCallVC animated:NO completion:nil];
    }
    
}
-(TeleMedicineAlertView *)alertView{
    if (!_alertView) {
        _alertView = [[TeleMedicineAlertView alloc]init];
        
    }
    return _alertView;
}
@end
