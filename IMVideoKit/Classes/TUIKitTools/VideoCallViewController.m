//
//  VideoCallViewController.m
//  LiveFuller
//
//  Created by kerwin Zhang on 2020/5/10.
//  Copyright © 2020 Fullerton. All rights reserved.
//

#import "VideoCallViewController.h"
#import "VideoCallUserModel.h"
#import "IMManager.h"
#import "ZYPlaySound.h"
#import "TeleMedicineAlertView.h"
#import "OnDemainAlertView.h"
#import "TRTCCloud.h"
#import <IMVideoKit/IMVideoKit-Swift.h>
#define kSmallVideoWidth   94.0
@interface VideoCallViewController ()<UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property(nonatomic,strong)NSMutableArray<VideoCallUserModel*>* userList;
@property(nonatomic,strong)UIButton *hangup;
@property(nonatomic,strong)UIButton *accept;
@property(nonatomic,strong)UIButton *cameraSwitch;
@property(nonatomic,strong)UIButton *mute;
@property(nonatomic,strong)UIButton *pauseCamera;
@property(nonatomic,strong)UIButton *prescriptionButton;
@property(nonatomic,strong)UILabel  *prescriptionCountLab;
@property(nonatomic,strong)UIImageView *backImageV;
@property(nonatomic,strong)VideoCallUserModel *curSponsor;
@property(nonatomic,assign)UInt32 callingTime;
@property(nonatomic,strong)UILabel *callTimeLabel;
@property(nonatomic,strong)UILabel *doctorNameLable;
@property(nonatomic,strong)UILabel *doctorJobLable;

@property(nonatomic,strong)UIView *localPreView;
@property(nonatomic,assign)VideoCallState curState;
@property(nonatomic,strong)UIView *sponsorPanel;
@property(nonatomic,strong)dispatch_source_t codeTimer;
@property(nonatomic,strong)UICollectionView *userCollectionView;
@property(nonatomic,assign)NSInteger collectionCount;
@property(nonatomic,strong)NSArray<VideoCallUserModel*>* avaliableList;
@property(nonatomic,assign)BOOL isFrontCamera;
@property(nonatomic,strong)UILabel *networkLab;
@property(nonatomic,strong)ZYPlaySound *playSound;
@property(nonatomic,assign)BOOL micPermision;
@property(nonatomic,assign)BOOL cameraPermision;
@property(nonatomic,strong)TeleMedicineAlertView *alertView;

@end
static NSMutableArray <VideoRenderView *> *renderViews;
@implementation VideoCallViewController

