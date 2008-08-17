//
//  BoardTile.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-17.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "BoardTile.h"

static float frand(float max) {
    return (rand()/((float)INT_MAX))*max;
}


@implementation BoardTile


- (id)initWithFrame:(CGRect)frame {
	if (![super initWithFrame:frame])
        return nil;
    
    return self;
}


- (void)drawRect:(CGRect)rect {
	[[UIColor colorWithHue:frand(1.0) saturation:frand(1.0) brightness:frand(1.0) alpha:1.0] set];
    UIRectFill(rect);
}


- (void)dealloc {
	[super dealloc];
}

@synthesize owner;
@synthesize value;

@end
