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

#define TILESIZE CGSizeMake(20, 20)

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
      _nextGenerationTileStates = std::vector<BOOL>(_tiles.count, NO);
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

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
   if (!_running)
      for (UITouch *touch in touches)
      {
         CGPoint location = [touch locationInNode:self];
         int row = location.y / TILESIZE.height;
         int col = location.x / TILESIZE.width;
         int arrayIndex = row*_gridDimensions.columns + col;

         GLTileNode *tile = [_tiles objectAtIndex:arrayIndex];
         tile.isLiving = !tile.isLiving;
         _currentTileBeingTouched = tile;
      }
}

- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event
{
   if (!_running)
   {
      UITouch *touch = [[touches allObjects] lastObject];
      CGPoint location = [touch locationInNode:self];
      int row = location.y / TILESIZE.height;
      int col = location.x / TILESIZE.width;
      int arrayIndex = row*_gridDimensions.columns + col;

      GLTileNode *tile = [_tiles objectAtIndex:arrayIndex];
      if (_currentTileBeingTouched != tile)
      {
         _currentTileBeingTouched = tile;
         tile.isLiving = !tile.isLiving;
      }
   }
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

- (BOOL)getStateForTileAtIndex:(int)index
{
   int liveCount = [self getNorthSouthLiveCountForTileAtIndex:index];
   GLTileNode *tile;

   // east
   int eastNeighborIndex = index + 1;
   if (eastNeighborIndex / _gridDimensions.columns > index / _gridDimensions.columns)
      eastNeighborIndex -= _gridDimensions.columns;
   tile = [_tiles objectAtIndex:eastNeighborIndex];
   if (tile.isLiving)
      ++liveCount;

   liveCount += [self getNorthSouthLiveCountForTileAtIndex:eastNeighborIndex];

   // west
   int westNeighborIndex = index - 1;
   if (westNeighborIndex < 0 ||
       westNeighborIndex / _gridDimensions.columns < index / _gridDimensions.columns)
      westNeighborIndex += _gridDimensions.columns;
   tile = [_tiles objectAtIndex:westNeighborIndex];
   if (tile.isLiving)
      ++liveCount;

   liveCount += [self getNorthSouthLiveCountForTileAtIndex:westNeighborIndex];

   tile = [_tiles objectAtIndex:index];

   // behold, the meaning of life:
   if (tile.isLiving)
      if (liveCount == 2)
         return YES;
   if (liveCount == 3)
      return YES;

   return NO;
}

- (void)updateNextGeneration:(CFTimeInterval)currentTime
{
   _lastGenerationTime = currentTime;
   for (int i = 0; i < _tiles.count; ++i)
      _nextGenerationTileStates[i] = [self getStateForTileAtIndex:i];

   for (int i = 0; i < _tiles.count; ++i)
   {
      GLTileNode *tile = [_tiles objectAtIndex:i];
      tile.isLiving = _nextGenerationTileStates[i];
   }
}

-(void)update:(CFTimeInterval)currentTime
{
   if (_running && currentTime - _lastGenerationTime > .75)
      [self updateNextGeneration:currentTime];
}

@end
