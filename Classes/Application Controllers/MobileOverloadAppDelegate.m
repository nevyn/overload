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
#import "CollectionUtils.h"

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
}
#pragma mark 
#pragma mark Launch, paranoidTimer
- (void)applicationDidFinishLaunching:(UIApplication *)application {
    if([window respondsToSelector:@selector(setRootViewController:)])
        [window setRootViewController:rootViewController];
    else
        [window addSubview:[rootViewController view]];
	[window makeKeyAndVisible];
    
    paranoidTimer = [[NSTimer scheduledTimerWithTimeInterval:10.0 target:self selector:@selector(paranoid) userInfo:nil repeats:YES] retain];
    
    NSUserDefaults *defs = [NSUserDefaults standardUserDefaults];
    NSInteger startCount = [defs integerForKey:@"startCount"] + 1;
    [defs setInteger:startCount forKey:@"startCount"];
}
#pragma mark 
#pragma mark Launch/quit/saving settings
- (void)applicationWillResignActive:(UIApplication *)application;
{
    [self.rootViewController.mainViewController.board persist];
    [[NSUserDefaults standardUserDefaults] synchronize];
}
- (void)applicationWillTerminate:(UIApplication *)application;
{
    [self.rootViewController.mainViewController.board persist];
    [[NSUserDefaults standardUserDefaults] synchronize];
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