-(NSArray<VideoCallUserModel *> *)avaliableList{
    NSMutableArray *array = [NSMutableArray array];
    for (VideoCallUserModel *model in self.userList) {
        if (model.isEnter) {
            [array addObject:model];
        }
    }
    return array;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self.playSound play];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(checkSystemPreferences) name:UIApplicationDidBecomeActiveNotification object:nil];
    [[UIApplication sharedApplication]setIdleTimerDisabled: YES];
    dispatch_async(dispatch_get_main_queue(), ^{
        [self setupUI];
    });
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self reloadData:NO];
}
-(void)setCurState:(VideoCallState)curState{
    if (curState!=_curState) {
        _curState = curState;
        [self autoSetUIByState];
    }
}
-(void)setNetworkStr:(NSString *)networkStr{
    _networkStr = [networkStr copy];
    self.networkLab.text = _networkStr;
}
-(UIView *)sponsorPanel{
    if (!_sponsorPanel) {
        _sponsorPanel = [[UIView alloc]init];
        _sponsorPanel.backgroundColor = [UIColor clearColor];
        [self.view addSubview:_sponsorPanel];
    }
    return _sponsorPanel;
}
- (instancetype)initWithSponsor:(VideoCallUserModel *)sponsor{
    
    
    self = [super init];
    self.curSponsor = sponsor;
    if (sponsor) {
        self.curState = VideoCallStateOnInvitee;
    }else{
        self.curState = VideoCallStateDailing;
    }
    self.isFrontCamera = YES;
    return self;
    
}
-(void)dealloc{
    [[TRTCVideoCall shared] closeCamara];
    [renderViews removeAllObjects];
    [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
}

-(NSInteger)collectionCount{
    NSInteger count;
    if (self.avaliableList.count <= 4) {
        count = self.avaliableList.count;
    }else{
        count = 9;
    }
    if (self.curState == VideoCallStateOnInvitee || self.curState == VideoCallStateDailing) {
        count = 0;
    }
    return count;
}

-(VideoCallUserModel * _Nullable)getUserById:(NSString *)userId{
    for (VideoCallUserModel *user in self.userList) {
        if ([user.userId isEqualToString:userId]) {
            return user;
        }
    }
    return nil;
}
-(void)disMiss{
    if (self.curState != VideoCallStateCalling) {
        if (self.codeTimer && dispatch_source_testcancel(self.codeTimer)){
            dispatch_resume(self.codeTimer);
        }
    }
    if (self.codeTimer) {
        dispatch_source_cancel(self.codeTimer);
    }
    [self dismissViewControllerAnimated:NO completion:^{
        if (self.dissmissBlock) {
            self.dissmissBlock();
        }
    }];
    [self.playSound stop];
 
}
#pragma - mark - UI
-(void)setupUI{
    self.accept = [UIButton buttonWithType:UIButtonTypeCustom];
    
    self.cameraSwitch = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.mute = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.prescriptionButton = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.prescriptionButton.enabled = NO;
    self.prescriptionCountLab = [[UILabel alloc]init];
    self.hangup = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.pauseCamera = [UIButton buttonWithType:(UIButtonTypeCustom)];
    self.callTimeLabel = [[UILabel alloc]init];
    self.doctorJobLable = [[UILabel alloc]init];
    self.doctorNameLable = [[UILabel alloc]init];
    self.localPreView = [[UIView alloc]init];
    self.userList = [NSMutableArray array];
    self.networkLab = [[UILabel alloc]init];
    
    renderViews = [NSMutableArray array];
    self.view.backgroundColor = SYSTEM_BLACK;
    [self.view addSubview:self.userCollectionView];
    self.userCollectionView.frame = CGRectMake(0, Top_Safe_Height + 62, Main_Screen_Width, Main_Screen_Height-Top_Safe_Height-194);
    [self.view addSubview: self.localPreView];
    self.localPreView.backgroundColor = SYSTEM_BLACK;
    self.localPreView.frame = [UIApplication sharedApplication].keyWindow.bounds;
    self.localPreView.userInteractionEnabled = NO;
    self.localPreView.layer.cornerRadius = 8;
    self.localPreView.clipsToBounds = YES;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture:)];
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
    [self.localPreView addGestureRecognizer:tap];
    [pan requireGestureRecognizerToFail:tap];
    [self.localPreView addGestureRecognizer:pan];
    
    self.userCollectionView.hidden = YES;
    
    
    [self setupSponsorPanel];
    [self setupControls];
    [self autoSetUIByState];
    self.accept.hidden = (self.curSponsor == nil);
    self.backImageV.hidden = (self.curSponsor == nil);
    [self checkSystemPreferences];
    
    
}
-(void)setupSponsorPanel{
    if (self.backImageV.superview == nil) {
           [self.view addSubview:self.backImageV];
       }
    if(self.curSponsor) {
        
        
        
        [self.view addSubview:self.sponsorPanel];
        self.sponsorPanel.frame = CGRectMake(0, Top_Safe_Height + 100, Main_Screen_Width, 240);
        
        UILabel *titleLab = [[UILabel alloc]init];
        titleLab.textAlignment = NSTextAlignmentCenter;
        titleLab.font = BOLDSYSTEMFONT(18);
        titleLab.textColor = SYSTEM_BLACK;
        titleLab.text = @"LiveFuller";
        [self.sponsorPanel addSubview:titleLab];
        titleLab.frame = CGRectMake(30, Top_Safe_Height + 30, Main_Screen_Width-60, 30);
        
        //发起者头像
        UIImageView *userImage = [[UIImageView alloc]initWithFrame:CGRectZero];
        [self.sponsorPanel addSubview:userImage];
        userImage.frame = CGRectMake((Main_Screen_Width-160)/2, Top_Safe_Height + 30, 160, 160);
        userImage.layer.cornerRadius = 80;
        userImage.layer.masksToBounds = YES;
        [userImage sd_setImageWithURL:[NSURL URLWithString:self.sponserPortrait]];
        
        
         //提醒文字
        UILabel *invite = [[UILabel alloc]init];
        invite.textAlignment = NSTextAlignmentCenter;
        invite.font = BOLDSYSTEMFONT(20);
        invite.textColor = SYSTEM_BLACK;
        invite.text = @"Incoming Call";
        [self.sponsorPanel addSubview:invite];
        invite.frame = CGRectMake(0, Top_Safe_Height + 220, Main_Screen_Width, 22);
        
                //发起者名字
        UILabel *userName = [[UILabel alloc]init];
        userName.textAlignment = NSTextAlignmentCenter;
        userName.font = BOLDSYSTEMFONT(16);
        userName.textColor = SYSTEM_BLACK;
        userName.text = self.sponserName;
        [self.sponsorPanel addSubview:userName];
        
        userName.frame = CGRectMake(30, CGRectGetMaxY(invite.frame)+30 , Main_Screen_Width-60, 20);
        
        //医生职称
        UILabel *doctorProfession = [[UILabel alloc]init];
        doctorProfession.textAlignment = NSTextAlignmentCenter;
        doctorProfession.font = SYSTEMFONT(16);
        doctorProfession.textColor = SYSTEM_BLACK;
        doctorProfession.text = self.doctorProfession;
        [self.sponsorPanel addSubview:doctorProfession];
        doctorProfession.frame = CGRectMake(30, CGRectGetMaxY(userName.frame), Main_Screen_Width-60, 20);
        
        //诊所名称
        UILabel *clinicName = [[UILabel alloc]init];
        clinicName.numberOfLines = 0;
        clinicName.textAlignment = NSTextAlignmentCenter;
        clinicName.font = SYSTEMFONT(16);
        clinicName.textColor = SYSTEM_BLACK;
        clinicName.text = self.clinicName;
        [self.sponsorPanel addSubview:clinicName];
        clinicName.frame = CGRectMake(30, CGRectGetMaxY(doctorProfession.frame), Main_Screen_Width-60, 40);
        [clinicName sizeToFit];
        
    }
}
- (void)shakeView:(UIView*)viewToShake
{
    CGFloat t =4.0;
    CGAffineTransform translateRight  =CGAffineTransformTranslate(CGAffineTransformIdentity, t,0.0);
    CGAffineTransform translateLeft =CGAffineTransformTranslate(CGAffineTransformIdentity,-t,0.0);
    viewToShake.transform = translateLeft;
    [UIView animateWithDuration:0.07 delay:0.0 options:UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat animations:^{
        [UIView setAnimationRepeatCount:2.0];
        viewToShake.transform = translateRight;
    } completion:^(BOOL finished){
        if(finished){
            [UIView animateWithDuration:0.05 delay:0.0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                viewToShake.transform =CGAffineTransformIdentity;
            } completion:NULL];
        }
    }];
}
-(void)setPrescriptionCount:(NSInteger)prescriptionCount{
    _prescriptionCount = prescriptionCount;
    
    
    [self shakeView:self.prescriptionCountLab];
    
    if (self.curState == VideoCallStateCalling) {
        self.prescriptionCountLab.text = [NSString stringWithFormat:@"%ld",_prescriptionCount];
           if (_prescriptionCount == 0) {
               self.prescriptionCountLab.hidden = YES;
               
               [self.prescriptionButton setImage:[UIImage imageNamed:@"ic_prescription_unable"] forState:(UIControlStateNormal)];
               self.prescriptionButton.enabled = NO;
           }else{
               self.prescriptionCountLab.hidden = NO;
               [self.prescriptionButton setImage:[UIImage imageNamed:@"ic_prescription"] forState:(UIControlStateNormal)];
               self.prescriptionButton.enabled = YES;
           }
    }else{
        self.prescriptionCountLab.hidden = YES;
        self.prescriptionButton.hidden = YES;
    }
    
}

