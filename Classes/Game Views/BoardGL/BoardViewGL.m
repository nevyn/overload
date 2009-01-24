#ifdef BOARDVIEW_OPENGL
//
//  BoardView.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-18.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "BoardView.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/EAGL.h>


@implementation BoardView
+ (Class) layerClass
{
    return [CAEAGLLayer class];
}
-(id)initWithFrame:(CGRect)frame;
{
    if( ! [super initWithFrame:frame] ) return nil;
    
    CAEAGLLayer *glLayer = (CAEAGLLayer*)self.layer;
    glLayer.opaque = YES;
    
    return self;
}
-(void)setValue:(CGFloat)v atPosition:(BoardPoint)p;
{
    
}
-(void)setOwner:(Player)player atPosition:(BoardPoint)p;
{
    
}
-(void)explode:(BoardPoint)explodingTile;
{
    
}


@synthesize sizeInTiles;
@synthesize delegate;
@synthesize tileSize;
@end


#endif