//
//  AI2.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-12-20.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "AI2.h"


@implementation AI2

-(BoardPoint)chooseTile;
{

    // 1. Look for any fully charged tiles next to an opponent's fully charged tile
    for (Tile *tile in [self randomBoardTiles]) {

        if(tile.owner != self.player)
           continue;
        
        if(tile.value < SparkleEnergy-0.05)
            continue;
        
        for (Tile *sibling in tile.surroundingTiles) {
            if(sibling.owner != self.player && sibling.value >= SparkleEnergy-0.05)
                //if(rand()%4 < 3) // one in four that he ignores it
                return tile.boardPosition;
        }
        
    }
    
    // 2. Find my tile such as 0 < tile.value < 0.75 and charge it
    for (Tile *tile in [self randomBoardTiles]) {

        if(tile.owner != self.player)
            continue;
        
        if(tile.value < SparkleEnergy || rand()%4==0) {
            // Here's a good tile, just make sure we're not walking into a trap first
            BOOL trap = NO;
            for (Tile *sibling in tile.surroundingTiles) {
                if(sibling.owner != self.player && sibling.value >= SparkleEnergy-0.05) {
                    trap = YES;
                    break;
                }
            }
            if(trap) continue;
            
            return tile.boardPosition;
        }
    }
    
    // Last resort: use super's stupid impl
    return [super chooseTile];
}
@end
