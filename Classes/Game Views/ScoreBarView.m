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
    
    self.player = player_;
    
    [self setCurrentPlayer:PlayerNone];
    
    CGRect pen = frame;
    pen.size.height -= 14;
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
    

    pen.origin.x = 0;
    pen.size.height = 14;
    pen.origin.y = frame.size.height-pen.size.height;
    pen = CGRectIntegral(pen);
    NSArray *scoreColors = [NSArray arrayWithObjects:
                            [UIColor colorWithHue:Hues[1] saturation:0.6 brightness:0.6 alpha:1.0],
                            [UIColor colorWithHue:Hues[2] saturation:0.6 brightness:0.6 alpha:1.0],
                            nil];
    scoreIndicator = [[[ScoreIndicator alloc] initWithFrame:pen colors:scoreColors] autorelease];
    [self addSubview:scoreIndicator];
    
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

@synthesize player;

-(void)flipStatus;
{
    [UIView beginAnimations:nil context:NULL];
	[UIView setAnimationDuration:0.5];
    status.transform = CGAffineTransformMakeRotation(M_PI);
    [UIView commitAnimations];
}

@synthesize delegate;

-(void)setCurrentPlayer:(Player)currentPlayer;
{
    BOOL _ = currentPlayer == self.player;
    [UIView beginAnimations:@"statusBar.changeCurrentPlayer" context:nil];
    self.backgroundColor = [UIColor colorWithHue:Hues[self.player] saturation:_?0.6:0.3 brightness:_?0.8:0.5 alpha:1.0];
    [UIView commitAnimations];
    
    status.transform = CGAffineTransformIdentity;
    
    
    if(_)
        self.status = @"Your turn.";
    else
        self.status = @"Their turn.";
}
@end
