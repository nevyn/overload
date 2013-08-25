//
//  FlipsideViewController.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-12.
//  Copyright Third Cog Software 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TypesAndConstants.h"
@class RootViewController;
@class BoardViewController;

@interface FlipsideViewController : UIViewController <UIActionSheetDelegate>{
    IBOutlet UIImageView *cogU, *cogM, *cogL;
    IBOutlet UILabel *versionLabel;
    NSTimer *rotationTimer;
    NSTimeInterval first;
    RootViewController *rootController;
    BoardViewController *mainController;
    
    IBOutlet UISlider *boardSize;
    IBOutlet UISwitch *chaosGame;
    IBOutlet UISwitch *soundSwitch;    
    IBOutlet UILabel *sizeLabel;
    IBOutlet UILabel *estimatedTimeLabel;
    BoardSize newBoardSize;
    NSMutableArray *stuffToDoWhenFlipped;
}
- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
       rootController:(RootViewController*)rootController_
       mainController:(BoardViewController*)mainController_;
- (IBAction)toggleView:(id)sender;
- (IBAction)newGame:(id)sender;
- (IBAction)shuffleGame:(id)sender;

-(void)updateSizeLabel:(BoardSize)size;
- (IBAction)setGameBoardSize:(UISlider*)sender;

- (IBAction)toggleChaosGame:(UISwitch*)sender;
- (IBAction)toggleSound:(UISwitch*)sender;
@end
