//
//  OLSoundPlayer.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-09-07.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "OLSoundPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "AVAudioPlayerQueue.h"
#import <AudioToolbox/AudioToolbox.h>

@implementation OLSoundPlayer
-(id)init;
{
    if(![super init]) return nil;
    
    self.sound = [[NSUserDefaults standardUserDefaults] boolForKey:@"sound"];
    
    avObjects = [[NSMutableDictionary alloc] init];
    
    static BOOL sessionInitialized = NO;
    if(!sessionInitialized) {
        OSStatus sessionInitializedSuccessfully = AudioSessionInitialize(NULL, NULL, NULL, NULL);
        sessionInitialized = sessionInitializedSuccessfully == noErr;
    }
    
    UInt32 sessionCategory = kAudioSessionCategory_UserInterfaceSoundEffects;
    AudioSessionSetProperty (
                             kAudioSessionProperty_AudioCategory,
                             sizeof (sessionCategory),
                             &sessionCategory
                             );
    
    
#define loadSound(soundName) \
    [avObjects setObject:[AVAudioPlayerQueue playerQueueWithPrototypePlayer:[[[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:soundName ofType:@"wav"]] error:nil] autorelease] maxConcurrentSounds:4] forKey:soundName]; \
    
    loadSound(@"explosion");
    loadSound(@"charge25");
    loadSound(@"charge50");
    loadSound(@"charge75");
    loadSound(@"charge100");
    loadSound(@"win");
    
    return self;
}

-(void)dealloc;
{
    [avObjects release];
    
    [super dealloc];
}


-(void)playChargeSound:(CGFloat)chargeLevel;
{
    if( ! sound) return;
    

    
    if(chargeLevel < 0.26)
        [(AVAudioPlayerQueue*)[avObjects objectForKey:@"charge25"] play];
    else if(chargeLevel < 0.51)
        [(AVAudioPlayerQueue*)[avObjects objectForKey:@"charge50"] play];
    else if(chargeLevel < 0.76)
        [(AVAudioPlayerQueue*)[avObjects objectForKey:@"charge75"] play];
    else
        [(AVAudioPlayerQueue*)[avObjects objectForKey:@"charge100"] play];
}
-(void)playExplosionSound;
{
    if( ! sound) return;
    [(AVAudioPlayerQueue*)[avObjects objectForKey:@"explosion"] play];

}
-(void)playWinSound;
{
    if( ! sound) return;
    [(AVAudioPlayerQueue*)[avObjects objectForKey:@"win"] play];

}

@synthesize sound;
-(void)setSound:(BOOL)sound_;
{
    sound = sound_;
    [[NSUserDefaults standardUserDefaults] setBool:self.sound forKey:@"sound"];
}

@end
