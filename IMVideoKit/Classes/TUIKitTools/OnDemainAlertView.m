//
//  OnDemainAlertView.m
//  LiveFuller
//
//  Created by kerwin Zhang on 2020/7/16.
//  Copyright © 2020 Fullerton. All rights reserved.
//

#import "OnDemainAlertView.h"
#import <IMVideoKit/THeader.h>
@interface OnDemainAlertView()


@end
@implementation OnDemainAlertView


- (instancetype)init
{
    self = [super init];
    if (self) {
        self = [[NSBundle mainBundle]loadNibNamed:@"OnDemainAlertView" owner:self options:nil].lastObject;
        self.frame = KEY_WINDOW.bounds;
    }
    return self;
}
-(void)setType:(OnDemandAlertType)type
{
    _type = type;
    [self setUI];
}
-(void)setUI{
    [super layoutSubviews];
    switch (self.type) {
        case OnDemandAlertTypeCancel:{
            
            self.titleLab.text = @"Cancel video consultation";
            self.subtitleLab.text = @"Are you sure you want to end the call?";
            [self.confirmButton setTitle:@"CANCEL CALL" forState:(UIControlStateNormal)];
            [self.cancelButton setTitle:@"DON'T CANCEL" forState:(UIControlStateNormal)];
            break;
        }
        case OnDemandAlertTypeHangUp:{
            
           self.titleLab.text = @"End video consultation";
           self.subtitleLab.text = @"Are you sure you want to end the call?";
           [self.confirmButton setTitle:@"END CALL" forState:(UIControlStateNormal)];
           [self.cancelButton setTitle:@"CANCEL" forState:(UIControlStateNormal)];
            break;
        }
        
        default:
            break;
    }
    [KEY_WINDOW addSubview:self];
}
- (IBAction)mainButtonClick:(id)sender {
    [self removeFromSuperview];
    if(self.onDemandDissmissBlock)
    {
        self.onDemandDissmissBlock();
    }
}
- (IBAction)cancel:(id)sender {
    [self removeFromSuperview];
}

-(void)setContentStr:(NSString *)contentStr{
    _contentStr = [contentStr copy];
    self.contentLab.text = _contentStr;
    self.contentLab_height.constant = 85;
}

@end
