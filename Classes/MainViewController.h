//
//  MainViewController.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-12.
//  Copyright Third Cog Software 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ScoreBarView.h"
#import "TypesAndConstants.h"
@class BoardView;
@interface MainViewController : UIViewController {
    ScoreBarView *score1, *score2;
    BoardView *boardView;
    BOOL chaosGame, tinyGame;
    UIImageView *winPlaque, *losePlaque;
}
-(void)setScores:(CGFloat[])scores;
-(void)setCurrentPlayer:(Player)player;
-(void)setWinner:(Player)player;

-(void)restart;
-(void)shuffle;

-(void)persistBoard;
-(void)loadBoard;

@property BOOL chaosGame;
@property BOOL tinyGame;
@end