-(void)setupControls{
    kWeakSelf(self);
    
    if (self.accept.superview == nil) {
        [self.accept setMasterStyleWithTitle:@"ANSWER"];
        [self.view addSubview:self.accept];
        [self.accept addActionHandler:^(NSInteger tag) {
            [weakself.playSound stop];
            [[TRTCVideoCall shared] accept];
            
            VideoCallUserModel *curUser = [[VideoCallUserModel alloc]init];
            curUser.userId = [IMManager shareManager].userid;
            curUser.isEnter = YES;
            curUser.isVideoAvaliable = YES;
            
            [weakself enterUser:curUser];
            weakself.curState = VideoCallStateCalling;
            weakself.accept.hidden = YES;
            
            weakself.backImageV.hidden = YES;
            [[TRTCVideoCall shared] openCameraWithFrontCamera:YES view:weakself.localPreView];
            
        }];
    }
    
    if (self.prescriptionButton.superview == nil) {
        [self.prescriptionButton setImage:[UIImage imageNamed:@"ic_prescription"] forState:(UIControlStateNormal)];
        [self.view addSubview:self.prescriptionButton];
        [self.prescriptionButton addActionHandler:^(NSInteger tag) {
            //展示处方列表
        }];
        self.prescriptionButton.hidden = YES;
        self.prescriptionButton.frame = CGRectMake(16, CGRectGetHeight(self.view.frame)-66-50, 50, 50);
    }
    if (self.prescriptionCountLab.superview == nil) {
        self.prescriptionCountLab.layer.cornerRadius = 14;
        [self.view addSubview:self.prescriptionCountLab];
        self.prescriptionCountLab.backgroundColor = SYSTEM_BLUE;
        self.prescriptionCountLab.hidden = YES;
        self.prescriptionCountLab.clipsToBounds = YES;
        self.prescriptionCountLab.textAlignment = NSTextAlignmentCenter;
        self.prescriptionCountLab.textColor = [UIColor whiteColor];
        self.prescriptionCountLab.font = SYSTEMFONT(14);
        self.prescriptionCountLab.frame = CGRectMake(0, 0, 28, 28);
        self.prescriptionCountLab.center = CGPointMake(CGRectGetMinX(self.prescriptionButton.frame), CGRectGetMinY(self.prescriptionButton.frame));
    }
    if (self.mute.superview == nil ){
        [self.mute setImage:[UIImage imageNamed:@"ic_mute"] forState:(UIControlStateNormal)];
        [self.view addSubview:self.mute];
        [self.mute addActionHandler:^(NSInteger tag) {
            
            [TRTCVideoCall shared].isMicMute = ![TRTCVideoCall shared].isMicMute;
            [weakself.mute setImage:[UIImage imageNamed:[TRTCVideoCall shared].isMicMute?@"ic_mute_on":@"ic_mute"] forState:(UIControlStateNormal)];
        }];
        self.mute.hidden = YES;
        self.mute.frame = CGRectMake(16, CGRectGetHeight(self.view.frame)-196-50, 50, 50);
        
    }
    if (self.hangup.superview == nil) {
        
        [self.hangup setImage:[UIImage imageNamed:@"ic_hangup"] forState:(UIControlStateNormal)];
        
        [self.view addSubview:self.hangup];
        [self.hangup addActionHandler:^(NSInteger tag) {
            OnDemainAlertView *alertView = [[OnDemainAlertView alloc]init];
            alertView.type = OnDemandAlertTypeHangUp;
            alertView.onDemandDissmissBlock = ^{
                [[TRTCVideoCall shared] hangup];
                [weakself disMiss];
                if (weakself.hangUpBlock) {
                    weakself.hangUpBlock();
                }
            };
        }];
        self.hangup.hidden = YES;
        self.hangup.frame = CGRectMake(0, 0, 70, 70);
        self.hangup.center = CGPointMake(self.view.center.x, CGRectGetHeight(self.view.frame)-54);
        }
    if (self.pauseCamera.superview == nil) {
        [self.pauseCamera setImage:[UIImage imageNamed:@"ic_camera_on"] forState:(UIControlStateNormal)];
        [self.view addSubview:self.pauseCamera];
        [self.pauseCamera addActionHandler:^(NSInteger tag) {
            
            [TRTCVideoCall shared].isVideoMute = ![TRTCVideoCall shared].isVideoMute;
            [weakself.pauseCamera setImage:[UIImage imageNamed:[TRTCVideoCall shared].isVideoMute?@"ic_camera_off":@"ic_camera_on"] forState:(UIControlStateNormal)];
            if ([TRTCVideoCall shared].isVideoMute ) {
              
                [[TRTCVideoCall shared] closeCamara];
            }else{
                [[TRTCVideoCall shared] openCameraWithFrontCamera:YES view:weakself.localPreView];
            }
            
        }];
        self.pauseCamera.hidden = YES;
        
        self.pauseCamera.frame = CGRectMake(16, CGRectGetHeight(self.view.frame)-131-50, 50, 50);
    }
    if (self.cameraSwitch.superview == nil) {
        
        [self.cameraSwitch setImage:[UIImage imageNamed:@"ic_switch_camera"] forState:(UIControlStateNormal)];
        [self.cameraSwitch setImage:[UIImage imageNamed:@"icon_select_camera"] forState:(UIControlStateHighlighted)];
        
        
        [self.view addSubview:self.cameraSwitch];
        
        [self.cameraSwitch addActionHandler:^(NSInteger tag) {
            weakself.isFrontCamera = !weakself.isFrontCamera;
            [[TRTCVideoCall shared] switchCameraWithFrontCamera:weakself.isFrontCamera];
        }];
        self.cameraSwitch.hidden = YES;
        self.cameraSwitch.frame = CGRectMake(16, CGRectGetHeight(self.view.frame)-66-50, 50, 50);
    }
    
    if (self.callTimeLabel.superview == nil) {
        self.callTimeLabel.textColor = [UIColor whiteColor];
        self.callTimeLabel.backgroundColor = RGBA(0, 0, 0, 0.5);
        self.callTimeLabel.text = @"00:00";
        self.callTimeLabel.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.callTimeLabel];
        self.callTimeLabel.hidden = YES;
        self.callTimeLabel.layer.cornerRadius = 16;
        self.callTimeLabel.clipsToBounds = YES;
        self.callTimeLabel.frame = CGRectMake((Main_Screen_Width-90)/2, Top_Safe_Height+36, 90, 32);
    }
    if (self.doctorNameLable.superview == nil) {
        self.doctorNameLable.font = BOLDSYSTEMFONT(12);
        self.doctorNameLable.textColor = [UIColor whiteColor];
        self.doctorNameLable.textAlignment = NSTextAlignmentCenter;
        self.doctorNameLable.text = self.sponserName;
        [self.view addSubview:self.doctorNameLable];
        self.doctorNameLable.hidden = YES;
        self.doctorNameLable.frame = CGRectMake(Main_Screen_Width-20, CGRectGetMaxY(self.callTimeLabel.frame), Main_Screen_Width-40, 32);
    }
    if (self.doctorJobLable.superview == nil) {
        self.doctorJobLable.font = SYSTEMFONT(12);
        self.doctorJobLable.text = self.doctorProfession;
        self.doctorJobLable.textColor = [UIColor whiteColor];
        self.doctorJobLable.textAlignment = NSTextAlignmentCenter;
        [self.view addSubview:self.doctorJobLable];
        self.doctorJobLable.hidden = YES;
        self.doctorJobLable.frame = CGRectMake(Main_Screen_Width-20, CGRectGetMaxY(self.doctorNameLable.frame), Main_Screen_Width-40, 32);
    }
    if (self.networkLab.superview == nil) {
        self.networkLab.textColor = [UIColor whiteColor];
        self.networkLab.textAlignment = NSTextAlignmentCenter;
        self.networkLab.font = SYSTEMFONT(14);
        [self.view addSubview:self.networkLab];
        self.networkLab.hidden = YES;
        self.networkLab.frame = CGRectMake(20, CGRectGetMinY(self.mute.frame)-60, Main_Screen_Width-40, 20);
    }
}

