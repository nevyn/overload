//
//  MobileOverloadAppDelegate.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-12.
//  Copyright Third Cog Software 2008. All rights reserved.
//

#import "MobileOverloadAppDelegate.h"
#import "GameViewController.h"
#import "Beacon+OptIn.h"
#import "CollectionUtils.h"
#import "MobileOverloadAppDelegate+AskAboutStatistics.h"

@interface GameViewController (BoardViewHack)
@property (readonly, nonatomic) BoardView *boardView;
@end
@implementation GameViewController (BoardViewHack)
-(BoardView*)boardView; { return boardView; }
@end
@interface BoardView (BoardViewPrivate)
-(void)relayoutTiles;
@end


@implementation MobileOverloadAppDelegate
@synthesize window;
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
		$array($object(WidthInTiles/2), $object(HeightInTiles/2)), @"boardSize",
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
#pragma mark Launch and paranoidTimer
- (void)applicationDidFinishLaunching:(UIApplication *)application;
{
	
	// 1. Setup views
	[window addSubview:nav.view];
	[window makeKeyAndVisible];
	
	// 2. Figure out if this is the first run
	
	NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
	NSInteger startCount = [defs integerForKey:@"startCount"] + 1;
	[defs setInteger:startCount forKey:@"startCount"];
	
	
	if(startCount > 1) {
		if( ! [defs boolForKey:@"hasAskedAboutStatistics"] ) {
			[self askAboutStatistics];
		}
	}
	
	// 3. Setup the Paranoid timer (autosaves every n secs)
	paranoidTimer = [[NSTimer scheduledTimerWithTimeInterval:10.0
																										target:self
																									selector:@selector(paranoid)
																									userInfo:nil
																									 repeats:YES] retain];
	
	
}

#pragma mark 
#pragma mark Launch/quit/saving settings
- (void)applicationWillResignActive:(UIApplication *)application;
{
#warning AppDelegate can't save settings anymore
	//[self.rootViewController.mainViewController.game persist];
	[[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)applicationDidBecomeActive:(UIApplication *)application;
{
	// ...
}
- (void)applicationWillTerminate:(UIApplication *)application;
{
#warning AppDelegate can't save settings anymore
	//[self.rootViewController.mainViewController.game persist];
	[[NSUserDefaults standardUserDefaults] synchronize];
	[[Beacon sharedIfOptedIn] endBeacon];
}
- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
{
#warning AppDelegate can't save settings anymore
	//[self.rootViewController.mainViewController.boardView relayoutTiles];
}

- (void)dealloc {
	[paranoidTimer invalidate]; [paranoidTimer release]; paranoidTimer = nil;
	[window release];
	[super dealloc];
}

-(void)paranoid;
{
#warning AppDelegate can't save settings anymore
	//[self.rootViewController.mainViewController.game persist];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

@end
