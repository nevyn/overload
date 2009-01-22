//
//  Beacon+OptIn.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2009-01-22.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "Beacon+OptIn.h"


@implementation Beacon (OptIn)
+(id)sharedIfOptedIn;
{
    BOOL optedIn = [[NSUserDefaults standardUserDefaults] boolForKey:@"collectStatistics"];
    // No need to check if we have asked about stats, because the above defaults to NO
    
    if(optedIn)
        return [Beacon shared];
    else
        return nil;
}
@end
