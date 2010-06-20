//
//  MobileOverloadAppDelegate.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-12.
//  Copyright Third Cog Software 2008. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface MobileOverloadAppDelegate : NSObject <UIApplicationDelegate> {
	IBOutlet UIWindow *window;
	IBOutlet UINavigationController *nav;
  NSTimer *paranoidTimer; // continually persists board
}
+(void)startBeacon;

@property (nonatomic, retain) UIWindow *window;
@end

extern NSString *applicationCode;