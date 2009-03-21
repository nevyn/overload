//
//  Game.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2009-03-15.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "Game.h"
#import "AI2.h"
#import "Beacon+OptIn.h"


@implementation Game
-(id)init;
{
	if( ! [super init] ) return nil;
	
	board = [[Board alloc] init];
	board.game = self;
	players = [[NSMutableArray alloc] init];
	
	return self;
}
-(void)dealloc;
{
	[board release];
	[players release];
	[super dealloc];
}
-(void)load;
{
	// TODO: If the last game wasn't a local game, don't load
	[board load];
	
	if([[NSUserDefaults standardUserDefaults] boolForKey:@"currentGame.hasAI"])
        [self startAI];

}
-(void)persist;
{
	[board persist];
}
-(void)update;
{
	[board update];
}

#pragma mark Gameplay
-(BOOL)hasEnded;
{
	return board.hasEnded;
}
-(void)restart;
{
	[self stopAI];
	[board restart];
}
-(void)shuffle;
{
	[board shuffle];
}
-(BOOL)canMakeMoveNow;
{
	return [board canMakeMoveNow];
}
-(BOOL)makeMoveForCurrentPlayer:(BoardPoint)actionPoint;
{
	return [board chargeTileForCurrentPlayer:actionPoint];
}

#pragma mark AI

-(void)startAI;
{
    ai = [[AI2 alloc] initPlaying:PlayerP2 onGame:self];

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"currentGame.hasAI"];
}
-(void)stopAI;
{
    if(!ai) return;
    
    [ai release]; ai = nil;
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"currentGame.hasAI"];
}

#pragma mark Properties
@synthesize board;

@synthesize delegate;
-(void)setDelegate:(id)delegate_;
{
	delegate = delegate_;
	board.delegate = self;
}
-(Player)currentPlayer;
{
	return board.currentPlayer;
}
-(void)setCurrentPlayer:(Player)newPlayer;
{
	board.currentPlayer = newPlayer;
}



#pragma mark Board delegates
-(void)tile:(Tile*)tile changedOwner:(Player)owner;
{
	[delegate tile:tile changedOwner:owner];
}
-(void)tile:(Tile*)tile changedValue:(CGFloat)value;
{
	[delegate tile:tile changedValue:value];
}
-(void)tile:(Tile*)tile wasChargedTo:(CGFloat)value byPlayer:(Player)player;
{
    [delegate tile:tile wasChargedTo:value byPlayer:player];
    
    if(ai && player == PlayerP1)
        [ai player:player choseTile:tile.boardPosition];
}
-(void)tileExploded:(Tile*)tile;
{
	[delegate tileExploded:tile];
}
-(void)tileWillSoonExplode:(Tile*)tile;
{
	[delegate tileWillSoonExplode:tile];
}
-(void)board:(Board*)board_ changedScores:(Scores)scores;
{
	[delegate board:board_ changedScores:scores];
}
-(void)board:(Board*)board_ endedWithWinner:(Player)winner;
{
    if(ai)
        [[Beacon sharedIfOptedIn] endSubBeaconWithName:@"Local AI Game"];
    else
        [[Beacon sharedIfOptedIn] endSubBeaconWithName:@"Local 2P Game"];

	[delegate board:board_ endedWithWinner:winner];
}
-(void)boardIsStartingAnew:(Board*)board_;
{
	[delegate boardIsStartingAnew:board_];
}

-(void)board:(Board*)board_ changedCurrentPlayer:(Player)currentPlayer;
{
    if(board.isBoardEmpty)
        [[Beacon sharedIfOptedIn] startSubBeaconWithName:@"Local 2P Game" timeSession:YES];
    
    if(currentPlayer == PlayerP2)
        [ai performSelector:@selector(performMove) withObject:nil afterDelay:0.2];
	[delegate board:board_ changedCurrentPlayer:currentPlayer];
}
-(void)board:(Board*)board_ changedSize:(BoardSize)newSize;
{
	[delegate board:board_ changedSize:newSize];
}
@end
