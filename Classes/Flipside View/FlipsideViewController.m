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
#import "Beacon+OptIn.h"
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
    boardSize.value = mainController.board.sizeInTiles.width/(float)WidthInTiles;
    soundSwitch.on = mainController.soundPlayer.sound;

    [self updateSizeLabel:mainController.board.sizeInTiles];
}
-(void)startRotatingWheels;
{
    rotationTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(rotateWheels:) userInfo:nil repeats:YES];
}
-(void)viewWillAppear:(BOOL)yeah;
{
    newBoardSize = BoardSizeMake(-1, -1);
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
    if(newBoardSize.width != -1) {
        [[Beacon sharedIfOptedIn] startSubBeaconWithName:[NSString stringWithFormat:@"Board size > %dx%d", newBoardSize.width, newBoardSize.height] timeSession:NO];
        
        if(mainController.board.hasEnded)
            schedule(mainController.board, restart);
        schedule(mainController.board, setSizeInTiles:newBoardSize);
    }
    
    
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
    // TODO: release it?
}
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if(buttonIndex == 1) return;

    if([actionSheet.title isEqualToString:SHUFFLE_TITLE]) {
        [[Beacon sharedIfOptedIn] startSubBeaconWithName:@"Shuffled Local Game from Options" timeSession:NO];
        schedule(mainController.board, restart);
        schedule(mainController.board, shuffle);
    } else {
        [[Beacon sharedIfOptedIn] startSubBeaconWithName:@"Restarted Local Game from Options" timeSession:NO];
        schedule(mainController.board, restart);
    }
    [self toggleView:nil];
}
-(void)updateSizeLabel:(BoardSize)size;
{
    NSString *estimatedTime;
    switch(size.width) {
        case 2:  estimatedTime = @"10s"; break;
        case 3:  estimatedTime = @"10s"; break;
        case 4:  estimatedTime = @"1min"; break;
        case 5:  estimatedTime = @"5min"; break;
        case 6:  estimatedTime = @"5min"; break;
        case 7:  estimatedTime = @"10min"; break;
        case 8:  estimatedTime = @"30min"; break;
        case 9:  estimatedTime = @"1.5h"; break;
        default:
        case 10: estimatedTime = @"2h"; break;
    }
    [sizeLabel setText:[NSString stringWithFormat:@"%dx%d%@\n%@",
                        size.width, size.height, ((size.width==5&&size.height==6)?@" (default)":@""),
                        estimatedTime]];
    
}
- (IBAction)setGameBoardSize:(UISlider*)sender;
{
    newBoardSize = BoardSizeMake(WidthInTiles*sender.value, HeightInTiles*sender.value);
    [self updateSizeLabel:newBoardSize];
}
- (IBAction)toggleChaosGame:(UISwitch*)sender;
{
    [[Beacon sharedIfOptedIn] startSubBeaconWithName:[NSString stringWithFormat:@"Chaos game > %@", sender.on?@"on":@"off"] timeSession:NO];

    mainController.board.chaosGame = sender.on;
}

- (IBAction)toggleSound:(UISwitch*)sender;
{
    [[Beacon sharedIfOptedIn] startSubBeaconWithName:[NSString stringWithFormat:@"Switched sound %@", sender.on?@"on":@"off"] timeSession:NO];
    
    mainController.soundPlayer.sound = sender.on;
}

@end
