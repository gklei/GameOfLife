//
//  GLGridScene.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/7/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLGridScene.h"
#import "GLTileNode.h"
#import "UIColor+Crayola.h"

#include <vector>

// NOTE: both TILESIZE.width and TILESIZE.height must be greater than 1
#define TILESIZE CGSizeMake(20, 20)
#define LIVING YES
#define DEAD   NO

@interface GLGridScene()
{
   GridDimensions _gridDimensions;
   NSArray *_tiles;
   CFTimeInterval _lastGenerationTime;

   std::vector<BOOL> _nextGenerationTileStates;
   BOOL _running;
   GLTileNode *_currentTileBeingTouched;
}
@end

@implementation GLGridScene

- (void)setupGridWithSize:(CGSize)size
{
   self.backgroundColor = [SKColor crayolaPeriwinkleColor];

   _gridDimensions.rows = size.height/TILESIZE.height;
   _gridDimensions.columns = size.width/TILESIZE.width;

   for (int yPos = 0; yPos < size.height; yPos += TILESIZE.height)
      for (int xPos = 0; xPos < size.width; xPos += TILESIZE.width)
         [self addChild:[GLTileNode tileWithRect:CGRectMake(xPos + 0.5,
                                                            yPos + 0.5,
                                                            TILESIZE.width - 1,
                                                            TILESIZE.height - 1)]];
}

-(id)initWithSize:(CGSize)size
{
   if (self = [super initWithSize:size])
   {
      [self setupGridWithSize:size];
      _tiles = [NSArray arrayWithArray:self.children];
      _nextGenerationTileStates = std::vector<BOOL>(_tiles.count, DEAD);
   }
   return self;
}

- (void)setTilesBirthingDuration:(float)bDuration
                   dyingDuration:(float)dDuration
{
   for (GLTileNode *tile in _tiles)
   {
      tile.birthingDuration = bDuration;
      tile.dyingDuration = dDuration;
   }
}

- (void)toggleRunning
{
   float duration = (_running) ? .15 : .35;
   [self setTilesBirthingDuration:duration
                    dyingDuration:duration];

   _running = !_running;
}

- (GLTileNode *)tileAtTouch:(UITouch *)touch
{
   CGPoint location = [touch locationInNode:self];
   
   int row = location.y / TILESIZE.height;
   int col = location.x / TILESIZE.width;
   int arrayIndex = row*_gridDimensions.columns + col;
   
   if (arrayIndex >= 0 && arrayIndex < _tiles.count)
      return [_tiles objectAtIndex:arrayIndex];
   
   return nil;
}

- (void)toggleLivingForTileAtTouch:(UITouch *)touch
{
   GLTileNode *tile = [self tileAtTouch:touch];
   if (_currentTileBeingTouched != tile)
   {
      _currentTileBeingTouched = tile;
      tile.isLiving = !tile.isLiving;
   }
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
   if (!_running)
      for (UITouch *touch in touches)
         [self toggleLivingForTileAtTouch:touch];
}

- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event
{
   if (!_running)
      [self toggleLivingForTileAtTouch:[[touches allObjects] lastObject]];
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
   _currentTileBeingTouched = nil;
}

- (int)getNorthSouthLiveCountForTileAtIndex:(int)index
{
   GLTileNode *tile;
   int liveCount = 0;
   int neighborIndex;

   // north
   neighborIndex = index + _gridDimensions.columns;
   if (neighborIndex >= _tiles.count)
      neighborIndex -= _tiles.count;

   tile = [_tiles objectAtIndex:neighborIndex];
   if (tile.isLiving)
      ++liveCount;

   // south
   neighborIndex = index - _gridDimensions.columns;
   if (neighborIndex < 0)
      neighborIndex += _tiles.count;

   tile = [_tiles objectAtIndex:neighborIndex];
   if (tile.isLiving)
      ++liveCount;

   return liveCount;
}

- (int)getEastBlockLiveCountForTileAtIndex:(int)index
{
   int result = 0;
   
   int neighborIdx = index + 1;
   if (neighborIdx / _gridDimensions.columns > index / _gridDimensions.columns)
      neighborIdx -= _gridDimensions.columns;
   
   if (((GLTileNode *)[_tiles objectAtIndex:neighborIdx]).isLiving)
      ++result;
   
   result += [self getNorthSouthLiveCountForTileAtIndex:neighborIdx];
   
   return result;
}

- (int)getWestBlockLiveCountForTileAtIndex:(int)index
{
   int result = 0;
   
   int neighborIdx = index - 1;
   if (neighborIdx < 0 || neighborIdx / _gridDimensions.columns < index / _gridDimensions.columns)
      neighborIdx += _gridDimensions.columns;
   
   if (((GLTileNode *)[_tiles objectAtIndex:neighborIdx]).isLiving)
      ++result;
   
   result += [self getNorthSouthLiveCountForTileAtIndex:neighborIdx];
   
   return result;
}

- (BOOL)getIsLivingForNextGenerationAtIndex:(int)index
{
   int liveCount = [self getNorthSouthLiveCountForTileAtIndex:index];
   liveCount += [self getEastBlockLiveCountForTileAtIndex:index];
   
   if (liveCount > 3) return DEAD; // optimization - no need to check any further
   
   liveCount += [self getWestBlockLiveCountForTileAtIndex:index];
   
   GLTileNode * tile = [_tiles objectAtIndex:index];
   
   // behold, the meaning of life (all in one statement)
   return ((tile.isLiving && liveCount == 2) || (liveCount == 3))? LIVING : DEAD;
}

- (void)updateNextGeneration:(CFTimeInterval)currentTime
{
   _lastGenerationTime = currentTime;
   for (int i = 0; i < _tiles.count; ++i)
      _nextGenerationTileStates[i] = [self getIsLivingForNextGenerationAtIndex:i];

   for (int i = 0; i < _tiles.count; ++i)
      ((GLTileNode *)[_tiles objectAtIndex:i]).isLiving = _nextGenerationTileStates[i];
}

-(void)update:(CFTimeInterval)currentTime
{
   if (_running && currentTime - _lastGenerationTime > .75)
      [self updateNextGeneration:currentTime];
}

@end
