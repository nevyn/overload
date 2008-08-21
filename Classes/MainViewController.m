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
            nil, nil
        ]
     ];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if( ! [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) return nil;
    
    self.tinyGame = [[NSUserDefaults standardUserDefaults] boolForKey:@"tinyGame"];
    self.chaosGame = [[NSUserDefaults standardUserDefaults] boolForKey:@"chaosGame"];
    
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
    NSString *win = @"Congratulations, you win!", *lose = @"Bummer, you lose.";
    if(winner == PlayerP1)
        score1.status = win, score2.status = lose;
    else
        score1.status = lose, score2.status = win;
    score1.score = score2.score = @"Tap board to play again.";
}

-(void)restart;
{
    [boardView removeFromSuperview];
    boardView = [[BoardView alloc] initWithFrame:CGRectMake(0, 45, BoardWidth, BoardHeight) controller:self];
    CGFloat scores[3] = {0,0,0};
    [self setScores:scores];
    boardView.chaosGame = chaosGame;
    boardView.tinyGame = tinyGame;
    [self.view insertSubview:boardView belowSubview:score1];
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
