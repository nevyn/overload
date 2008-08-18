//
//  MainViewController.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-12.
//  Copyright Third Cog Software 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScoreBarView.h"

@interface MainViewController : UIViewController {
    ScoreBarView *score1, *score2;
}
-(void)setScores:(CGFloat[])scores;
@end
