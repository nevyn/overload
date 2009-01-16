//
//  FlipsideViewController.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-12.
//  Copyright Third Cog Software 2008. All rights reserved.
//

#import "FlipsideViewController.h"
#import "RootViewController.h"
#import "BoardViewController.h"
#import "CInvocationGrabber.h"
#import "Beacon.h"
#import <MediaPlayer/MediaPlayer.h>

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
    
    first = [NSDate timeIntervalSinceReferenceDate];
    
    NSString *version = [[[NSBundle mainBundle]infoDictionary]objectForKey:@"CFBundleVersion"];
    versionLabel.text = [NSString stringWithFormat:@"v%@", version];
    
    chaosGame.on = mainController.board.chaosGame;
    giganticGame.on = ! mainController.board.tinyGame;
    soundSwitch.on = mainController.soundPlayer.sound;
}
-(void)startRotatingWheels;
{
    rotationTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(rotateWheels:) userInfo:nil repeats:YES];
}
-(void)viewWillAppear:(BOOL)yeah;
{
    [self startRotatingWheels];
}
-(void)viewDidDisappear:(BOOL)yeah;
{
    [rotationTimer invalidate]; rotationTimer = nil;
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
    UIActionSheet *sheet = 
    [[[UIActionSheet alloc] initWithTitle:@"Really start new game?"
                              delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:@"New Game"
                      otherButtonTitles:nil] autorelease]; // todo: use destructiveButtonTitle
    [sheet showInView:self.view];
}

#define SHUFFLE_TITLE @"Really shuffle? Every tile will be randomized."
- (IBAction)shuffleGame:(id)sender;
{
    UIActionSheet *sheet = 
    [[[UIActionSheet alloc] initWithTitle:SHUFFLE_TITLE
                              delegate:self
                     cancelButtonTitle:@"Cancel"
                     destructiveButtonTitle:@"Shuffle"
                      otherButtonTitles:nil] autorelease]; // todo: use destructiveButtonTitle
    [sheet showInView:self.view];
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if(buttonIndex == 1) return;

    if([actionSheet.title isEqualToString:SHUFFLE_TITLE]) {
        [[Beacon shared] startSubBeaconWithName:@"Shuffled Local Game from Options" timeSession:NO];
        schedule(mainController.board, shuffle);
    } else {
        [[Beacon shared] startSubBeaconWithName:@"Restarted Local Game from Options" timeSession:NO];
        schedule(mainController.board, restart);
    }
    [self toggleView:nil];
}
- (IBAction)toggleGameBoardSize:(UISwitch*)sender;
{
    {
        BoardSize newSize = (!sender.on) ?
            BoardSizeMake(WidthInTiles/2, HeightInTiles/2) :
            BoardSizeMake(WidthInTiles, HeightInTiles);
        [[Beacon shared] startSubBeaconWithName:[NSString stringWithFormat:@"Switched to local game board size %dx%d", newSize.width, newSize.height] timeSession:NO];
    }

    schedule(mainController.board, setTinyGame:!sender.on);
}
- (IBAction)toggleChaosGame:(UISwitch*)sender;
{
    [[Beacon shared] startSubBeaconWithName:[NSString stringWithFormat:@"Switched local chaos game %@", sender.on?@"on":@"off"] timeSession:NO];

    mainController.board.chaosGame = sender.on;
}

- (IBAction)toggleSound:(UISwitch*)sender;
{
    [[Beacon shared] startSubBeaconWithName:[NSString stringWithFormat:@"Switched sound %@", sender.on?@"on":@"off"] timeSession:NO];
    
    mainController.soundPlayer.sound = sender.on;
}

@end
