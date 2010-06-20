//
//  GVCOnline.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2009-06-14.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GameViewController.h"

@interface GVCOnline : GameViewController <OLClientClient> {
	OLClient *client;
}

@end
