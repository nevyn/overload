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
#import "SoundEngine.h"
NSTimeInterval BoardAnimationOccurredAt = 0;

@interface BoardView()
-(void)sparkle;
@end

typedef enum {
    kExplosion, kCharge25, kCharge50, kCharge75, kCharge100, kSoundNamesMax
}soundNames;
UInt32 sounds[kSoundNamesMax];


@implementation BoardView
+(void)initialize
{
    SoundEngine_Initialize(0);
#define __wavPath(name) [[[NSBundle mainBundle] pathForResource:name ofType:@"wav"] UTF8String]
    SoundEngine_LoadEffect(__wavPath(@"explosion"), &(sounds[kExplosion]));
    SoundEngine_LoadEffect(__wavPath(@"charge25"), &(sounds[kCharge25]));
    SoundEngine_LoadEffect(__wavPath(@"charge50"), &(sounds[kCharge50]));
    SoundEngine_LoadEffect(__wavPath(@"charge75"), &(sounds[kCharge75]));
    SoundEngine_LoadEffect(__wavPath(@"charge100"), &(sounds[kCharge100]));
    
}
/* Never uninitialize, no need
 for (NSUInteger i = 0; i < kSoundNamesMax; i++) {
 SoundEngine_StopEffect(sounds[i], 0);
 SoundEngine_UnloadEffect(sounds[i]);
 }
 SoundEngine_Teardown();
*/

- (id)initWithFrame:(CGRect)frame controller:(MainViewController*)controller_;
{
	if (![super initWithFrame:frame]) return nil;
    
    controller = controller_;

    for(NSUInteger y = 0; y < HeightInTiles; y++) {
        for (NSUInteger x = 0; x < WidthInTiles; x++) {
            BoardTile *tile = [[[BoardTile alloc] initWithFrame:CGRectMake(x*TileWidth, y*TileHeight, TileWidth, TileHeight)] autorelease];
            tile.boardPosition = BoardPointMake(x, y);
            tile.board = self;
            boardTiles[x][y] = tile;
            [self addSubview:tile];
        }
    }
    
    self.backgroundColor = [UIColor whiteColor];
    
    self.currentPlayer = PlayerP1;
    [self scheduleWinningConditionCheck];
    
    self.chaosGame = NO;
    self.tinyGame = NO;
#if TARGET_IPHONE_SIMULATOR
#undef __wavPath
#define __wavPath(name) ((CFURLRef)[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:name ofType:@"wav"]])
    AudioServicesCreateSystemSoundID(__wavPath(@"explosion"), &explosion);
    AudioServicesCreateSystemSoundID(__wavPath(@"charge25"), &charge25);
    AudioServicesCreateSystemSoundID(__wavPath(@"charge50"), &charge50);
    AudioServicesCreateSystemSoundID(__wavPath(@"charge75"), &charge75);
    AudioServicesCreateSystemSoundID(__wavPath(@"charge100"), &charge100);
#endif
    
    
	return self;
}
- (void)dealloc {
    [winningConditionTimer invalidate];
#if TARGET_IPHONE_SIMULATOR
    AudioServicesDisposeSystemSoundID(explosion);
    AudioServicesDisposeSystemSoundID(charge25);
    AudioServicesDisposeSystemSoundID(charge50);
    AudioServicesDisposeSystemSoundID(charge75);
    AudioServicesDisposeSystemSoundID(charge100);
#endif
    
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
    
    [self playChargeSound:tile.value+ChargeEnergy];
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


#pragma mark Sound
-(void)playChargeSound:(CGFloat)chargeLevel;
{
    if( ! controller.sound) return;
    
#if TARGET_IPHONE_SIMULATOR
    if(chargeLevel < 0.26)
        AudioServicesPlaySystemSound(charge25);
    else if(chargeLevel < 0.51)
        AudioServicesPlaySystemSound(charge50);
    else if(chargeLevel < 0.76)
        AudioServicesPlaySystemSound(charge75);
    else
        AudioServicesPlaySystemSound(charge100);
#else
    if(chargeLevel < 0.26)
        SoundEngine_StartEffect(sounds[kCharge25]);
    else if(chargeLevel < 0.51)
        SoundEngine_StartEffect(sounds[kCharge50]);
    else if(chargeLevel < 0.76)
        SoundEngine_StartEffect(sounds[kCharge75]);
    else
        SoundEngine_StartEffect(sounds[kCharge100]);
#endif
}
-(void)playExplosionSound;
{
    if( ! controller.sound) return;
#if TARGET_IPHONE_SIMULATOR
    AudioServicesPlaySystemSound(explosion);
#else
    SoundEngine_StartEffect(sounds[kExplosion]);
#endif
}
@end
