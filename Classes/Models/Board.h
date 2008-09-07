//
//  Board.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-09-05.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TypesAndConstants.h"

@class Board;
@class Tile;

@protocol BoardDelegate
-(void)tile:(Tile*)tile changedOwner:(Player)owner;
-(void)tile:(Tile*)tile changedValue:(CGFloat)value;
-(void)tile:(Tile*)tile wasChargedTo:(CGFloat)value byPlayer:(Player)player;
-(void)tileExploded:(Tile*)tile;
-(void)board:(Board*)board changedScores:(CGFloat[])scores;
-(void)board:(Board*)board endedWithWinner:(Player)winner;
-(void)boardIsStartingAnew:(Board*)board;
-(void)board:(Board*)board changedCurrentPlayer:(Player)currentPlayer;
-(void)board:(Board*)board changedSize:(BoardSize)newSize;
@end

@interface Board : NSObject {
    Tile *boardTiles[10][12]; // [x][y]
    Player currentPlayer;
    NSTimer *winningConditionTimer;
    BOOL gameEnded;
    
    BOOL chaosGame;
    BOOL tinyGame;
    
    id<BoardDelegate> delegate;
    
    NSTimeInterval lastExplosionTime;
}
#pragma mark Accessors
-(Tile*)tile:(BoardPoint)point;
-(BOOL)isBoardEmpty;
-(BOOL)hasGameEnded;
-(BOOL)canMakeMoveNow;


#pragma mark Mutators
-(void)restart;
-(void)shuffle;
-(void)chargeTileForCurrentPlayer:(BoardPoint)tilePoint;

#pragma mark Persistance
-(void)persist;
-(void)load;

#pragma mark Properties
/// Setting the delegate will also trigger all delegate methods to give the delegate a complete view of the board state.
@property (assign) id<BoardDelegate> delegate;
@property Player currentPlayer;
@property BOOL chaosGame;
@property BOOL tinyGame;
@property (readonly) BoardSize sizeInTiles;
@end

@interface Tile : NSObject
{
    Player owner;
    CGFloat value;
    BoardPoint boardPosition;
    Board *board;
}
-(void)charge:(CGFloat)amount;
-(void)charge:(CGFloat)amount forPlayer:(Player)newOwner;
-(void)explode;

@property (assign) Board* board;
@property Player owner;
@property CGFloat value;
@property BoardPoint boardPosition;

@end
