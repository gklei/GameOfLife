//
//  GLGrid.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/29/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLGrid.h"
#import "GLAlertLayer.h"
#import "GLAppDelegate.h"
#import "GLHUDSettingsManager.h"
#import "GLScannerAnimation.h"
#import "GLTileNode.h"
#import "UIColor+CrossFade.h"

#include <list>
#include <map>
#include <vector>

#define LIVING YES
#define DEAD   NO

#define MAX_LOOP_DETECT_DEPTH 4096

#define TILESIZE CGSizeMake(20, 20)

@interface GLGrid() <GLTileColorProvider, HUDSettingsObserver>
{
   std::list<std::vector<char> > _generationLoops;
   
   std::vector<char> _LiFE;
   std::vector<char> _storedTileStates;
   std::vector<char> _nextGenerationTileStates;
   std::vector<CrayolaColorName> _storedTileColorNames;
   std::vector<CrayolaColorName> _currentTileColorNames;

   std::vector<char> _scannedStates;
   std::vector<CrayolaColorName> _scannedColors;
   
   BOOL _running;
   BOOL _startedWithLife;
   
   // color handling 
   BOOL _lockedColorMode;
   BOOL _trackGeneration;
   
   CGFloat _boardMaxDistance;
   CGPoint _currentColorCenter;
   CGSize  _viewSize;
   CGSize  _gridSize;  // may be smaller than _viewSize
   
   NSUInteger _gridImageIndex;
   
   CrayolaColorName _currentColorName;
}
@end

@implementation GLGrid

+ (int)currentVersion
{
   return 1;
}

- (void)observeGridLiveColorNameChanges
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"GridLiveColorName"];
}

- (void)observeLockedColorMode
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"LockedColorMode"];
}

- (void)observeTileGenerationTracking
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"TileGenerationTracking"];
}

- (void)setupObservations
{
   [self observeGridLiveColorNameChanges];
   [self observeLockedColorMode];
   [self observeTileGenerationTracking];
}

- (id)initWithSize:(CGSize)size
{
   if (self = [super init])
   {
      [self setupGridWithSize:size];
      [self setupObservations];
   }
   
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
   
   NSArray * storedColors = ((NSArray *)[standardDefaults objectForKey:@"StoredTileColors"]);
   if (storedColors && storedColors.count == _tiles.count)
   {
      for (int i = 0; i < _tiles.count; ++i)
      {
         _storedTileColorNames[i] = (CrayolaColorName)[((NSNumber *)[storedColors objectAtIndex:i])
                                                       intValue];
         _currentTileColorNames[i] = _storedTileColorNames[i];
      }
   }
}

