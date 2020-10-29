//
//  OnDemainAlertView.h
//  LiveFuller
//
//  Created by kerwin Zhang on 2020/7/16.
//  Copyright © 2020 Fullerton. All rights reserved.
//


NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,OnDemandAlertType){
    
    OnDemandAlertTypeCancel,       //end 主动取消
    OnDemandAlertTypeHangUp,     //reject 主动挂断
   
};
@interface OnDemainAlertView : UIView
@property(nonatomic,assign)OnDemandAlertType type;
@property(nonatomic,copy)void (^onDemandDissmissBlock)(void);
@property (weak, nonatomic) IBOutlet UILabel *contentLab;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentLab_height;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLab;
@property (weak, nonatomic) IBOutlet UILabel *subtitleLab;
@property(nonatomic,copy)NSString *contentStr;
@end

NS_ASSUME_NONNULL_END
