//
//  BoardTile.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-17.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "BoardTileView.h"
#import <QuartzCore/QuartzCore.h>
#import "BoardView.h"


@interface BoardTileView()
-(void)updateColor;
@end

@implementation BoardTileView

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
    [self.board.delegate boardTileViewWasTouched:self];
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
    

    
    /*if(self.value < SparkleEnergy) {
        self.layer.opacity = 1.0;
    }*/

    self.backgroundColor = [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1.0];
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
@synthesize value;
-(void)setValue:(CGFloat)newValue;
{
    value = newValue;
    [self updateColor];
}
@synthesize boardPosition;
@synthesize board;


static CGRect boardPointToFrameRect(CGSize ts, BoardPoint bp)
{
    return CGRectMake(bp.x*ts.width, bp.y*ts.height, ts.width, ts.height);
}
-(void)explode;
{
    BoardPoint urdl[4] =   {BoardPointMake(self.boardPosition.x, self.boardPosition.y-1),
        BoardPointMake(self.boardPosition.x+1, self.boardPosition.y),
        BoardPointMake(self.boardPosition.x, self.boardPosition.y+1),
        BoardPointMake(self.boardPosition.x-1, self.boardPosition.y)};

    
        
    CGSize ts = board.tileSize;
    NSArray *animationTiles = [NSArray arrayWithObjects:
                               [[[BoardTileView alloc] initWithFrame:self.frame] autorelease],
                               [[[BoardTileView alloc] initWithFrame:self.frame] autorelease], 
                               [[[BoardTileView alloc] initWithFrame:self.frame] autorelease], 
                               [[[BoardTileView alloc] initWithFrame:self.frame] autorelease],
                              nil];
    for (NSUInteger i = 0; i < 4; i++) {
        BoardTileView *aniTile = [animationTiles objectAtIndex:i];

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
    
    
}

-(void)_resetExplosionAnimation:(id)_:(id)__
{
    [self removeFromSuperview];
}
@end
