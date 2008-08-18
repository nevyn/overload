//
//  BoardView.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-18.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardTile.h"

#import "TypesAndConstants.h"

extern NSTimeInterval BoardAnimationOccurredAt;
@class MainViewController;
@interface BoardView : UIView {
    BoardTile *boardTiles[10][12]; // [x][y]
    Player currentPlayer;
    MainViewController *controller;
    NSTimer *winningConditionTimer;
    BOOL gameEnded;
    
    BOOL chaosGame;
    BOOL tinyGame;

}
- (id)initWithFrame:(CGRect)frame controller:(MainViewController*)controller_;

-(BoardTile*)tile:(BoardPoint)point;

-(void)currentPlayerPerformCharge:(CGFloat)amount at:(BoardPoint)point;

@property Player currentPlayer;

-(void)updateScores;
-(void)scheduleWinningConditionCheck;

-(void)shuffle;
@property BOOL chaosGame;
@property BOOL tinyGame;

@end
