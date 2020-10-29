//
//  ZYPlaySound.m
//  LiveFuller
//
//  Created by kerwin Zhang on 2020/6/8.
//  Copyright © 2020 Fullerton. All rights reserved.
//

#import "ZYPlaySound.h"
@interface ZYPlaySound ()
@property (nonatomic,strong)NSTimer *_vibrationTimer;
@end
@implementation ZYPlaySound
@synthesize _vibrationTimer;
- (instancetype)initForPlayingVibrate
{
    self = [super init];
    if (self) {
        soundID = kSystemSoundID_Vibrate;
    }
    return self;
}

- (instancetype)initForPlayingSystemSoundEffectWith:(NSString *)resourceName ofType:(NSString *)type
{
    self = [super init];
    if (self) {
        NSString *path = [[NSBundle mainBundle]pathForResource:resourceName ofType:type];
        if (path) {
            SystemSoundID theSoundID;
            OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)[NSURL fileURLWithPath:path], &theSoundID);
            if (error == kAudioServicesNoError) {
                soundID = theSoundID;
            }else{
                NSLog(@"Failed to create sound");
            }
        }
    }
    return self;
}
- (instancetype)initForPalyingSoundEffectWith:(NSString *)filename
{
    self = [super init];
    if (self) {
        NSURL *fileURL = [[NSBundle mainBundle]URLForResource:filename withExtension:nil];
        if (fileURL != nil) {
            SystemSoundID theSoundID;
            OSStatus error = AudioServicesCreateSystemSoundID((__bridge CFURLRef)fileURL, &theSoundID);
            if (error == kAudioServicesNoError) {
                soundID = theSoundID;
            }else{
                NSLog(@"Faild to create sound");
            }
        }
    }
    return self;
}

-(void)play{
    _vibrationTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playSystemSound) userInfo:nil repeats:YES];
}
-(void)playSystemSound{
    AudioServicesPlaySystemSound(soundID);
}
-(void)stop{
    [_vibrationTimer invalidate];
    AudioServicesRemoveSystemSoundCompletion(soundID);
    AudioServicesDisposeSystemSoundID(soundID);
}
-(void)dealloc{
    AudioServicesDisposeSystemSoundID(soundID);
}

@end
