//
//  GLGrid.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/29/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLGrid.h"
#import "GLAppDelegate.h"
#import "GLTileNode.h"
#import "UIColor+CrossFade.h"

#include <vector>

#define LIVING YES
#define DEAD   NO
#define TILESIZE CGSizeMake(20, 20)

@interface GLGrid()
{
   std::vector<BOOL> _LiFE;
   std::vector<BOOL> _storedTileStates;
   std::vector<BOOL> _nextGenerationTileStates;
   std::vector<BOOL> _currentGenerationTileStates;
   std::vector<BOOL> _priorGenerationTileStates;

   BOOL _clearingGrid;
   BOOL _running;
   
   CrayolaColorName _currentColorName;
}

@end


@implementation GLGrid

- (id)initWithSize:(CGSize)size
{
   if (self = [super init])
      [self setupGridWithSize:size];
   
   return self;
}

- (void)loadLifeTileStates
{
   for (int i = 0; i < _tiles.count; ++i)
      _storedTileStates[i] = _LiFE[i];
}

- (void)loadStoredTileStates
{
   NSUserDefaults * standardDefaults = [NSUserDefaults standardUserDefaults];
   NSArray * storedState = ((NSArray *)[standardDefaults objectForKey:@"StoredTileState"]);
   if (storedState && storedState.count == _tiles.count)
      for (int i = 0; i < _tiles.count; ++i)
         _storedTileStates[i] = [((NSNumber *)[storedState objectAtIndex:i]) boolValue];
}

