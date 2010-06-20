//
//  ScoreBarView.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-17.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "StatusBarView.h"
#import "CollectionUtils.h"

@implementation StatusBarView
+(float)defaultHeight;
{
	return 44-14;
}

- (id)initWithFrame:(CGRect)frame;
{
	if (![super initWithFrame:frame]) return nil;
	
	[self setCurrentPlayer:PlayerNone];
	
	CGRect pen = frame;
	pen.origin.y = 0;
	pen.origin.x = 6;
	pen = CGRectIntegral(pen);
	status = [[[UILabel alloc] initWithFrame:pen] autorelease];
	status.text = @"Welcome to Overload.";
	status.backgroundColor = [UIColor clearColor];
	[self addSubview:status];
	
	pen.size.height /= 2;
	pen.origin.x = 0;
	UIImageView *gloss = [[[UIImageView alloc] initWithFrame:pen] autorelease];
	gloss.image = [UIImage imageNamed:@"gloss.png"];
	[self addSubview:gloss];
	pen.size.height *= 2;
	
	
	status.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
	
	return self;
}
- (void)dealloc {
	[super dealloc];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
	[delegate scoreBarTouched:self];
}


-(void)setScores:(CGFloat[])scores;
{
	[scoreIndicator setScores:scores];
}

-(void)setStatus:(NSString*)newStatus;
{
	status.text = newStatus;
}
-(NSString*)status;
{
	return status.text;
}


@synthesize delegate;

-(void)setCurrentPlayer:(PlayerID)currentPlayer;
{
	[UIView beginAnimations:@"statusBar.changeCurrentPlayer" context:nil];
	self.backgroundColor = [UIColor colorWithHue:Hues[currentPlayer] saturation:0.6 brightness:0.8 alpha:1.0];
	[UIView commitAnimations];
	
	status.transform = CGAffineTransformIdentity;
	
	self.status = $sprintf(@"Player %d's turn.", currentPlayer);
}
@end