-(void)autoSetUIByState
{
    self.userCollectionView.hidden = (self.curState!= VideoCallStateCalling || self.collectionCount <= 2);
    if (self.curSponsor) {
        self.sponsorPanel.hidden = self.curState == VideoCallStateCalling;
    }
    switch (self.curState) {
        case VideoCallStateDailing:{
            break;
        }
        case VideoCallStateOnInvitee:{
            
            self.backImageV.frame = self.view.frame;
            
            self.accept.frame = CGRectMake(16, CGRectGetMaxY(self.view.frame)-70-Bottom_Safe_Height, Main_Screen_Width-32, 50);
           
            break;
        }
            
        case VideoCallStateCalling:{
            [self startGCDTimer];
            break;
        }
    }
    if (self.curState == VideoCallStateCalling) {
        [self loadPrescriptionList];
        self.mute.hidden = NO;
        self.pauseCamera.hidden = NO;
        self.prescriptionButton.hidden = NO;
        self.hangup.hidden = NO;
        self.cameraSwitch.hidden = NO;
        self.callTimeLabel.hidden = NO;
        self.doctorNameLable.hidden = NO;
        self.doctorJobLable.hidden = NO;
        self.networkLab.hidden = NO;
        self.mute.alpha = 0.0;
        self.cameraSwitch.alpha = 0.0;
        self.callTimeLabel.alpha = 0.0;
        self.networkLab.alpha = 0.0;
    }
    [UIView animateWithDuration:0.3 animations:^{
        [self.view layoutIfNeeded];
        if (self.curState == VideoCallStateCalling) {
            self.mute.alpha = 1.0;
            self.cameraSwitch.alpha = 1.0;
            self.callTimeLabel.alpha = 1.0;
            self.networkLab.alpha = 1.0;
        }
    }];
}

