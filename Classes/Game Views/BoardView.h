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

@interface BoardView : UIView {
    BoardTile *boardTiles[10][12]; // [x][y]
    Player currentPlayer;
}

-(BoardTile*)tile:(BoardPoint)point;

-(void)currentPlayerPerformCharge:(CGFloat)amount at:(BoardPoint)point;

@property Player currentPlayer;

@end
