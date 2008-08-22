//
//  MainViewController.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-12.
//  Copyright Third Cog Software 2008. All rights reserved.
//

#import "MainViewController.h"
#import "MainView.h"
#import "BoardView.h"
#import <QuartzCore/QuartzCore.h>
@implementation MainViewController

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
    
    self.tinyGame = [[NSUserDefaults standardUserDefaults] boolForKey:@"tinyGame"];
    self.chaosGame = [[NSUserDefaults standardUserDefaults] boolForKey:@"chaosGame"];
    sound = [[NSUserDefaults standardUserDefaults] boolForKey:@"sound"];

    
	return self;
}
- (void)viewDidLoad {
    score1 = [[ScoreBarView alloc] initWithFrame:CGRectMake(0, 44+BoardHeight, 320, 44) player:PlayerP1];

    score2 = [[ScoreBarView alloc] initWithFrame:CGRectMake(0, 0, 320, 44) player:PlayerP2];
    score2.transform = CGAffineTransformMakeRotation(M_PI);    
    boardView = [[BoardView alloc] initWithFrame:CGRectMake(0, 44, BoardWidth, BoardHeight) controller:self];
    
    boardView.tinyGame = tinyGame;
    boardView.chaosGame = chaosGame;
    
    [self.view addSubview:boardView];
    [self.view addSubview:score1];
    [self.view addSubview:score2];
    
    boardView.sparkling = YES;
    
    [self performSelector:@selector(loadBoard) withObject:nil afterDelay:0.1];
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}




- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
	[super dealloc];
}

-(void)setScores:(CGFloat[])scores;
{
    [score1 setScores:scores];
    [score2 setScores:scores];
}
-(void)setCurrentPlayer:(Player)player;
{
    [score1 setCurrentPlayer:player];
    [score2 setCurrentPlayer:player];
}
-(void)setWinner:(Player)winner;
{
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];

    if(winner == PlayerNone) {
        [winPlaque removeFromSuperview]; winPlaque = nil;
        [losePlaque removeFromSuperview]; winPlaque = nil;
        [UIView commitAnimations];
        return;
    }
    winPlaque = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"win.png"]] autorelease];
    losePlaque = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"lose.png"]] autorelease];
    
    UIImageView *p1Plaque = winner==PlayerP1?winPlaque:losePlaque,
                *p2Plaque = winner==PlayerP2?winPlaque:losePlaque;
    
    p1Plaque.frame = CGRectMake(0, 230, 320, 230);
    p2Plaque.frame = CGRectMake(0, 0, 320, 230);
    p2Plaque.transform = CGAffineTransformMakeRotation(M_PI);
    

    [self.view addSubview:p1Plaque];
    [self.view addSubview:p2Plaque];
    
	[UIView commitAnimations];
}

-(void)restart;
{
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:1];
    [UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];

    [self setWinner:PlayerNone];
    boardView.sparkling = NO;
    [boardView removeFromSuperview];
    boardView = [[BoardView alloc] initWithFrame:CGRectMake(0, 44, BoardWidth, BoardHeight) controller:self];
    CGFloat scores[3] = {0,0,0};
    [self setScores:scores];
    boardView.chaosGame = chaosGame;
    boardView.tinyGame = tinyGame;
    boardView.sparkling = YES;
    [self.view insertSubview:boardView belowSubview:score1];
    
    [UIView commitAnimations];
}
-(void)shuffle;
{
    [boardView shuffle];
}

-(void)setChaosGame:(BOOL)_; {
    chaosGame = boardView.chaosGame = _;
    [[NSUserDefaults standardUserDefaults] setBool:_ forKey:@"chaosGame"];
}
-(BOOL)chaosGame; { return boardView.chaosGame; }
-(void)setTinyGame:(BOOL)_; {
    [[NSUserDefaults standardUserDefaults] setBool:_ forKey:@"tinyGame"];
    tinyGame = _;
    // note: not setting in boardView until on viewDidAppear
} 
@synthesize sound;
-(void)setSound:(BOOL)_; {
    [[NSUserDefaults standardUserDefaults] setBool:_ forKey:@"sound"];
    sound = _;
} 

-(BOOL)tinyGame; { return boardView.tinyGame; }

- (void)viewDidAppear:(BOOL)animated; 
{
    boardView.sparkling = YES;
    [self performSelector:@selector(_setTinyView) withObject:nil afterDelay:1.0];
}
- (void)viewDidDisappear:(BOOL)animated;
{
    boardView.sparkling = NO;
}

-(void)_setTinyView;
{
    boardView.tinyGame = tinyGame;
}


-(void)persistBoard;
{
    BoardStruct bs = boardView.boardStruct;
    NSData *serializedBs = [NSData dataWithBytes:&bs length:sizeof(bs)];
    [[NSUserDefaults standardUserDefaults] setObject:serializedBs forKey:@"boardStruct"];
    [[NSUserDefaults standardUserDefaults] setInteger:boardView.currentPlayer forKey:@"currentPlayer"];
}
-(void)loadBoard;
{
    NSData *serializedBs = [[NSUserDefaults standardUserDefaults] objectForKey:@"boardStruct"];
    if(!serializedBs) return;
    BoardStruct bs;
    [serializedBs getBytes:&bs length:sizeof(bs)];
    boardView.boardStruct = bs;
    boardView.currentPlayer = [[NSUserDefaults standardUserDefaults] integerForKey:@"currentPlayer"];
    [boardView checkWinningCondition:nil];
}

@end
