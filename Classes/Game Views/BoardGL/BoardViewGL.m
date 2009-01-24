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

@interface BoardView ()
-(BOOL)createFramebuffer;
-(void)destroyFramebuffer;
-(void)render;
@property (nonatomic, assign) NSTimer *animationTimer;
@end



@implementation BoardView
+ (Class) layerClass
{
    return [CAEAGLLayer class];
}
-(id)initWithFrame:(CGRect)frame;
{
    if( ! [super initWithFrame:frame] ) return nil;
    
    animationInterval = 1.0/60.0;
    
    // 1. Setup our "window"
    CAEAGLLayer *glLayer = (CAEAGLLayer*)self.layer;
    glLayer.opaque = YES;
    
    // 2. Get a context to the hardware [EAGL]
    ctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    if( !ctx || ![EAGLContext setCurrentContext:ctx]) {
        [self release];
        return nil;
    }
    
    self.animated = YES;
    
    return self;
}
#pragma mark 
#pragma mark Context/buffer setup and teardown
#pragma mark -
- (void)layoutSubviews {
    [EAGLContext setCurrentContext:ctx];
    [self destroyFramebuffer];
    [self createFramebuffer];
    [self render];
}

- (BOOL)createFramebuffer;
{
    // 3. Setup the frame description object [OGLES]
    glGenFramebuffersOES(1, &fbo);
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, fbo); // Bind it to the context
    
    // 4. Get a buffer to draw color into [OGLES/EAGL]
    glGenRenderbuffersOES(1, &rbo);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, rbo); // Bind it to the context
    [ctx renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:(CAEAGLLayer*)self.layer];
    
    // 5. Connect the framebuffer and renderbuffer [OGLES]
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_COLOR_ATTACHMENT0_OES, GL_RENDERBUFFER_OES, rbo);
    

    
#if 0 // If we want a depth buffer...
    glGenRenderbuffersOES(1, &depthRenderbuffer);
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
    glRenderbufferStorageOES(GL_RENDERBUFFER_OES, GL_DEPTH_COMPONENT16_OES, backingWidth, backingHeight);
    glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, GL_DEPTH_ATTACHMENT_OES, GL_RENDERBUFFER_OES, depthRenderbuffer);
#endif
    
    if(glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) != GL_FRAMEBUFFER_COMPLETE_OES) {
        NSLog(@"[BoardViewGL createFrameBuffer]: Failed to make complete framebuffer object %x", glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}
- (void)destroyFramebuffer
{
    glDeleteFramebuffersOES(1, &fbo); fbo = 0;
    glDeleteRenderbuffersOES(1, &rbo); rbo = 0;
    // If we are using the depth buffer, remove that too
}
-(void)dealloc;
{
    if ([EAGLContext currentContext] == ctx)
        [EAGLContext setCurrentContext:nil];
    
    [ctx release];
    [super dealloc];
}


#pragma mark 
#pragma mark Rendering
#pragma mark -
-(void)render;
{
    if(!fbo) return;
    
    // Replace the implementation of this method to do your own custom drawing
    
    const GLfloat squareVertices[] = {
        -0.5f, -0.5f,
        0.5f,  -0.5f,
        -0.5f,  0.5f,
        0.5f,   0.5f,
    };
    const GLubyte squareColors[] = {
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0,   0,
        255,   0, 255, 255,
    };
    
    [EAGLContext setCurrentContext:ctx];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, fbo);
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof(-1.0f, 1.0f, -1.5f, 1.5f, -1.0f, 1.0f);
    glMatrixMode(GL_MODELVIEW);
    glRotatef(3.0f, 0.0f, 0.0f, 1.0f);
    
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
    
    glVertexPointer(2, GL_FLOAT, 0, squareVertices);
    glEnableClientState(GL_VERTEX_ARRAY);
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, squareColors);
    glEnableClientState(GL_COLOR_ARRAY);
    
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, rbo);
    [ctx presentRenderbuffer:GL_RENDERBUFFER_OES];
}


#pragma mark 
#pragma mark Input handling
#pragma mark -

#pragma mark 
#pragma mark Public interface
#pragma mark -
-(void)setValue:(CGFloat)v atPosition:(BoardPoint)p;
{
    
}
-(void)setOwner:(Player)player atPosition:(BoardPoint)p;
{
    
}
-(void)explode:(BoardPoint)explodingTile;
{
    
}

@synthesize animationTimer;
-(void)setAnimationTimer:(NSTimer*)animationTimer_;
{
    [animationTimer invalidate];
    [animationTimer_ retain];
    [animationTimer release];
    animationTimer = animationTimer_;
}
-(BOOL)animated;
{
    return animationTimer != nil;
}
-(void)setAnimated:(BOOL)animate_;
{
    if(!self.animated && animate_) {
        [self.animationTimer invalidate];
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(render) userInfo:nil repeats:YES];
    } else if(self.animated && !animate_)
        self.animationTimer = nil;
}

@synthesize sizeInTiles;
@synthesize delegate;
@synthesize tileSize;
@end


#endif