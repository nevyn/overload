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

@implementation MainViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if( ! [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) return nil;
    
	return self;
}
- (void)viewDidLoad {
    score1 = [[ScoreBarView alloc] initWithFrame:CGRectMake(0, 46+BoardHeight, 320, 43) color:[UIColor colorWithHue:.0 saturation:0.6 brightness:0.75 alpha:1.0]];
    score2 = [[ScoreBarView alloc] initWithFrame:CGRectMake(0, 0, 320, 44) color:[UIColor colorWithHue:.35 saturation:0.6 brightness:0.55 alpha:1.0]];
    score2.transform = CGAffineTransformMakeRotation(M_PI);    
    BoardView *boardView = [[BoardView alloc] initWithFrame:CGRectMake(0, 45, BoardWidth, BoardHeight) controller:self];
    
    [self.view addSubview:boardView];
    [self.view addSubview:score1];
    [self.view addSubview:score2];
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
    NSString *score = [NSString stringWithFormat:@"%.2f (you) %.2f (opponent) of 120", scores[1], scores[2]];
    score1.score = score;
    score = [NSString stringWithFormat:@"%.2f (you) %.2f (opponent) of 120", scores[2], scores[1]];
    score2.score = score;
}
-(void)setCurrentPlayer:(Player)player;
{
    NSString *my = @"Your turn.", *theirs = @"Their turn.";
    if(player == PlayerP1)
        score1.status = my, score2.status = theirs;
    else
        score1.status = theirs, score2.status = my;
}


@end
