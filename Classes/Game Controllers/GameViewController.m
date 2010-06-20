//
//  BoardViewController.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-12.
//  Copyright Third Cog Software 2008. All rights reserved.
//

#import "GameViewController.h"
#import "BoardView.h"
#import <QuartzCore/QuartzCore.h>
#import "CInvocationGrabber.h"
#import "AI2.h"
#import "AIMinMax.h"
#import "Beacon+OptIn.h"


@interface GameViewController ()
@property (retain, nonatomic) NSTimer *heartbeat;
@end


@implementation GameViewController

#pragma mark Initialization and memory management

-(id)init
{
	if( ! [super initWithNibName:@"GameView" bundle:nil]) return nil;
	
	soundPlayer = [[OLSoundPlayer alloc] init];
	
	return self;
}

-(void)layout;
{
	[NSException raise:NSGenericException format:@"GameViewController is abstract"]; 
}


- (void)viewDidLoad {
	self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;

	[self layout];
}

- (void)viewDidAppear:(BOOL)animated; 
{
	self.heartbeat = [NSTimer scheduledTimerWithTimeInterval:1./1000. target:self selector:@selector(update) userInfo:nil repeats:YES];
	
	if(!boardView) {
		boardView = [[[BoardView alloc] initWithFrame:CGRectMake(14, 0, BoardWidth, BoardHeight())] autorelease];
		[boardView setSizeInTiles:game.board.sizeInTiles];
		boardView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		boardView.delegate = self;
		[self.view insertSubview:boardView belowSubview:status];
	}
	game.delegate = self; // Triggers calling all delegate methods to match board view to model    
}
- (void)viewDidDisappear:(BOOL)animated;
{
	self.heartbeat = nil;
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
	[game release];
	[soundPlayer release];
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
		[game update];
		lastBoardUpdate = now;
	}
	if(lastViewUpdate + viewUpdateDt < now) {
		[boardView render];
		lastViewUpdate = now;
	}
}


#pragma mark Board delegates
-(void)tile:(Tile*)tile changedOwner:(PlayerID)owner;
{
	[boardView setOwner:owner atPosition:tile.boardPosition];
}
-(void)tile:(Tile*)tile changedValue:(CGFloat)value;
{
	[boardView setValue:value atPosition:tile.boardPosition];
}
-(void)tile:(Tile*)tile wasChargedTo:(CGFloat)value byPlayer:(PlayerID)player;
{
	[soundPlayer playChargeSound:value];
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
-(void)board:(Board*)board endedWithWinner:(PlayerID)winner;
{    
	[soundPlayer playWinSound];
	PlayerID loser = (!(winner-1))+1;
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
	[self.navigationController popViewControllerAnimated:YES];
	return;
	
	[UIView beginAnimations:nil context:NULL]; // Why doesn't it animate?
	[UIView setAnimationDuration:1];
	
	[winPlaque removeFromSuperview]; winPlaque = nil;
	[losePlaque removeFromSuperview]; losePlaque = nil;
	
	[UIView commitAnimations];
}

-(void)board:(Board*)board_ changedCurrentPlayer:(PlayerID)currentPlayer;
{
	[status setCurrentPlayer:currentPlayer];
}
-(void)board:(Board*)board changedSize:(BoardSize)newSize;
{
	[boardView setSizeInTiles:newSize];
}

#pragma mark Board view delegates
-(void)boardTileViewWasTouched:(BoardPoint)pointThatWasTouched;
{
	[game makeMoveForCurrentPlayer:pointThatWasTouched];
}

#pragma mark Score bar delegates
-(void)scoreBarTouched:(StatusBarView*)scoreBarView;
{
	
}


#pragma mark Properties
@synthesize soundPlayer;
@synthesize game;
@end
