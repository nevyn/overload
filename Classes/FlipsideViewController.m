//
//  FlipsideViewController.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-12.
//  Copyright Third Cog Software 2008. All rights reserved.
//

#import "FlipsideViewController.h"
#import "FlipsideView.h"
#import "RootViewController.h"
#import "MainViewController.h"

@implementation FlipsideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
       rootController:(RootViewController*)rootController_
       mainController:(MainViewController*)mainController_;
{
    if(![super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) return nil;
    rootController = rootController_;
    mainController = mainController_;
    
    return self;
}

- (void)viewDidLoad {
    ((FlipsideView*)self.view).image = [UIImage imageNamed:@"background.png"];
    first = [NSDate timeIntervalSinceReferenceDate];
    rotationTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(rotateWheels:) userInfo:nil repeats:YES];
    
    NSString *version = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleVersion"];
    versionLabel.text = [NSString stringWithFormat:@"v%@", version];
    
}

-(void)rotateWheels:(NSTimer*)caller;
{
    NSTimeInterval diff = [NSDate timeIntervalSinceReferenceDate] - first;
    cogU.transform = cogL.transform = CGAffineTransformMakeRotation(diff/4);
    cogM.transform = CGAffineTransformMakeRotation(-diff/2);
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	// Return YES for supported orientations
	return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void)didReceiveMemoryWarning {
	[super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
	// Release anything that's not essential, such as cached data
}


- (void)dealloc {
    [rotationTimer invalidate]; rotationTimer = nil;
	[super dealloc];
}


- (IBAction)toggleView:(id)sender;
{
    [rootController toggleView];
}
- (IBAction)newGame:(id)sender;
{
    UIAlertView *alert = 
    [[UIAlertView alloc] initWithTitle:@"Really start new game?"
                               message:@"This will empty your game board."
                              delegate:self
                     cancelButtonTitle:@"Cancel"
                     otherButtonTitles:@"New Game", nil]; // todo: use destructiveButtonTitle
    [alert show];
    [alert release];
}
- (IBAction)shuffleGame:(id)sender;
{
    UIAlertView *alert = 
    [[UIAlertView alloc] initWithTitle:@"Really shuffle?"
                               message:@"This will undo your current game board and replace it with a random board."
                              delegate:self
                     cancelButtonTitle:@"Cancel"
                     otherButtonTitles:@"Shuffle", nil]; // todo: use destructiveButtonTitle
    [alert show];
    [alert release];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if(buttonIndex == 0) return;

    if([alertView.title isEqualToString:@"Really shuffle?"])
        [mainController shuffle];
    else
        [mainController restart];
    [rootController toggleView];
}
- (IBAction)toggleGameBoardSize:(UISwitch*)sender;
{
    mainController.tinyGame = sender.on;
}
- (IBAction)toggleChaosGame:(UISwitch*)sender;
{
    mainController.chaosGame = sender.on;
}



@end
