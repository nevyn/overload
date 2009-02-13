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
#import "ColorConversion.h"
#import "UIImage+GLTexture.h"
#import "CollectionUtils.h"

@interface BoardView ()
-(BOOL)createFramebuffer;
-(void)destroyFramebuffer;
-(void)prepareScene;
@property (retain) Texture2D *gloss;
@property (retain) Texture2D *t0;
@property (retain) Texture2D *t25;
@property (retain) Texture2D *t50;
@property (retain) Texture2D *t75;
@end

@interface BoardPointWrapper : NSObject
{
    BoardPoint p;
}
@property (assign, nonatomic) BoardPoint p;
@end
@implementation BoardPointWrapper
+(id)wrap:(BoardPoint)p_; { BoardPointWrapper *pw = [[[BoardPointWrapper alloc] init] autorelease]; pw.p = p_; return pw; }
-(BOOL)isEqual:(BoardPointWrapper*)other; { return (other.p.x == self.p.x) && (other.p.y == self.p.y); }
@synthesize p;
@end



@interface BoardViewExplosion : NSObject
{
    NSTimeInterval start;
    BoardPoint position;
    Player owner;
    id delegate;
}
-(void)render;
@property (assign, nonatomic) NSTimeInterval start;
@property (assign, nonatomic) BoardPoint position;
@property (assign, nonatomic) Player owner;
@property (assign, nonatomic) id delegate;
@end



typedef struct tile_t {
    CGFloat value;
    Player player;
} tile_t;

@implementation BoardView
+ (Class) layerClass
{
    return [CAEAGLLayer class];
}
-(id)initWithFrame:(CGRect)frame;
{
    if( ! [super initWithFrame:frame] ) return nil;
        
    memset(&board, 0, sizeof(board));
    
    explosions = [[NSMutableArray alloc] init];
    aboutToExplode = [[NSMutableArray alloc] init];
    touchedTile = BoardPointMake(-1, -1);
    
    // 1. Setup our "window"
    CAEAGLLayer *glLayer = (CAEAGLLayer*)self.layer;
    glLayer.opaque = YES;
    
    // 2. Get a context to the hardware [EAGL]
    ctx = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
    if( !ctx || ![EAGLContext setCurrentContext:ctx] ) {
        [self release];
        return nil;
    }
    
    [self prepareScene];
    [self render];
    
    self.animated = YES;
    
    return self;
}
-(void)dealloc;
{
    if ([EAGLContext currentContext] == ctx)
        [EAGLContext setCurrentContext:nil];
    
    self.gloss = self.t0 = self.t25 = self.t50 = self.t75 = nil;
    
    [explosions release];
    [aboutToExplode release];
    [ctx release];
    [super dealloc];
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


#pragma mark Prepare scene
-(void)reloadTexturesForResolution:(NSUInteger)resolution;
{
    self.gloss = [Texture2D textureNamed:$sprintf(@"%d/tilegloss.png", resolution)];
    self.t0 = [Texture2D textureNamed:$sprintf(@"%d/tile-0.png", resolution)];
    self.t25 = [Texture2D textureNamed:$sprintf(@"%d/tile-25.png", resolution)];
    self.t50 = [Texture2D textureNamed:$sprintf(@"%d/tile-50.png", resolution)];
    self.t75 = [Texture2D textureNamed:$sprintf(@"%d/tile-75.png", resolution)];
}

-(void)prepareScene;
{
    [self reloadTexturesForResolution:64];
}

#pragma mark 
#pragma mark Rendering
#pragma mark -
// Very much not thread safe, but neither is OpenGL, so that's okay
void renderColor(Player owner, CGFloat value, CGFloat a)
{
    static GLubyte cornerColors[] = {
        255, 255,   0, 255,
        0,   255, 255, 255,
        0,     0,   0, 255,
        255,   0, 255, 255,
    };
    CGFloat hue = Hues[owner];
    CGFloat sat = Saturations[owner];
    CGFloat val = 1.0-(value/2.);
    CGFloat r, g, b; HSVtoRGB(hue*360., sat, val, &r, &g, &b);
    cornerColors[0] = cornerColors[4] = cornerColors[ 8] = cornerColors[12] = r*255;
    cornerColors[1] = cornerColors[5] = cornerColors[ 9] = cornerColors[13] = g*255;
    cornerColors[2] = cornerColors[6] = cornerColors[10] = cornerColors[14] = b*255;
    cornerColors[3] = cornerColors[7] = cornerColors[11] = cornerColors[15] = a*255;

    
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, cornerColors);
}