-(void) startGCDTimer {
    
    NSTimeInterval period = 1.0; //设置时间间隔
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    self.codeTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    dispatch_source_set_timer(self.codeTimer, DISPATCH_TIME_NOW, period * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.codeTimer, ^{
        self.callingTime += 1;
        // UI 更新
        dispatch_async(dispatch_get_main_queue(), ^{
            UInt32 mins = 0;
            UInt32 seconds = 0;
            mins = self.callingTime / 60;
            seconds = self.callingTime % 60;
            self.callTimeLabel.text = [NSString stringWithFormat:@"%02d:%02d",mins,seconds];
        });
    });
    if (self.codeTimer && dispatch_source_testcancel(self.codeTimer)) {
        return;
    }
    dispatch_resume(self.codeTimer);
}
-(void)handleTapGesture:(UIPanGestureRecognizer *)tap {
    if (self.collectionCount != 2){
        return;
    }
    if (tap.view == self.localPreView) {
        if (self.localPreView.frame.size.width == kSmallVideoWidth) {

            NSMutableArray <VideoCallUserModel*>* userList = [NSMutableArray array];
            for (VideoCallUserModel *model in self.avaliableList) {
                if (![model.userId isEqualToString: [[VideoCallUtils shared] curUserId]]) {
                    [userList addObject:model];
                }
            }
            
            if (userList.firstObject) {
                VideoRenderView *firstRender = [VideoCallViewController getRenderView:userList[0].userId];
                if  (firstRender)  {
                    [firstRender removeFromSuperview];
                    [self.view insertSubview:firstRender aboveSubview:self.localPreView];
                   
                    [UIView animateWithDuration:0.3 animations:^{
                        self.localPreView.frame = self.view.frame;
                        firstRender.frame = CGRectMake(self.view.frame.size.width - kSmallVideoWidth - 18, 36 + Top_Safe_Height, kSmallVideoWidth, kSmallVideoWidth / 9.0 * 16.0);
                        firstRender.layer.cornerRadius = 8;
                        self.localPreView.layer.cornerRadius = 0;
                    }];
                }
            }
            
        }
    } else {
        
        if ([UIViewController currentViewController] != self) {
            [KEY_WINDOW.rootViewController presentViewController:self animated:NO completion:nil];
        }
        UIView *smallView = tap.view;
        if (smallView) {
            if (smallView.frame.size.width == kSmallVideoWidth) {
                [smallView removeFromSuperview];
                [self.view insertSubview:smallView belowSubview:self.localPreView];
                [UIView animateWithDuration:0.3 animations:^{
                    smallView.frame = self.view.frame;
                    self.localPreView.frame = CGRectMake(self.view.frame.size.width - kSmallVideoWidth - 18., 36 + Top_Safe_Height, kSmallVideoWidth, kSmallVideoWidth/9.0 * 16.0);
                    self.localPreView.layer.cornerRadius = 8;
                    smallView.layer.cornerRadius = 0;
                }];
            }
        }
    }
}
-(void)handlePanGesture:(UIPanGestureRecognizer *)pan{
    UIView *smallView = pan.view;
    if (smallView){
        if (smallView.frame.size.width == kSmallVideoWidth ){
            if (pan.state == UIGestureRecognizerStateBegan) {
                
            } else if (pan.state == UIGestureRecognizerStateChanged) {
                CGPoint translation = [pan translationInView:self.view];
                CGFloat newCenterX = translation.x + (smallView.center.x);
                CGFloat newCenterY = translation.y + (smallView.center.y);
                if (( newCenterX < (smallView.bounds.size.width) / 2) || ( newCenterX > self.view.bounds.size.width - (smallView.bounds.size.width) / 2))  {
                    return;
                }
                if (( newCenterY < (smallView.bounds.size.height) / 2) ||
                    (newCenterY > self.view.bounds.size.height - (smallView.bounds.size.height) / 2))  {
                    return;
                }
                [UIView animateWithDuration:0.1 animations:^{
                    smallView.center = CGPointMake(newCenterX, newCenterY);
                }];
                [pan setTranslation:CGPointZero inView:self.view];
            } else if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
                
            }
        }
    }
}
-(UICollectionView *)userCollectionView{
    
    if (!_userCollectionView) {
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc]init];
        layout.minimumLineSpacing = 0;
        layout.minimumInteritemSpacing = 0;
        layout.scrollDirection = UICollectionViewScrollDirectionVertical;
        _userCollectionView = [[UICollectionView alloc]initWithFrame:CGRectZero collectionViewLayout:layout];
        [_userCollectionView registerClass:[VideoCallUserCell class] forCellWithReuseIdentifier:@"VideoCallUserCell"];
        if (@available(iOS 10.0, *)) {
            _userCollectionView.prefetchingEnabled = YES;
        } else {

        }
        _userCollectionView.showsVerticalScrollIndicator = NO;
        _userCollectionView.showsHorizontalScrollIndicator = NO;
        _userCollectionView.contentMode = UIViewContentModeScaleToFill;
        _userCollectionView.backgroundColor = [UIColor blackColor];
        _userCollectionView.dataSource = self;
        _userCollectionView.delegate = self;
    }
    return _userCollectionView;
}
+(VideoRenderView * _Nullable)getRenderView:( NSString *)userID{
    for (VideoRenderView *renderView in renderViews) {
        if ([renderView.userModel.userId isEqualToString: userID]) {
            return renderView;
        }
    }
    return nil;
}

