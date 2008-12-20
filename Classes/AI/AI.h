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
    Board *board;
    id<BoardViewDelegate> delegate;
    Player player;
    Player opponent;
}
-(id)initPlaying:(Player)player_ onBoard:(Board*)board_ delegate:(id<BoardViewDelegate>)delegate_;

-(void)performMove;

// Override these:
-(void)player:(Player)player choseTile:(BoardPoint)boardPoint;
-(BoardPoint)chooseTile;

@property (assign) Board *board;
@property (assign) id<BoardViewDelegate> delegate;
@property (assign) Player player;

-(NSArray*)randomBoardTiles;
@end
