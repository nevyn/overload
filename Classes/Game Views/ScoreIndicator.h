//
//  ScoreIndicator.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-21.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
	ScoreIndicatorHorizontal,
	ScoreIndicatorVertical
} ScoreIndicatorOrientation;

@interface ScoreIndicator : UIView {
  UIView *container;
	ScoreIndicatorOrientation orientation;
}
+(float)defaultSize;

-(id)initWithFrame:(CGRect)frame
						colors:(NSArray*)colors
			 orientation:(ScoreIndicatorOrientation)orientation_;
-(void)setScores:(CGFloat[])scores;

@property (readonly, nonatomic) NSUInteger playerCount;
@end
