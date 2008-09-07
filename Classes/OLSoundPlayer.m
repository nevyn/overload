//
//  OLSoundPlayer.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-09-07.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "OLSoundPlayer.h"

typedef enum {
    kExplosion, kCharge25, kCharge50, kCharge75, kCharge100, kWin, kSoundNamesMax
}soundNames;
UInt32 sounds[kSoundNamesMax];


@implementation OLSoundPlayer
-(id)init;
{
    if(![super init]) return nil;
    
    self.sound = [[NSUserDefaults standardUserDefaults] boolForKey:@"sound"];
    
    SoundEngine_Initialize(0);
#define __wavPath(name) [[[NSBundle mainBundle] pathForResource:name ofType:@"wav"] UTF8String]
    SoundEngine_LoadEffect(__wavPath(@"explosion"), &(sounds[kExplosion]));
    SoundEngine_LoadEffect(__wavPath(@"charge25"), &(sounds[kCharge25]));
    SoundEngine_LoadEffect(__wavPath(@"charge50"), &(sounds[kCharge50]));
    SoundEngine_LoadEffect(__wavPath(@"charge75"), &(sounds[kCharge75]));
    SoundEngine_LoadEffect(__wavPath(@"charge100"), &(sounds[kCharge100]));
    SoundEngine_LoadEffect(__wavPath(@"win"), &(sounds[kWin]));
    
    
#if TARGET_IPHONE_SIMULATOR
#undef __wavPath
#define __wavPath(name) ((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:name ofType:@"wav"]])
    AudioServicesCreateSystemSoundID(__wavPath(@"explosion"), &explosion);
    AudioServicesCreateSystemSoundID(__wavPath(@"charge25"), &charge25);
    AudioServicesCreateSystemSoundID(__wavPath(@"charge50"), &charge50);
    AudioServicesCreateSystemSoundID(__wavPath(@"charge75"), &charge75);
    AudioServicesCreateSystemSoundID(__wavPath(@"charge100"), &charge100);
    AudioServicesCreateSystemSoundID(__wavPath(@"win"), &win);
#endif

    return self;
}

-(void)dealloc;
{
#if TARGET_IPHONE_SIMULATOR
    AudioServicesDisposeSystemSoundID(explosion);
    AudioServicesDisposeSystemSoundID(charge25);
    AudioServicesDisposeSystemSoundID(charge50);
    AudioServicesDisposeSystemSoundID(charge75);
    AudioServicesDisposeSystemSoundID(charge100);
    AudioServicesDisposeSystemSoundID(win);
#endif
    
    SoundEngine_Teardown();
    [super dealloc];
}


-(void)playChargeSound:(CGFloat)chargeLevel;
{
    if( ! sound) return;
    
#if TARGET_IPHONE_SIMULATOR
    if(chargeLevel < 0.26)
        AudioServicesPlaySystemSound(charge25);
    else if(chargeLevel < 0.51)
        AudioServicesPlaySystemSound(charge50);
    else if(chargeLevel < 0.76)
        AudioServicesPlaySystemSound(charge75);
    else
        AudioServicesPlaySystemSound(charge100);
#else
    if(chargeLevel < 0.26)
        SoundEngine_StartEffect(sounds[kCharge25]);
    else if(chargeLevel < 0.51)
        SoundEngine_StartEffect(sounds[kCharge50]);
    else if(chargeLevel < 0.76)
        SoundEngine_StartEffect(sounds[kCharge75]);
    else
        SoundEngine_StartEffect(sounds[kCharge100]);
#endif
}
-(void)playExplosionSound;
{
    if( ! sound) return;
#if TARGET_IPHONE_SIMULATOR
    AudioServicesPlaySystemSound(explosion);
#else
    SoundEngine_StartEffect(sounds[kExplosion]);
#endif
}
-(void)playWinSound;
{
    if( ! sound) return;
#if TARGET_IPHONE_SIMULATOR
    AudioServicesPlaySystemSound(win);
#else
    SoundEngine_StartEffect(sounds[kWin]);
#endif
}

@synthesize sound;
-(void)setSound:(BOOL)sound_;
{
    sound = sound_;
    [[NSUserDefaults standardUserDefaults] setBool:self.sound forKey:@"sound"];
}


@end
