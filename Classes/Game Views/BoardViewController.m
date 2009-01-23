//
//  BoardViewController.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-12.
//  Copyright Third Cog Software 2008. All rights reserved.
//

#import "BoardViewController.h"
#import "BoardView.h"
#import <QuartzCore/QuartzCore.h>
#import "CInvocationGrabber.h"
#import "AI2.h"
#import "AIMinMax.h"
#import "Beacon+OptIn.h"
@implementation BoardViewController

#pragma mark Initialization and memory management

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if( ! [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) return nil;
    
    soundPlayer = [[OLSoundPlayer alloc] init];
    
    board = [[Board alloc] init];
#ifndef AI_VS_AI
    [board load];
#else
    board.tinyGame = YES;
    board.chaosGame = YES;
#endif
    [self boardIsStartingAnew:board];
        
	return self;
}

- (void)viewDidLoad {
    score1 = [[[ScoreBarView alloc] initWithFrame:CGRectMake(0, BoardHeight()+ScoreBarHeight, BoardWidth, ScoreBarHeight) player:PlayerP1] autorelease];
    score1.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;

    score2 = [[[ScoreBarView alloc] initWithFrame:CGRectMake(0, 0, BoardWidth, ScoreBarHeight) player:PlayerP2] autorelease];
    score2.transform = CGAffineTransformMakeRotation(M_PI);
    score2.delegate = self;
        
    [self.view addSubview:score1];
    [self.view addSubview:score2];
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"currentGame.hasAI"])
        [self startAI];
}

- (void)viewDidAppear:(BOOL)animated; 
{
    if(!boardView) {
        boardView = [[[BoardView alloc] initWithFrame:CGRectMake(0, ScoreBarHeight, BoardWidth, BoardHeight())] autorelease];
        [boardView setSize:board.sizeInTiles];
        boardView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        boardView.delegate = self;
        [self.view insertSubview:boardView belowSubview:score1];
    }
    board.delegate = self; // Triggers calling all delegate methods to match board view to model    
}
- (void)viewDidDisappear:(BOOL)animated;
{
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    if(!self.view.superview) {
        [boardView removeFromSuperview];
        boardView = nil;
    }
}

- (void)dealloc {
    [board release];
    [soundPlayer release];
    [ai release];
	[super dealloc];
}

#pragma mark Board delegates
-(void)tile:(Tile*)tile changedOwner:(Player)owner;
{
    [boardView setOwner:owner atPosition:tile.boardPosition];
}
-(void)tile:(Tile*)tile changedValue:(CGFloat)value;
{
    [boardView setValue:value atPosition:tile.boardPosition];
}
-(void)tile:(Tile*)tile wasChargedTo:(CGFloat)value byPlayer:(Player)player;
{
    [soundPlayer playChargeSound:value];
    
    if(ai && player == PlayerP1)
        [ai player:player choseTile:tile.boardPosition];
}
-(void)tileExploded:(Tile*)tile;
{
    [soundPlayer playExplosionSound];
    [boardView explode:tile.boardPosition];
}
-(void)board:(Board*)board changedScores:(Scores)scores;
{
    [score1 setScores:scores.scores];
    [score2 setScores:scores.scores];
}
-(void)board:(Board*)board endedWithWinner:(Player)winner;
{
    if(ai)
        [[Beacon sharedIfOptedIn] endSubBeaconWithName:@"Local AI Game"];
    else
        [[Beacon sharedIfOptedIn] endSubBeaconWithName:@"Local 2P Game"];
    
    [soundPlayer playWinSound];
    Player loser = (!(winner-1))+1;
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
    
    winPlaque =  [[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"win-p%d.png", winner]]] autorelease];
    losePlaque = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:[NSString stringWithFormat:@"lose-p%d.png", loser]]] autorelease];
    
    UIImageView *p1Plaque = winner==PlayerP1?winPlaque:losePlaque,
    *p2Plaque = winner==PlayerP2?winPlaque:losePlaque;
    
    p1Plaque.frame = CGRectMake(0, 230, 320, 230);
    p2Plaque.frame = CGRectMake(0, 0, 320, 230);
    p2Plaque.transform = CGAffineTransformMakeRotation(M_PI);
    
    [self.view addSubview:p1Plaque];
    [self.view addSubview:p2Plaque];
        
	[UIView commitAnimations];
}
-(void)boardIsStartingAnew:(Board*)board;
{
    [self stopAI];

    [UIView beginAnimations:nil context:NULL]; // Why doesn't it animate?
	[UIView setAnimationDuration:1];

    [winPlaque removeFromSuperview]; winPlaque = nil;
    [losePlaque removeFromSuperview]; losePlaque = nil;
        
    [UIView commitAnimations];
}

-(void)board:(Board*)board_ changedCurrentPlayer:(Player)currentPlayer;
{
    [score1 setCurrentPlayer:currentPlayer];
    [score2 setCurrentPlayer:currentPlayer];
    
    if(board.isBoardEmpty) {
        score2.status = @"    Tap me to play against iPhone";
        [[Beacon sharedIfOptedIn] startSubBeaconWithName:@"Local 2P Game" timeSession:YES];
        [score2 flipStatus];
    }
    
    if(currentPlayer == PlayerP2)
        [ai performMove];
#ifdef AI_VS_AI
    else
        if(!board.isBoardEmpty)
            [ai2 performSelector:@selector(performMove) withObject:nil afterDelay:0.1];
#endif
}
-(void)board:(Board*)board changedSize:(BoardSize)newSize;
{
    [boardView setSize:newSize];
}

#pragma mark Board view delegates
-(void)boardTileViewWasTouched:(BoardPoint)pointThatWasTouched;
{
    [board chargeTileForCurrentPlayer:pointThatWasTouched];
}

#pragma mark Score bar delegates
-(void)scoreBarTouched:(ScoreBarView*)scoreBarView;
{
    if(scoreBarView == score2 && score2.status == @"    Tap me to play against iPhone") {
        [self startAI];
        [[Beacon sharedIfOptedIn] startSubBeaconWithName:@"Local AI Game" timeSession:YES];
    }
    
}

#pragma mark AI
-(void)startAI;
{
    ai = [[AI2 alloc] initPlaying:PlayerP2 onBoard:board delegate:self];
#ifdef AI_VS_AI
    ai2 = [[AI2 alloc] initPlaying:PlayerP1 onBoard:board delegate:self];
#endif
    score2.status = @"    iPhone is waiting on you...";
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
@synthesize soundPlayer;
@end
