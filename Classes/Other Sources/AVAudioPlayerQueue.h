//
//  AVAudioPlayerQueue.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-12-16.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface AVAudioPlayerQueue : NSObject <AVAudioPlayerDelegate> {
    AVAudioPlayer *prototypePlayer;
    NSMutableArray *freePlayers;
    NSMutableArray *busyPlayers;
}
+(AVAudioPlayerQueue*)playerQueueWithPrototypePlayer:(AVAudioPlayer*)prototype
         maxConcurrentSounds:(NSUInteger)maxConcurrency;

-(id)initWithPrototypePlayer:(AVAudioPlayer*)prototype
         maxConcurrentSounds:(NSUInteger)maxConcurrency;

-(BOOL)play;
-(void)stop;
@property (readonly) AVAudioPlayer *prototypePlayer;
@end
