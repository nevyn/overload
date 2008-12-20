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
    NSMutableArray *chainReactionStarters = [NSMutableArray array];
    for (Tile *tile in [self randomBoardTiles]) {

        if(tile.owner != self.player)
           continue;
        
        if(tile.value < SparkleEnergy-0.05)
            continue;
        
        for (Tile *sibling in tile.surroundingTiles) {
            if(sibling.owner != self.player && sibling.value >= SparkleEnergy-0.05)
                [chainReactionStarters addObject:tile];
        }
        
    }
    // 1.1 Look through the candidates from above and see which one would be most effective
    if([chainReactionStarters count] == 1)
        return [[chainReactionStarters objectAtIndex:0] boardPosition];
    if([chainReactionStarters count] > 1) {
        NSUInteger bestIdx = 0, currentIdx = 0;
        CGFloat bestScore = -99999;
        NSLog(@"Comparing chain reactions:");
        for (Tile *tryThis in chainReactionStarters) {
            Board *copy = [[self.board copy] autorelease];
            [copy chargeTileForCurrentPlayer:tryThis.boardPosition];
            
            CGFloat currentScore = copy.scores.scores[self.player];
            NSLog(@"%d @ %d%d: %f", currentIdx, tryThis.boardPosition.x, tryThis.boardPosition.y, currentScore);
            if(currentScore > bestScore) {
                bestScore = currentScore;
                bestIdx = currentIdx;
            }
            currentIdx += 1;
        }
        NSLog(@"Choosing %d", bestIdx);
        
        return [[chainReactionStarters objectAtIndex:bestIdx] boardPosition];
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
