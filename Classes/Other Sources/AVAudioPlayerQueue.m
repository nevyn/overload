//
//  AVAudioPlayerQueue.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-12-16.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "AVAudioPlayerQueue.h"

@interface NSMutableArray (StackAdditions)
- (id)pop;
- (void)push:(id)object;
@end

@implementation NSMutableArray (StackAdditions)
- (id)pop
{
    id lastObject = [[[self lastObject] retain] autorelease];
    if(lastObject == nil) return nil;
    
    [self removeLastObject];
    return lastObject;
}

- (void)push:(id)object
{
    [self addObject:object];
}
@end

@interface AVAudioPlayer (AVAudioPlayerCopying)
- (id)copyWithZone:(NSZone *)zone;
@end
@implementation AVAudioPlayer (AVAudioPlayerCopying)

- (id)copyWithZone:(NSZone *)zone
{
    if(zone != nil) {
        NSLog(@"AVAudioPlayer can't be copied with non-nil zone");
        return nil;
    }
    
    AVAudioPlayer *myCopy = self.data?[[AVAudioPlayer alloc] initWithData:self.data error:nil]:
                                      [[AVAudioPlayer alloc] initWithContentsOfURL:self.url error:nil];
    
    myCopy.volume = self.volume;
    if(self.currentTime > 0)
        myCopy.currentTime = self.currentTime;
    myCopy.numberOfLoops = self.numberOfLoops;
    myCopy.meteringEnabled = self.meteringEnabled;
    
    myCopy.delegate = self.delegate;
    
    return myCopy;
}

@end




@implementation AVAudioPlayerQueue
+(AVAudioPlayerQueue*)playerQueueWithPrototypePlayer:(AVAudioPlayer*)prototype
                                 maxConcurrentSounds:(NSUInteger)maxConcurrency;
{
    return [[[AVAudioPlayerQueue alloc] initWithPrototypePlayer:prototype maxConcurrentSounds:maxConcurrency] autorelease];
}
-(id)initWithPrototypePlayer:(AVAudioPlayer*)prototype
         maxConcurrentSounds:(NSUInteger)maxConcurrency;
{
    if( ! [super init] ) return nil;
    
    prototypePlayer = [prototype retain];
    
    freePlayers = [[NSMutableArray alloc] init];
    busyPlayers = [[NSMutableArray alloc] init];
    
    
    for(NSUInteger i = 0; i < maxConcurrency; i++) {
        AVAudioPlayer *clone = [[prototypePlayer copy] autorelease];
        clone.delegate = self;
        [freePlayers push:clone];
    }
    
    return self;
}
-(void)dealloc;
{
    [prototypePlayer release];
    
    for (AVAudioPlayer *player in busyPlayers)
        player.delegate = nil;
    
    [self stop];
    [freePlayers release];
    [busyPlayers release];
    
    [super dealloc];
}

-(BOOL)play;
{
    if([freePlayers count] == 0) return NO;
    
    AVAudioPlayer *freePlayer = [freePlayers pop];
    [busyPlayers push:freePlayer];
    BOOL playSuccess = [freePlayer play];
    //NSLog(@"playing for %@ is %@", freePlayer.url.path.lastPathComponent, playSuccess?@"success":@"failure");
    if(!playSuccess) {
        [busyPlayers removeObject:freePlayer];
        [freePlayers addObject:freePlayer];
    }
    return playSuccess;
}
-(void)stop;
{
    for (id player in busyPlayers) {
        [player stop];
    }
}
@synthesize prototypePlayer;

-(NSString*)description;
{
    return [[NSDictionary dictionaryWithObjectsAndKeys:prototypePlayer.url.path.lastPathComponent, @"filename", busyPlayers, @"busyPlayers", freePlayers, @"freePlayers", nil] description];
}

#pragma mark AVAudioPlayer delegates
- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag;
{
    //NSLog(@"didFinishPlaying for %@", player.url.path.lastPathComponent);
    [[player retain] autorelease];
    [busyPlayers removeObject:player];
    [freePlayers push:player];
}
- (void)audioPlayerDecodeErrorDidOccur:(AVAudioPlayer *)player error:(NSError *)error;
{
    NSLog(@"%@ had decode error: %@", player.url.path.lastPathComponent, error);
    player.currentTime = 0.0;
    [[player retain] autorelease];
    [busyPlayers removeObject:player];
    [freePlayers push:player];    
}
- (void)audioPlayerBeginInterruption:(AVAudioPlayer *)player;
{
    NSLog(@"%@ had interruption", player.url.path.lastPathComponent);

}

@end
