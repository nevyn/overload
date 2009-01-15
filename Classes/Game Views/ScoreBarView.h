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

@class ScoreBarView;
@protocol ScoreBarViewDelegate
-(void)scoreBarTouched:(ScoreBarView*)scoreBarView;
@end


@interface ScoreBarView : UIView {
    ScoreIndicator *scoreIndicator;
    UILabel *status;
    Player player;
    
    id<ScoreBarViewDelegate> delegate;
}
- (id)initWithFrame:(CGRect)frame player:(Player)player;

-(void)setScores:(CGFloat[])scores;

@property (nonatomic) Player player;
@property (copy, nonatomic) NSString *status;
-(void)flipStatus;

@property (assign, nonatomic) id<ScoreBarViewDelegate> delegate;


-(void)setCurrentPlayer:(Player)currentPlayer_;

@end
