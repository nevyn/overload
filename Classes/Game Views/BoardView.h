//
//  BoardView.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-18.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BoardTileView.h"
#import "TypesAndConstants.h"

@protocol BoardViewDelegate
-(void)boardTileViewWasTouched:(BoardTileView*)boardTileView;
@end


@class BoardViewController;
@interface BoardView : UIView {
    BoardTileView *boardTiles[10][12]; // [x][y]
    BoardViewController *controller;
    
    BOOL sparkling;
    
    CGSize tileSize;
    BoardSize sizeInTiles;
    
    id<BoardViewDelegate> delegate;
}

-(BoardTileView*)tile:(BoardPoint)point;

-(void)setSize:(BoardSize)newSize;

@property BOOL sparkling; // for turning off sparkling when the game is inactive

@property (assign) id<BoardViewDelegate> delegate;
@property (readonly) CGSize tileSize;
@end
