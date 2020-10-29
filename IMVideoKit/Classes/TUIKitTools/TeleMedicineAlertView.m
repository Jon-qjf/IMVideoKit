//
//  TeleMedicineAlertView.m
//  LiveFuller
//
//  Created by kerwin Zhang on 2020/5/14.
//  Copyright © 2020 Fullerton. All rights reserved.
//

#import "TeleMedicineAlertView.h"
#import "THeader.h"

@interface TeleMedicineAlertView ()
@property (weak, nonatomic) IBOutlet UIImageView *topImageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (weak, nonatomic) IBOutlet UIButton *mainButton;


@end
@implementation TeleMedicineAlertView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self = [[NSBundle mainBundle]loadNibNamed:@"TeleMedicineAlertView" owner:self options:nil].lastObject;
        
        self.frame = KEY_WINDOW.bounds;
    }
    return self;
}
-(void)setType:(TeleMedicineAlertType)type
{
    _type = type;
    [self setUI];
}
-(void)setUI{
    [super layoutSubviews];
    switch (self.type) {
        case TeleMedicineAlertTypeEnd:{
            [self.topImageView setImage:[UIImage imageNamed:@"img_video_end"]];
            self.titleLab.text = @"The video call ended";
            self.contentLab.text = @"If the call was ended prematurely, the doctor will send you another video call request at no additional charge. Otherwise, you may access your diagnosis, prescription, and medical certificate by viewing your consultation details.";
            [self.mainButton setMasterStyleWithTitle:@"OK"];
            break;
        }
        case TeleMedicineAlertTypeReject:{
            
            [self.topImageView setImage:[UIImage imageNamed:@"img_video_miss"]];
            self.titleLab.text = @"The consultation has been rejected.";
            self.contentLab.text = @"Your digital consultation has been rejected by the doctor. Please view your consultation details to check the reason for rejecting.";
            [self.mainButton setMasterStyleWithTitle:@"VIEW CONSULTATION DETAILS"];
            break;
        }
        case TeleMedicineAlertTypePermission:{
            
            [self.topImageView setImage:[UIImage imageNamed:@"img_video_permission"]];
            self.titleLab.text = @"Notification";
            self.contentLab.text = @"LiveFuller needs access to your phone’s microphone and camera in order to proceed with the digital consultation. Please go to your phone settings to allow access and try again.";
            [self.mainButton setMasterStyleWithTitle:@"OK"];
            break;
        }
        default:
            break;
    }
    [KEY_WINDOW addSubview:self];
}
- (IBAction)mainButtonClick:(id)sender {
    [self removeFromSuperview];
    if(self.teleMedicineDissmissBlock)
    {
        self.teleMedicineDissmissBlock();
    }
}


@end
