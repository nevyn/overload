//
//  RemoteGame.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2009-03-15.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import "RemoteGame.h"



@implementation RemoteGame
-(id)init;
{
	return [super init];
}
-(void)client:(OLClient*)client receivedMessage:(OLMessage)msg;
{
	if(msg.type == OLFullBoard) {
		self.board.board = msg.payload.fullBoard.bs;
	} else if(msg.type == OLTileUpdated) {
		Tile *t = [self.board tile:msg.payload.tileUpdated.pos];
		t.owner = msg.payload.tileUpdated.owner;
		t.value = msg.payload.tileUpdated.value;
	} else if (msg.type == OLTileExploded) {
		Tile *t = [self.board tile:msg.payload.tileExploded.pos];
		[board.delegate tileExploded:t];
		
	} else if (msg.type == OLTileWillExplode) {
		Tile *t = [self.board tile:msg.payload.tileWillExplode.pos];
		[board.delegate tileWillSoonExplode:t];
		
	} else if(msg.type == OLPlayerChargedTile) {
		Tile *t = [self.board tile:msg.payload.playerChargedTile.pos];
		CGFloat newValue = msg.payload.playerChargedTile.newValue;
		Player player = msg.payload.playerChargedTile.chargingPlayer;
		
		[delegate tile:t wasChargedTo:newValue byPlayer:player];

	}
}

-(BOOL)canMakeMoveNow;
{
	// Todo: Query server?
	return YES;
}
-(BOOL)makeMoveForCurrentPlayer:(BoardPoint)actionPoint;
{
	OLMessage msg;
	msg.type = OLChargeAt;
	msg.payload.chargeAt.pos = actionPoint;
	[client send:msg payloadLength:sizeof(msg.payload.chargeAt)];
	
	return YES; // todo: wait for reply?
}
@synthesize client;
@end
