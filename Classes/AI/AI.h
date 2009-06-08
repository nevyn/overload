//
//  AI.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-09-07.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Board.h"
#import "GameViewController.h"
#import "TypesAndConstants.h"

@interface AI : NSObject {
	Game *game;
    PlayerID player;
    PlayerID opponent;
}
-(id)initPlaying:(PlayerID)player_ onGame:(Game*)game;

-(void)performMove;

// Override these:
-(void)player:(PlayerID)player choseTile:(BoardPoint)boardPoint;
-(BoardPoint)chooseTile;

@property (assign, nonatomic) Game *game;
@property (assign, nonatomic) PlayerID player;

-(NSArray*)randomBoardTiles;
@end