#pragma - mark - Data
-(void)resetWithUserList:(NSArray<VideoCallUserModel*>*)users isInit:(BOOL)isInit{
    [self resetUserList];

    NSMutableArray <VideoCallUserModel*>* userList = [NSMutableArray array];
    for (VideoCallUserModel *model in self.avaliableList) {
        if (![model.userId isEqualToString: [[VideoCallUtils shared] curUserId]]) {
            [userList addObject:model];
        }
    }
    [self.userList addObjectsFromArray:userList];
    if (!isInit) {
        [self reloadData:NO];
    }
}
-(void)resetUserList{
    if (self.curSponsor) {
        self.curSponsor.isVideoAvaliable = NO;
        self.userList = [NSMutableArray arrayWithObject:self.curSponsor];
    } else {
        VideoCallUserModel *curUser = [[VideoCallUserModel alloc]init];
        curUser.userId = [IMManager shareManager].userid;
        curUser.isVideoAvaliable = YES;
        curUser.isEnter = YES;
        self.userList = [NSMutableArray arrayWithObject:curUser];
    }
}
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    if (self.collectionCount == 2) {
        return 0;
    }
    return  self.collectionCount;
    
}
-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    VideoCallUserCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoCallUserCell" forIndexPath:indexPath];
    if (indexPath.row < self.avaliableList.count) {
        VideoCallUserModel *user = self.avaliableList[indexPath.row];
        cell.userModel = user;
        if ([user.userId isEqualToString:[[VideoCallUtils shared] curUserId]]) {
            [self.localPreView removeFromSuperview];
            [cell addSubview:self.localPreView];
            [cell sendSubviewToBack:self.localPreView];
            self.localPreView.frame = CGRectMake(0, 0, cell.bounds.size.width, cell.bounds.size.height);
        }
    }else{
        cell.userModel = [[VideoCallUserModel alloc]init];
    }
    return cell;
    
}
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat collectW = collectionView.frame.size.width;
    CGFloat collectH = collectionView.frame.size.height;
    if (self.collectionCount < 4) {
        CGFloat width = collectW / 2;
        CGFloat height = collectH / 2;
        if (self.collectionCount % 2 == 1 && indexPath.row == self.collectionCount - 1) {
            if (indexPath.row == 0 && self.collectionCount == 1) {
                return CGSizeMake(width, width);
            }else{
                return CGSizeMake(width, height);
            }
        }else{
            return CGSizeMake(width, height);
        }
    }else{
        CGFloat width = collectW / 3;
        CGFloat height = collectH / 3;
        return CGSizeMake(width, height);
    }
    
    
}
-(CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 0;
}

