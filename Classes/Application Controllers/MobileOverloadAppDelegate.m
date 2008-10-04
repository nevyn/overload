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


- (void)applicationDidFinishLaunching:(UIApplication *)application {
    NSString *applicationCode = @"f41f960eeef940e4f2bbc28259d1165c";
    [Beacon initAndStartBeaconWithApplicationCode:applicationCode useCoreLocation:NO];

    
	[window addSubview:[rootViewController view]];
	[window makeKeyAndVisible];
}
- (void)applicationWillTerminate:(UIApplication *)application;
{
    [self.rootViewController.mainViewController.board persist];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [[Beacon shared] endBeacon];
}

- (void)dealloc {
	[rootViewController release];
	[window release];
	[super dealloc];
}

@end
