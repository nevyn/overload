/*
 *  TypesAndConstants.m
 *  MobileOverload
 *
 *  Created by Joachim Bengtsson on 2008-08-18.
 *  Copyright 2008 Third Cog Software. All rights reserved.
 *
 */

const NSUInteger BoardWidth = 320;
const NSUInteger BoardHeight = 372;
const NSUInteger TileWidth = 32;
const NSUInteger TileHeight = 31;
const NSUInteger WidthInTiles = 10; //BoardWidth/TileWidth
const NSUInteger HeightInTiles = 12; //BoardHeight/TileHeight

const NSTimeInterval ExplosionDelay = 0.10;
const NSTimeInterval ExplosionSpreadEnergy = 0.25;
const CGFloat ChargeEnergy = 0.25;

float frand(float max) {
    return (rand()/((float)INT_MAX))*max;
}
