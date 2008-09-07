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
#import "BoardViewController.h"
#import "CInvocationGrabber.h"

#define schedule(target, stuff) {\
    id grabber = [[CInvocationGrabber invocationGrabber] prepareWithInvocationTarget:target]; \
    [grabber stuff]; \
    [stuffToDoWhenFlipped addObject:[grabber invocation]];\
}


@implementation FlipsideViewController

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
       rootController:(RootViewController*)rootController_
       mainController:(BoardViewController*)mainController_;
{
    if(![super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) return nil;
    rootController = rootController_;
    mainController = mainController_;
    
    stuffToDoWhenFlipped = [[NSMutableArray alloc] init];
    
    return self;
}

- (void)viewDidLoad {
    ((FlipsideView*)self.view).image = [UIImage imageNamed:@"background.png"];
    first = [NSDate timeIntervalSinceReferenceDate];
    rotationTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(rotateWheels:) userInfo:nil repeats:YES];
    
    NSString *version = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleVersion"];
    versionLabel.text = [NSString stringWithFormat:@"v%@", version];
    
    chaosGame.on = mainController.board.chaosGame;
    giganticGame.on = ! mainController.board.tinyGame;
    soundSwitch.on = mainController.soundPlayer.sound;

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
    [stuffToDoWhenFlipped release]; stuffToDoWhenFlipped = nil;
	[super dealloc];
}


- (IBAction)toggleView:(id)sender;
{
    for (NSInvocation *invocation in stuffToDoWhenFlipped) {
        [invocation performSelector:@selector(invoke) withObject:nil afterDelay:1.1];
    }
    [stuffToDoWhenFlipped removeAllObjects];
    [rootController toggleView];
}
- (IBAction)newGame:(id)sender;
{
    UIAlertView *alert = 
    [[[UIAlertView alloc] initWithTitle:@"Really start new game?"
                               message:@"This will empty your game board."
                              delegate:self
                     cancelButtonTitle:@"Cancel"
                     otherButtonTitles:@"New Game", nil] autorelease]; // todo: use destructiveButtonTitle
    [alert show];
}
- (IBAction)shuffleGame:(id)sender;
{
    UIAlertView *alert = 
    [[[UIAlertView alloc] initWithTitle:@"Really shuffle?"
                               message:@"This will undo your current game board and replace it with a random board."
                              delegate:self
                     cancelButtonTitle:@"Cancel"
                     otherButtonTitles:@"Shuffle", nil] autorelease]; // todo: use destructiveButtonTitle
    [alert show];
}
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if(buttonIndex == 0) return;

    if([alertView.title isEqualToString:@"Really shuffle?"]) {
        schedule(mainController.board, shuffle);
    } else {
        schedule(mainController.board, restart);
    }
    [self toggleView:nil];
}
- (IBAction)toggleGameBoardSize:(UISwitch*)sender;
{
    schedule(mainController.board, setTinyGame:!sender.on);
}
- (IBAction)toggleChaosGame:(UISwitch*)sender;
{
    mainController.board.chaosGame = sender.on;
}

- (IBAction)toggleSound:(UISwitch*)sender;
{
    mainController.soundPlayer.sound = sender.on;
}


@end
