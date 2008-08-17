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
    static CGFloat hues[] = {.6, .0, .35 };
    CGFloat brightness = 0.25+(1.0-self.value)*0.75;
    self.backgroundColor = [UIColor colorWithHue:hues[self.owner] saturation:0.6 brightness:brightness alpha:1.0];
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
    if(self.value >= 1.0)
        [self explode];
}
-(void)charge:(CGFloat)amount forPlayer:(Player)newOwner;
{
    self.owner = newOwner;
    [self charge:amount];
}
-(void)explode;
{
    self.value = 0.0;
    BoardTile *targets[] = {[self.board tile:BoardPointMake(self.boardPosition.x, self.boardPosition.y-1)],
                            [self.board tile:BoardPointMake(self.boardPosition.x+1, self.boardPosition.y)],
                            [self.board tile:BoardPointMake(self.boardPosition.x, self.boardPosition.y+1)],
                            [self.board tile:BoardPointMake(self.boardPosition.x-1, self.boardPosition.y)]};
    
    [NSTimer scheduledTimerWithTimeInterval:0 target:targets[0] selector:@selector(_explosionCharge:) userInfo:self repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:ExplosionDelay*1 target:targets[1] selector:@selector(_explosionCharge:) userInfo:self repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:ExplosionDelay*2 target:targets[2] selector:@selector(_explosionCharge:) userInfo:self repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:ExplosionDelay*3 target:targets[3] selector:@selector(_explosionCharge:) userInfo:self repeats:NO];
}
-(void)_explosionCharge:(NSTimer*)caller;
{
    [self charge:ExplosionSpreadEnergy forPlayer:[(BoardTile*)[caller userInfo] owner]];
}
@end
