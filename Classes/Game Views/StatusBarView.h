//
//  ScoreBarView.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-17.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TypesAndConstants.h"
#import "ScoreIndicator.h"

@class StatusBarView;
@protocol ScoreBarViewDelegate
-(void)scoreBarTouched:(StatusBarView*)scoreBarView;
@end


@interface StatusBarView : UIView {
    ScoreIndicator *scoreIndicator;
    UILabel *status;
    
    id<ScoreBarViewDelegate> delegate;
}
+(float)defaultHeight;

- (id)initWithFrame:(CGRect)frame;

-(void)setScores:(CGFloat[])scores;

@property (copy, nonatomic) NSString *status;

@property (assign, nonatomic) id<ScoreBarViewDelegate> delegate;


-(void)setCurrentPlayer:(PlayerID)currentPlayer_;

@end
