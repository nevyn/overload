//
//  BoardViewController.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-12.
//  Copyright Third Cog Software 2008. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StatusBarView.h"
#import "TypesAndConstants.h"
#import "BoardView.h"
#import "OLSoundPlayer.h"
#import "Game.h"
#import "OLClient.h"

@class OLClient;
@interface BoardViewController : UIViewController <BoardDelegate, BoardViewDelegate, ScoreBarViewDelegate, OLClientClient> {
    StatusBarView *status;
	ScoreIndicator *score;
    UIImageView *winPlaque, *losePlaque;
    
    OLSoundPlayer *soundPlayer;
    
    BoardView *boardView;
	Game *game;
	OLClient *client;

    NSTimer *heartbeat;
}

#pragma mark Properties
@property (readonly, nonatomic) OLSoundPlayer *soundPlayer;
@property (readonly, nonatomic) Game *game;
@end
