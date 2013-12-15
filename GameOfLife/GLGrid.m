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

#define IS_WIDESCREEN (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
#define IS_IPHONE     ([[[UIDevice currentDevice] model] isEqualToString: @"iPhone"])
#define IS_IPOD       ([[[UIDevice currentDevice] model] isEqualToString: @"iPod touch"])
#define IS_IPHONE_5   (IS_IPHONE && IS_WIDESCREEN)

#define LIVING YES
#define DEAD   NO
#define TILESIZE CGSizeMake(20, 20)

@interface GLGrid() <GLTileColorDelegate>
{
   std::vector<BOOL> _storedTileStates;
   std::vector<BOOL> _nextGenerationTileStates;
   std::vector<BOOL> _currentGenerationTileStates;
   std::vector<BOOL> _priorGenerationTileStates;

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
   float maxRowHeight = size.height;

   // check for iPhone 5
   if (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
      if ([[[UIDevice currentDevice] model] isEqualToString: @"iPhone"])
         maxRowHeight -= TILESIZE.height;
   
   SKTexture *texture1 = nil;
   SKTexture *texture2 = nil;
//   int i = arc4random_uniform(7);
   int i = 6;
   switch (i)
   {
      case 0:
         texture1 = [SKTexture textureWithImageNamed:@"tile.ring.png"];
         break;
      case 1:
         texture1 = [SKTexture textureWithImageNamed:@"tile.cylinder.png"];
         break;
      case 2:
         texture1 = [SKTexture textureWithImageNamed:@"tile.spiral.png"];
         break;
      case 3:
         texture1 = [SKTexture textureWithImageNamed:@"tile.buldge.png"];
         break;
      case 4:
         texture1 = [SKTexture textureWithImageNamed:@"tile.ring3d.png"];
         break;
      case 5:
         texture1 = [SKTexture textureWithImageNamed:@"tile.frowny.png"];
         texture2 = [SKTexture textureWithImageNamed:@"tile.smiley.png"];
         break;
      default:
         texture1 = [SKTexture textureWithImageNamed:@"tile.circle.png"];
   }
   
   for (int yPos = 0; yPos < maxRowHeight; yPos += TILESIZE.height)
   {
      for (int xPos = 0; xPos < size.width; xPos += TILESIZE.width)
      {
         GLTileNode *tile = [GLTileNode tileWithTexture:texture1
                                                   rect:CGRectMake(xPos + 0.5,
                                                                   yPos + 0.5,
                                                                   TILESIZE.width - 1,
                                                                   TILESIZE.height - 1)];
         if (texture2)
            tile.liveTexture = texture2;
         
         tile.delegate = self;
         [self addChild:tile];
      }
   }
   
   _tiles = [NSArray arrayWithArray:self.children];
   
   _priorGenerationTileStates = std::vector<BOOL>(_tiles.count, DEAD);
   _currentGenerationTileStates = std::vector<BOOL>(_tiles.count, DEAD);
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

- (void)updateNextGeneration
{
   for (int i = 0; i < _tiles.count; ++i)
   {
      _priorGenerationTileStates[i] = _currentGenerationTileStates[i];
      _currentGenerationTileStates[i] = _nextGenerationTileStates[i];
      _nextGenerationTileStates[i] = [self getIsLivingForNextGenerationAtIndex:i];
   }
   
   _inContinuousLoop = [self currentlyInContinuousLoop];
   if (_inContinuousLoop)
      return;

   if ([self currentlyInContinuousBiLoop] == NO)
      ++_generationCount;  // don't add to count if we are not generating new life
   
   for (int i = 0; i < _tiles.count; ++i)
      ((GLTileNode *)[_tiles objectAtIndex:i]).isLiving = _nextGenerationTileStates[i];

   [self updateColorCenter];
}

- (BOOL)currentlyInContinuousBiLoop
{
   for (int i = 0; i < _tiles.count; ++i)
      if (_nextGenerationTileStates[i] != _priorGenerationTileStates[i])
         return NO;
   
   return YES;
}

- (BOOL)currentlyInContinuousLoop
{
   for (int i = 0; i < _tiles.count; ++i)
      if (((GLTileNode *)_tiles[i]).isLiving != _nextGenerationTileStates[i])
         return NO;

   return YES;
}

- (void)storeGridState
{
   for (int i = 0; i < _tiles.count; ++i)
      _storedTileStates[i] = ((GLTileNode *)[_tiles objectAtIndex:i]).isLiving;

   _inContinuousLoop = NO;
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
   _inContinuousLoop = NO;
}

- (void)clearGrid
{
   for (GLTileNode *tile in _tiles)
      [tile clearTile];
   
   _inContinuousLoop = NO;
}

- (void)prepareForNextRun
{
   _generationCount = 0;
   
   for (int i = 0; i < _tiles.count; ++i)
   {
      BOOL isLiving = ((GLTileNode*)[_tiles objectAtIndex:i]).isLiving;
      _priorGenerationTileStates[i] = DEAD;
      _currentGenerationTileStates[i] = isLiving;
      _nextGenerationTileStates[i] = isLiving;
   }
}

- (void)toggleRunning:(BOOL)starting
{
   if (starting) [self prepareForNextRun];
}

- (void)setCurrentColor:(UIColor *)color
{
   _currentColor = color;
   for (GLTileNode *tile in _tiles)
      [tile updateColor];
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

- (BOOL)currentStateIsRunnable
{
   for (int i=0; i < _tiles.count; ++i)
      if (((GLTileNode*)_tiles[i]).isLiving != [self getIsLivingForNextGenerationAtIndex:i])
         return YES;
   
   return NO;
}

#pragma mark GLTileColor Delegate Methods
- (SKColor *)currentTileColor
{
   return _currentColor;
}

#pragma mark Helper Methods
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

@end
