//
//  Beacon+OptIn.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2009-01-22.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Beacon.h"

@interface Beacon (OptIn)
// Returns [Beacon shared] if the default collectStatistics is YES
+(id)sharedIfOptedIn;
@end
