//
//  AI.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-09-07.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Board.h"
#import "BoardViewController.h"
#import "TypesAndConstants.h"

@interface AI : NSObject {
	Game *game;
    Player player;
    Player opponent;
}
-(id)initPlaying:(Player)player_ onGame:(Game*)game;

-(void)performMove;

// Override these:
-(void)player:(Player)player choseTile:(BoardPoint)boardPoint;
-(BoardPoint)chooseTile;

@property (assign, nonatomic) Game *game;
@property (assign, nonatomic) Player player;

-(NSArray*)randomBoardTiles;
@end
