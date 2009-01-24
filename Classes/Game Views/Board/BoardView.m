//
//  BoardView.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-08-18.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "BoardView.h"
#import <QuartzCore/QuartzCore.h>

@interface BoardView()
-(void)sparkle;
-(void)relayoutTiles;
-(BoardTileView*)tile:(BoardPoint)tilePos;

@end


@implementation BoardView

- (id)initWithFrame:(CGRect)frame;
{
	if (![super initWithFrame:frame]) return nil;

    for(NSUInteger y = 0; y < HeightInTiles; y++) {
        for (NSUInteger x = 0; x < WidthInTiles; x++) {
            BoardTileView *tile = [[[BoardTileView alloc] initWithFrame:CGRectMake(x*TileWidth, y*TileHeight, TileWidth, TileHeight)] autorelease];
            tile.boardPosition = BoardPointMake(x, y);
            tile.board = self;
            boardTiles[x][y] = tile;
            [self addSubview:tile];
        }
    }
    
    self.backgroundColor = [UIColor whiteColor];
    [self setSize:BoardSizeMake(WidthInTiles, HeightInTiles)];
    
    [self sparkle];
    
	return self;
}
- (void)dealloc {
    
	[super dealloc];
}

-(void)sparkle;
{
    static CGFloat animationDuration = 0.5;
    static BOOL on = NO;
    [UIView beginAnimations:@"sparkle" context:nil];
    [UIView setAnimationDuration:animationDuration];
    if(sparkling)
        [self performSelector:@selector(sparkle) withObject:nil afterDelay:animationDuration];
    
    
    for(NSUInteger y = 0; y < sizeInTiles.height; y++) {
        for (NSUInteger x = 0; x < sizeInTiles.width; x++) {
            BoardTileView *tile = [self tile:BoardPointMake(x, y)];
            if(tile.value >= SparkleEnergy-0.01)
                if(on == NO) {
                    tile.layer.opacity = SparkleOpacityLow;
                } else {
                    tile.layer.opacity = 1.;
                }
            
        }
    }
    [UIView commitAnimations];    
    on = ! on;    
}

-(BoardTileView*)tile:(BoardPoint)tilePos;
{
    if(tilePos.x > WidthInTiles-1 || tilePos.x < 0 || tilePos.y > HeightInTiles-1 || tilePos.y < 0) 
        return nil;
    
    return boardTiles[tilePos.x][tilePos.y];
}

-(BoardSize)size;
{
    return sizeInTiles;
}
-(void)setSize:(BoardSize)newSize;
{
    sizeInTiles = newSize;
    tileSize = CGSizeMake(BoardWidth/newSize.width, BoardHeight()/newSize.height);

    if(tileSize.width == [self tile:BoardPointMake(0, 0)].frame.size.width)
        return;
    
    [self relayoutTiles];
    
}
-(void)relayoutTiles;
{
    tileSize = CGSizeMake(BoardWidth/sizeInTiles.width, BoardHeight()/sizeInTiles.height);


    if(delegate) {
        [UIView beginAnimations:@"Resize board" context:nil];
        [UIView setAnimationDuration:1];
    }
    
    for(NSUInteger y = 0; y < HeightInTiles; y++) {
        for (NSUInteger x = 0; x < WidthInTiles; x++) {
            [self tile:BoardPointMake(x, y)].frame = 
            CGRectMake(x*tileSize.width, y*tileSize.height, tileSize.width, tileSize.height);
        }
    }
    
    if(delegate)
        [UIView commitAnimations];    
}

@synthesize delegate;
@synthesize tileSize;
@end
