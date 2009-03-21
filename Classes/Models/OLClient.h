//
//  Network.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2009-03-16.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "TypesAndConstants.h"
@class RemoteGame;

extern UInt16 OLDefaultPort;

typedef struct {
	enum {
		OLMessageTypeMessageDomain = 0x01000,
		
		OLMessageTypeLobbyDomain = 0x02000,
		
		OLMessageTypeGameDomain  = 0x03000,
		OLFullBoard				 = 0x03001,
		OLTileUpdated			 = 0x03002,
		OLTileWillExplode		 = 0x03003,
		
		OLMessageTypeOutgoingDomain = 0x10000,
		OLLogin = 0x10001,
		
		OLChargeAt				 = 0x13001,
		
	} type;
	
	union {
		// Error domain
		
		
		// Lobby domain
		
		// Game domain
		struct {
			BoardStruct bs;
		} fullBoard;
		struct {
			BoardPoint pos;
			Player  owner;
			CGFloat value;
		} tileUpdated;
		struct {
			BoardPoint pos;
		} tileWillExplode;
		
		// Outgoing domain
		struct {
			char deviceUUID[128];
			char name[256];
			struct {
				CGFloat hue;
				CGFloat saturation;
				CGFloat value;
			} color;
		} login;
		
		struct {
			BoardPoint pos;
		} chargeAt;
	} payload;
} OLMessage;

@class OLClient;
@protocol OLClientClient
-(void)client:(OLClient*)client receivedMessage:(OLMessage)msg;
@end

@class BoardViewController;
@interface OLClient : NSObject {
	AsyncSocket *socket;
	RemoteGame *game;
	BoardViewController *gameController;
}
-(id)initTo:(NSString*)host port:(UInt16)port;

-(void)login:(NSString*)name color:(UIColor*)color;

-(void)send:(OLMessage)msg;

@property (assign, nonatomic) RemoteGame *game;
@property (assign, nonatomic) BoardViewController *gameController;
@end
