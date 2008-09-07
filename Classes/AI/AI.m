//
//  AI.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-09-07.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "AI.h"


@implementation AI

-(id)initPlaying:(Player)player_ onBoard:(Board*)board_ delegate:(id<BoardViewDelegate>)delegate_;
{
    if(![super init]) return nil;
    
    self.player = player_;
    self.board = board_;
    self.delegate = delegate_;
    
    return self;
}

-(void)performMove;
{
    if([board hasGameEnded])
        return;
    
    if(![board canMakeMoveNow])
        [self performSelector:@selector(performMove) withObject:nil afterDelay:ExplosionDelay];

    Tile *chosenTile = nil;
        
    for(NSUInteger x = 0; x < board.sizeInTiles.width; x++) {
        for(NSUInteger y = 0; y < board.sizeInTiles.height; y++) {
            Tile *tile = [board tile:BoardPointMake(x, y)];
            if((tile.owner == self.player || tile.owner == PlayerNone) && tile.value >= chosenTile.value && (!chosenTile || rand()%2))
                chosenTile = tile;
        }
    }
    
    [delegate boardTileViewWasTouched:(BoardTileView*)chosenTile];
}

@synthesize board;
@synthesize delegate;
@synthesize player;
@end
