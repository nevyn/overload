//
//  Network.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2009-03-16.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "OLClient.h"
#import "RemoteGame.h"
#import "UIColor-Expanded.h"


@interface OLClient ()
@property (readwrite, retain, nonatomic) AsyncSocket *socket;
-(void)dispatch:(OLMessage)msg;
@end

UInt16 OLDefaultPort = 14242;

static const int ReadLength = 0;
static const int ReadData = 1;

// TODO: Set timeouts and handle them


@implementation OLClient
-(id)initTo:(NSString*)host port:(UInt16)port;
{
	if( ! [super init] ) return nil;
	
	self.socket = [[[AsyncSocket alloc] initWithDelegate:self] autorelease];
	
	NSError *error;
	
	if( ! [self.socket connectToHost:host onPort:port error:&error] )
		NSLog(@"Failed to connect: %@", error);
	
	
	
	[socket readDataToLength:4 withTimeout:-1 tag:ReadLength];
	
	return self;
}

-(void)login:(NSString*)name color:(UIColor*)color;
{
	OLMessage loginMessage;
	loginMessage.type = OLLogin;
	NSString *devu = [UIDevice currentDevice].uniqueIdentifier;
	NSUInteger len;
	[devu getBytes:loginMessage.payload.login.deviceUUID maxLength:128 usedLength:&len encoding:NSUTF8StringEncoding options:0 range:NSMakeRange(0, devu.length) remainingRange:NULL];
	loginMessage.payload.login.deviceUUID[len] = 0;
	[name getBytes:loginMessage.payload.login.name maxLength:255 usedLength:&len encoding:NSUTF8StringEncoding options:0 range:NSMakeRange(0, name.length) remainingRange:NULL];
	loginMessage.payload.login.name[len] = 0;

	
	[color hue:&loginMessage.payload.login.color.hue
	saturation:&loginMessage.payload.login.color.saturation
	brightness:&loginMessage.payload.login.color.value
		 alpha:NULL];
	
	[self send:loginMessage];
		
}

#pragma mark 
#pragma mark Network callbacks
- (void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;
{
	if(tag == ReadLength) {
		uint32_t len;
		[data getBytes:&len length:4];
		len = CFSwapInt32BigToHost(len);
		[sock readDataToLength:len withTimeout:-1 tag:ReadData];
	} else if(tag == ReadData) {
		OLMessage newMessage;
		[data getBytes:&newMessage length:sizeof(newMessage)];
		
		[self dispatch:newMessage];
		
		[socket readDataToLength:4 withTimeout:-1 tag:ReadLength];
	}
}

#pragma mark Incoming
-(void)dispatch:(OLMessage)msg;
{
	if(msg.type & OLMessageTypeMessageDomain ||
	   msg.type & OLMessageTypeLobbyDomain)
		[gameController client:self receivedMessage:msg];
	if(msg.type & OLMessageTypeGameDomain)
		[game client:self receivedMessage:msg];
}

#pragma mark Outgoing
-(void)send:(OLMessage)msg;
{
	NSUInteger msgLength;
	switch (msg.type) {
		case OLLogin:
			msgLength = sizeof(msg.type) + sizeof(msg.payload.login);
			break;
		default:
			NSLog(@"Can't send message of type %d: Can't determine length", msg.type);
			return;
	}
	NSUInteger msgLengthSwapped = CFSwapInt32HostToBig(msgLength);
	
	NSMutableData *packet = [NSMutableData dataWithBytes:&msgLengthSwapped length:4];
	[packet appendBytes:&msg length:msgLength];
	
	[socket writeData:packet withTimeout:-1 tag:0];
}

#pragma mark Properties
@synthesize game;
@synthesize socket;
@synthesize gameController;


@end
