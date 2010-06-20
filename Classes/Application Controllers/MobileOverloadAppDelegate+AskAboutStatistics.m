//
//  MobileOverloadAppDelegate+AskAboutStatistics.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2009-06-14.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "MobileOverloadAppDelegate+AskAboutStatistics.h"
#import "MobileOverloadAppDelegate.h"
#import "Beacon+OptIn.h"

static UIAlertView *askAboutStatistics;
static UIAlertView *sayPlease;


@implementation MobileOverloadAppDelegate (AskAboutStatistics)
-(void)askAboutStatistics;
{
	askAboutStatistics = 
	[[UIAlertView alloc] initWithTitle:@"May I collect usage statistics?"
														 message:@"The anonymous statistics are sent through the internet.\n\n The statistics collected help guide Overload's development."
														delegate:self
									 cancelButtonTitle:nil
									 otherButtonTitles:@"Collect", @"Do not collect", @"Read more", nil];
	
	[askAboutStatistics show];    
}

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
@end
