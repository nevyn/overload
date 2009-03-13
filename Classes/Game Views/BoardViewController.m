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

@interface BoardViewController ()
@property (retain, nonatomic) NSTimer *heartbeat;
@end


@implementation BoardViewController

#pragma mark Initialization and memory management

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if( ! [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) return nil;
    
    soundPlayer = [[OLSoundPlayer alloc] init];
    
    board = [[Board alloc] init];
#ifndef AI_VS_AI
    [board load];
#else
    board.sizeInTiles = BoardSizeMake(WidthInTiles/2, HeightInTiles/2);
    board.chaosGame = YES;
#endif
    [self boardIsStartingAnew:board];
        
	return self;
}

- (void)viewDidLoad {
    score1 = [[[ScoreBarView alloc] initWithFrame:CGRectMake(0, BoardHeight(), BoardWidth+14, ScoreBarHeight) player:PlayerP1] autorelease];
    score1.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	score1.delegate = self;
    [self.view addSubview:score1];
    /*score2 = [[[ScoreBarView alloc] initWithFrame:CGRectMake(0, 0, BoardWidth, ScoreBarHeight) player:PlayerP2] autorelease];
    score2.transform = CGAffineTransformMakeRotation(M_PI);
    score2.delegate = self;*/

    /*[self.view addSubview:score2];*/
	 
	
	NSArray *scoreColors = [NSArray arrayWithObjects:
                            [UIColor colorWithHue:00 saturation:0.0 brightness:0.6 alpha:1.0],
                            [UIColor colorWithHue:Hues[1] saturation:0.6 brightness:0.6 alpha:1.0],
                            [UIColor colorWithHue:Hues[2] saturation:0.6 brightness:0.6 alpha:1.0],
                            nil];
	
    score = [[ScoreIndicator alloc] initWithFrame:CGRectMake(0, 0, 14, BoardHeight()) colors:scoreColors];
	
	[self.view addSubview:score];
        
    
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    
    
    if([[NSUserDefaults standardUserDefaults] boolForKey:@"currentGame.hasAI"])
        [self startAI];
}

- (void)viewDidAppear:(BOOL)animated; 
{
    self.heartbeat = [NSTimer scheduledTimerWithTimeInterval:1./60. target:self selector:@selector(update) userInfo:nil repeats:YES];

    if(!boardView) {
        boardView = [[[BoardView alloc] initWithFrame:CGRectMake(14, 0, BoardWidth, BoardHeight())] autorelease];
        [boardView setSizeInTiles:board.sizeInTiles];
        boardView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        boardView.delegate = self;
        [self.view insertSubview:boardView belowSubview:score1];
    }
    boardView.animated = YES;
    board.delegate = self; // Triggers calling all delegate methods to match board view to model    
}
- (void)viewDidDisappear:(BOOL)animated;
{
    self.heartbeat = nil;
    boardView.animated = NO;
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
    self.heartbeat = nil;
    [board release];
    [soundPlayer release];
    [ai release];
	[super dealloc];
}

#pragma mark Hearbeat
@synthesize heartbeat;
-(void)setHeartbeat:(NSTimer*)heartbeat_;
{
    if(heartbeat != heartbeat_)
        [heartbeat invalidate];
    [heartbeat_ retain];
    [heartbeat release];
    heartbeat = heartbeat_;
}

-(void)update;
{
    static NSTimeInterval lastBoardUpdate = 0;
    static NSTimeInterval lastViewUpdate = 0;
    
    static const NSTimeInterval boardUpdateDt = 1./30.;
    static const NSTimeInterval viewUpdateDt = 1./60.;
    
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    if(lastBoardUpdate + boardUpdateDt < now) {
        [board update];
        lastBoardUpdate = now;
    }
    if(lastViewUpdate + viewUpdateDt < now) {
        [boardView render];
        lastViewUpdate = now;
    }
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
-(void)tileWillSoonExplode:(Tile*)tile;
{
    [boardView aboutToExplode:tile.boardPosition];
}
-(void)board:(Board*)board changedScores:(Scores)scores;
{
    [score setScores:scores.scores];
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
    
    if(board.isBoardEmpty) {
        score1.status = @"    Tap me to play against iPhone";
        [[Beacon sharedIfOptedIn] startSubBeaconWithName:@"Local 2P Game" timeSession:YES];
    }
    
    if(currentPlayer == PlayerP2)
        [ai performSelector:@selector(performMove) withObject:nil afterDelay:0.2];
#ifdef AI_VS_AI
    else
        if(!board.isBoardEmpty)
            [ai2 performSelector:@selector(performMove) withObject:nil afterDelay:0.2];
#endif
}
-(void)board:(Board*)board changedSize:(BoardSize)newSize;
{
    [boardView setSizeInTiles:newSize];
}

#pragma mark Board view delegates
-(void)boardTileViewWasTouched:(BoardPoint)pointThatWasTouched;
{
    [board chargeTileForCurrentPlayer:pointThatWasTouched];
}

#pragma mark Score bar delegates
-(void)scoreBarTouched:(ScoreBarView*)scoreBarView;
{
    if([score1.status isEqual:@"    Tap me to play against iPhone"]) {
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
    score1.status = @"    iPhone is waiting on you...";
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