void renderWhite()
{
    static GLubyte cornerColors[] = {
        255, 255, 255, 255,
        255, 255, 255, 255,
        255, 255, 255, 255,
        255, 255, 255, 255,
    };    
    
    glColorPointer(4, GL_UNSIGNED_BYTE, 0, cornerColors);
}


-(void)render;
{
    if(!fbo) return;
    
    const GLfloat squareVertices[] = {
        0.f,   0.f,
        1.f,   0.f,
        0.f,   1.f,
        1.f,   1.f,
    };
    const GLshort spriteTexcoords[] = {
        0, 0,
        1, 0,
        0, 1,
        1, 1,
    };
    
    
    
    
    // Setup our surface for this frame
    [EAGLContext setCurrentContext:ctx];
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, fbo);
    
    // Setup the projection
    glViewport(0, 0, self.frame.size.width, self.frame.size.height);
    
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glOrthof(0, sizeInTiles.width, sizeInTiles.height, 0, -1.0f, 1.0f);
    
    // Prepare for textures
	glEnable(GL_TEXTURE_2D);
    
    glBlendFunc(GL_ONE, GL_ONE_MINUS_SRC_ALPHA);
    glEnable(GL_BLEND);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    
    
    // Begin drawing
    glMatrixMode(GL_MODELVIEW);
    
    // Clear to background
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    
    
    // Draw tiles
    //  Setup shared state for tiles (vert and texcoord pointers)
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_COLOR_ARRAY);

    glVertexPointer(2, GL_FLOAT, 0, squareVertices);
    
    //////// Color
    glDisable(GL_TEXTURE_2D);
    for(NSUInteger y = 0; y < self.sizeInTiles.height; y++) {
        for(NSUInteger x = 0; x < self.sizeInTiles.width; x++) {
            glLoadIdentity();
            glTranslatef(x, y, 0);
            
            // Color
            Player owner = board.owners[x][y];
            CGFloat value = board.values[x][y];
            CGFloat pulse = 0;
            if(value > 0.74)
                pulse = sin(5.*[NSDate timeIntervalSinceReferenceDate]+x+y*self.sizeInTiles.width)*0.20+0.20;
            renderColor(owner, value, 1.0-pulse);
            
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        }
    }
    
    
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
	glTexCoordPointer(2, GL_SHORT, 0, spriteTexcoords);
    glEnable(GL_TEXTURE_2D);
    renderWhite();
    
    
    //////// Symbol
    for(NSUInteger y = 0; y < self.sizeInTiles.height; y++) {
        for(NSUInteger x = 0; x < self.sizeInTiles.width; x++) {
            glLoadIdentity();
            glTranslatef(x, y, 0);
            
            if([aboutToExplode containsObject:[BoardPointWrapper wrap:BoardPointMake(x, y)]])
                glTranslatef(0.05-frand(0.1), 0.05-frand(0.1), 0);
            
            CGFloat value = board.values[x][y];
            
            Texture2D *tileImages[] = {t0, t25, t50, t75};
            NSInteger tileImageIdx = MIN(floor(value*4.), 3);
            Texture2D *tileImage = tileImages[tileImageIdx];
            if(tileImageIdx < 0 || tileImageIdx > 3 || !tileImage) NSLog(@"FEL");
    
            glBindTexture(GL_TEXTURE_2D, tileImage.name);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        }
    }
    
    //////// Gloss
    
    for(NSUInteger y = 0; y < self.sizeInTiles.height; y++) {
        for(NSUInteger x = 0; x < self.sizeInTiles.width; x++) {
            glLoadIdentity();
            glTranslatef(x, y, 0);
                        
            glBindTexture(GL_TEXTURE_2D, gloss.name);
            glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
        }
    }
    
    if(touchedTile.x != -1) {
        glLoadIdentity();
        glTranslatef(touchedTile.x, touchedTile.y, 0);
        glBindTexture(GL_TEXTURE_2D, gloss.name);
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);
    }
    
    
    glDisable(GL_TEXTURE_2D);

    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
    // Explosions
    for (id explosion in [[explosions copy] autorelease])
        [explosion render];
    
    
    
    
    
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, rbo);
    [ctx presentRenderbuffer:GL_RENDERBUFFER_OES];
}


