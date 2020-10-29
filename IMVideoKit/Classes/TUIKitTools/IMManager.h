//
//  IMManager.h
//  LiveFuller
//
//  Created by kerwin Zhang on 2020/4/22.
//  Copyright © 2020 Fullerton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TIMUserProfile+DataProvider.h"
#import "TUIKit.h"
NS_ASSUME_NONNULL_BEGIN

@class TUIConversationCellData;
@class VideoCallUserModel;
@protocol IMManagerDelegate <NSObject>

/// 用户状态发生改变
/// @param status 用户状态
-(void)UserStatusChange:(TUIUserStatus)status;

/// 医生离开类型
/// @param hangUpType   1:end  2:reject  3:complete
/// @param appointmentId 回传订单号
-(void)onDoctorLeaveWithHangUpType:(NSInteger)hangUpType appointmentId:(NSString *)appointmentId;

/// 用户挂断回调
-(void)userHangUp;
@end

typedef NS_ENUM(NSInteger, VideoUserRemoveReason) {
     VideoUserRemoveReasonLeave = 0,
     VideoUserRemoveReasonReject ,
     VideoUserRemoveReasonNoresp ,
     VideoUserRemoveReasonBusy
};
@interface IMManager : NSObject
typedef void (^IMManagerMuteBlock)(BOOL isMute);
@property(nonatomic,weak)id<IMManagerDelegate> delegate;
@property(nonatomic,copy)NSString *conversationId;
@property(nonatomic,copy)NSString *userid;
@property(nonatomic,assign)BOOL isGroup;
@property(nonatomic,assign)BOOL alreadyHasAGroup;
@property(nonatomic,readonly,assign)NSInteger unreadNum;
@property(nonatomic,readonly,copy)NSString *groupName;
@property(nonatomic,copy)NSString *ImAppId;//appid
@property(nonatomic,copy)NSString *ImCertID;//证书id
///  单例
+(IMManager *)shareManager;

/// 是否全部禁言
/// @param result 返回结果
-(void)isAllMute:(IMManagerMuteBlock)result;

/// 登录IM
/// @param userid 用户id
/// @param userSig 用户sig
-(void)loginIMWithAppId:(NSString *)appId UserId:(NSString *)userid userSig:(NSString *)userSig deviceToken:(NSData * _Nullable)deviceToken success:(void(^)(void))success fail:(void(^)(NSInteger code,NSString *msg))fail;

/// 获取会话数据对象
-(TUIConversationCellData *)conversationData;

/// 设置全部已读
-(void)setAllRead;

/// 退出登录
-(void)IMLogout;

/// 判断上一条是否为结束
-(BOOL)lastMsgIsEnd;

/// 获取指定用户的个人信息

/// 设置devicetoken
/// @param deviceToken 设备token
-(void)setToken:(NSData *)deviceToken;

+(void)getUsersProfile:(NSArray<NSString*>*)users successBlock:(void(^)(NSArray<TIMUserProfile *> *))success failBlock:(void(^)(int code, NSString *msg))fail;

@end

NS_ASSUME_NONNULL_END
