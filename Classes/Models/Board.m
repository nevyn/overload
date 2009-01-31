//
//  Board.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-09-05.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "Board.h"
#import "CInvocationGrabber.h"


@interface Board()
#pragma mark Game logic
-(void)updateScores;
-(void)scheduleWinningConditionCheck;
-(void)checkWinningCondition:(NSTimer*)sender;
-(void)advancePlayer;

-(void)setLastExplosionTime:(NSTimeInterval)explodedAt;
@property (readwrite, assign) NSUInteger explosionsQueued;
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
-(id)initWithBoard:(Board*)other;
{
    if(![super init]) return nil;
    
    for(NSUInteger y = 0; y < HeightInTiles; y++) {
        for (NSUInteger x = 0; x < WidthInTiles; x++) {
            Tile *tile = [[Tile alloc] init];
            tile.boardPosition = BoardPointMake(x, y);
            tile.board = self;
            
            Tile *otherTile = [other tile:tile.boardPosition];
            tile.value = otherTile.value;
            tile.owner = otherTile.owner;

            boardTiles[x][y] = tile;
        }
    }
    
    self.currentPlayer = other.currentPlayer;
    self.chaosGame = other.chaosGame;
    self.tinyGame = other.tinyGame;
    
    return self;
}
- (id)copyWithZone:(NSZone *)zone
{
    Board *copy = [[[self class] allocWithZone: zone]
                     initWithBoard:self];
    return copy;
    
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
    if(delegate)
        [delegate board:self changedScores:self.scores];
}
-(void)scheduleWinningConditionCheck;
{
    [winningConditionTimer invalidate];
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

-(Player)winner;
{
    //return gameEnded;
    Player winner = [self tile:BoardPointMake(0, 0)].owner;
    if(winner == PlayerNone) return PlayerNone;
    
    for(NSUInteger y = 0; y < self.sizeInTiles.height; y++) {
        for (NSUInteger x = 0; x < self.sizeInTiles.width; x++) {
            Tile *tile = [self tile:BoardPointMake(x, y)];
            if(tile.owner != winner)
                return PlayerNone;
        }
    }
    return winner;
    
}
-(BOOL)hasEnded;
{
    return self.winner;
}
-(BOOL)canMakeMoveNow;
{
    if( chaosGame )
        return YES;
    
    if( self.explosionsQueued == 0)
//    if( [NSDate timeIntervalSinceReferenceDate] > lastExplosionTime+(2.*ExplosionDelay) )
        return YES;
    
    return NO;
}
-(Scores)scores;
{
    Scores scores = {{0,0,0}};
    for(NSUInteger y = 0; y < self.sizeInTiles.height; y++) {
        for (NSUInteger x = 0; x < self.sizeInTiles.width; x++) {
            Tile *tile = [self tile:BoardPointMake(x, y)];
            scores.scores[tile.owner] += tile.value;
        }
    }
    return scores;
}
-(BOOL)player:(Player)player canChargeTile:(BoardPoint)tilePoint;
{    
    Tile *tile = [self tile:tilePoint];
    if( ! (tile.owner == player || tile.owner == PlayerNone) )
        return NO;
    return YES;
}

#pragma mark Mutators
-(void)restart;
{
    gameEnded = NO;
    self.currentPlayer = PlayerP1;
    [delegate boardIsStartingAnew:self];
    for(NSUInteger y = 0; y < HeightInTiles; y++) {
        for (NSUInteger x = 0; x < WidthInTiles; x++) {
            Tile *tile = [self tile:BoardPointMake(x, y)];
            [self performSelector:@selector(_zeroTile:) withObject:tile afterDelay:frand(0.5)];
        }
    }
    [self scheduleWinningConditionCheck];
    
    id selfProxy = [[CInvocationGrabber invocationGrabber] prepareWithInvocationTarget:self];
    [selfProxy setCurrentPlayer:PlayerP1];
    [[selfProxy invocation] performSelector:@selector(invoke) withObject:nil afterDelay:0.6];

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
    tile.value = (rand()%4)*0.25;
}


-(BOOL)chargeTileForCurrentPlayer:(BoardPoint)tilePoint;
{
    if(gameEnded) {
        [self restart];
        return NO;
    }
    
    if(![self canMakeMoveNow])
        return NO;
    
    Tile *tile = [self tile:tilePoint];
    if( ! (tile.owner == currentPlayer || tile.owner == PlayerNone) )
        return NO; // Invalid move
    
    [delegate tile:tile wasChargedTo:tile.value+ChargeEnergy byPlayer:self.currentPlayer];
    [tile charge:ChargeEnergy forPlayer:self.currentPlayer];

    [self advancePlayer];
    return YES;
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
    
    [[NSUserDefaults standardUserDefaults] setInteger:currentPlayer forKey:@"currentPlayer"];
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
    
    self.currentPlayer = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentPlayer"];
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
@synthesize explosionsQueued;
@end




@implementation Tile
-(void)charge:(CGFloat)amount;
{
    self.value += amount;
    if(self.value >= 0.9999)
        [self explode];
    
    [board setLastExplosionTime:[NSDate timeIntervalSinceReferenceDate]-ExplosionDelay/2];
}
-(void)charge:(CGFloat)amount forPlayer:(Player)newOwner;
{
    self.owner = newOwner;
    [self charge:amount];
}


-(void)_explosionCharge:(NSTimer*)caller;
{
    Player p = (int)caller < 10 ? (Player)caller : [(Tile*)[caller userInfo] owner];
    [self charge:ExplosionSpreadEnergy forPlayer:p];
    [board setLastExplosionTime:[NSDate timeIntervalSinceReferenceDate]];
    board.explosionsQueued -= 1;
}
-(void)explode;
{
    self.value = 0.0;
    
#define doitnow(target) [target _explosionCharge:(NSTimer*)self.owner]
#define doitlater(target_) [NSTimer scheduledTimerWithTimeInterval:ExplosionDelay*1 target:target_ selector:@selector(_explosionCharge:) userInfo:self repeats:NO]
    
    for (Tile *sibling in self.surroundingTiles) {
        board.explosionsQueued += 1;
        if(board.delegate)
            doitlater(sibling);
        else
            doitnow(sibling);
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
-(void)setOwner:(Player)newOwner;
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
