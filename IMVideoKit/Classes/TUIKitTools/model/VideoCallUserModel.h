//
//  VideoCallUserModel.h
//  LiveFuller
//
//  Created by kerwin Zhang on 2020/5/10.
//  Copyright © 2020 Fullerton. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface VideoCallUserModel : NSObject
@property(nonatomic,copy)NSString *avatarUrl;
@property(nonatomic,copy)NSString *userId;
@property(nonatomic,copy)NSString *name;
@property(nonatomic,assign)BOOL isEnter;
@property(nonatomic,assign)BOOL isVideoAvaliable;
@end
@interface VideoCallUserCell : UICollectionViewCell
@property(nonatomic,strong)VideoCallUserModel *userModel;
@end

NS_ASSUME_NONNULL_END