- (void)buildLife:(CGSize)size
{
   NSUInteger st = 10 * 16;  // st = sarting tile in the row
   
   // check for iPhone 5 - if so, shift the game up
   if (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
      if ([[[UIDevice currentDevice] model] isEqualToString: @"iPhone"])
         st = 12 * 16;
   
   if (_LiFE.size() <= st+109)
   {
      NSLog(@"Trying to initialize Life beyond grid size.");
      return;
   }
   
   _LiFE[st+1]   = _LiFE[st+2]   = _LiFE[st+3]   = _LiFE[st+5]   = _LiFE[st+7]   = _LiFE[st+11]  =
   _LiFE[st+12]  = _LiFE[st+13]  = _LiFE[st+17]  = _LiFE[st+21]  = _LiFE[st+23]  = _LiFE[st+27]  =
   _LiFE[st+33]  = _LiFE[st+37]  = _LiFE[st+39]  = _LiFE[st+43]  = _LiFE[st+49]  = _LiFE[st+53]  =
   _LiFE[st+55]  = _LiFE[st+56]  = _LiFE[st+57]  = _LiFE[st+59]  = _LiFE[st+60]  = _LiFE[st+61]  =
   _LiFE[st+65]  = _LiFE[st+71]  = _LiFE[st+75]  = _LiFE[st+81]  = _LiFE[st+85]  = _LiFE[st+87]  =
   _LiFE[st+91]  = _LiFE[st+97]  = _LiFE[st+103] = _LiFE[st+104] = _LiFE[st+105] = _LiFE[st+107] =
   _LiFE[st+108] = _LiFE[st+109] = LIVING;
}

- (void)setupGridWithSize:(CGSize)size
{
   SKColor * color = [SKColor colorForCrayolaColorName:_currentColorName];
   assert(color != nil);
   _dimensions.rows = size.width/TILESIZE.width;
   _dimensions.columns = size.width/TILESIZE.width;
   
   SKTexture *texture = [SKTexture textureWithImageNamed:@"tile.square.png"];
   double textureRotation = -M_PI_2;
   
   float maxRowHeight = size.height;
   
   // check for iPhone 5
   if (fabs((double)[[UIScreen mainScreen]bounds].size.height - (double)568) < DBL_EPSILON)
      if ([[[UIDevice currentDevice] model] isEqualToString: @"iPhone"])
         maxRowHeight -= TILESIZE.height;
   
   for (int yPos = 0; yPos < maxRowHeight; yPos += TILESIZE.height)
   {
      for (int xPos = 0; xPos < size.width; xPos += TILESIZE.width)
      {
         GLTileNode *tile = [GLTileNode tileWithTexture:texture
                                                   rect:CGRectMake(xPos + 0.5,
                                                                   yPos + 0.5,
                                                                   TILESIZE.width - 1,
                                                                   TILESIZE.height - 1)
                                            andRotation:textureRotation];
         tile.deadRotation = textureRotation;
         [self addChild:tile];
      }
   }
   
   _tiles = [NSArray arrayWithArray:self.children];
   
   _priorGenerationTileStates = std::vector<BOOL>(_tiles.count, DEAD);
   _currentGenerationTileStates = std::vector<BOOL>(_tiles.count, DEAD);
   _nextGenerationTileStates = std::vector<BOOL>(_tiles.count, DEAD);
   _storedTileStates = std::vector<BOOL>(_tiles.count, DEAD);
   _LiFE = std::vector<BOOL>(_tiles.count, DEAD);
   [self buildLife:(CGSize)size];
   
   CGPoint boardCenter = CGPointMake(_dimensions.columns * TILESIZE.width * 0.5,
                                     _dimensions.rows * TILESIZE.height * 0.5);
   float maxBoardDistance = sqrt(size.width * size.width * 3.25 + size.height * size.height * 3.25);
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
   int arrayIndex = row * _dimensions.columns + col;

   if (arrayIndex >= 0 && arrayIndex < _tiles.count)
      return [_tiles objectAtIndex:arrayIndex];

   return nil;
}

- (void)setDeadImage:(NSString *)deadImageName
{
   if (deadImageName.length == 0) return;
   
   SKTexture *texture = [SKTexture textureWithImageNamed:deadImageName];
   if (texture == nil) return;
   
   for (GLTileNode *tile in _tiles)
      tile.deadTexture = texture;
}

- (void)setDeadRotation:(double)rotation
{
   for (GLTileNode *tile in _tiles)
      tile.deadRotation = rotation;
}

- (void)setLiveImage:(NSString *)liveImageName
{
   SKTexture *texture = nil;
   
   if (liveImageName.length > 0)
      texture = [SKTexture textureWithImageNamed:liveImageName];
   
   for (GLTileNode *tile in _tiles)
      tile.liveTexture = texture;
}

- (void)setLiveRotation:(double)rotation
{
   for (GLTileNode *tile in _tiles)
      tile.liveRotation = rotation;
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
         return (_considersContinuousBiLoops)? [self currentlyInContinuousBiLoop] : NO;

   return YES;
}

- (void)storeGridState
{
   NSMutableArray * storedState = [NSMutableArray arrayWithCapacity:_tiles.count];
   for (int i = 0; i < _tiles.count; ++i)
   {
      _storedTileStates[i] = ((GLTileNode *)[_tiles objectAtIndex:i]).isLiving;
      [storedState addObject:[NSNumber numberWithBool:_storedTileStates[i]]];
   }
   
   _inContinuousLoop = NO;
   
   NSUserDefaults * standardDefaults = [NSUserDefaults standardUserDefaults];
   [standardDefaults setObject:[NSArray arrayWithArray:storedState] forKey:@"StoredTileState"];
}

- (void)restoreGrid
{
   if (!_running)
   {
      CGPoint center = CGPointMake(_dimensions.columns * TILESIZE.width * 0.5,
                                   _dimensions.rows * TILESIZE.height * 0.5);
      
      for (int i = 0; i < _tiles.count; ++i)
      {
         GLTileNode * tile = [_tiles objectAtIndex:i];
         tile.isLiving = _storedTileStates[i];
         [tile setColorCenter:center];
         [tile clearActionsAndRestore:YES];
      }
      
      _inContinuousLoop = NO;
   }
}

- (void)resetGrid
{
   for (GLTileNode *tile in _tiles)
   {
      [tile clearActionsAndRestore:YES];
      [tile clearTile];
   }
   
   _inContinuousLoop = NO;
}

- (NSMutableArray *)getLivingTiles
{
   NSMutableArray *livingTiles = [NSMutableArray new];
   for (GLTileNode *tile in _tiles)
      if (tile.isLiving)
         [livingTiles addObject:tile];

   return livingTiles;
}

- (void)clearGrid
{
   [self resetGrid];
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
   if (starting)
   {
      _running = YES;
      [self prepareForNextRun];
   }
   else
   {
      _running = NO;
   }
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

#pragma mark Helper Methods
- (NSArray *)getNeighborTilesForTile:(GLTileNode *)tile
{
   int tileIndex = (int)[_tiles indexOfObject:tile];
   NSMutableArray *neighbors = [NSMutableArray arrayWithCapacity:8];

   for (GLTileNode *tile in [self getCenterNeighborTilesForTileAtIndex:tileIndex])
      [neighbors addObject:tile];

   for (GLTileNode *tile in [self getEastNeighborTilesForTileAtIndex:tileIndex])
      [neighbors addObject:tile];

   for (GLTileNode *tile in [self getWestNeighborTilesForTileAtIndex:tileIndex])
      [neighbors addObject:tile];

   return [NSArray arrayWithArray:neighbors];
}

- (NSArray *)getCenterNeighborTilesForTileAtIndex:(int)index
{
   int neighborIndex;

   // north
   neighborIndex = index + _dimensions.columns;
   if (neighborIndex >= _tiles.count)
      neighborIndex -= _tiles.count;

   GLTileNode *northTile = [_tiles objectAtIndex:neighborIndex];

   // south
   neighborIndex = index - _dimensions.columns;
   if (neighborIndex < 0)
      neighborIndex += _tiles.count;

   GLTileNode *southTile = [_tiles objectAtIndex:neighborIndex];

   return @[northTile, southTile];
}

- (NSArray *)getEastNeighborTilesForTileAtIndex:(int)index
{
   NSMutableArray *returnTiles = [NSMutableArray arrayWithCapacity:3];

   int neighborIdx = index + 1;
   if (neighborIdx / _dimensions.columns > index / _dimensions.columns)
      neighborIdx -= _dimensions.columns;

   GLTileNode *eastTile = [_tiles objectAtIndex:neighborIdx];
   [returnTiles addObject:eastTile];

   for (GLTileNode *tile in [self getCenterNeighborTilesForTileAtIndex:neighborIdx])
      [returnTiles addObject:tile];

   return [NSArray arrayWithArray:returnTiles];
}
- (NSArray *)getWestNeighborTilesForTileAtIndex:(int)index
{
   NSMutableArray *returnTiles = [NSMutableArray new];

   int neighborIdx = index - 1;
   if (neighborIdx < 0 || neighborIdx / _dimensions.columns < index / _dimensions.columns)
      neighborIdx += _dimensions.columns;

   GLTileNode *westTile = [_tiles objectAtIndex:neighborIdx];
   [returnTiles addObject:westTile];

   for (GLTileNode *tile in [self getCenterNeighborTilesForTileAtIndex:neighborIdx])
      [returnTiles addObject:tile];

   return [NSArray arrayWithArray:returnTiles];
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

   GLTileNode *eastTile = [_tiles objectAtIndex:neighborIdx];
   if (eastTile.isLiving)
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

   GLTileNode *westTile = [_tiles objectAtIndex:neighborIdx];
   if (westTile.isLiving)
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
   return ((tile.isLiving && liveCount == 2) || (liveCount == 3)) ? LIVING : DEAD;
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
   for (GLTileNode * tile in _tiles)
      tile.colorCenter = position;
}

@end
