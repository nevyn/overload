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
@interface BoardTile : UIView {
    Player owner;
    CGFloat value;
    BoardPoint boardPosition;
    BoardView *board;
}
@property Player owner;
@property CGFloat value;
@property BoardPoint boardPosition;
@property (assign) BoardView *board;

-(void)charge:(CGFloat)amount;
-(void)charge:(CGFloat)amount forPlayer:(Player)newOwner;
-(void)explode;
@end
