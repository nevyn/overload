//
//  MobileOverloadAppDelegate.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-12.
//  Copyright Third Cog Software 2008. All rights reserved.
//

#import "MobileOverloadAppDelegate.h"
#import "RootViewController.h"
#import "MainViewController.h"

@implementation MobileOverloadAppDelegate


@synthesize window;
@synthesize rootViewController;


- (void)applicationDidFinishLaunching:(UIApplication *)application {
	
	[window addSubview:[rootViewController view]];
	[window makeKeyAndVisible];
}
- (void)applicationWillTerminate:(UIApplication *)application;
{
    [self.rootViewController.mainViewController persistBoard];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)dealloc {
	[rootViewController release];
	[window release];
	[super dealloc];
}

@end
