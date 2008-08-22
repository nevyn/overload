//
//  BoardView.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-18.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "BoardView.h"
#import "MainViewController.h"
#import <QuartzCore/QuartzCore.h>
NSTimeInterval BoardAnimationOccurredAt = 0;

@interface BoardView()
-(void)sparkle;
@end

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
    
    self.chaosGame = NO;
    self.tinyGame = NO;
    
	return self;
}
- (void)dealloc {
    [winningConditionTimer invalidate];
    [sparkleTimer invalidate];
	[super dealloc];
}

-(void)setSparkling:(BOOL)sparkling_;
{
    if(sparkling_ && !sparkling) {
        sparkling = sparkling_;
        [self sparkle];
    }

    sparkling = sparkling_;
}
-(BOOL)sparkling;
{
    return sparkling;
}
-(void)sparkle;
{
    static CGFloat animationDuration = 0.5;
    static BOOL on = NO;
    [UIView beginAnimations:@"sparkle" context:nil];
    [UIView setAnimationDuration:animationDuration];
    if(sparkling)
        [self performSelector:@selector(sparkle) withObject:nil afterDelay:animationDuration];
    
    
    for(NSUInteger y = 0; y < sizeInTiles.height; y++) {
        for (NSUInteger x = 0; x < sizeInTiles.width; x++) {
            BoardTile *tile = [self tile:BoardPointMake(x, y)];
            if(tile.value >= SparkleEnergy)
                if(on == NO) {
                    tile.layer.opacity = SparkleOpacityLow;
                } else {
                    tile.layer.opacity = 1.;
                }
            
        }
    }
    [UIView commitAnimations];    
    on = ! on;    
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
    
    if( !chaosGame && (BoardAnimationOccurredAt+(2.*ExplosionDelay) > [NSDate timeIntervalSinceReferenceDate]))
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
    CGFloat scores[3] = {0,0,0};
    for(NSUInteger y = 0; y < sizeInTiles.height; y++) {
        for (NSUInteger x = 0; x < sizeInTiles.width; x++) {
            BoardTile *tile = [self tile:BoardPointMake(x, y)];
            scores[tile.owner] += tile.value;
        }
    }
    [controller setScores:scores];
}
-(void)scheduleWinningConditionCheck;
{
    winningConditionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkWinningCondition:) userInfo:nil repeats:YES];
}
-(void)checkWinningCondition:(NSTimer*)timer;
{
    Player winner = [self tile:BoardPointMake(0, 0)].owner;
    if(winner == PlayerNone) return;
    
    for(NSUInteger y = 0; y < sizeInTiles.height; y++) {
        for (NSUInteger x = 0; x < sizeInTiles.width; x++) {
            BoardTile *tile = [self tile:BoardPointMake(x, y)];
            if(tile.owner != winner)
                return;
        }
    }
    gameEnded = YES;
    [winningConditionTimer invalidate]; winningConditionTimer = nil;
    [controller setWinner:winner];
}

-(void)shuffle;
{
    srand(time(NULL));
    for(NSUInteger y = 0; y < sizeInTiles.height; y++) {
        for (NSUInteger x = 0; x < sizeInTiles.width; x++) {
            BoardTile *tile = [self tile:BoardPointMake(x, y)];
            tile.owner = rand()%2 + 1;
            tile.value = frand(1.0);
        }
    }
}

-(BOOL)isBoardEmpty;
{
    for(NSUInteger y = 0; y < sizeInTiles.height; y++) {
        for (NSUInteger x = 0; x < sizeInTiles.width; x++) {
            BoardTile *tile = [self tile:BoardPointMake(x, y)];
            if(tile.owner != PlayerNone)
                return NO;
        }
    }
    return YES;
}
-(BOOL)hasGameEnded;
{
    return gameEnded;
}
@synthesize chaosGame;
@synthesize tinyGame;
-(void)setTinyGame:(BOOL)tinyGame_;
{
    tileSize = tinyGame_ ? CGSizeMake(TileWidth*2, TileHeight*2) : CGSizeMake(TileWidth, TileHeight);
    sizeInTiles = tinyGame_ ? BoardSizeMake(WidthInTiles/2, HeightInTiles/2) : BoardSizeMake(WidthInTiles, HeightInTiles);
    tinyGame = tinyGame_;

    if(tileSize.width == [self tile:BoardPointMake(0, 0)].frame.size.width)
        return;
    
    if( ! [self isBoardEmpty] ) {
        [UIView beginAnimations:@"Resize board" context:nil];
        [UIView setAnimationDuration:1];
    }

    for(NSUInteger y = 0; y < HeightInTiles; y++) {
        for (NSUInteger x = 0; x < WidthInTiles; x++) {
            [self tile:BoardPointMake(x, y)].frame = 
                CGRectMake(x*tileSize.width, y*tileSize.height, tileSize.width, tileSize.height);
        }
    }
    if( ! [self isBoardEmpty] )
        [UIView commitAnimations];
}

@synthesize tileSize;
@synthesize sizeInTiles;


-(BoardStruct)boardStruct;
{
    BoardStruct bs;
    for(NSUInteger y = 0; y < HeightInTiles; y++) {
        for (NSUInteger x = 0; x < WidthInTiles; x++) {
            BoardTile *tile = [self tile:BoardPointMake(x, y)];
            bs.values[x][y] = tile.value;
            bs.owners[x][y] = tile.owner;
        }
    }
    return bs;
}
-(void)setBoardStruct:(BoardStruct)bs;
{
    for(NSUInteger y = 0; y < HeightInTiles; y++) {
        for (NSUInteger x = 0; x < WidthInTiles; x++) {
            BoardTile *tile = [self tile:BoardPointMake(x, y)];
            NSNumber *val = [NSNumber numberWithFloat:bs.values[x][y]];
            NSNumber *own = [NSNumber numberWithInteger:bs.owners[x][y]];
            CGFloat delay = frand(0.5);
            [tile performSelector:@selector(setOwner_:) withObject:own afterDelay:delay];
            [tile performSelector:@selector(setValue_:) withObject:val afterDelay:delay];
//            tile.value = bs.values[x][y];
//            tile.owner = bs.owners[x][y];
        }
    }
}
@end
