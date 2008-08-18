//
//  FlipsideViewController.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-12.
//  Copyright Third Cog Software 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RootViewController;
@class MainViewController;

@interface FlipsideViewController : UIViewController {
    IBOutlet UIImageView *cogU, *cogM, *cogL;
    IBOutlet UILabel *versionLabel;
    NSTimeInterval first;
    NSTimer *rotationTimer;
    RootViewController *rootController;
    MainViewController *mainController;
}
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
       rootController:(RootViewController*)rootController_
       mainController:(MainViewController*)mainController_;
- (IBAction)toggleView:(id)sender;
- (IBAction)newGame:(id)sender;
- (IBAction)shuffleGame:(id)sender;
- (IBAction)toggleGameBoardSize:(UISwitch*)sender;
- (IBAction)toggleChaosGame:(UISwitch*)sender;
@end
