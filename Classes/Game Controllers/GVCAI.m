//
//  GVCAI.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2009-06-14.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "GVCAI.h"


@implementation GVCAI
-(void)layout;
{
	status = [[[StatusBarView alloc] initWithFrame:CGRectMake(0, BoardHeight(), BoardWidth+14, [StatusBarView defaultHeight])] autorelease];
	status.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	status.delegate = self;
	[self.view addSubview:status];	 
	
	NSArray *scoreColors = [NSArray arrayWithObjects:
													[UIColor colorWithHue:00 saturation:0.0 brightness:0.6 alpha:1.0],
													[UIColor colorWithHue:Hues[1] saturation:0.6 brightness:0.6 alpha:1.0],
													[UIColor colorWithHue:Hues[2] saturation:0.6 brightness:0.6 alpha:1.0],
													nil];
	
	score = [[ScoreIndicator alloc] initWithFrame:CGRectMake(0, 0, 14, BoardHeight()) 
																				 colors:scoreColors
																		orientation:ScoreIndicatorVertical];
	
	[self.view addSubview:score];	
}

@end
