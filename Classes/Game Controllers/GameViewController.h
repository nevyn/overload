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
@interface GameViewController : UIViewController
<BoardDelegate, BoardViewDelegate, ScoreBarViewDelegate>
{
  StatusBarView *status;
	ScoreIndicator *score;
  UIImageView *winPlaque, *losePlaque;
    
  OLSoundPlayer *soundPlayer;
    
  BoardView *boardView;
	Game *game;

	NSTimer *heartbeat;
}
// This class is abstract; use one of the GGC subclasses
-(id)init;

-(void)layout; // override this in subclasses

#pragma mark Properties
@property (readonly, nonatomic) OLSoundPlayer *soundPlayer;
@property (readonly, nonatomic) Game *game;
@end
