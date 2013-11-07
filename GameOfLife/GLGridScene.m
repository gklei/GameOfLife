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
}
@end

@implementation GLGridScene

- (void)setupGridWithSize:(CGSize)size
{
   self.backgroundColor = [SKColor crayolaPeriwinkleColor];

   _gridDimensions.rows = size.height/TILESIZE.height;
   _gridDimensions.columns = size.width/TILESIZE.width;

   for (int ypos = 0; ypos < size.height; ypos += TILESIZE.height)
      for (int xpos = 0; xpos < size.width; xpos += TILESIZE.width)
         [self addChild:[GLTileNode tileWithRect:CGRectMake(xpos + 0.5,
                                                            ypos + 0.5,
                                                            TILESIZE.width - 1,
                                                            TILESIZE.height - 1)]];
   _tiles = [NSArray arrayWithArray:self.children];
}

-(id)initWithSize:(CGSize)size {
   if (self = [super initWithSize:size])
   {
      [self setupGridWithSize:size];
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

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
   if (touches.count > 1)
   {
      float duration = (_running) ? .15 : .55;
      [self setTilesBirthingDuration:duration
                       dyingDuration:duration];

      _running = !_running;
   }

   if (!_running)
      for (UITouch *touch in touches)
      {
         CGPoint location = [touch locationInNode:self];
         int row = location.y / TILESIZE.height;
         int col = location.x / TILESIZE.width;
         int arrayIndex = row*_gridDimensions.columns + col;

         GLTileNode *tile = [_tiles objectAtIndex:arrayIndex];
         tile.isLiving = !tile.isLiving;
      }
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
   int neighborIndex;
   int liveCount = [self getNorthSouthLiveCountForTileAtIndex:index];
   GLTileNode *tile;

   // east
   neighborIndex = index + 1;
   if (neighborIndex /_gridDimensions.columns > index / _gridDimensions.columns)
      neighborIndex -= _gridDimensions.columns;
   tile = [_tiles objectAtIndex:neighborIndex];
   if (tile.isLiving)
      ++liveCount;

   liveCount += [self getNorthSouthLiveCountForTileAtIndex:neighborIndex];

   // west
   neighborIndex = index - 1;
   if (neighborIndex < 0 || neighborIndex /_gridDimensions.columns < index / _gridDimensions.columns)
      neighborIndex += _gridDimensions.columns;
   tile = [_tiles objectAtIndex:neighborIndex];
   if (tile.isLiving)
      ++liveCount;

   liveCount += [self getNorthSouthLiveCountForTileAtIndex:neighborIndex];

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
   {
      _nextGenerationTileStates[i] = [self getStateForTileAtIndex:i];
   }

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
