//
//  BoardView.h
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-18.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TypesAndConstants.h"

# ifndef BOARDVIEW_OPENGL
#   import "BoardTileView.h"
# else
#   import <OpenGLES/EAGL.h>
#   import <OpenGLES/EAGLDrawable.h>
#   import <OpenGLES/ES1/gl.h>
#   import <OpenGLES/ES1/glext.h>
# endif
@protocol BoardViewDelegate
-(void)boardTileViewWasTouched:(BoardPoint)pointThatWasTouched;
@end


@interface BoardView : UIView {    
    CGSize tileSize;
    BoardSize sizeInTiles;
    
    id<BoardViewDelegate> delegate;
    
#ifndef BOARDVIEW_OPENGL
    BoardTileView *boardTiles[10][12]; // [x][y]
#else
    EAGLContext *ctx;
    GLuint fbo, rbo;
    GLuint gloss, t0, t25, t50, t75;
    
    NSTimer *animationTimer;
    NSTimeInterval animationInterval;
    BoardStruct board;
    
    NSMutableArray *explosions;
#endif
}

-(void)setValue:(CGFloat)v atPosition:(BoardPoint)p;
-(void)setOwner:(Player)player atPosition:(BoardPoint)p;
-(void)explode:(BoardPoint)explodingTile;

@property (assign, nonatomic) BOOL animated;

@property (assign, nonatomic) BoardSize sizeInTiles;
@property (assign, nonatomic) id<BoardViewDelegate> delegate;
@property (readonly, nonatomic) CGSize tileSize;
@end
