//
//  BoardTile.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-17.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "BoardTile.h"
#import <QuartzCore/QuartzCore.h>
#import "BoardView.h"

static float frand(float max) {
    return (rand()/((float)INT_MAX))*max;
}

@interface BoardTile()
-(void)updateColor;
@end

@implementation BoardTile

- (id)initWithFrame:(CGRect)frame {
	if (![super initWithFrame:frame])
        return nil;
    
    [self updateColor];
    
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
    [self.board currentPlayerPerformCharge:ChargeEnergy at:self.boardPosition];
}

-(void)updateColor;
{
    [UIView beginAnimations:@"Tile color" context:nil];
    static CGFloat hues[] = {.6, .0, .35 };
    CGFloat brightness = 0.25+(1.0-self.value)*0.75;
    CGFloat saturation = (self.value >= 0.74)?1.0:0.6;
    if(self.owner == PlayerNone) {
        saturation = 0.3;
    }

    self.backgroundColor = [UIColor colorWithHue:hues[self.owner] saturation:saturation brightness:brightness alpha:1.0];
    [UIView commitAnimations];
}


- (void)dealloc {
	[super dealloc];
}

@synthesize owner;
@synthesize value;
-(void)setValue:(CGFloat)newValue;
{
    value = newValue;
    [self updateColor];
}
@synthesize boardPosition;
@synthesize board;

-(void)charge:(CGFloat)amount;
{
    self.value += amount;
    if(self.value >= 0.9999)
        [self explode];
    [self.board updateScores];
}
-(void)charge:(CGFloat)amount forPlayer:(Player)newOwner;
{
    self.owner = newOwner;
    [self charge:amount];
}
-(void)explode;
{
    [UIView beginAnimations:@"Explosion" context:nil];
    //[UIView setAnimationDuration:1.0];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    
    // Actions for self
    self.value = 0.0;
    
    // Actions for explosion
    BoardTile *animationTile = [[[BoardTile alloc] initWithFrame:self.frame] autorelease];
    animationTile.owner = self.owner;
    animationTile.value = self.value;
    [self.superview addSubview:animationTile];
    animationTile.transform = CGAffineTransformMakeScale(4, 4);
    animationTile.layer.opacity = 0.0;
    [UIView setAnimationDelegate:animationTile];
    [UIView setAnimationDidStopSelector:@selector(_resetExplosionAnimation::)];
    [UIView commitAnimations];
    
    BoardTile *targets[] = {[self.board tile:BoardPointMake(self.boardPosition.x, self.boardPosition.y-1)],
                            [self.board tile:BoardPointMake(self.boardPosition.x+1, self.boardPosition.y)],
                            [self.board tile:BoardPointMake(self.boardPosition.x, self.boardPosition.y+1)],
                            [self.board tile:BoardPointMake(self.boardPosition.x-1, self.boardPosition.y)]};
    
    [NSTimer scheduledTimerWithTimeInterval:0 target:targets[0] selector:@selector(_explosionCharge:) userInfo:self repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:ExplosionDelay*1 target:targets[1] selector:@selector(_explosionCharge:) userInfo:self repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:ExplosionDelay*2 target:targets[2] selector:@selector(_explosionCharge:) userInfo:self repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:ExplosionDelay*3 target:targets[3] selector:@selector(_explosionCharge:) userInfo:self repeats:NO];
}

-(void)_resetExplosionAnimation:(id)_:(id)__
{
    [self removeFromSuperview];
}
-(void)_explosionCharge:(NSTimer*)caller;
{
    [self charge:ExplosionSpreadEnergy forPlayer:[(BoardTile*)[caller userInfo] owner]];
    BoardAnimationOccurredAt = [NSDate timeIntervalSinceReferenceDate];
}
@end
