//
//  GLGrid.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/29/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLGrid.h"
#import "GLTileNode.h"

#include <vector>

#define LIVING YES
#define DEAD   NO
#define TILESIZE CGSizeMake(20, 20)

@interface GLGrid() <GLTileColorDelegate>
{
   std::vector<BOOL> _storedTileStates;
   std::vector<BOOL> _nextGenerationTileStates;

   SKColor *_currentColor;
}
@end

@implementation GLGrid

- (id)initWithSize:(CGSize)size
{
   if (self = [super init])
   {
      [self setupGridWithSize:size];
   }
   return self;
}

- (void)setupGridWithSize:(CGSize)size
{
   _dimensions.rows = size.width/TILESIZE.width;
   _dimensions.columns = size.width/TILESIZE.width;

   for (int yPos = 0; yPos < size.height; yPos += TILESIZE.height)
   {
      for (int xPos = 0; xPos < size.width; xPos += TILESIZE.width)
      {
         GLTileNode *tile = [GLTileNode tileWithRect:CGRectMake(xPos + 0.5,
                                                                yPos + 0.5,
                                                                TILESIZE.width - 1,
                                                                TILESIZE.height - 1)];
         tile.delegate = self;
         [self addChild:tile];
      }
   }
   _tiles = [NSArray arrayWithArray:self.children];
   _nextGenerationTileStates = std::vector<BOOL>(_tiles.count, DEAD);
   _storedTileStates = std::vector<BOOL>(_tiles.count, DEAD);

   CGPoint boardCenter = CGPointMake(_dimensions.columns * TILESIZE.width * 0.5,
                                     _dimensions.rows * TILESIZE.height * 0.5);
   float maxBoardDistance = sqrt(size.width * size.width + size.height * size.height);
   for (GLTileNode *tile in _tiles)
   {
      tile.boardMaxDistance = maxBoardDistance;
      [tile setColorCenter:boardCenter];
   }
}

- (GLTileNode *)tileAtTouch:(UITouch *)touch
{
   CGPoint location = [touch locationInNode:self];

   int row = location.y / TILESIZE.height;
   int col = location.x / TILESIZE.width;
   int arrayIndex = row*_dimensions.columns + col;

   if (arrayIndex >= 0 && arrayIndex < _tiles.count)
      return [_tiles objectAtIndex:arrayIndex];

   return nil;
}

- (int)getNorthSouthTileLiveCountForTileAtIndex:(int)index
{
   GLTileNode *tile;
   int liveCount = 0;
   int neighborIndex;

   // north
   neighborIndex = index + _dimensions.columns;
   if (neighborIndex >= _tiles.count)
      neighborIndex -= _tiles.count;

   tile = [_tiles objectAtIndex:neighborIndex];
   if (tile.isLiving)
      ++liveCount;

   // south
   neighborIndex = index - _dimensions.columns;
   if (neighborIndex < 0)
      neighborIndex += _tiles.count;

   tile = [_tiles objectAtIndex:neighborIndex];
   if (tile.isLiving)
      ++liveCount;

   return liveCount;
}

- (int)getEastTileLiveCountForTileAtIndex:(int)index
{
   int result = 0;

   int neighborIdx = index + 1;
   if (neighborIdx / _dimensions.columns > index / _dimensions.columns)
      neighborIdx -= _dimensions.columns;

   if (((GLTileNode *)[_tiles objectAtIndex:neighborIdx]).isLiving)
      ++result;

   result += [self getNorthSouthTileLiveCountForTileAtIndex:neighborIdx];

   return result;
}

- (int)getWestTileLiveCountForTileAtIndex:(int)index
{
   int result = 0;

   int neighborIdx = index - 1;
   if (neighborIdx < 0 || neighborIdx / _dimensions.columns < index / _dimensions.columns)
      neighborIdx += _dimensions.columns;

   if (((GLTileNode *)[_tiles objectAtIndex:neighborIdx]).isLiving)
      ++result;

   result += [self getNorthSouthTileLiveCountForTileAtIndex:neighborIdx];

   return result;
}

- (int)getLiveCountAtIndex:(int)index
{
   int liveCount = ((GLTileNode *)[_tiles objectAtIndex:index]).isLiving;
   liveCount += [self getNorthSouthTileLiveCountForTileAtIndex:index];
   liveCount += [self getEastTileLiveCountForTileAtIndex:index];
   liveCount += [self getWestTileLiveCountForTileAtIndex:index];
   return liveCount;
}

- (BOOL)getIsLivingForNextGenerationAtIndex:(int)index
{
   int liveCount = [self getNorthSouthTileLiveCountForTileAtIndex:index];
   liveCount += [self getEastTileLiveCountForTileAtIndex:index];

   if (liveCount > 3) return DEAD; // optimization - no need to check any further

   liveCount += [self getWestTileLiveCountForTileAtIndex:index];

   GLTileNode * tile = [_tiles objectAtIndex:index];

   // behold, the meaning of life (all in one statement)
   return ((tile.isLiving && liveCount == 2) || (liveCount == 3))? LIVING : DEAD;
}

- (void)updateColorCenter
{
   int maxCount = [self getLiveCountAtIndex:0];
   int indexForColorCenter = 0;
   for (int i = 1; i < _tiles.count; ++i)
   {
      int count = [self getLiveCountAtIndex:i];
      if (count > maxCount)
      {
         maxCount = count;
         indexForColorCenter = i;
      }
   }

   CGPoint position = ((GLTileNode *)[_tiles objectAtIndex:indexForColorCenter]).position;
   for (int i = 0; i < _tiles.count; ++i)
      ((GLTileNode *)[_tiles objectAtIndex:i]).colorCenter = position;
}

- (void)updateNextGeneration
{
   for (int i = 0; i < _tiles.count; ++i)
      _nextGenerationTileStates[i] = [self getIsLivingForNextGenerationAtIndex:i];

   for (int i = 0; i < _tiles.count; ++i)
      ((GLTileNode *)[_tiles objectAtIndex:i]).isLiving = _nextGenerationTileStates[i];

   [self updateColorCenter];
}

- (void)restoreGrid
{
   CGPoint center = CGPointMake(_dimensions.columns * TILESIZE.width * 0.5,
                                _dimensions.rows * TILESIZE.height * 0.5);
   for (int i = 0; i < _tiles.count; ++i)
   {
      GLTileNode * tile = [_tiles objectAtIndex:i];
      tile.isLiving = _storedTileStates[i];
      [tile setColorCenter:center];
   }
}

- (void)storeGridState
{
   for (int i = 0; i < _tiles.count; ++i)
      _storedTileStates[i] = ((GLTileNode *)[_tiles objectAtIndex:i]).isLiving;
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

- (void)clearGrid
{
   for (GLTileNode *tile in _tiles)
      [tile clearTile];
}

- (SKColor *)currentTileColor
{
   return _currentColor;
}

- (void)setCurrentColor:(UIColor *)color
{
   _currentColor = color;
   for (GLTileNode *tile in _tiles)
      [tile updateColor];
}

@end
