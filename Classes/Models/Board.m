//
//  Board.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-09-05.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "Board.h"
#import "CInvocationGrabber.h"
#import "CollectionUtils.h"

@interface Board()
#pragma mark Game logic
-(void)updateScores;
-(void)advancePlayer;

-(void)scheduleCharge:(Tile*)t owner:(Player)owner;
@end

@interface ScheduledCharge : NSObject {
    Tile *tile;
    Player owner;
}
@property (readwrite, assign, nonatomic) Tile *tile;
@property (readwrite, assign, nonatomic) Player owner;
@end
@implementation ScheduledCharge
@synthesize tile, owner;
@end



@implementation Board
#pragma mark Initialization and memory management
-(id)init;
{
    if(![super init]) return nil;
    
    for(NSUInteger y = 0; y < HeightInTiles(); y++) {
        for (NSUInteger x = 0; x < WidthInTiles(); x++) {
            Tile *tile = [[Tile alloc] init];
            tile.boardPosition = BoardPointMake(x, y);
            tile.board = self;
            boardTiles[x][y] = tile;
        }
    }
    
    self.currentPlayer = PlayerP1;
    self.chaosGame = NO;
    self.sizeInTiles = BoardSizeMake(WidthInTiles(), HeightInTiles());
    
    explosionsQueue = [[NSMutableDictionary alloc] init];
    
    return self;
}
-(id)initWithBoard:(Board*)other;
{
    if(![super init]) return nil;
    
    for(NSUInteger y = 0; y < HeightInTiles(); y++) {
        for (NSUInteger x = 0; x < WidthInTiles(); x++) {
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
    self.sizeInTiles = other.sizeInTiles;
    
    // Why no explosions queue? because this method is used for making
    // a board for the AI, which doesn't use it. Should rename the method to reflect
    // this, I know...
    
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
    [explosionsQueue release]; explosionsQueue = nil;

    for(NSUInteger y = 0; y < HeightInTiles(); y++) 
        for (NSUInteger x = 0; x < WidthInTiles(); x++) 
            [boardTiles[x][y] release];
    
    
    [super dealloc];
}

#pragma mark Game logic
-(void)updateScores;
{
    if(delegate)
        [delegate board:self changedScores:self.scores];
}
-(void)checkWinningCondition;
{
    if(gameEnded) return;
    
    Player winner = self.winner;
    if(winner == PlayerNone) return;

    gameEnded = YES;
    [delegate board:self endedWithWinner:winner];    
}
-(void)advancePlayer;
{
    if(self.currentPlayer == PlayerP1)
        self.currentPlayer = PlayerP2;
    else
        self.currentPlayer = PlayerP1;
}


#pragma mark Accessors
-(Tile*)tile:(BoardPoint)tilePos;
{
    if(tilePos.x > WidthInTiles()-1 || tilePos.x < 0 || tilePos.y > HeightInTiles()-1 || tilePos.y < 0) 
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
    return self.winner != PlayerNone;
}
-(BOOL)canMakeMoveNow;
{
    if( chaosGame )
        return YES;
    
    if( explosionsQueue.count == 0)
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
    
    for(NSUInteger y = 0; y < HeightInTiles(); y++) {
        for (NSUInteger x = 0; x < WidthInTiles(); x++) {
            Tile *tile = [self tile:BoardPointMake(x, y)];
            tile.owner = PlayerNone;
            tile.value = 0;
//            [self performSelector:@selector(_zeroTile:) withObject:tile afterDelay:frand(0.5)];
        }
    }
    
    //id selfProxy = [[CInvocationGrabber invocationGrabber] prepareWithInvocationTarget:self];
    //[selfProxy setCurrentPlayer:PlayerP1];
    //[[selfProxy invocation] performSelector:@selector(invoke) withObject:nil afterDelay:0.6];
    [self setCurrentPlayer:PlayerP1];
}
-(void)_zeroTile:(Tile*)tile;
{
    tile.owner = PlayerNone;
    tile.value = 0;
}
-(void)shuffle;
{
    srand(time(NULL));
    for(NSUInteger y = 0; y < HeightInTiles(); y++) {
        for (NSUInteger x = 0; x < WidthInTiles(); x++) {
            Tile *tile = [self tile:BoardPointMake(x, y)];
            tile.owner = rand()%2 + 1;
            tile.value = (rand()%4)*0.25;

            //[self performSelector:@selector(_shuffleTile:) withObject:tile afterDelay:frand(0.5)];
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
    
    if(explosionsQueue.count == 0 || self.chaosGame)
        [self advancePlayer];
    return YES;
}

#pragma mark Persistance
-(void)persist;
{
    NSUserDefaults *udef = [NSUserDefaults standardUserDefaults];

    [udef setBool:self.chaosGame forKey:@"chaosGame"];
    [udef setObject:$array($object(self.sizeInTiles.width), $object(self.sizeInTiles.height)) forKey:@"boardSize"];
    
    for(NSUInteger y = 0; y < HeightInTiles(); y++) {
        for (NSUInteger x = 0; x < WidthInTiles(); x++) {
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
    NSArray *widthHeight = [udef objectForKey:@"boardSize"];
    self.sizeInTiles = BoardSizeMake([[widthHeight objectAtIndex:0] intValue], [[widthHeight objectAtIndex:1] intValue]);

    for(NSUInteger y = 0; y < HeightInTiles(); y++) {
        for (NSUInteger x = 0; x < WidthInTiles(); x++) {
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
    for(NSUInteger y = 0; y < HeightInTiles(); y++) {
        for (NSUInteger x = 0; x < WidthInTiles(); x++) {
            Tile *tile = [self tile:BoardPointMake(x, y)];
            [self performSelector:@selector(_sendTile:) withObject:tile afterDelay:frand(0.5)];
        }
    }
    
    self.chaosGame = self.chaosGame;
    self.sizeInTiles = self.sizeInTiles;
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
-(BoardSize)sizeInTiles;
{
    return sizeInTiles;
}
-(void)setSizeInTiles:(BoardSize)newSize;
{
    if(newSize.height > 0 && newSize.width > 0 && newSize.height <= HeightInTiles() && newSize.width <= WidthInTiles()) {
        sizeInTiles = newSize;
        [delegate board:self changedSize:self.sizeInTiles];
    } else {
        NSAssert(false, @"newSize must be >= 1 x 1 and <= WidthInTiles() x HeightInTiles()");
    }
}

-(void)scheduleCharge:(Tile*)t owner:(Player)owner;
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

    if(explosionsQueue.count == 0 && !self.chaosGame)
        [self advancePlayer];
}
-(void)update;
{
    static NSTimeInterval lastWinUpdate = 0;
    static const NSTimeInterval winUpdateDt = 1.;
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    
    if(lastWinUpdate + winUpdateDt < now) {
        [self checkWinningCondition];
        lastWinUpdate = now;
    }
    
    if([explosionsQueue count] == 0)
        return;

#define FAST 1
#if FAST
    for (NSNumber *when in [explosionsQueue.allKeys sortedArrayUsingSelector:@selector(compare:)]) {
        NSTimeInterval when2 = [when doubleValue];
        if(when2 > [NSDate timeIntervalSinceReferenceDate])
            return;
        
        ScheduledCharge *charge = [explosionsQueue objectForKey:when];
		[[charge retain] autorelease];
        [explosionsQueue removeObjectForKey:when];
        [self explosionCharge:charge];
    }
#else
    NSNumber *when = [[explosionsQueue.allKeys sortedArrayUsingSelector:@selector(compare:)] objectAtIndex:0];
    NSTimeInterval when2 = [when doubleValue];
    if(when2 > [NSDate timeIntervalSinceReferenceDate])
        return;
    ScheduledCharge *charge = [explosionsQueue objectForKey:when];
	[[charge retain] autorelease];
    [explosionsQueue removeObjectForKey:when];
    [self explosionCharge:charge];
#endif
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
    
    for (Tile *sibling in self.surroundingTiles) {
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
