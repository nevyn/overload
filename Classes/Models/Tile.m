//
//  Tile.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2009-03-15.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "Tile.h"
#import "Board.h"
#import "Board+Private.h"

@implementation Tile
-(void)charge:(CGFloat)amount;
{
    self.value += amount;
    if(self.value >= 0.9999)
        [self explode];
}
-(void)charge:(CGFloat)amount forPlayer:(PlayerID)newOwner;
{
    self.owner = newOwner;
    [self charge:amount];
}

-(void)explode;
{
    self.value = 0.0;
    
    for (Tile *sibling in self.surroundingTiles) {
        board.explosionsQueued += 1;
        if(board.delegate)
            [self.board scheduleCharge:sibling owner:self.owner];
        else {
            ScheduledCharge *charge = [[[ScheduledCharge alloc] init] autorelease];
            charge.owner = self.owner;
            charge.tile = sibling;
            [self.board explosionCharge:charge];
        }
    }
    
    [self.board.delegate tileExploded:self];
}

-(NSArray*)surroundingTiles;
{
    BoardPoint urdl[4] =   {BoardPointMake(self.boardPosition.x, self.boardPosition.y-1),
		BoardPointMake(self.boardPosition.x+1, self.boardPosition.y),
		BoardPointMake(self.boardPosition.x, self.boardPosition.y+1),
	BoardPointMake(self.boardPosition.x-1, self.boardPosition.y)};
    NSMutableArray *surroundingTiles = [NSMutableArray array];
    if(urdl[0].y >= 0)
        [surroundingTiles addObject:[self.board tile:urdl[0]]];
    if(urdl[1].x < self.board.sizeInTiles.width)
        [surroundingTiles addObject:[self.board tile:urdl[1]]];
    if(urdl[2].y < self.board.sizeInTiles.height)
        [surroundingTiles addObject:[self.board tile:urdl[2]]];
    if(urdl[3].x >= 0)
        [surroundingTiles addObject:[self.board tile:urdl[3]]];
    
    return surroundingTiles;
}




@synthesize board;
@synthesize owner;
-(void)setOwner:(PlayerID)newOwner;
{
    owner = newOwner;
    [self.board.delegate tile:self changedOwner:owner];
    [self.board updateScores];
}
@synthesize value;
-(void)setValue:(CGFloat)newValue;
{
    value = newValue;
    [self.board.delegate tile:self changedValue:value];
    [self.board updateScores];
}
@synthesize boardPosition;

@end
