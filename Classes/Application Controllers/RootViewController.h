//
//  RootViewController.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-12.
//  Copyright Third Cog Software 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class BoardViewController;
@class FlipsideViewController;

@interface RootViewController : UIViewController {

	IBOutlet UIButton *infoButton;
	BoardViewController *mainViewController;
	FlipsideViewController *flipsideViewController;
}

@property (nonatomic, retain) UIButton *infoButton;
@property (nonatomic, retain) BoardViewController *mainViewController;
@property (nonatomic, retain) FlipsideViewController *flipsideViewController;

- (IBAction)toggleView;

@end
