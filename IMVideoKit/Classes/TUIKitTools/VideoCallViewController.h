//
//  VideoCallViewController.h
//  LiveFuller
//
//  Created by kerwin Zhang on 2020/5/10.
//  Copyright © 2020 Fullerton. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VideoCallUserModel.h"
NS_ASSUME_NONNULL_BEGIN
typedef void(^DissmissBlock)(void);
typedef NS_ENUM(NSInteger, VideoCallState) {
     VideoCallStateDailing = 0,
     VideoCallStateOnInvitee ,
     VideoCallStateCalling
};
@class VideoRenderView;
@class TRTCVideoCall;
@interface VideoCallViewController : UIViewController
@property(nonatomic,copy)NSString *sponserPortrait;
@property(nonatomic,copy)NSString *appointmentId;
@property(nonatomic,copy)NSString *sponserName;
@property(nonatomic,copy)NSString *doctorProfession;
@property(nonatomic,copy)NSString *clinicName;
@property(nonatomic,copy)DissmissBlock dissmissBlock;
@property(nonatomic,copy)NSString *networkStr;
@property(nonatomic,strong)VideoRenderView *renderView;
@property(nonatomic,assign)NSInteger prescriptionCount;
@property(nonatomic,copy)void (^hangUpBlock)(void);

-(void)loadPrescriptionList;

- (void)resetWithUserList:(NSArray<VideoCallUserModel*>*)users isInit:(BOOL)isInit;
- (instancetype)initWithSponsor:(VideoCallUserModel *)sponsor;
+(VideoRenderView * _Nullable)getRenderView:( NSString *)userID;
-(VideoCallUserModel * _Nullable)getUserById:(NSString *)userId;
-(void)enterUser:(VideoCallUserModel *)user;
-(void) leaveUser:(VideoCallUserModel *)user;
-(void) updateUser:(VideoCallUserModel *)user animate:(BOOL)animate;
-(void)disMiss;
@end

@interface VideoRenderView : UIView
@property(nonatomic,strong)VideoCallUserModel *userModel;
@property(nonatomic,strong)UIImageView *cellImgView;
@property(nonatomic,strong)UILabel *cellUserLabel;
@end

NS_ASSUME_NONNULL_END
