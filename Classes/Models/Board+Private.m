//
//  Board+Private.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2009-03-15.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "Board+Private.h"

@implementation Board (Private)
-(void)updateScores;
{
    if(delegate)
        [delegate board:self changedScores:self.scores];
}
-(void)advancePlayer;
{
    if(self.currentPlayer == PlayerP1)
        self.currentPlayer = PlayerP2;
    else
        self.currentPlayer = PlayerP1;
}
-(void)scheduleCharge:(Tile*)t owner:(PlayerID)owner;
{
    ScheduledCharge *charge = [[[ScheduledCharge alloc] init] autorelease];
    charge.owner = owner;
    charge.tile = t;
    [explosionsQueue setObject:charge forKey:[NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]+ExplosionDelay]];
    if(charge.tile.value > 0.74)
        [delegate tileWillSoonExplode:t];
}
-(void)explosionCharge:(ScheduledCharge*)charge;
{
    [charge.tile charge:ExplosionSpreadEnergy forPlayer:charge.owner];
    self.explosionsQueued -= 1;
}

@end



@implementation ScheduledCharge
@synthesize tile, owner;
@end