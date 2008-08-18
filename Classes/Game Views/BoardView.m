//
//  BoardView.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-18.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "BoardView.h"
#import "MainViewController.h"
NSTimeInterval BoardAnimationOccurredAt = 0;


@implementation BoardView


- (id)initWithFrame:(CGRect)frame controller:(MainViewController*)controller_;
{
	if (![super initWithFrame:frame]) return nil;
    
    controller = controller_;

    for(NSUInteger y = 0; y < HeightInTiles; y++) {
        for (NSUInteger x = 0; x < WidthInTiles; x++) {
            BoardTile *tile = [[BoardTile alloc] initWithFrame:CGRectMake(x*TileWidth, y*TileHeight, TileWidth, TileHeight)];
            tile.boardPosition = BoardPointMake(x, y);
            tile.board = self;
            boardTiles[x][y] = tile;
            [self addSubview:tile];
            [tile autorelease]; // match alloc; still retained as subview
        }
    }
    
    self.currentPlayer = PlayerP1;
    [self scheduleWinningConditionCheck];
    
	return self;
}
- (void)dealloc {
    [winningConditionTimer invalidate];
	[super dealloc];
}

-(BoardTile*)tile:(BoardPoint)tilePos;
{
    if(tilePos.x > WidthInTiles-1 || tilePos.x < 0 || tilePos.y > HeightInTiles-1 || tilePos.y < 0) 
        return nil;
    
    return boardTiles[tilePos.x][tilePos.y];
}

-(void)currentPlayerPerformCharge:(CGFloat)amount at:(BoardPoint)point;
{
    if(gameEnded) {
        [controller restart];
        return;
    }
    
    if(BoardAnimationOccurredAt+(2.*ExplosionDelay) > [NSDate timeIntervalSinceReferenceDate])
        return; // Still animating; moving now would be invalid
    
    BoardTile *tile = [self tile:point];
    if( ! (tile.owner == currentPlayer || tile.owner == PlayerNone) )
        return; // Invalid move

    [tile charge:ChargeEnergy forPlayer:self.currentPlayer];
    
    if(self.currentPlayer == PlayerP1)
        self.currentPlayer = PlayerP2;
    else
        self.currentPlayer = PlayerP1;
}

@synthesize currentPlayer;
-(void)setCurrentPlayer:(Player)newPlayer;
{
    currentPlayer = newPlayer;
    [controller setCurrentPlayer:newPlayer];
}

-(void)updateScores;
{
    CGFloat scores[3];
    for(NSUInteger y = 0; y < HeightInTiles; y++) {
        for (NSUInteger x = 0; x < WidthInTiles; x++) {
            BoardTile *tile = [self tile:BoardPointMake(x, y)];
            scores[tile.owner] += tile.value;
        }
    }
    [controller setScores:scores];
}
-(void)scheduleWinningConditionCheck;
{
    winningConditionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_winningConditionCheck:) userInfo:nil repeats:YES];
}
-(void)_winningConditionCheck:(NSTimer*)timer;
{
    Player winner = [self tile:BoardPointMake(0, 0)].owner;
    if(winner == PlayerNone) return;
    
    for(NSUInteger y = 0; y < 3; y++) {
        for (NSUInteger x = 0; x < 3; x++) {
            BoardTile *tile = [self tile:BoardPointMake(x, y)];
            if(tile.owner != winner)
                return;
        }
    }
    gameEnded = YES;
    [timer invalidate]; timer = nil;
    [controller setWinner:winner];
}

@end
