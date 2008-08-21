//
//  ScoreIndicator.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-21.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ScoreIndicator : UIView {
    UIView *container;
}
-(id)initWithFrame:(CGRect)frame colors:(NSArray*)colors;
-(void)setScores:(CGFloat[])scores;

@property (readonly) NSUInteger playerCount;
@end
