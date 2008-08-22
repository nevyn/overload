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


@interface BoardTile()
-(void)updateColor;
@end

@implementation BoardTile

- (id)initWithFrame:(CGRect)frame {
	if (![super initWithFrame:frame])
        return nil;
    
    [self updateColor];
    
    UIImageView *image = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tile.png"]] autorelease];
    frame.origin = CGPointMake(0, 0);
    image.frame = frame;
    image.autoresizingMask = UIViewAutoresizingFlexibleHeight|UIViewAutoresizingFlexibleWidth;
    [self addSubview:image];
    
    return self;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
    [self.board currentPlayerPerformCharge:ChargeEnergy at:self.boardPosition];
}

-(void)updateColor;
{
    [UIView beginAnimations:@"Tile color" context:nil];
    [UIView setAnimationBeginsFromCurrentState:YES];
    CGFloat hue = Hues[self.owner];
    CGFloat saturation = Saturations[self.owner];
    CGFloat brightness = 1.0-self.value;
    
    if(self.owner == PlayerNone)
        saturation = Saturations[self.owner];
    

    
    if(self.value >= SparkleEnergy) {
        //self.transform = CGAffineTransformMakeScale(0.8, 0.8);
        //[self sparkle2]; // sparkling occurs in the board view
    } else {
        self.transform = CGAffineTransformIdentity;
        self.layer.opacity = 1.0;
    }

    self.backgroundColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0];
    [UIView commitAnimations];
}
-(void)sparkle;
{
    //[UIView beginAnimations:@"sparkle" context:nil];
    if(self.value >= SparkleEnergy)
        [self performSelector:@selector(sparkle) withObject:nil afterDelay:0.1];
        //[UIView setAnimationDidStopSelector:@selector(sparkle)];
    
    self.transform = CGAffineTransformMakeTranslation(frand(2.)-1., frand(2.)-1.);
    
}
-(void)sparkle2;
{
    [UIView beginAnimations:@"sparkle" context:nil];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDelay:0.2];
    if(self.value >= SparkleEnergy)
        [UIView setAnimationDidStopSelector:@selector(sparkle2)];
    
    if(self.layer.opacity == 1.) {
        self.layer.opacity = SparkleOpacityLow;
    } else {
        self.layer.opacity = 1.;
    }
    
    [UIView commitAnimations];    
}


- (void)dealloc {
	[super dealloc];
}

@synthesize owner;
-(void)setOwner:(Player)owner_;
{
    owner = owner_;
    [self updateColor];
}
-(void)setOwner_:(NSNumber*)owner_;
{
    self.owner = [owner_ intValue];
    [board updateScores];
}
@synthesize value;
-(void)setValue:(CGFloat)newValue;
{
    value = newValue;
    [self updateColor];
    [board updateScores];
}
-(void)setValue_:(NSNumber*)newValue;
{
    self.value = [newValue floatValue];
}
@synthesize boardPosition;
@synthesize board;

-(void)charge:(CGFloat)amount;
{
    self.value += amount;
    if(self.value >= 0.9999)
        [self explode];
}
-(void)charge:(CGFloat)amount forPlayer:(Player)newOwner;
{
    self.owner = newOwner;
    [self charge:amount];
}

static CGRect boardPointToFrameRect(CGSize ts, BoardPoint bp)
{
    return CGRectMake(bp.x*ts.width, bp.y*ts.height, ts.width, ts.height);
}
-(void)explode;
{
    [board playExplosionSound];
    
    BoardPoint urdl[4] =   {BoardPointMake(self.boardPosition.x, self.boardPosition.y-1),
        BoardPointMake(self.boardPosition.x+1, self.boardPosition.y),
        BoardPointMake(self.boardPosition.x, self.boardPosition.y+1),
        BoardPointMake(self.boardPosition.x-1, self.boardPosition.y)};

    
    
    self.value = 0.0;
        
    // Actions for explosion
    CGSize ts = board.tileSize;
    NSArray *animationTiles = [NSArray arrayWithObjects:
                               [[[BoardTile alloc] initWithFrame:self.frame] autorelease],
                               [[[BoardTile alloc] initWithFrame:self.frame] autorelease], 
                               [[[BoardTile alloc] initWithFrame:self.frame] autorelease], 
                               [[[BoardTile alloc] initWithFrame:self.frame] autorelease],
                              nil];
    for (NSUInteger i = 0; i < 4; i++) {
        BoardTile *aniTile = [animationTiles objectAtIndex:i];

        [[[aniTile subviews] objectAtIndex:0] removeFromSuperview];
        
        [UIView beginAnimations:@"Explosion1" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:0.6];
        [UIView setAnimationDelay:(ExplosionDelay/2)*(i+1)];
        
        aniTile.owner = self.owner;
        aniTile.value = 1.0-0.25*i;
        [self.superview addSubview:aniTile];
        
        aniTile.frame = boardPointToFrameRect(ts, urdl[i]);
        aniTile.layer.opacity = 0.0;
        
        [UIView setAnimationDelegate:aniTile];
        [UIView setAnimationDidStopSelector:@selector(_resetExplosionAnimation::)];
        
        [UIView commitAnimations];
    }
    
    
    BoardTile *targets[] = {[self.board tile:urdl[0]],
                            [self.board tile:urdl[1]],
                            [self.board tile:urdl[2]],
                            [self.board tile:urdl[3]]};
    
    [NSTimer scheduledTimerWithTimeInterval:ExplosionDelay*1 target:targets[0] selector:@selector(_explosionCharge:) userInfo:self repeats:NO];
    if(urdl[1].x < board.sizeInTiles.width)
        [NSTimer scheduledTimerWithTimeInterval:ExplosionDelay*2 target:targets[1] selector:@selector(_explosionCharge:) userInfo:self repeats:NO];
    if(urdl[2].y < board.sizeInTiles.height)
        [NSTimer scheduledTimerWithTimeInterval:ExplosionDelay*3 target:targets[2] selector:@selector(_explosionCharge:) userInfo:self repeats:NO];
    [NSTimer scheduledTimerWithTimeInterval:ExplosionDelay*4 target:targets[3] selector:@selector(_explosionCharge:) userInfo:self repeats:NO];
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