-(void)enterUser:(VideoCallUserModel *)user{
    
    if(![user.userId isEqualToString: [[VideoCallUtils shared] curUserId]]) {
        VideoRenderView *renderView = [[VideoRenderView alloc]init];
        
        renderView.userModel = user;
        renderView.layer.cornerRadius = 8;
        renderView.clipsToBounds = YES;
        [[TRTCVideoCall shared]startRemoteViewWithUserId:user.userId view:renderView];
        [renderViews addObject:renderView];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(handleTapGesture:)];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(handlePanGesture:)];
        
        [renderView addGestureRecognizer:tap];
        [pan requireGestureRecognizerToFail:tap];

        [renderView addGestureRecognizer:pan];
    }
    
    self.curState = VideoCallStateCalling;
    [self updateUser:user animate:YES];
}
-(void) leaveUser:(VideoCallUserModel *)user{
    [[TRTCVideoCall shared] stopRemoteViewWithUserId:user.userId];
    NSMutableArray *views = [NSMutableArray array];
    for (VideoRenderView *view in renderViews) {
        if(![view.userModel.userId isEqualToString:user.userId]){
            [views addObject:view];
        }
    }
    renderViews = views;
    NSInteger index = 0;
    for (int i = 0; i < self.userList.count; i++) {
        VideoCallUserModel *view = self.userList[i];
        if ([view.userId isEqualToString:user.userId]) {
            index = i;
            break;
        }
    }
    BOOL animate = self.userList[index].isVideoAvaliable;
    [self.userList removeObjectAtIndex:index];
    [self reloadData:animate];
    
}
-(void) updateUser:(VideoCallUserModel *)user animate:(BOOL)animate{
    NSInteger index = -1;
    for (int i = 0; i < self.userList.count; i++) {
        VideoCallUserModel *model = self.userList[i];
        if ([model.userId isEqualToString:user.userId]) {
            index = i;
            [self.userList replaceObjectAtIndex:[self.userList indexOfObject:model] withObject:user];
            break;
        }
    }
    if (index == -1) {
        [self.userList addObject:user];
    }
   
    [self reloadData:animate];
    
}
-(void)reloadData:(BOOL)animate{
    
    if (self.curState == VideoCallStateCalling && self.collectionCount > 2) {
        self.userCollectionView.hidden = NO;
    } else {
        self.userCollectionView.hidden = YES;
    }
    if (self.collectionCount <= 2 ){
        [self updateLayout];
        return;
    }
    if (animate) {
        [self.userCollectionView performBatchUpdates:^{
            self.userCollectionView.frame = CGRectMake(0, self.collectionCount == 1 ? (Top_Safe_Height + 62) : Top_Safe_Height, Main_Screen_Width, Main_Screen_Height - 132-Top_Safe_Height);
        } completion:^(BOOL finished) {
            
        }];
        
    } else {
        [UIView performWithoutAnimation:^{
            self.userCollectionView.frame = CGRectMake(0, self.collectionCount == 1 ? (Top_Safe_Height + 62) : Top_Safe_Height, Main_Screen_Width, Main_Screen_Height - 132-Top_Safe_Height);
            [self.userCollectionView reloadSections:[NSIndexSet indexSetWithIndex:0]];
        }];
    }
}

-(void) updateLayout{
    
    if (self.collectionCount == 2 ){
        if (self.localPreView.superview != self.view) { // 从9宫格变回来
            [self setLocalViewInVCView: CGRectMake(self.view.frame.size.width - kSmallVideoWidth - 18,
                                                      36 + Top_Safe_Height,  kSmallVideoWidth,  kSmallVideoWidth / 9.0 * 16.0) shouldTap: YES];
        } else { //进来了一个人
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                if (self.collectionCount == 2) {
                    if (self.localPreView.bounds.size.width != kSmallVideoWidth) {
                        [self setLocalViewInVCView: CGRectMake(self.view.frame.size.width - kSmallVideoWidth - 18,
                                                                  36 + Top_Safe_Height, kSmallVideoWidth,  kSmallVideoWidth / 9.0 * 16.0) shouldTap: YES];
                    }
                    
                }
            });
        }
        NSMutableArray *userlist = [NSMutableArray array];
        for (VideoCallUserModel *model in self.avaliableList) {
            if (![model.userId isEqualToString:[[VideoCallUtils shared] curUserId]]) {
                [userlist addObject:model];
            }
        }
        VideoCallUserModel *userFirst = userlist.firstObject;
        if (userFirst){
            VideoRenderView *firstRender = [VideoCallViewController getRenderView:userFirst.userId];
            if  (firstRender) {
                firstRender.userModel = userFirst;
                if (firstRender.superview != self.view) {
                    CGRect preFrame =[self.view convertRect:self.localPreView.frame toView:self.localPreView.superview];
                    [self.view insertSubview:firstRender belowSubview:self.localPreView];
                    firstRender.frame = preFrame;
                    [UIView animateWithDuration:0.1 animations:^{
                        firstRender.frame = self.view.bounds;
                    }];
                } else {
                    firstRender.frame = self.view.bounds;
                }
            } else {
                NSLog(@"error");
            }
        }
        
    } else { //用户退出只剩下自己（userleave引起的）
        if (self.collectionCount == 1 ){
            [self setLocalViewInVCView:[UIApplication sharedApplication].keyWindow.bounds shouldTap:NO];
        }
    }
}
-(void)setLocalViewInVCView:(CGRect)frame shouldTap:(BOOL)shouldTap {
    if (CGRectEqualToRect(self.localPreView.frame, frame)) {
        return;
    }
    self.localPreView.userInteractionEnabled = shouldTap;
    self.localPreView.subviews.firstObject.userInteractionEnabled = !shouldTap;
    if (self.localPreView.superview != self.view) {
        CGRect preFrame =[self.view convertRect:self.localPreView.frame toView:self.localPreView.superview];
        [self.localPreView removeFromSuperview];
        [self.view insertSubview:self.localPreView aboveSubview:self.userCollectionView];
        self.localPreView.frame = preFrame;
        [UIView animateWithDuration:0.3 animations:^{
            self.localPreView.frame = frame;
        }];
    } else {
        [UIView animateWithDuration:0.3 animations:^{
            self.localPreView.frame = frame;
        }];
    }
}

