//
//  RootViewController.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-12.
//  Copyright Third Cog Software 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <iAd/iAd.h>

@class BoardViewController;
@class FlipsideViewController;

@interface RootViewController : UIViewController
@property (nonatomic, retain) IBOutlet UIButton *infoButton;
@property (nonatomic, retain) BoardViewController *mainViewController;
@property (nonatomic, retain) FlipsideViewController *flipsideViewController;
@property (nonatomic, retain) UIPopoverController *ipadInfoPopover;
@property (nonatomic, retain) ADBannerView *banner;

- (IBAction)toggleView;

@end
