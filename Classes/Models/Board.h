//
//  Board.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-09-05.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TypesAndConstants.h"
#import "Tile.h"

@class Board;
@class Tile;

@protocol BoardDelegate
-(void)tile:(Tile*)tile changedOwner:(Player)owner;
-(void)tile:(Tile*)tile changedValue:(CGFloat)value;
-(void)tile:(Tile*)tile wasChargedTo:(CGFloat)value byPlayer:(Player)player;
-(void)tileWillSoonExplode:(Tile*)tile;
-(void)tileExploded:(Tile*)tile;
-(void)board:(Board*)board changedScores:(Scores)scores;
-(void)board:(Board*)board endedWithWinner:(Player)winner;
-(void)boardIsStartingAnew:(Board*)board;
-(void)board:(Board*)board changedCurrentPlayer:(Player)currentPlayer;
-(void)board:(Board*)board changedSize:(BoardSize)newSize;
@end

@interface Board : NSObject <NSCopying>{
    Tile *boardTiles[10][12]; // [x][y]
    Player currentPlayer;
    BOOL gameEnded;
    
    BOOL chaosGame;
    BoardSize sizeInTiles;
    
    id<BoardDelegate> delegate;
    
    NSUInteger explosionsQueued;
    NSMutableDictionary *explosionsQueue;
}
-(id)init;
-(id)initWithBoard:(Board*)other;
- (id)copyWithZone:(NSZone *)zone;

// heartbeat
-(void)update;

#pragma mark Accessors
-(Tile*)tile:(BoardPoint)point;
-(BOOL)isBoardEmpty;
-(Player)winner;
-(BOOL)hasEnded;
-(BOOL)canMakeMoveNow;
-(Scores)scores;
-(BOOL)player:(Player)player canChargeTile:(BoardPoint)tilePoint;

#pragma mark Mutators
-(void)restart;
-(void)shuffle;
-(BOOL)chargeTileForCurrentPlayer:(BoardPoint)tilePoint;

#pragma mark Persistance
-(void)persist;
-(void)load;

#pragma mark Properties
/// Setting the delegate will also trigger all delegate methods to give the delegate a complete view of the board state.
@property (assign, nonatomic) id<BoardDelegate> delegate;
@property (nonatomic) Player currentPlayer;
@property (nonatomic) BOOL chaosGame;
@property (readwrite, nonatomic) BoardSize sizeInTiles;
@end

