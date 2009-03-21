//
//  RemoteGame.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2009-03-15.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Game.h"
#import "OLClient.h"

@interface RemoteGame : Game <OLClientClient> {
	OLClient *client;
}
-(id)init;

@property (assign) OLClient *client;
@end
