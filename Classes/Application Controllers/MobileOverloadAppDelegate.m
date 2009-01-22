//
//  MobileOverloadAppDelegate.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-12.
//  Copyright Third Cog Software 2008. All rights reserved.
//

#import "MobileOverloadAppDelegate.h"
#import "RootViewController.h"
#import "BoardViewController.h"
#import "Beacon+OptIn.h"

@interface BoardViewController (BoardViewHack)
@property (readonly, nonatomic) BoardView *boardView;
@end
@implementation BoardViewController (BoardViewHack)
-(BoardView*)boardView; { return boardView; }
@end
@interface BoardView (BoardViewPrivate)
-(void)relayoutTiles;
@end


@implementation MobileOverloadAppDelegate
@synthesize window;
@synthesize rootViewController;
NSString *applicationCode = @"f41f960eeef940e4f2bbc28259d1165c";

+(void)startBeacon;
{
    if( [[NSUserDefaults standardUserDefaults] boolForKey:@"collectStatistics"] )
        [Beacon initAndStartBeaconWithApplicationCode:applicationCode useCoreLocation:YES];
}

+(void)initialize;
{
    [[NSUserDefaults standardUserDefaults] registerDefaults:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [NSNumber numberWithBool:YES], @"tinyGame",
      [NSNumber numberWithBool:NO], @"chaosGame",
      [NSNumber numberWithBool:YES], @"sound",
      [NSNumber numberWithInt:PlayerP1], @"currentPlayer",
      [NSNumber numberWithInt:0], @"startCount",
      [NSNumber numberWithBool:NO], @"collectStatistics",
      [NSNumber numberWithBool:NO], @"collectStatisticsJustOncePerVersion",
      [NSNumber numberWithBool:NO], @"hasAskedAboutStatistics",
      nil, nil
      ]
     ];
    [self startBeacon];
}
#pragma mark 
#pragma mark Launch, paranoidTimer, asking about statistics
static UIAlertView *askAboutStatistics;
-(void)askAboutStatistics;
{
    askAboutStatistics = 
    [[UIAlertView alloc] initWithTitle:@"May I collect usage statistics?"
                               message:@"The statistics are sent through the internet, but are completely anonymous. The statistics collected help guide Overload's development. Press 'Read more' for exact details.\n\n\n "
                              delegate:self
                     cancelButtonTitle:nil
                     otherButtonTitles:@"Yes", @"No", @"Read more", nil];
    
    [askAboutStatistics show];    
}
- (void)applicationDidFinishLaunching:(UIApplication *)application {
    [window addSubview:[rootViewController view]];
	[window makeKeyAndVisible];
    
    paranoidTimer = [[NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(paranoid) userInfo:nil repeats:YES] retain];
    
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSInteger startCount = [defs integerForKey:@"startCount"] + 1;
    [defs setInteger:startCount forKey:@"startCount"];

    if(startCount > 1) {
        if( ! [defs boolForKey:@"hasAskedAboutStatistics"] ) {
            [self askAboutStatistics];
        }
    }
}
static UIAlertView *sayPlease;
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if(alertView == askAboutStatistics) {
        if(buttonIndex == 0) { // yes
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasAskedAboutStatistics"];
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"collectStatistics"];
            [[self class] startBeacon];

        } else if(buttonIndex == 1) { // no
            sayPlease = 
                [[UIAlertView alloc] initWithTitle:@"Just once?"
                                           message:@"May I just record the fact that I have one more user? Nothing else will be sent again, ever."
                                          delegate:self
                                 cancelButtonTitle:nil
                                 otherButtonTitles:@"Just once.", @"Never send anything", @"Go back", nil];
            
            [sayPlease show];
            
        } else { // More info
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://thirdcog.eu/overload/analytics/"]];
        }
        [askAboutStatistics release]; askAboutStatistics = nil;
    } else {
        if(buttonIndex == 2) { //Go back
            [self askAboutStatistics];
        } else {
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasAskedAboutStatistics"];
            [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"collectStatistics"];

            if(buttonIndex == 0) {// Yeah, just once
                NSLog(@"Sending Pinch Analytics data once only.");
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"collectStatisticsJustOncePerVersion"];
                [Beacon initAndStartBeaconWithApplicationCode:applicationCode useCoreLocation:YES];
            }
            // else == 2 == No, never
        }
        [sayPlease release]; sayPlease = nil;
    }
}
#pragma mark 
#pragma mark Launch/quit/saving settings
- (void)applicationWillResignActive:(UIApplication *)application;
{
    [self.rootViewController.mainViewController.board persist];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)applicationDidBecomeActive:(UIApplication *)application;
{
    // ...
}
- (void)applicationWillTerminate:(UIApplication *)application;
{
    [self.rootViewController.mainViewController.board persist];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[Beacon sharedIfOptedIn] endBeacon];
}
- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
{
    [self.rootViewController.mainViewController.boardView relayoutTiles];
}

- (void)dealloc {
    [paranoidTimer invalidate]; [paranoidTimer release]; paranoidTimer = nil;
	[rootViewController release];
	[window release];
	[super dealloc];
}

-(void)paranoid;
{
    [self.rootViewController.mainViewController.board persist];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
