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
    opponent = (!(player-1))+1;
    self.board = board_;
    self.delegate = delegate_;
    
    return self;
}

-(void)performMove;
{
    if([board hasEnded])
        return;
    
    if(board.currentPlayer != self.player)
        return;
    
    if(![board canMakeMoveNow])
        [self performSelector:@selector(performMove) withObject:nil afterDelay:ExplosionDelay];
    
    BoardPoint chosenTilePoint = [self chooseTile];
    
    [delegate boardTileViewWasTouched:(BoardTileView*)[board tile:chosenTilePoint]];
}

-(void)player:(Player)player choseTile:(BoardPoint)boardPoint;
{
    // Ignore
}

-(BoardPoint)chooseTile;
{
    Tile *chosenTile = nil;
    
    for(NSUInteger x = 0; x < board.sizeInTiles.width; x++) {
        for(NSUInteger y = 0; y < board.sizeInTiles.height; y++) {
            Tile *tile = [board tile:BoardPointMake(x, y)];
            if((tile.owner == self.player || tile.owner == PlayerNone) && tile.value >= chosenTile.value && (!chosenTile || rand()%2))
                chosenTile = tile;
        }
    }
    
    return chosenTile.boardPosition;
}

@synthesize board;
@synthesize delegate;
@synthesize player;
@end
