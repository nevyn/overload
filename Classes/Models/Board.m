//
//  Board.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-09-05.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "Board.h"



@interface Board()
#pragma mark Game logic
-(void)updateScores;
-(void)scheduleWinningConditionCheck;
-(void)checkWinningCondition:(NSTimer*)sender;
-(void)advancePlayer;

-(void)setLastExplosionTime:(NSTimeInterval)explodedAt;

@end


@implementation Board
#pragma mark Initialization and memory management
-(id)init;
{
    if(![super init]) return nil;
    
    for(NSUInteger y = 0; y < HeightInTiles; y++) {
        for (NSUInteger x = 0; x < WidthInTiles; x++) {
            Tile *tile = [[Tile alloc] init];
            tile.boardPosition = BoardPointMake(x, y);
            tile.board = self;
            boardTiles[x][y] = tile;
        }
    }
    
    self.currentPlayer = PlayerP1;
    self.chaosGame = NO;
    self.tinyGame = NO;

    [self scheduleWinningConditionCheck];
    
    return self;
}
-(void)dealloc;
{
    [winningConditionTimer invalidate];

    for(NSUInteger y = 0; y < HeightInTiles; y++) 
        for (NSUInteger x = 0; x < WidthInTiles; x++) 
            [boardTiles[x][y] release];
    
    
    [super dealloc];
}

#pragma mark Game logic
-(void)updateScores;
{
    CGFloat scores[3] = {0,0,0};
    for(NSUInteger y = 0; y < self.sizeInTiles.height; y++) {
        for (NSUInteger x = 0; x < self.sizeInTiles.width; x++) {
            Tile *tile = [self tile:BoardPointMake(x, y)];
            scores[tile.owner] += tile.value;
        }
    }
    [delegate board:self changedScores:scores];
}
-(void)scheduleWinningConditionCheck;
{
    winningConditionTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(checkWinningCondition:) userInfo:nil repeats:YES];
}
-(void)checkWinningCondition:(NSTimer*)sender;
{
    Player winner = [self tile:BoardPointMake(0, 0)].owner;
    if(winner == PlayerNone) return;
    
    for(NSUInteger y = 0; y < self.sizeInTiles.height; y++) {
        for (NSUInteger x = 0; x < self.sizeInTiles.width; x++) {
            Tile *tile = [self tile:BoardPointMake(x, y)];
            if(tile.owner != winner)
                return;
        }
    }
    gameEnded = YES;
    [winningConditionTimer invalidate]; winningConditionTimer = nil;
    [delegate board:self endedWithWinner:winner];    
}
-(void)advancePlayer;
{
    if(self.currentPlayer == PlayerP1)
        self.currentPlayer = PlayerP2;
    else
        self.currentPlayer = PlayerP1;    
}

-(void)setLastExplosionTime:(NSTimeInterval)explodedAt;
{
    lastExplosionTime = explodedAt;
}


