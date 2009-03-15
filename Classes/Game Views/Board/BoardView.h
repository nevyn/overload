//
//  BoardView.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-18.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TypesAndConstants.h"

#import <OpenGLES/EAGL.h>
#import <OpenGLES/EAGLDrawable.h>
#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import "Texture2D.h"

@protocol BoardViewDelegate
-(void)boardTileViewWasTouched:(BoardPoint)pointThatWasTouched;
@end


@interface BoardView : UIView {    
    CGSize tileSize;
    BoardSize sizeInTiles;
    
    id<BoardViewDelegate> delegate;
    
    EAGLContext *ctx;
    GLuint fbo, rbo;
    Texture2D *gloss, *t0, *t25, *t50, *t75;
    
    BoardStruct board;
    
    BoardPoint touchedTile;
    
    NSMutableArray *explosions;
    NSMutableArray *aboutToExplode;
}

-(void)setValue:(CGFloat)v atPosition:(BoardPoint)p;
-(void)setOwner:(Player)player atPosition:(BoardPoint)p;
-(void)aboutToExplode:(BoardPoint)explodingTile;
-(void)explode:(BoardPoint)explodingTile;

// heartbeat
-(void)render;

@property (assign, nonatomic) BoardSize sizeInTiles;
@property (assign, nonatomic) id<BoardViewDelegate> delegate;
@property (readonly, nonatomic) CGSize tileSize;
@end
