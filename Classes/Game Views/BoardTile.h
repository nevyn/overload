//
//  BoardTile.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-17.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    OwnerNone,
    OwnerP1,
    OwnerP2
} TileOwner;

const static NSTimeInterval kOLExplosionDelay = 0.05;
const static NSTimeInterval kOLExplosionSpreadEnergy = 0.25;


@interface BoardTile : UIView {
    TileOwner owner;
    CGFloat value;
}
@property TileOwner owner;
@property CGFloat value;
@end
