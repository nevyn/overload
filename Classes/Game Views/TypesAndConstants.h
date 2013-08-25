/*
 *  TypesAndConstants.h
 *  MobileOverload
 *
 *  Created by Joachim Bengtsson on 2008-08-18.
 *  Copyright 2008 Third Cog Software. All rights reserved.
 *
 */

extern const CGFloat ScoreBarHeight;
extern CGFloat BoardWidth();
extern CGFloat BoardHeight();
extern NSUInteger WidthInTiles();
extern NSUInteger HeightInTiles();

typedef enum {
    PlayerNone,
    PlayerP1,
    PlayerP2
} Player;

typedef struct {
    NSInteger x;
    NSInteger y;
} BoardPoint;
CG_INLINE BoardPoint BoardPointMake(NSInteger x, NSInteger y) { BoardPoint p; p.x = x, p.y = y; return p; }

typedef struct {
    NSInteger width;
    NSInteger height;
} BoardSize;
CG_INLINE BoardSize BoardSizeMake(NSInteger x, NSInteger y) { BoardSize p; p.width = x, p.height = y; return p; }



extern const CGFloat ChargeEnergy;
extern const CGFloat SparkleEnergy;
extern const CGFloat SparkleOpacityLow;
extern const NSTimeInterval ExplosionDelay;
extern const NSTimeInterval ExplosionSpreadEnergy;
extern const NSTimeInterval ExplosionDuration;

extern float frand(float max);


typedef struct {
    CGFloat values[10][12]; // [x][y]
    Player  owners[10][12]; // [x][y]
} BoardStruct;

extern const CGFloat Hues[3];
extern const CGFloat Saturations[4];

typedef struct {
    CGFloat scores[3];
} Scores;