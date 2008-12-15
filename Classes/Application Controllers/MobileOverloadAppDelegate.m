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
#import "Beacon.h"


@implementation MobileOverloadAppDelegate


@synthesize window;
@synthesize rootViewController;
+(void)initialize;
{
    NSString *applicationCode = @"f41f960eeef940e4f2bbc28259d1165c";
    [Beacon initAndStartBeaconWithApplicationCode:applicationCode useCoreLocation:YES];
}

- (void)applicationDidFinishLaunching:(UIApplication *)application {
    [window addSubview:[rootViewController view]];
	[window makeKeyAndVisible];
    
    paranoidTimer = [[NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(paranoid) userInfo:nil repeats:YES] retain];
}
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
    [[Beacon shared] endBeacon];
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
