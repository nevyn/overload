/*
 *  TypesAndConstants.h
 *  MobileOverload
 *
 *  Created by Joachim Bengtsson on 2008-08-18.
 *  Copyright 2008 Third Cog Software. All rights reserved.
 *
 */

extern const NSUInteger BoardWidth;
extern const NSUInteger BoardHeight;
extern const NSUInteger TileWidth;
extern const NSUInteger TileHeight;
extern const NSUInteger WidthInTiles; // = 10
extern const NSUInteger HeightInTiles; // = 12

typedef enum {
    PlayerNone,
    PlayerP1,
    PlayerP2
} Player;

typedef struct {
    NSUInteger x;
    NSUInteger y;
} BoardPoint;
CG_INLINE BoardPoint BoardPointMake(NSUInteger x, NSUInteger y) { BoardPoint p; p.x = x, p.y = y; return p; }

typedef struct {
    NSUInteger width;
    NSUInteger height;
} BoardSize;
CG_INLINE BoardSize BoardSizeMake(NSUInteger x, NSUInteger y) { BoardSize p; p.width = x, p.height = y; return p; }



extern const CGFloat ChargeEnergy;
extern const NSTimeInterval ExplosionDelay;
extern const NSTimeInterval ExplosionSpreadEnergy;

extern float frand(float max);


typedef struct {
    CGFloat values[10][12];
    Player  owners[10][12];
} BoardStruct;