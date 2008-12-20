//
//  AIMinMax.m
//  MobileOverload
//
//  Created by Joachim Bengtsson on 2008-09-08.
//  Copyright 2008 Third Cog Software. All rights reserved.
//

#import "AIMinMax.h"

static NSInteger MinMaxDepth = 2;

@implementation AIMMTreeNode
-(id)initWithState:(Board*)state inAI:(AIMinMax*)ai_;
{
    if(![super init]) return nil;
    board = [state retain];
    ai = ai_;
    return self;
}
-(AIMMTreeNode*)node:(BoardPoint)tilePos;
{
    if(tilePos.x > WidthInTiles-1 || tilePos.x < 0 || tilePos.y > HeightInTiles-1 || tilePos.y < 0) 
        return nil;
    
    return children[tilePos.x][tilePos.y];
}
-(AIMMTreeNode*)bestChoice;
{
    AIMMTreeNode *bestChoice = nil;
    CGFloat bestValue = NSIntegerMin;
    
    for(NSUInteger x = 0; x < board.sizeInTiles.width; x++) {
        for(NSUInteger y = 0; y < board.sizeInTiles.height; y++) {
            AIMMTreeNode *current = [self node:BoardPointMake(x, y)];
            if(current) {
                CGFloat currentValue = [current minMaxAtDepth:MinMaxDepth];
                if(currentValue > bestValue) {
                    bestValue = currentValue;
                    bestChoice = current;
                }
            }
        }
    }
    if(!bestChoice) NSLog(@"nil best choice!");
    return bestChoice; // TODO: bestChoice might be uninitialized
}

-(void)dealloc;
{
    for(NSUInteger x = 0; x < board.sizeInTiles.width; x++) {
        for(NSUInteger y = 0; y < board.sizeInTiles.height; y++) {
            [children[x][y] release];
        }
    }
    [board release];
    [super dealloc];
}

-(NSArray*)makeChildren;
{
    NSMutableArray *collectedChildren = [NSMutableArray array];
    if(hasChildren) {
        for(NSUInteger x = 0; x < board.sizeInTiles.width; x++)
            for(NSUInteger y = 0; y < board.sizeInTiles.height; y++)
                if(children[x][y])
                    [collectedChildren addObject:children[x][y]];
        return collectedChildren;
    }
    
    for(NSUInteger x = 0; x < board.sizeInTiles.width; x++) {
        for(NSUInteger y = 0; y < board.sizeInTiles.height; y++) {
            BoardPoint p = BoardPointMake(x, y);
            if( ! [board player:board.currentPlayer canChargeTile:p])
                children[x][y] = nil;
            else {
                Board *copy = [[board copy] autorelease];
                [copy chargeTileForCurrentPlayer:p];
                AIMMTreeNode *newNode = [[AIMMTreeNode alloc] initWithState:copy inAI:ai];
                newNode->representsMoveAt = p;
                children[x][y] = newNode;
                [collectedChildren addObject:newNode];
            }
        }
    }
    hasChildren = YES;
    return collectedChildren;
}

@synthesize board;
@synthesize representsMoveAt;

#pragma mark MinMax
-(CGFloat)minMaxAtDepth:(NSUInteger)depth;
{
    Player winner = self.board.winner;
    if(winner)
        return winner==ai.player ? NSIntegerMax : NSIntegerMin;
    if(depth == 0)
        return self.valueEstimate;
    
    CGFloat a = NSIntegerMin;
    for (AIMMTreeNode *child in [self makeChildren]) {
        a = MAX(a, -[child minMaxAtDepth:depth-1]);
    }
    return a;
}

-(CGFloat)valueEstimate;
{
    Scores _ = board.scores;
    
    CGFloat value = _.scores[PlayerP1] - _.scores[PlayerP2];
    
    if(ai.player == PlayerP2)
        value = 0-value;
    
    return value;
}
@end


@implementation AIMinMax

-(id)initPlaying:(Player)player_ onBoard:(Board*)board_ delegate:(id<BoardViewDelegate>)delegate_;
{
    if(![super initPlaying:player_ onBoard:board_ delegate:delegate_]) return nil;
    
    self.root = [[[AIMMTreeNode alloc] initWithState:[[board_ copy] autorelease] inAI:self] autorelease];
    
    
    return self;
}


-(void)player:(Player)player choseTile:(BoardPoint)boardPoint;
{
    self.root = [root node:boardPoint];
}


-(BoardPoint)chooseTile;
{
    AIMMTreeNode *best = [root bestChoice];
    [self player:player choseTile:best.representsMoveAt];
    return best.representsMoveAt;
}

@synthesize root;
-(void)setRoot:(AIMMTreeNode*)newRoot;
{
    [newRoot retain];
    [root release];
    root = newRoot;
    [root makeChildren];
}
@end
