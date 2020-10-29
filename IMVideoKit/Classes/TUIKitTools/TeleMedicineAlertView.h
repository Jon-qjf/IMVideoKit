//
//  TeleMedicineAlertView.h
//  LiveFuller
//
//  Created by kerwin Zhang on 2020/5/14.
//  Copyright © 2020 Fullerton. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
typedef NS_ENUM(NSInteger,TeleMedicineAlertType){
    
    TeleMedicineAlertTypeEnd,       //end 结束弹出
    TeleMedicineAlertTypeReject,     //reject 结束弹出
    TeleMedicineAlertTypePermission     //权限弹窗
};
typedef void(^TeleMedicineDissmissBlock)(void);
@interface TeleMedicineAlertView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *backImage;
@property(nonatomic,assign)TeleMedicineAlertType type;
@property(nonatomic,copy)TeleMedicineDissmissBlock teleMedicineDissmissBlock;
@end

NS_ASSUME_NONNULL_END
