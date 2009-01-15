//
//  OLSoundPlayer.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-09-07.
//  Copyright 2008 Third Cog Software. All rights reserved.
//


@interface OLSoundPlayer : NSObject {
    BOOL sound;
    NSMutableDictionary *avObjects;
}
-(void)playChargeSound:(CGFloat)chargeLevel;
-(void)playExplosionSound;
-(void)playWinSound;


@property (nonatomic) BOOL sound;
@end
