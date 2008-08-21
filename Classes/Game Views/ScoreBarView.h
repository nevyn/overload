//
//  ScoreBarView.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-17.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TypesAndConstants.h"

@interface ScoreBarView : UIView {
    IBOutlet UILabel *scoreText;
    Player player;
}
- (id)initWithFrame:(CGRect)frame player:(Player)player;

-(void)setScores:(CGFloat[])scores;

@property Player player;

-(void)setCurrentPlayer:(Player)currentPlayer_;
@end