#pragma mark Accessors
-(Tile*)tile:(BoardPoint)tilePos;
{
    if(tilePos.x > WidthInTiles-1 || tilePos.x < 0 || tilePos.y > HeightInTiles-1 || tilePos.y < 0) 
        return nil;
    
    return boardTiles[tilePos.x][tilePos.y];    
}
-(BOOL)isBoardEmpty;
{
    for(NSUInteger y = 0; y < self.sizeInTiles.height; y++) {
        for (NSUInteger x = 0; x < self.sizeInTiles.width; x++) {
            Tile *tile = [self tile:BoardPointMake(x, y)];
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

#pragma mark Mutators
-(void)restart;
{
    self.currentPlayer = PlayerP1;
    gameEnded = NO;
    [delegate boardIsStartingAnew:self];
    for(NSUInteger y = 0; y < HeightInTiles; y++) {
        for (NSUInteger x = 0; x < WidthInTiles; x++) {
            Tile *tile = [self tile:BoardPointMake(x, y)];
            [self performSelector:@selector(_zeroTile:) withObject:tile afterDelay:frand(0.5)];
        }
    }
    [self scheduleWinningConditionCheck];
}
-(void)_zeroTile:(Tile*)tile;
{
    tile.owner = PlayerNone;
    tile.value = 0;
}
-(void)shuffle;
{
    srand(time(NULL));
    for(NSUInteger y = 0; y < HeightInTiles; y++) {
        for (NSUInteger x = 0; x < WidthInTiles; x++) {
            Tile *tile = [self tile:BoardPointMake(x, y)];
            [self performSelector:@selector(_shuffleTile:) withObject:tile afterDelay:frand(0.5)];
        }
    }
}
-(void)_shuffleTile:(Tile*)tile;
{
    tile.owner = rand()%2 + 1;
    tile.value = frand(1.0);
}


-(void)chargeTileForCurrentPlayer:(BoardPoint)tilePoint;
{
    if(gameEnded) {
        [self restart];
        return;
    }
    
    if( !chaosGame && (lastExplosionTime+(2.*ExplosionDelay) > [NSDate timeIntervalSinceReferenceDate]))
        return; // Still animating; moving now would be invalid
    
    Tile *tile = [self tile:tilePoint];
    if( ! (tile.owner == currentPlayer || tile.owner == PlayerNone) )
        return; // Invalid move
    
    [delegate tile:tile wasChargedTo:tile.value+ChargeEnergy byPlayer:self.currentPlayer];
    [tile charge:ChargeEnergy forPlayer:self.currentPlayer];

    [self advancePlayer];
}

#pragma mark Persistance
-(void)persist;
{
    NSUserDefaults *udef = [NSUserDefaults standardUserDefaults];

    [udef setBool:self.chaosGame forKey:@"chaosGame"];
    [udef setBool:self.tinyGame forKey:@"tinyGame"];
    
    for(NSUInteger y = 0; y < HeightInTiles; y++) {
        for (NSUInteger x = 0; x < WidthInTiles; x++) {
            Tile *tile = [self tile:BoardPointMake(x, y)];
            [udef setFloat:tile.value forKey:[NSString stringWithFormat:@"board.%d.%d.value", x, y]];
            [udef setInteger:tile.owner forKey:[NSString stringWithFormat:@"board.%d.%d.owner", x, y]];
        }
    }
}
-(void)load;
{
    NSUserDefaults *udef = [NSUserDefaults standardUserDefaults];
    self.chaosGame = [udef boolForKey:@"chaosGame"];
    self.tinyGame = [udef boolForKey:@"tinyGame"];

    for(NSUInteger y = 0; y < HeightInTiles; y++) {
        for (NSUInteger x = 0; x < WidthInTiles; x++) {
            Tile *tile = [self tile:BoardPointMake(x, y)];
            tile.value = [udef floatForKey:[NSString stringWithFormat:@"board.%d.%d.value", x, y]];
            tile.owner = [udef integerForKey:[NSString stringWithFormat:@"board.%d.%d.owner", x, y]];
        }
    }
}

#pragma mark Properties
@synthesize delegate;
-(void)setDelegate:(id<BoardDelegate>)delegate_;
{
    delegate = delegate_;
    srand(time(NULL));
    
    // Trigger all delegate methods
    for(NSUInteger y = 0; y < HeightInTiles; y++) {
        for (NSUInteger x = 0; x < WidthInTiles; x++) {
            Tile *tile = [self tile:BoardPointMake(x, y)];
            [self performSelector:@selector(_sendTile:) withObject:tile afterDelay:frand(0.5)];
        }
    }
    
    self.chaosGame = self.chaosGame;
    self.tinyGame = self.tinyGame;
    [self updateScores];
    self.currentPlayer = self.currentPlayer;
}
-(void)_sendTile:(Tile*)tile;
{
    tile.value = tile.value;
    tile.owner = tile.owner;
}

@synthesize currentPlayer;
-(void)setCurrentPlayer:(Player)newPlayer;
{
    currentPlayer = newPlayer;
    [delegate board:self changedCurrentPlayer:currentPlayer];
}
@synthesize chaosGame;
@synthesize tinyGame;
-(void)setTinyGame:(BOOL)isTiny;
{
    tinyGame = isTiny;
    [delegate board:self changedSize:self.sizeInTiles];
}
-(BoardSize)sizeInTiles;
{
    return tinyGame ?
            BoardSizeMake(WidthInTiles/2, HeightInTiles/2) :
            BoardSizeMake(WidthInTiles, HeightInTiles);
}
@end




@implementation Tile
-(void)charge:(CGFloat)amount;
{
    self.value += amount;
    if(self.value >= 0.9999)
        [self explode];
}
-(void)charge:(CGFloat)amount forPlayer:(Player)newOwner;
{
    self.owner = newOwner;
    [self charge:amount];
}
-(void)explode;
{
    self.value = 0.0;

    BoardPoint urdl[4] =   {BoardPointMake(self.boardPosition.x, self.boardPosition.y-1),
                            BoardPointMake(self.boardPosition.x+1, self.boardPosition.y),
                            BoardPointMake(self.boardPosition.x, self.boardPosition.y+1),
                            BoardPointMake(self.boardPosition.x-1, self.boardPosition.y)};

    Tile *targets[] = {[self.board tile:urdl[0]],
        [self.board tile:urdl[1]],
        [self.board tile:urdl[2]],
    [self.board tile:urdl[3]]};
    
    [NSTimer scheduledTimerWithTimeInterval:ExplosionDelay*1 target:targets[0] selector:@selector(_explosionCharge:) userInfo:self repeats:NO];
    if(urdl[1].x < board.sizeInTiles.width)
        [NSTimer scheduledTimerWithTimeInterval:ExplosionDelay*1 target:targets[1] selector:@selector(_explosionCharge:) userInfo:self repeats:NO];
    if(urdl[2].y < board.sizeInTiles.height)
        [NSTimer scheduledTimerWithTimeInterval:ExplosionDelay*1 target:targets[2] selector:@selector(_explosionCharge:) userInfo:self repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:ExplosionDelay*1 target:targets[3] selector:@selector(_explosionCharge:) userInfo:self repeats:NO];    
    
    
    [self.board.delegate tileExploded:self];
}
-(void)_explosionCharge:(NSTimer*)caller;
{
    [self charge:ExplosionSpreadEnergy forPlayer:[(Tile*)[caller userInfo] owner]];
    [board setLastExplosionTime:[NSDate timeIntervalSinceReferenceDate]];
}


@synthesize board;
@synthesize owner;
-(void)setOwner:(Player)newOwner;
{
    owner = newOwner;
    [self.board.delegate tile:self changedOwner:owner value:value];
    [self.board updateScores];
}
@synthesize value;
-(void)setValue:(CGFloat)newValue;
{
    value = newValue;
    [self.board.delegate tile:self changedOwner:owner value:value];
    [self.board updateScores];
}
@synthesize boardPosition;

@end