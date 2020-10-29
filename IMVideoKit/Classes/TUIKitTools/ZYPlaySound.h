//
//  ZYPlaySound.h
//  LiveFuller
//
//  Created by kerwin Zhang on 2020/6/8.
//  Copyright © 2020 Fullerton. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <AudioToolbox/AudioToolbox.h>
NS_ASSUME_NONNULL_BEGIN
@interface ZYPlaySound : NSObject{
    SystemSoundID soundID;
}
- (instancetype)initForPlayingVibrate;
- (instancetype)initForPlayingSystemSoundEffectWith:(NSString *)resourceName ofType:(NSString *)type;
- (instancetype)initForPalyingSoundEffectWith:(NSString *)filename;
-(void)play;
-(void)stop;
@end

NS_ASSUME_NONNULL_END
