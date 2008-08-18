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
#import "ScoreBarView.h"

@implementation MainViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if( ! [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) return nil;
    
	return self;
}
- (void)viewDidLoad {
    [self.view addSubview:[[BoardView alloc] initWithFrame:CGRectMake(0, 45, BoardWidth, BoardHeight)]];
    score1 = [[ScoreBarView alloc] initWithFrame:CGRectMake(0, 0, 320, 44) color:[UIColor colorWithHue:.0 saturation:0.6 brightness:0.75 alpha:1.0]];
    score2 = [[ScoreBarView alloc] initWithFrame:CGRectMake(0, 46+BoardHeight, 320, 43) color:[UIColor colorWithHue:.35 saturation:0.6 brightness:0.55 alpha:1.0]];
    score1.transform = CGAffineTransformMakeRotation(M_PI);
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


@end