-(void)checkSystemPreferences{
    
    //检查麦克风权限
    
    AVAuthorizationStatus authStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeAudio];
    switch (authStatus) {
        case AVAuthorizationStatusNotDetermined:{
            //没有询问是否开启麦克风
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeAudio completionHandler:^(BOOL granted) {
                
            }];
            self.micPermision = YES;
            break;
        }
        case AVAuthorizationStatusRestricted:
            //未授权，家长限制
        case AVAuthorizationStatusDenied:
            //未授权
            self.micPermision = NO;
            break;
        case AVAuthorizationStatusAuthorized:
            //授权
            self.micPermision = YES;
            break;
        default:
            break;
    }
    AVAuthorizationStatus videoAuthStatus = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    switch (videoAuthStatus) {
        case AVAuthorizationStatusNotDetermined:
            //没有询问是否开启相机
        {
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                
            }];
            self.cameraPermision = YES;
            break;
        }
        case AVAuthorizationStatusRestricted:
            //未授权，家长限制
        case AVAuthorizationStatusDenied:
            //未授权
            self.cameraPermision = NO;
            break;
        case AVAuthorizationStatusAuthorized:
            //玩家授权
            self.cameraPermision = YES;
            break;
        default:
            break;
    }
    if (!self.cameraPermision || !self.micPermision){
        [self requestPermision];
    }
    
}
-(void)requestPermision{
    if (self.cameraPermision & self.micPermision){
        return ;
    }else{
        [self.alertView setType:(TeleMedicineAlertTypePermission)];
        self.alertView.teleMedicineDissmissBlock = ^{
            NSURL *url = [[NSURL alloc] initWithString:UIApplicationOpenSettingsURLString];
            if( [[UIApplication sharedApplication] canOpenURL:url]) {
                [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
            }
        };
    }
}
-(ZYPlaySound *)playSound{
    if (!_playSound) {
        _playSound = [[ZYPlaySound alloc]initForPlayingVibrate];
    }
    return _playSound;
}
-(TeleMedicineAlertView *)alertView{
    if (!_alertView) {
        _alertView = [[TeleMedicineAlertView alloc]init];
        _alertView.teleMedicineDissmissBlock = ^{
            
        };
    }
    return _alertView;
}
@end

@implementation VideoRenderView

-(void)configModel:(VideoCallUserModel *)model{
    self.backgroundColor = [UIColor darkGrayColor];
    if (model.userId) {
        
        self.cellImgView.frame = CGRectMake(0, 0, 40, 40);
        self.cellImgView.center = CGPointMake(self.center.x, self.center.y-20);
        [self.cellImgView sd_setImageWithURL:[NSURL URLWithString:model.avatarUrl]];
        self.cellUserLabel.frame = CGRectMake(0, CGRectGetMaxY(self.cellImgView.frame), self.frame.size.width, 22);
        self.cellUserLabel.text = model.name;
        self.cellImgView.hidden = model.isVideoAvaliable;
        self.cellUserLabel.hidden = model.isVideoAvaliable;
    }
}
-(void)setUserModel:(VideoCallUserModel *)userModel{
    _userModel = userModel;
    [self configModel:userModel];
}
-(UIImageView *)cellImgView{
    if (!_cellImgView) {
        _cellImgView = [[UIImageView alloc]init];
        [self addSubview:_cellImgView];
    }
    return _cellImgView;
}

-(UILabel *)cellUserLabel
{
    if (!_cellUserLabel) {
        _cellUserLabel.textColor = [UIColor whiteColor];
        _cellUserLabel.backgroundColor = [UIColor clearColor];
        _cellUserLabel.textAlignment = NSTextAlignmentCenter;
        _cellUserLabel.font = SYSTEMFONT(11);
        _cellUserLabel.numberOfLines = 2;
        [self addSubview:_cellUserLabel];
    }
    return _cellUserLabel;
}
@end
