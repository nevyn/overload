/*
 *  TypesAndConstants.h
 *  MobileOverload
 *
 *  Created by Joachim Bengtsson on 2008-08-18.
 *  Copyright 2008 Third Cog Software. All rights reserved.
 *
 */

extern const float ScoreBarHeight;
extern const float BoardWidth;
extern float BoardHeight();
extern const float TileWidth;
extern const float TileHeight;
extern const NSUInteger WidthInTiles; // = 10
extern const NSUInteger HeightInTiles; // = 12

typedef enum {
    PlayerNone,
    PlayerP1,
    PlayerP2
} Player;

typedef struct {
    int32_t x;
    int32_t y;
} BoardPoint;
CG_INLINE BoardPoint BoardPointMake(int32_t x, int32_t y) { BoardPoint p; p.x = x, p.y = y; return p; }

typedef struct {
    int32_t width;
    int32_t height;
} BoardSize;
CG_INLINE BoardSize BoardSizeMake(int32_t x, int32_t y) { BoardSize p; p.width = x, p.height = y; return p; }



extern const float ChargeEnergy;
extern const float SparkleEnergy;
extern const float SparkleOpacityLow;
extern const NSTimeInterval ExplosionDelay;
extern const NSTimeInterval ExplosionSpreadEnergy;
extern const NSTimeInterval ExplosionDuration;

extern float frand(float max);


typedef struct {
    float values[10][12]; // [x][y]
    Player  owners[10][12]; // [x][y]
} BoardStruct;

extern const float Hues[3];
extern const float Saturations[4];

typedef struct {
    float scores[3];
} Scores;