//
//  ScoreIndicator.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-21.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "ScoreIndicator.h"


@implementation ScoreIndicator


-(id)initWithFrame:(CGRect)frame colors:(NSArray*)colors;
{
    if ( ! [super initWithFrame:frame]) return nil;
    
    NSUInteger playerCount = [colors count];
    
    CGRect pen = frame;
    pen.origin = CGPointMake(0, 0);
    
    container = [[[UIView alloc] initWithFrame:pen] autorelease];
    [self addSubview:container];
    
    pen.size.height /= 2;
    UIImageView *gloss = [[[UIImageView alloc] initWithFrame:pen] autorelease];
    gloss.image = [UIImage imageNamed:@"gloss.png"];
    [self addSubview:gloss];
    pen.size.height *= 2;
    
    pen.size.width /= playerCount;
    for (UIColor *color in colors) {

        UIView *bar = [[[UIView alloc] initWithFrame:pen] autorelease];
        bar.backgroundColor = color;
        pen.origin.x += pen.size.width;
        
        UILabel *barText = [[[UILabel alloc] initWithFrame:CGRectMake(0, 0, pen.size.width, pen.size.height)] autorelease];
        barText.text = @"0";
        barText.backgroundColor = [UIColor clearColor];
        barText.textAlignment = UITextAlignmentCenter;
        barText.font = [UIFont systemFontOfSize:12];
        barText.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [bar addSubview:barText];
        [container addSubview:bar];
    }
    
	return self;
}

- (void)dealloc {
	[super dealloc];
}

-(NSUInteger)playerCount;
{
    return [container.subviews count];
}

-(void)setScores:(CGFloat[])scores;
{
    CGFloat totalScore = 0;
    for (NSUInteger i = 1; i < self.playerCount+1; i++) {
        totalScore += scores[i];
    }
    if(totalScore == 0)
        totalScore = 1;
    
    NSArray *views = [container subviews];
    CGFloat widthPerPoint = self.frame.size.width/totalScore;
    CGFloat pen = 0;
    

    [UIView beginAnimations:@"scorebar" context:nil];
    for (NSUInteger i = 1; i < self.playerCount+1; i++) {
        CGFloat thisProportion = widthPerPoint * scores[i];
        
        UIView *colorBar = [views objectAtIndex:i-1];
        [colorBar setFrame:
            CGRectMake(pen, 0, thisProportion, self.frame.size.height)];
        pen += thisProportion;
        
        UILabel *barText = [[colorBar subviews] objectAtIndex:0];
        barText.text = [NSString stringWithFormat:@"%.2f", scores[i]];
    }
    [UIView commitAnimations];
}

@end
