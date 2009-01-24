//
//  BoardView.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-18.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TypesAndConstants.h"
#ifndef BOARDVIEW_OPENGL
#import "BoardTileView.h"
#endif
@protocol BoardViewDelegate
-(void)boardTileViewWasTouched:(BoardPoint)pointThatWasTouched;
@end


@interface BoardView : UIView {    
    CGSize tileSize;
    BoardSize sizeInTiles;
    
    id<BoardViewDelegate> delegate;
    
#ifndef BOARDVIEW_OPENGL
    BoardTileView *boardTiles[10][12]; // [x][y]
#endif
}

-(void)setValue:(CGFloat)v atPosition:(BoardPoint)p;
-(void)setOwner:(Player)player atPosition:(BoardPoint)p;
-(void)explode:(BoardPoint)explodingTile;


@property (assign, nonatomic) BoardSize sizeInTiles;
@property (assign, nonatomic) id<BoardViewDelegate> delegate;
@property (readonly, nonatomic) CGSize tileSize;
@end
