//
//  Tile.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2009-03-15.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypesAndConstants.h"
@class Board;

@interface Tile : NSObject
{
    PlayerID owner;
    CGFloat value;
    BoardPoint boardPosition;
    Board *board;
}
-(void)charge:(CGFloat)amount;
-(void)charge:(CGFloat)amount forPlayer:(PlayerID)newOwner;
-(void)explode;

-(NSArray*)surroundingTiles;

@property (assign, nonatomic) Board* board;
@property (nonatomic) PlayerID owner;
@property (nonatomic) CGFloat value;
@property (nonatomic) BoardPoint boardPosition;

@end
