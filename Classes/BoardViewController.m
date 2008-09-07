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
@implementation BoardViewController

#pragma mark Initialization and memory management

+(void)initialize;
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:
        [NSDictionary dictionaryWithObjectsAndKeys:
            [NSNumber numberWithBool:YES], @"tinyGame",
            [NSNumber numberWithBool:NO], @"chaosGame",
            [NSNumber numberWithBool:YES], @"sound",
            nil, nil
        ]
     ];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if( ! [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) return nil;
    
    soundPlayer = [[OLSoundPlayer alloc] init];
    
    board = [[Board alloc] init];
    [board load];
    
	return self;
}
- (void)viewDidLoad {
    score1 = [[[ScoreBarView alloc] initWithFrame:CGRectMake(0, 44+BoardHeight, 320, 44) player:PlayerP1] autorelease];

    score2 = [[[ScoreBarView alloc] initWithFrame:CGRectMake(0, 0, 320, 44) player:PlayerP2] autorelease];
    score2.transform = CGAffineTransformMakeRotation(M_PI);    
        
    [self.view addSubview:score1];
    [self.view addSubview:score2];
}

- (void)viewDidAppear:(BOOL)animated; 
{
    if(!boardView) {
        boardView = [[[BoardView alloc] initWithFrame:CGRectMake(0, 44, BoardWidth, BoardHeight)] autorelease];
        [boardView setSize:board.sizeInTiles];
        boardView.delegate = self;
        boardView.sparkling = YES;
        [self.view insertSubview:boardView belowSubview:score1];
    }    
    board.delegate = self; // Triggers calling all delegate methods to match board view to model

    id boardViewProxy = [[CInvocationGrabber invocationGrabber] prepareWithInvocationTarget:boardView];
    [boardViewProxy setSparkling:YES];
    [[boardViewProxy invocation] performSelector:@selector(invoke) withObject:nil afterDelay:1.0];
    
}
- (void)viewDidDisappear:(BOOL)animated;
{
    boardView.sparkling = NO;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
    if(!self.view.superview)
        [boardView removeFromSuperview]; boardView = nil;
}

- (void)dealloc {
    [board release];
    [soundPlayer release];
	[super dealloc];
}

#pragma mark Board delegates
-(void)tile:(Tile*)tile changedOwner:(Player)owner value:(CGFloat)value;
{
    BoardTileView *tileView = [boardView tile:tile.boardPosition];
    tileView.value = tile.value;
    tileView.owner = tile.owner;
}
-(void)tile:(Tile*)tile wasChargedTo:(CGFloat)value byPlayer:(Player)player;
{
    [soundPlayer playChargeSound:value];
}
-(void)tileExploded:(Tile*)tile;
{
    [soundPlayer playExplosionSound];
    [[boardView tile:tile.boardPosition] explode];
}
-(void)board:(Board*)board changedScores:(CGFloat[])scores;
{
    [score1 setScores:scores];
    [score2 setScores:scores];
}
-(void)board:(Board*)board endedWithWinner:(Player)winner;
{
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
    [UIView beginAnimations:nil context:NULL]; // Why doesn't it animate?
	[UIView setAnimationDuration:1];

    [winPlaque removeFromSuperview]; winPlaque = nil;
    [losePlaque removeFromSuperview]; losePlaque = nil;
    
    [UIView commitAnimations];
}

-(void)board:(Board*)board changedCurrentPlayer:(Player)currentPlayer;
{
    [score1 setCurrentPlayer:currentPlayer];
    [score2 setCurrentPlayer:currentPlayer];
}
-(void)board:(Board*)board changedSize:(BoardSize)newSize;
{
    [boardView setSize:newSize];
}

#pragma mark Board view delegates
-(void)boardTileViewWasTouched:(BoardTileView*)boardTileView;
{
    [board chargeTileForCurrentPlayer:boardTileView.boardPosition];
}

#pragma mark Properties
@synthesize board;
@synthesize soundPlayer;
@end