- (void)buildLiFE
{
   static const NSUInteger LiFEheight = 7;
   int row = (_dimensions.rows - LiFEheight) * 0.5;
   NSUInteger startingRow = ((_dimensions.rows - LiFEheight) - row) + 1;
   NSUInteger st = startingRow * _dimensions.columns;
   
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
   _viewSize = size;
   _dimensions.rows = size.height / TILESIZE.height;
   _dimensions.columns = size.width / TILESIZE.width;
   _gridSize = CGSizeMake(_dimensions.columns * TILESIZE.width,
                          _dimensions.rows * TILESIZE.height);
   
   _currentColorCenter = CGPointMake(_dimensions.columns * TILESIZE.width * 0.5,
                                     _dimensions.rows * TILESIZE.height * 0.5);
   _boardMaxDistance = sqrt(size.width * size.width * 3.25 + size.height * size.height * 3.25);
   
   SKTexture *texture = [SKTexture textureWithImageNamed:@"tile.square.png"];
   double textureRotation = -M_PI_2;
   
   for (int yPos = 0; yPos < _gridSize.height; yPos += TILESIZE.height)
   {
      for (int xPos = 0; xPos < _gridSize.width; xPos += TILESIZE.width)
      {
         GLTileNode *tile = [GLTileNode tileWithTexture:texture
                                                   rect:CGRectMake(xPos + 0.5,
                                                                   yPos + 0.5,
                                                                   TILESIZE.width - 1,
                                                                   TILESIZE.height - 1)
                                            andRotation:textureRotation];
         tile.colorProvider = self;
         tile.deadRotation = textureRotation;
         [self addChild:tile];
      }
   }
   
   _tiles = [NSArray arrayWithArray:self.children];
   
   NSUInteger count = _tiles.count;
   _nextGenerationTileStates = std::vector<char>(count, DEAD);
   _storedTileStates = std::vector<char>(count, DEAD);
   _LiFE = std::vector<char>(count, DEAD);
   
   _storedTileColorNames = std::vector<CrayolaColorName>(count, CCN_INVALID_CrayolaColor);
   _currentTileColorNames = std::vector<CrayolaColorName>(count, CCN_INVALID_CrayolaColor);

   _scannedStates = std::vector<char>(_tiles.count, DEAD);
   _scannedColors = std::vector<CrayolaColorName>(_tiles.count, CCN_INVALID_CrayolaColor);

   [self buildLiFE];
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

- (void)addGenerationToLoopDetection:(std::vector<char>)generation
{
   _generationLoops.push_front(generation);
   
   if (_generationLoops.size() > MAX_LOOP_DETECT_DEPTH)
      _generationLoops.pop_back();
}

- (CrayolaColorName)calculateColorNameForTile:(GLTileNode *)node
{
   if (!_lockedColorMode)
   {
      NSArray * neighbors = [self geLiveNeighborTilesForTile:node];
      if (neighbors.count == 3)
      {
         u_int32_t item = arc4random_uniform(3);
         GLTileNode * tile = ((GLTileNode *)[neighbors objectAtIndex:item]);
         NSUInteger index = [self indexOfTile:tile];
         if (index < _currentTileColorNames.size())
            return _currentTileColorNames[index];
      }
      
      NSLog(@"Couldn't find a neighboring node");
   }
   
   return _currentColorName;
}

- (void)updateLivingColors
{
   for (NSUInteger i = 0; i < _tiles.count; ++i)
   {
      GLTileNode * tile = _tiles[i];
      bool alive = _nextGenerationTileStates[i];
      if (alive && ![tile isLiving])   // tile is coming alive
         _currentTileColorNames[i] = [self calculateColorNameForTile:tile];
   }
}

- (void)updateNextGeneration
{
   for (int i = 0; i < _tiles.count; ++i)
      _nextGenerationTileStates[i] = [self getIsLivingForNextGenerationAtIndex:i];
   
   _inContinuousLoop = [self currentlyInContinuousLoop];
   if (_inContinuousLoop)
      return;  // nothing new to generate
   
   bool deepLoop = [self currentlyInContinuousDeepLoop];
   if (deepLoop)
   {
      if (_considerDeeperLoops)
      {
         _inContinuousLoop = YES;
         _generationLoops.clear();
         return;  // nothing new to generate
      }
   }
   else
   {
      [self addGenerationToLoopDetection:_nextGenerationTileStates];
      ++_generationCount;
   }
   
   [self updateLivingColors];
   
   for (int i = 0; i < _tiles.count; ++i)
      [((GLTileNode *)[_tiles objectAtIndex:i])
         setIsLivingAndUpdateColor:_nextGenerationTileStates[i]];

   [self updateColorCenter];
}

- (BOOL)currentlyInContinuousDeepLoop
{
   unsigned long count = _nextGenerationTileStates.size();
   std::list<std::vector<char> >::iterator it = _generationLoops.begin();
   for (; it != _generationLoops.end(); ++it)
      if (memcmp(&(_nextGenerationTileStates[0]), &((*it)[0]), count) == 0)
         return YES;
   
   return NO;
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
   _startedWithLife = YES;
   
   NSMutableArray * storedState = [NSMutableArray arrayWithCapacity:_tiles.count];
   NSMutableArray * storedColors = [NSMutableArray arrayWithCapacity:_tiles.count];
   
   for (int i = 0; i < _tiles.count; ++i)
   {
      _storedTileStates[i] = ((GLTileNode *)[_tiles objectAtIndex:i]).isLiving;
      [storedState addObject:[NSNumber numberWithBool:_storedTileStates[i]]];
      _storedTileColorNames[i] = _currentTileColorNames[i];
      [storedColors addObject:[NSNumber numberWithInteger:_storedTileColorNames[i]]];
      
      if (_startedWithLife && _storedTileStates[i] != _LiFE[i])
         _startedWithLife = NO;
   }
   
   _inContinuousLoop = NO;
   
   NSUserDefaults * standardDefaults = [NSUserDefaults standardUserDefaults];
   [standardDefaults setObject:[NSArray arrayWithArray:storedState] forKey:@"StoredTileState"];
   [standardDefaults setObject:[NSArray arrayWithArray:storedColors] forKey:@"StoredTileColors"];
}

- (void)restoreGrid
{
   if (!_running)
   {
      _currentColorCenter = CGPointMake(_dimensions.columns * TILESIZE.width * 0.5,
                                        _dimensions.rows * TILESIZE.height * 0.5);
      
      for (int i = 0; i < _tiles.count; ++i)
      {
         GLTileNode * tile = [_tiles objectAtIndex:i];
         [tile setIsLiving:_storedTileStates[i]];
         _currentTileColorNames[i] = _storedTileColorNames[i];
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
   
   for (int i = 0; i < _currentTileColorNames.size(); ++i)
      _currentTileColorNames[i] = CCN_INVALID_CrayolaColor;
   
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
   _generationLoops.clear();
}

- (void)toggleRunning:(BOOL)starting
{
   if (starting)
   {
      _running = YES;
      _inContinuousLoop = NO;
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
- (int)rowForDistanceFromTop:(int)distance
{
   int row = _dimensions.rows - (distance/TILESIZE.height);
   return row;
}

- (NSArray *)geLiveNeighborTilesForTile:(GLTileNode *)tile
{
   int tileIndex = (int)[_tiles indexOfObject:tile];
   NSMutableArray *neighbors = [NSMutableArray arrayWithCapacity:8];

   for (GLTileNode *tile in [self getCenterNeighborTilesForTileAtIndex:tileIndex])
      if (tile.isLiving)
         [neighbors addObject:tile];

   for (GLTileNode *tile in [self getEastNeighborTilesForTileAtIndex:tileIndex])
      if (tile.isLiving)
         [neighbors addObject:tile];

   for (GLTileNode *tile in [self getWestNeighborTilesForTileAtIndex:tileIndex])
      if (tile.isLiving)
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

   _currentColorCenter = ((GLTileNode *)[_tiles objectAtIndex:indexForColorCenter]).position;
}

- (BOOL)isCleared
{
   for (GLTileNode *tile in _tiles)
      if ([tile isLiving])
         return NO;
   
   return YES;
}

- (BOOL)startedWithLife
{
   return _startedWithLife;
}

- (void)refreshBoard
{
   for (GLTileNode *tile in _tiles)
      [tile clearActionsAndRestore:NO];
}

- (NSUInteger)indexOfTile:(GLTileNode *)tile
{
   NSUInteger location = 0;
   for (GLTileNode * node in _tiles)
   {
      if (tile == node) return location;
      ++location;
   }
   
   return location;
}

- (void)toggleTileLiving:(GLTileNode *)tile
{
   NSUInteger index = [self indexOfTile:tile];
   if (index < _tiles.count)
      _currentTileColorNames[index] = CCN_INVALID_CrayolaColor;
   
   [tile setIsLiving:![tile isLiving]];
}

#pragma mark - Image Scanning Code
- (int)alphaTypeForImage:(CGImageRef)imageRef
{
   int result = -1;
   
   size_t bpp = CGImageGetBitsPerPixel(imageRef);
   CGColorSpaceModel colormodel = CGColorSpaceGetModel(CGImageGetColorSpace(imageRef));
   
   if (bpp != 32|| colormodel != kCGColorSpaceModelRGB)
      return result;  // we only supporting a subset of image formats currently
   
   CGBitmapInfo info = CGImageGetBitmapInfo(imageRef);
   return (info & kCGBitmapAlphaInfoMask);
}

- (BOOL)canScanPreScaledImage:(CGImageRef)imageRef
                 getRedOffset:(int &)redOffset
                getBlueOffset:(int &)blueOffet
{
   // make sure the image was prescaled properly
   size_t pixelWidth = CGImageGetWidth(imageRef);
   size_t pixelHeight = CGImageGetHeight(imageRef);
   
   if (pixelWidth != _gridSize.width || pixelHeight != _gridSize.height)
   {
      NSLog(@"Image not pre-scaled properly");
      return NO;
   }
   
   // verify we can scan the image and if so, set the color offsets
   switch ([self alphaTypeForImage:imageRef])
   {
      case -1:
         NSLog(@"Unsupported image format");
         return NO;
      case kCGImageAlphaPremultipliedFirst:  // fall through
      case kCGImageAlphaFirst:               // fall through
      case kCGImageAlphaNoneSkipFirst:
         redOffset = 2; // BGRA
         blueOffet = 0;
         break;
      default:
         redOffset = 0; // RGBA
         blueOffet = 2;
   }
   
   return YES;
}

- (BOOL)scanPreScaledImage:(CGImageRef)imageRef
                    colors:(std::vector<CrayolaColorName> &)colors
                   flipped:(BOOL)flipped
{
   int offsetR, offsetB;
   if (![self canScanPreScaledImage:imageRef getRedOffset:offsetR getBlueOffset:offsetB])
      return NO;
   
   CFDataRef pixelData = CGDataProviderCopyData(CGImageGetDataProvider(imageRef));
   if (pixelData == NULL)
      return NO;
      
   const UInt8 * data = CFDataGetBytePtr(pixelData);
   
   size_t pixelWidth = CGImageGetWidth(imageRef);
   size_t pixelHeight = CGImageGetHeight(imageRef);
   
   int scanWidth  = (int)((float)pixelWidth  / _dimensions.columns);
   int scanHeight = (int)((float)pixelHeight / _dimensions.rows);
   
   int scanWidthOffset  = scanWidth * 0.5;
   int scanHeightOffset = scanHeight * 0.5;
   
   for (int row = 0; row < _dimensions.rows; ++row)
   {
      for (int col = 0; col < _dimensions.columns; ++col)
      {
         int xPos = col * scanWidth + scanWidthOffset;
         int yPos = row * scanHeight + scanHeightOffset;
         
         unsigned long pixelPos = ((pixelWidth  * yPos) + xPos) * 4;
         
         CGFloat red   = data[pixelPos + offsetR] / 255.0;
         CGFloat green = data[(pixelPos + 1)]     / 255.0;
         CGFloat blue  = data[pixelPos + offsetB] / 255.0;
         CGFloat alpha = data[pixelPos + 3]       / 255.0;
         
         CrayolaColorName name = [UIColor nearestCrayolaColorNameForR:red g:green b:blue a:alpha];
         
         // if the image is already flipped, then it is in the same orientation
         // as OpenGL, so just set the calculate index normally
         // if the image is not flipped, then we must flip the index to  compensate
         // for the fact that OpenGl is flipped compared to cocoa
         int index = flipped? row * _dimensions.columns + col:
                              ((_dimensions.rows - 1) - row) * _dimensions.columns + col;
         
         colors[index] = name;
      }
   }
   
   CFRelease(pixelData);
   return YES;
}

- (CrayolaColorName)calculateBackgroundColor:(std::vector<CrayolaColorName> &)colors
{
   // count the color name occurances
   size_t arraySize = colors.size();
   
   std::map<CrayolaColorName, uint32_t> colorAndCount;
   for (int i = 0; i < arraySize; ++i)
      colorAndCount[colors[i]]++;
   
   CrayolaColorName result = CCN_INVALID_CrayolaColor;
   uint32_t largestOccurance = 0;
   std::map<CrayolaColorName, uint32_t>::iterator it = colorAndCount.begin();
   for (; it != colorAndCount.end(); ++it)
   {
      if (it->second > largestOccurance)
      {
         largestOccurance = it->second;
         result = it->first;
      }
   }
   
   return result;
}

- (void)updateTileState:(std::vector<char> &)states
               andColor:(std::vector<CrayolaColorName> &)colors
     forBackgroundColor:(CrayolaColorName)bkgrndColor
{
   assert(states.size() == colors.size());
   
   size_t count = states.size();
   for (int i = 0; i < count; ++i)
      if (colors[i] == bkgrndColor)
         colors[i] = CCN_INVALID_CrayolaColor;
      else if (colors[i] != CCN_INVALID_CrayolaColor)
         states[i] = LIVING;
}

- (void)loadGameWithState:(std::vector<char> &)states
                 andColor:(std::vector<CrayolaColorName> &)colors
{
   assert(states.size() == colors.size());
   
   for (int i = 0; i < states.size(); ++i)
   {
      _storedTileStates[i] = states[i];
      _storedTileColorNames[i] = colors[i];
   }
   
   [self restoreGrid];
}

- (void)loadRow:(int)row
  withGameState:(std::vector<char> &)states
         colors:(std::vector<CrayolaColorName> &)colors
{
   int startTileIndex = row * _dimensions.columns;
   for (int i = startTileIndex; i < startTileIndex + _dimensions.columns; ++ i)
   {
      _storedTileStates[i] = states[i];
      _storedTileColorNames[i] = colors[i];
   }
   [self restoreGrid];
}

- (void)scanPreScaledImageForGameBoard:(CGImageRef)imageRef flipped:(BOOL)flipped
{
   _scannedColors.clear();
   _scannedColors = std::vector<CrayolaColorName>(_tiles.count, CCN_INVALID_CrayolaColor);

   _scannedStates.clear();
   _scannedStates = std::vector<char>(_tiles.count, DEAD);

   if (![self scanPreScaledImage:imageRef colors:_scannedColors flipped:flipped])
      return;
   
   CrayolaColorName bgrndColor = [self calculateBackgroundColor:_scannedColors];

   [self updateTileState:_scannedStates
                andColor:_scannedColors
      forBackgroundColor:bgrndColor];
}

static inline double radians(double degrees) {return degrees * M_PI/180;}

- (void)scanImageForGameBoard:(UIImage *)image
{
   if (image)
   {
      if (image.size.width != _gridSize.width || image.size.height != _gridSize.height)
      {
         CGRect imageRect = CGRectMake(0, 0, _gridSize.width, _gridSize.height);
         UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, 1.0);
         CGContextRef context = UIGraphicsGetCurrentContext();
         CGContextSetInterpolationQuality(context, kCGInterpolationHigh);
         CGContextSetShouldAntialias(context, NO);
         [image drawInRect:imageRect];
         image = UIGraphicsGetImageFromCurrentImageContext();
         UIGraphicsEndImageContext();
      }
      
      BOOL imageIsFlipped = (image.imageOrientation == UIImageOrientationDown);
      [self scanPreScaledImageForGameBoard:[image CGImage] flipped:imageIsFlipped];
   }
}

- (BOOL)readGridRepresentation:(NSString *)gridRep
{
   if (gridRep)
   {
      NSArray * data = [gridRep componentsSeparatedByString:@","];
      int headerFields = 8;
      if (data.count < headerFields) return NO;
      if ([(NSString *)[data objectAtIndex:0] compare:@"GRID"] != NSOrderedSame) return NO;
      int version = [(NSString *)[data objectAtIndex:1] intValue];
      if (version != GLGrid.currentVersion) return NO;
      if ([(NSString *)[data objectAtIndex:2] compare:@"IMAGE"] != NSOrderedSame) return NO;
      int imageIndex = [(NSString *)[data objectAtIndex:3] intValue];
      if ([(NSString *)[data objectAtIndex:4] compare:@"WIDTH"] != NSOrderedSame) return NO;
      int columns = [(NSString *)[data objectAtIndex:5] intValue];
      if (columns != _dimensions.columns) return NO;
      if ([(NSString *)[data objectAtIndex:6] compare:@"HEIGHT"] != NSOrderedSame) return NO;
      int rows = [(NSString *)[data objectAtIndex:7] intValue];
      if (rows == 0) return NO;
      if (data.count < rows * columns * 2) return NO;
      
      int startIndex = headerFields;
      int girdDataEnd = rows * columns + startIndex;
      
      // verify the data looks correct
      if ([(NSString *)[data objectAtIndex:girdDataEnd] compare:@"COLOR"] != NSOrderedSame) return NO;
      
      // scan the state
      _scannedStates.clear();
      _scannedStates = std::vector<char>(_tiles.count, DEAD);
      
      int loopEnd = std::min(_dimensions.rows, rows) * columns + startIndex;
      for (int index = startIndex; index < loopEnd; ++index)
         if ([(NSString *)[data objectAtIndex:index] intValue] != 0)
            _scannedStates[index - startIndex] = LIVING;
      
      // scan the color
      startIndex = girdDataEnd + 1;
      girdDataEnd = rows * columns + startIndex;
      loopEnd = std::min(_dimensions.rows, rows) * columns + startIndex;
      
      _scannedColors.clear();
      _scannedColors = std::vector<CrayolaColorName>(_tiles.count, CCN_INVALID_CrayolaColor);
      for (int index = startIndex; index < loopEnd; ++index)
      {
         CrayolaColorName name =
            (CrayolaColorName)[(NSString *)[data objectAtIndex:index] intValue];
         
         if (name < CCN_INVALID_CrayolaColor ||  name >= CCN_MAXIMUM_CrayolaColor)
            _scannedColors[index - startIndex] = CCN_INVALID_CrayolaColor;
         else
            _scannedColors[index - startIndex] = name;
      }
      
      NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
      [defaults setObject:[NSNumber numberWithUnsignedLong:imageIndex]
                   forKey:@"GridImageIndex"];
      
      return YES;
   }
   
   return NO;
}

- (void)scanImageDataForGameBoard:(NSDictionary *) imageData
{
   NSString * gridRep = [imageData objectForKey:@"GridRep"];
   
   if (gridRep)
      if ([self readGridRepresentation:gridRep])
         return;
   
   UIImage * image = [imageData objectForKey:@"UIImage"];
   [self scanImageForGameBoard:image];
}

- (void)scanAnimationFinished
{
   // scan animation is done,  ensure game is fully loaded
   size_t count = _scannedStates.size();
   for (size_t i = 0; i < count; ++ i)
   {
      _storedTileStates[i] = _scannedStates[i];
      _storedTileColorNames[i] = _scannedColors[i];
   }
   
   [self restoreGrid];
   [self storeGridState];
}

- (void)setGridImageIndex:(NSUInteger)gridIndex
{
   _gridImageIndex = gridIndex;
}

- (NSString *)generateMetaData
{
   unsigned long count = _tiles.count;
   NSUInteger capacity = count * (2 + 3) + 34;  // 2 chars per tile for state + 3 for color
                                                // plus 34 for the various header fields
   NSMutableString * result = [NSMutableString stringWithCapacity:capacity];
   
   // add the grid state
   [result appendString:[NSString stringWithFormat:@"GRID,%d,IMAGE,%lu,WIDTH,%d,HEIGHT,%d,",
                         GLGrid.currentVersion, (unsigned long)_gridImageIndex,
                         _dimensions.columns, _dimensions.rows]];
   
   for (GLTileNode * node in _tiles)
   {
      if (node.isLiving)
         [result appendString:@"1,"];
      else
         [result appendString:@"0,"];
   }
   
   // add the grid color
   [result appendString:@"COLOR,"];
   
   for (GLTileNode * node in _tiles)
   {
      CrayolaColorName color = [self colorNameForNode:node];
      [result appendString:[NSString stringWithFormat:@"%d,", color]];
   }

   return result;
}

#pragma mark GLScannerDelegate protocol
- (void)scannerAnimation:(GLScannerAnimation *)animation scannedOverDistance:(CGFloat)distance
{
   [self loadRow:[self rowForDistanceFromTop:(int)distance]
   withGameState:_scannedStates
          colors:_scannedColors];
}

#pragma mark - HUDSettingsObserver protocol
- (void)settingChanged:(NSNumber *)value ofType:(HUDValueType)type forKeyPath:(NSString *)keyPath
{
   if ([keyPath compare:@"GridLiveColorName"] == NSOrderedSame)
   {
      assert(type == HVT_UINT);
      
      // verify the live color name is valid;
      CrayolaColorName colorName = (CrayolaColorName)[value unsignedIntValue];
      SKColor * color = [SKColor colorForCrayolaColorName:colorName];
      if (color == nil)
         return;
      
      _currentColorName = colorName;
   }
   else if ([keyPath compare:@"TileGenerationTracking"] == NSOrderedSame)
   {
      assert(type == HVT_BOOL);
      
      _trackGeneration = [value boolValue];
   }
   else if ([keyPath compare:@"LockedColorMode"] == NSOrderedSame)
   {
      assert(type == HVT_BOOL);
      
      _lockedColorMode = [value boolValue];
   }
   
   [self refreshBoard];
}

#pragma mark - color calculation helpers

- (CGFloat)calcDistanceFromStart:(CGPoint)start toEnd:(CGPoint)end
{
   CGFloat dist = sqrt((start.x - end.x) * (start.x - end.x) +
                       (start.y - end.y) * (start.y - end.y));
   return dist;
}

- (CGFloat)colorDistanceForTile:(GLTileNode *)tile
{
   CGFloat dist = [self calcDistanceFromStart:_currentColorCenter toEnd:tile.position];
   dist /= _boardMaxDistance;
   return 1.0 - dist;
}

- (SKColor *)deadColor
{
   return [SKColor crayolaCoconutColor];
}

- (CrayolaColorName)colorNameForNode:(GLTileNode *)node
{
   if (_lockedColorMode) return _currentColorName;
   
   if (node && node.isLiving)
   {
      NSUInteger index = [self indexOfTile:node];
      if (index >= _tiles.count)
      {
         NSLog(@"indexOfTile returned invalid index (%lu)", (unsigned long)index);
         return _currentColorName;
      }
      
      CrayolaColorName colorName = _currentTileColorNames[index];
      if (colorName == CCN_INVALID_CrayolaColor)
         colorName = _currentColorName;
      
      return colorName;
   }
   
   return CCN_BACKGROUND_CrayolaColor;
}

- (SKColor *)colorForNode:(GLTileNode *)node withColorName:(CrayolaColorName)colorName
{
   if (_trackGeneration)
   {
      NSInteger nodeGenCount = node.generationCount - 1;
      colorName = [SKColor getColorNameForIndex:(colorName + nodeGenCount)];
   }
   
   CGFloat   dist = [self colorDistanceForTile:node];
   SKColor * liveColor = [SKColor colorForCrayolaColorName:colorName];
   
   if (node.generationCount == 0)
   {
      // special case for handling  
      CGFloat h, s, b;
      if ([liveColor getHue:&h saturation:&s brightness:&b alpha:0])
         return [SKColor colorWithHue:h saturation:s * 2 brightness:b * 2 alpha:1.0];
   }
   
   CGFloat r, g, b;
   if ([liveColor getRed:&r green:&g blue:&b alpha:0])
      return [SKColor colorWithRed:dist * r green:dist * g blue:dist * b alpha:1.0];
   
   NSLog(@"WTF???");
   return [SKColor colorForCrayolaColorName:_currentColorName];
}

- (SKColor *)unlockedColorForNode:(GLTileNode *)node
{
   NSUInteger index = [self indexOfTile:node];
   if (index >= _tiles.count)
   {
      NSLog(@"indexOfTile returned invalid index (%lu)", (unsigned long)index);
      return [self colorForNode:node withColorName:_currentColorName];
   }
   
   CrayolaColorName colorName = _currentTileColorNames[index];
   if (colorName == CCN_INVALID_CrayolaColor)
   {
      colorName = _currentColorName;
      _currentTileColorNames[index] = colorName;
   }
   
   return [self colorForNode:node withColorName:colorName];
}

#pragma mark - GLTileColorProvider protocol

- (SKColor *)liveColorForNode:(GLTileNode *)node
{
   assert(node != nil);
   
   if (_lockedColorMode)
      return [self colorForNode:node withColorName:_currentColorName];
   
   return [self unlockedColorForNode:node];
}

- (SKColor *)deadColorForNode:(GLTileNode *)node
{
   return [self deadColor];
}


@end
