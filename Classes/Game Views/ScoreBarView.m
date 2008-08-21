//
//  ScoreBarView.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-17.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "ScoreBarView.h"


@implementation ScoreBarView


- (id)initWithFrame:(CGRect)frame player:(Player)player_;
{
	if (![super initWithFrame:frame]) return nil;
    self.backgroundColor = [UIColor colorWithHue:Hues[player_] saturation:0.6 brightness:0.75 alpha:1.0];
    
    self.player = player_;
    
    CGRect frame1 = frame;
    frame1.size.height /= 2.2;
    frame1.size.width -= 12;
    frame1.origin.y = 0;
    frame1.origin.x += 6;
    frame1 = CGRectIntegral(frame1);
    statusText = [[UILabel alloc] initWithFrame:frame1];
    frame1.origin.y += frame1.size.height;
    frame1 = CGRectIntegral(frame1);
    scoreText = [[UILabel alloc] initWithFrame:frame1];
    statusText.text = @"Welcome to Overload.";
    scoreText.text = @"0 (you) 0 (opponent)";
    
    statusText.backgroundColor = [UIColor clearColor];
    scoreText.backgroundColor = [UIColor clearColor];
    [self addSubview:statusText];
    [self addSubview:scoreText];
    
	return self;
}
- (void)dealloc {
	[super dealloc];
}

-(void)setScores:(CGFloat[])scores;
{
    Player other = (self.player==PlayerP1)?PlayerP2:PlayerP1;
    scoreText.text= [NSString stringWithFormat:@"%.2f (you) %.2f (opponent)", scores[player], scores[other]];
    
}

-(NSString*)status;
{
    return statusText.text;
}
-(void)setStatus:(NSString*)newStatus;
{
    statusText.text = newStatus;
}
-(NSString*)score;
{
    return scoreText.text;
}
-(void)setScore:(NSString*)newScore;
{
    scoreText.text = newScore;
}


@synthesize player;
@end
