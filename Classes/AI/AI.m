//
//  AI.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-09-07.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "AI.h"


@implementation AI

-(id)initPlaying:(Player)player_ onGame:(Game*)game_;
{
    if(![super init]) return nil;
    
    self.player = player_;
    opponent = (!(player-1))+1;
	self.game = game_;
    
    srand(time(NULL));
    
    return self;
}

-(void)performMove;
{
    if([game hasEnded])
        return;
    
    if(game.currentPlayer != self.player)
        return;
    
    if(![game canMakeMoveNow])
        [self performSelector:@selector(performMove) withObject:nil afterDelay:ExplosionDelay];
    
    BoardPoint chosenTilePoint = [self chooseTile];
    
	[game makeMoveForCurrentPlayer:chosenTilePoint];
}

-(void)player:(Player)player choseTile:(BoardPoint)boardPoint;
{
    // Ignore
}

-(BoardPoint)chooseTile;
{
    Tile *chosenTile = nil;
    
    for (Tile *tile in [self randomBoardTiles]) {
        if((tile.owner == self.player || tile.owner == PlayerNone) && tile.value >= chosenTile.value && (!chosenTile || rand()%2))
            chosenTile = tile;
    }
    
    return chosenTile.boardPosition;
}

@synthesize game;
@synthesize player;


NSInteger randomSort(id obj1, id obj2, void *ctx) {
    return rand()%3-1;
}

// In order to decrease predictability, we need to be able to iterate the
// board in random order.
-(NSArray*)randomBoardTiles;
{
    NSMutableArray *tiles = [NSMutableArray array];
    for(NSUInteger x = 0; x < game.board.sizeInTiles.width; x++) {
        for(NSUInteger y = 0; y < game.board.sizeInTiles.height; y++) {
            Tile *tile = [game.board tile:BoardPointMake(x, y)];
            [tiles addObject:tile];
        }
    }
    [tiles sortUsingFunction:randomSort context:NULL];
    
    return tiles;
}


@end
