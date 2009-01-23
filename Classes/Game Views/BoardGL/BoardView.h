//
//  BoardView.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-18.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TypesAndConstants.h"

@protocol BoardViewDelegate
-(void)boardTileViewWasTouched:(BoardPoint)pointThatWasTouched;
@end


@interface BoardView : UIView {    
    CGSize tileSize;
    BoardSize sizeInTiles;
    
    id<BoardViewDelegate> delegate;
}

-(void)setValue:(CGFloat)v atPosition:(BoardPoint)p;
-(void)setOwner:(Player)p atPosition:(BoardPoint)p;
-(void)explode:(BoardPoint)explodingTile;


-(BoardSize)size;
-(void)setSize:(BoardSize)newSizeInTiles;

@property (assign, nonatomic) id<BoardViewDelegate> delegate;
@property (readonly, nonatomic) CGSize tileSize;
@end
