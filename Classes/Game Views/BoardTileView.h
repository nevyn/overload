//
//  BoardTile.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-17.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TypesAndConstants.h"

@class BoardView;
@interface BoardTileView : UIView {
    BoardPoint boardPosition;
    BoardView *board;
    
    Player owner;
    CGFloat value;
}
@property Player owner;
@property CGFloat value;
@property BoardPoint boardPosition;
@property (assign) BoardView *board;

-(void)explode;
@end
