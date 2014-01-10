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

@interface GLGrid() <GLTileColorDelegate>
{
   std::vector<BOOL> _storedTileStates;
   std::vector<BOOL> _nextGenerationTileStates;
   std::vector<BOOL> _currentGenerationTileStates;
   std::vector<BOOL> _priorGenerationTileStates;

   BOOL _clearingGrid;
   BOOL _running;

   NSMutableArray *_potentialTileColors;
   CrayolaColorName _currentColorName;
}

@end


@implementation GLGrid

- (id)initWithSize:(CGSize)size
{
   if (self = [super init])
   {
      _potentialTileColors = [NSMutableArray new];
      [self setupGridWithSize:size];
   }
   return self;
}

- (void)loadStoredTileStates
{
   NSUserDefaults * standardDefaults = [NSUserDefaults standardUserDefaults];
   NSArray * storedState = ((NSArray *)[standardDefaults objectForKey:@"StoredTileState"]);
   if (storedState && storedState.count == _tiles.count)
      for (int i = 0; i < _tiles.count; ++i)
         _storedTileStates[i] = [((NSNumber *)[storedState objectAtIndex:i]) boolValue];
}

- (void)setupGridWithSize:(CGSize)size
{
   SKColor * color = [UIColor colorForCrayolaColorName:_currentColorName];
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
         tile.tileColorDelegate = self;
         tile.liveColor = color;
         tile.deadRotation = textureRotation;
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

- (void)updateTextures
{
   for (GLTileNode *tile in _tiles)
      [tile updateTextures];
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
      SKColor *liveColor = [UIColor colorForCrayolaColorName:_currentColorName];
      for (int i = 0; i < _tiles.count; ++i)
      {
         GLTileNode * tile = [_tiles objectAtIndex:i];
         if (liveColor) tile.liveColor = liveColor;
         tile.isLiving = _storedTileStates[i];
         [tile setColorCenter:center];
      }
      
      _inContinuousLoop = NO;
   }
}

- (void)resetGrid
{
   for (GLTileNode *tile in _tiles)
      [tile clearTile];
   
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

- (void)resetTilesWithTileArray:(NSMutableArray *)tileArray index:(NSUInteger)tileIndex
{
   if (tileIndex >= tileArray.count)
   {
      // wait for the last tile to run the clearing actions
      [self runAction:[SKAction waitForDuration:.4]
           completion:^
      {
         _clearingGrid = NO;
      }];
      return;
   }

   GLTileNode *tile = [tileArray objectAtIndex:tileIndex];
   GLTileNode *dummyTile = [GLTileNode tileWithTexture:tile.texture
                                                  rect:tile.frame
                                           andRotation:0.0];
   [tile removeFromParent];
   [self addChild:dummyTile];
   [self addChild:tile];

   SKAction *scaleUp = [SKAction scaleTo:1.2 duration:.3];
   scaleUp.timingMode = SKActionTimingEaseIn;
   SKAction *scaleDown = [SKAction scaleTo:1 duration:.1];
   SKAction *decreaseAlpha = [SKAction fadeAlphaTo:0 duration:.3];
   decreaseAlpha.timingMode = SKActionTimingEaseIn;
   SKAction *rotateAndScaleUp = [SKAction group:@[scaleUp, decreaseAlpha]];
   SKAction *tileActions = [SKAction sequence:@[rotateAndScaleUp, scaleDown]];

   [tile runAction:tileActions
        completion:
    ^{
       tile.alpha = 1;
       tile.color = [SKColor colorForCrayolaColorName:tile.deadColorName];
       tile.isLiving = NO;
       [dummyTile removeFromParent];
    }];

   [self resetTilesWithTileArray:tileArray index:++tileIndex];
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

- (void)setLiveColorName:(CrayolaColorName)colorName
{
   SKColor * color = [UIColor colorForCrayolaColorName:colorName];
   if (color)
   {
      _currentColorName = colorName;
      for (GLTileNode *tile in _tiles)
      {
         tile.liveColor = color;
         [tile updateLivingAndColor:tile.isLiving];
      }
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

#pragma mark GLTileColor Delegate Methods
- (SKColor *)currentTileColor
{
   return [UIColor colorForCrayolaColorName:_currentColorName];
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
   {
      [_potentialTileColors addObject:tile.liveColor];
      ++liveCount;
   }

   // south
   neighborIndex = index - _dimensions.columns;
   if (neighborIndex < 0)
      neighborIndex += _tiles.count;

   tile = [_tiles objectAtIndex:neighborIndex];
   if (tile.isLiving)
   {
      [_potentialTileColors addObject:tile.liveColor];
      ++liveCount;
   }

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
   {
      [_potentialTileColors addObject:eastTile.liveColor];
      ++result;
   }

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
   {
      [_potentialTileColors addObject:westTile.liveColor];
      ++result;
   }

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
   [_potentialTileColors removeAllObjects];
   int liveCount = [self getNorthSouthTileLiveCountForTileAtIndex:index];
   liveCount += [self getEastTileLiveCountForTileAtIndex:index];

   if (liveCount > 3) return DEAD; // optimization - no need to check any further

   liveCount += [self getWestTileLiveCountForTileAtIndex:index];

   GLTileNode * tile = [_tiles objectAtIndex:index];

   // behold, the meaning of life (all in one statement)
   if ((tile.isLiving && liveCount == 2) || (liveCount == 3))
   {
      tile.liveColor = (tile.isLiving)? tile.liveColor :
                                        [_potentialTileColors objectAtIndex:arc4random_uniform(3)];
      return LIVING;
   }
   else
      return DEAD;
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
