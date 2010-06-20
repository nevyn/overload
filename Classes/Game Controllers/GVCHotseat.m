//
//  GVCHotseat.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2009-06-14.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "GVCHotseat.h"


@implementation GVCHotseat
-(void)layout;
{
	NSArray *scoreColors = [NSArray arrayWithObjects:
													[UIColor colorWithHue:0.0 saturation:0.0 brightness:0.6 alpha:1.0],
													[UIColor colorWithHue:Hues[1] saturation:0.6 brightness:0.6 alpha:1.0],
													[UIColor colorWithHue:Hues[2] saturation:0.6 brightness:0.6 alpha:1.0],
													nil];
	NSArray *scoreColors2 = [NSArray arrayWithObjects:
													 [UIColor colorWithHue:0.0 saturation:0.0 brightness:0.6 alpha:1.0],
													 [UIColor colorWithHue:Hues[2] saturation:0.6 brightness:0.6 alpha:1.0],
													 [UIColor colorWithHue:Hues[1] saturation:0.6 brightness:0.6 alpha:1.0],
													 nil];
	
	// From top to bottom.
	CGRect pen = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 0);
	
	
	// Player 2's stuff is at the top, with the score indicator by the top edge
	pen.size.height = [ScoreIndicator defaultSize];
	score2 = [[ScoreIndicator alloc] initWithFrame:pen colors:scoreColors2 orientation:ScoreIndicatorHorizontal];
	score2 .transform = CGAffineTransformMakeRotation(M_PI);
	pen.origin.y += pen.size.height;
	
	pen.size.height = [StatusBarView defaultHeight];
	status2 = [[[StatusBarView alloc] initWithFrame:pen] autorelease];
	status2.transform = CGAffineTransformMakeRotation(M_PI);
	pen.origin.y += pen.size.height;
	
	
	// Between scores is the board
	pen.size.height = self.view.frame.size.height - [ScoreIndicator defaultSize]*2 - [StatusBarView defaultHeight]*2;
	boardView = [[[BoardView alloc] initWithFrame:pen] autorelease];
	[boardView setSizeInTiles:game.board.sizeInTiles];
	boardView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	boardView.delegate = self;
	
	pen.origin.y += pen.size.height;

	
	// Player 1's stuff is at the bottom, with the score indicator by the bottom edge
	pen.size.height = [StatusBarView defaultHeight];
	status = [[[StatusBarView alloc] initWithFrame:pen] autorelease];
	pen.origin.y += pen.size.height;
	
	pen.size.height = [ScoreIndicator defaultSize];
	score = [[ScoreIndicator alloc] initWithFrame:pen colors:scoreColors orientation:ScoreIndicatorHorizontal];
	
	
	[self.view addSubview:status];
	[self.view addSubview:score];
	[self.view addSubview:status2];
	[self.view addSubview:score2];
	[self.view addSubview:boardView];
	
	
	
}

@end
