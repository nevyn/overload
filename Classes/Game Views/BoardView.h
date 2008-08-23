//
//  BoardView.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-18.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardTile.h"
#import <AudioToolbox/AudioToolbox.h>
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
    
    BOOL sparkling;
    
    CGSize tileSize;
    BoardSize sizeInTiles;
#if TARGET_IPHONE_SIMULATOR
    SystemSoundID explosion, charge25, charge50, charge75, charge100, win;
#endif
}
- (id)initWithFrame:(CGRect)frame controller:(MainViewController*)controller_;

-(BoardTile*)tile:(BoardPoint)point;

-(void)currentPlayerPerformCharge:(CGFloat)amount at:(BoardPoint)point;

@property Player currentPlayer;

-(void)updateScores;
-(void)scheduleWinningConditionCheck;
-(void)checkWinningCondition:(NSTimer*)sender;

-(void)shuffle;

-(BOOL)isBoardEmpty;
-(BOOL)hasGameEnded;
@property BOOL chaosGame;
@property BOOL tinyGame;
@property BOOL sparkling; // for turning off sparkling when the game is inactive

@property (readonly) CGSize tileSize;
@property (readonly) BoardSize sizeInTiles;

@property BoardStruct boardStruct;


-(void)playChargeSound:(CGFloat)chargeLevel;
-(void)playExplosionSound;
-(void)playWinSound;

@end