#pragma mark 
#pragma mark Input handling
#pragma mark -
-(BoardPoint)boardPointFromEvent:(UIEvent *)event;
{
    UITouch *t = [[event allTouches] anyObject];
    CGPoint tp = [t locationInView:self];
    
    BoardPoint p;
    p.x = floor((tp.x/self.bounds.size.width)*sizeInTiles.width);
    p.y = floor((tp.y/self.bounds.size.height)*sizeInTiles.height);
    return p;
}
#define ifPointOutsideBounds(p) if(p.x < 0 || p.y < 0 || p.x >= sizeInTiles.width || p.y >= sizeInTiles.height)

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event;
{
    [self touchesMoved:touches withEvent:event];
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event;
{
    BoardPoint p = [self boardPointFromEvent:event];
    ifPointOutsideBounds(p)
        touchedTile = BoardPointMake(-1, -1);
    else
        touchedTile = p;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event;
{
    touchedTile = BoardPointMake(-1, -1);
    BoardPoint p = [self boardPointFromEvent:event];
    ifPointOutsideBounds(p)
        return;
    
    [self.delegate boardTileViewWasTouched:p];
}
#pragma mark 
#pragma mark Public interface
#pragma mark -
-(void)setValue:(CGFloat)v atPosition:(BoardPoint)p;
{
    if(p.x < 0 || p.x >= WidthInTiles || p.y < 0 || p.y >= HeightInTiles) 
        return;
    
    board.values[p.x][p.y] = v;
}
-(void)setOwner:(Player)player atPosition:(BoardPoint)p;
{
    if(p.x < 0 || p.x >= WidthInTiles || p.y < 0 || p.y >= HeightInTiles) 
        return;
    
    board.owners[p.x][p.y] = player;
}
-(void)explode:(BoardPoint)p;
{
    if(p.x < 0 || p.x >= WidthInTiles || p.y < 0 || p.y >= HeightInTiles) 
        return;
    
    [aboutToExplode removeObject:[BoardPointWrapper wrap:p]];
    
    BoardViewExplosion *ex = [[BoardViewExplosion new] autorelease];
    ex.start = [NSDate timeIntervalSinceReferenceDate];
    ex.position = p;
    ex.owner = board.owners[p.x][p.y];
    ex.delegate = self;
    /*
    [self setOwner:ex.owner atPosition:BoardPointMake(p.x, p.y-1)];
    [self setOwner:ex.owner atPosition:BoardPointMake(p.x+1, p.y)];
    [self setOwner:ex.owner atPosition:BoardPointMake(p.x, p.y+1)];
    [self setOwner:ex.owner atPosition:BoardPointMake(p.x-1, p.y)];*/
    // don't do that! just makes us out of sync with the model.
    
    [explosions addObject:ex];
}
-(void)explosionEnded:(BoardViewExplosion*)ex;
{
    [explosions removeObject:ex];
}

-(void)aboutToExplode:(BoardPoint)p;
{
    if(p.x < 0 || p.x >= WidthInTiles || p.y < 0 || p.y >= HeightInTiles) 
        return;

    [aboutToExplode addObject:[BoardPointWrapper wrap:p]];
}


@synthesize sizeInTiles;
-(void)setSizeInTiles:(BoardSize)newSize;
{
    sizeInTiles = newSize;
    tileSize = CGSizeMake(BoardWidth/newSize.width, BoardHeight()/newSize.height);
    
    NSUInteger resolutions[] = {64, 128, 256};
    NSUInteger resolution = 256;
    for(int i = 0; i < 3; i++) {
        resolution = resolutions[i];
        if(resolution >= tileSize.width)
            break;
    }
    [self reloadTexturesForResolution:resolution];
}
@synthesize delegate;
@synthesize tileSize;

@synthesize gloss, t0, t25, t50, t75;
-(BOOL)animated; { return YES; } // nops, not needed in GL version
-(void)setAnimated:(BOOL)_; {}
@end

#pragma mark 
#pragma mark Animations (Explosions)
#pragma mark -
@implementation BoardViewExplosion
-(void)render;
{
    NSTimeInterval now = [NSDate timeIntervalSinceReferenceDate];
    NSTimeInterval delta = now - self.start;
    CGFloat frac = delta/ExplosionDuration;
    if(frac > 1.0) {
        [delegate explosionEnded:self];
        return;
    }
    BoardPoint s = self.position;
    BoardPoint dir[] = {
        { 0, -1},
        { 1,  0},
        { 0,  1},
        {-1,  0}
    };
    
    for(NSUInteger i = 0; i < 4; i++) {
        glLoadIdentity();
        
        BoardPoint d = dir[i];
        CGFloat x = s.x + d.x*frac;
        CGFloat y = s.y + d.y*frac;

        glTranslatef(x, y, 0);
        
        renderColor(self.owner, 1.0, 1.0-frac);
        
        glDrawArrays(GL_TRIANGLE_STRIP, 0, 4);

    }
    
    
}


@synthesize start;
@synthesize position;
@synthesize owner;
@synthesize delegate;

@end



#endif