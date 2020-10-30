//
//  VideoCallUserModel.m
//  LiveFuller
//
//  Created by kerwin Zhang on 2020/5/10.
//  Copyright © 2020 Fullerton. All rights reserved.
//

#import "VideoCallUserModel.h"
//#import "VideoCallViewController.h"
//#import "TUIkitModule-Swift.h"
//#import <IMVideoKit/IMVideoKit-Swift.h>

@implementation VideoCallUserModel

@end
@implementation VideoCallUserCell

-(void)setUserModel:(VideoCallUserModel *)userModel{
    [self configModel:userModel];
    
}
-(void)configModel:(VideoCallUserModel *)model{
    BOOL noModel = model.userId.length == 0;
//    if (!noModel ) {
//        if ([model.userId isEqualToString:[VideoCallUtils shared].curUserId]) {
//            VideoRenderView *render = [VideoCallViewController getRenderView:model.userId];
//            if(render) {
//                if (render.superview != self ){
//                    [render removeFromSuperview];
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        render.frame = self.bounds;
//                    });
//                    [self addSubview:render];
//                    render.userModel = model;
//                }
//            } else {
//                NSLog("error");
//            }
//        }
//    }
}
@end
