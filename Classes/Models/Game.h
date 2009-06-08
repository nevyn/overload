//
//  Game.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2009-03-15.
//  Copyright 2009 Third Cog Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Board.h"
#import "TypesAndConstants.h"

@class AI;
@interface Game : NSObject <BoardDelegate> {
	Board *board;
	NSMutableArray *players;
	AI *ai;
	
	id delegate;
}
-(id)init;
-(void)load;
-(void)persist;
-(void)update;

#pragma mark Gameplay
-(BOOL)hasEnded;
-(void)restart;
-(void)shuffle;
-(BOOL)canMakeMoveNow;
-(BOOL)makeMoveForCurrentPlayer:(BoardPoint)actionPoint;


#pragma mark AI
-(void)startAI;
-(void)stopAI;

#pragma mark Properties
@property PlayerID currentPlayer;
@property (readonly, nonatomic) Board *board;
@property (readwrite, assign, nonatomic) id delegate;

@end
