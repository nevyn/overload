/*
 *  TypesAndConstants.h
 *  MobileOverload
 *
 *  Created by Joachim Bengtsson on 2008-08-18.
 *  Copyright 2008 Third Cog Software. All rights reserved.
 *
 */

extern const float BoardWidth __attribute__((__deprecated__));
extern float BoardHeight() __attribute__((__deprecated__));
extern const float TileWidth;
extern const float TileHeight;
extern const NSUInteger WidthInTiles; // = 10
extern const NSUInteger HeightInTiles; // = 12

enum {
    PlayerNone = 0,
    PlayerP1 = 1,
    PlayerP2 = 2
};
typedef NSUInteger PlayerID;

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
    float values[12][10]; // [y][x]
    PlayerID  owners[12][10]; // [y][x]
} BoardStruct;

extern const float Hues[3];
extern const float Saturations[4];

typedef struct {
    float scores[3];
} Scores;