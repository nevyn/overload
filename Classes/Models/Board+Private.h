//
//  Board+Private.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2009-03-15.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Board.h"
#import "Tile.h"
#import "TypesAndConstants.h"

@class ScheduledCharge;

@interface Board( BoardPrivate )
#pragma mark Game logic
-(void)updateScores;
-(void)advancePlayer;

-(void)scheduleCharge:(Tile*)t owner:(Player)owner;
-(void)explosionCharge:(ScheduledCharge*)charge;

@property (readwrite, assign, nonatomic) NSUInteger explosionsQueued;
@end

@interface ScheduledCharge : NSObject {
    Tile *tile;
    Player owner;
}
@property (readwrite, assign, nonatomic) Tile *tile;
@property (readwrite, assign, nonatomic) Player owner;
@end
