//
//  ScoreBarView.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-17.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ScoreBarView : UIView {
    IBOutlet UILabel *statusText;
    IBOutlet UILabel *scoreText;
}
- (id)initWithFrame:(CGRect)frame color:(UIColor*)bg;

@property (copy) NSString *status;
@property (copy) NSString *score;
@end
