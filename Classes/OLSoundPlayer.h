//
//  OLSoundPlayer.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-09-07.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "SoundEngine.h"
#import <AudioToolbox/AudioToolbox.h>


@interface OLSoundPlayer : NSObject {
    BOOL sound;
#if TARGET_IPHONE_SIMULATOR
    SystemSoundID explosion, charge25, charge50, charge75, charge100, win;
#endif    
    
}
-(void)playChargeSound:(CGFloat)chargeLevel;
-(void)playExplosionSound;
-(void)playWinSound;


@property BOOL sound;
@end
