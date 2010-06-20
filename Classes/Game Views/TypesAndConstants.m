/*
 *  TypesAndConstants.m
 *  MobileOverload
 *
 *  Created by Joachim Bengtsson on 2008-08-18.
 *  Copyright 2008 Third Cog Software. All rights reserved.
 *
 */
#import "StatusBarView.h"

const float BoardWidth = 320;
float BoardHeight()
{
    CGRect screenFrame = [[UIScreen mainScreen] applicationFrame];
    return screenFrame.size.height - [StatusBarView defaultHeight];
}
const float TileWidth = 32;
const float TileHeight = 31;
const NSUInteger WidthInTiles = 10; //BoardWidth/TileWidth
const NSUInteger HeightInTiles = 12; //BoardHeight/TileHeight

const NSTimeInterval ExplosionDelay = 0.30;
const float ChargeEnergy = 0.25;
const NSTimeInterval ExplosionSpreadEnergy = 0.25;
const NSTimeInterval ExplosionDuration = 0.40;
const float SparkleEnergy = 0.75;
const float SparkleOpacityLow = 0.7;

float frand(float max) {
    return (rand()/((float)INT_MAX))*max;
}

const float Hues[3]        = {.6, .0, .35 };

const float Saturations[4] = {0.0, .5 , .8,  1.};