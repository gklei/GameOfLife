//
//  GLGridScene.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/7/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLGridScene.h"
#import "GLColorHud.h"
#import "GLGeneralHud.h"
#import "UIColor+Crayola.h"

#include <OpenGLES/ES1/glext.h>
#include <vector>

// NOTE: both TILESIZE.width and TILESIZE.height must be greater than 1
#define HUD_POSITION_DEFAULT CGPointMake(60, 60)
#define HUD_BUTTON_EDGE_PADDING 48
#define HUD_BUTTON_PADDING 50
#define TILESIZE CGSizeMake(20, 20)
#define LIVING YES
#define DEAD   NO

@interface GLGridScene() <GLColorHudDelegate, GLGeneralHudDelegate, CurrentColorDelegate>
{
   GridDimensions _gridDimensions;
   NSArray *_tiles;
   CFTimeInterval _lastGenerationTime;

   std::vector<BOOL> _storedTileStates;
   std::vector<BOOL> _nextGenerationTileStates;
   BOOL _running;
   GLTileNode *_currentTileBeingTouched;

   GLGeneralHud *_generalHudLayer;
   GLColorHud *_colorHudLayer;
   BOOL _colorHudIsAnimating;
   BOOL _generalHudIsAnimating;

   SKColor *_currentColor;

   CGPoint _firstLocationOfTouch;
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
      {
         GLTileNode *tile = [GLTileNode tileWithRect:CGRectMake(xPos + 0.5,
                                                                yPos + 0.5,
                                                                TILESIZE.width - 1,
                                                                TILESIZE.height - 1)];
         tile.delegate = self;
         [self addChild:tile];
      }
   _tiles = [NSArray arrayWithArray:self.children];
   
   
   CGPoint boardCenter = CGPointMake(_gridDimensions.columns * TILESIZE.width * 0.5,
                                     _gridDimensions.rows * TILESIZE.height * 0.5);
   float maxBoardDistance = sqrt(size.width * size.width + size.height * size.height);
   for (GLTileNode *tile in _tiles)
   {
      tile.boardMaxDistance = maxBoardDistance;
      [tile setColorCenter:boardCenter];
   }
}

-(id)initWithSize:(CGSize)size
{
   if (self = [super initWithSize:size])
   {
      [self setupGridWithSize:size];
      [self setupGeneralHud];
      [self setupColorHud];
      _nextGenerationTileStates = std::vector<BOOL>(_tiles.count, DEAD);
      _storedTileStates = std::vector<BOOL>(_tiles.count, DEAD);
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

- (void)setupColorHud
{
   _colorHudLayer = [GLColorHud new];
   _colorHudLayer.delegate = self;
   _currentColor = _colorHudLayer.currentColor;
   _colorHudLayer.position = CGPointMake(self.size.width - 60, 0);
   [self addChild:_colorHudLayer];
}

- (void)setupGeneralHud
{
   _generalHudLayer = [GLGeneralHud new];
   _generalHudLayer.delegate = self;
   _generalHudLayer.position = CGPointMake(-self.size.width + 60, 0);
   [self addChild:_generalHudLayer];
}

- (BOOL)isRunning
{
   return _running;
}

- (void)toggleRunning
{
   float duration = (_running)? .15 : .35;
   [self setTilesBirthingDuration:duration
                    dyingDuration:duration];

   _running = !_running;
   [_generalHudLayer updateStartStopButtonForState:(_running)? GL_RUNNING : GL_STOPPED];
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

- (void)restore
{
   CGPoint center = CGPointMake(_gridDimensions.columns * TILESIZE.width * 0.5,
                                _gridDimensions.rows * TILESIZE.height * 0.5);
   for (int i = 0; i < _tiles.count; ++i)
   {
      GLTileNode * tile = [_tiles objectAtIndex:i];
      tile.isLiving = _storedTileStates[i];
      [tile setColorCenter:center];
   }
}

- (void)storeGameState
{
   for (int i = 0; i < _tiles.count; ++i)
      _storedTileStates[i] = ((GLTileNode *)[_tiles objectAtIndex:i]).isLiving;
}

- (void)toggleLivingForTileAtTouch:(UITouch *)touch
{
   GLTileNode *tile = [self tileAtTouch:touch];
   if (_currentTileBeingTouched != tile)
   {
      _currentTileBeingTouched = tile;
      [tile updateLivingAndColor:!tile.isLiving];
      [self storeGameState];
   }
}

- (void)clear
{
   for (GLTileNode *tile in _tiles)
      [tile clearTile];
}

- (void)grabScreenShot
{
   CGFloat scale = self.view.contentScaleFactor;
   UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, scale);
   [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];
   UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
   UIGraphicsEndImageContext();
   
   if (viewImage)
      UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
   
//   // basically, straight out of of Apple's Technical Q&A QA1704 with a few tweaks
//   GLint x = 0;
//   GLint y = 0;
//   GLint width = 0;
//   GLint height = 0;
//   
//	// Bind the color renderbuffer used to render the OpenGL ES view
//	// If your application only creates a single color renderbuffer which is already bound at this point,
//	// this call is redundant, but it is needed if you're dealing with multiple renderbuffers.
//	// Note, replace "_colorRenderbuffer" with the actual name of the renderbuffer object defined in your class.
//   
//   // In SpriteKit the render-buffer is hopefully already bound since we have no access to it
//   //	glBindRenderbufferOES(GL_RENDERBUFFER_OES, _colorRenderbuffer);
//   
//	// Get the size of the backing Layer
//	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_WIDTH_OES, &width);
//	glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES, GL_RENDERBUFFER_HEIGHT_OES, &height);
//   
//	NSInteger dataLength = width * height * 4;
//	GLubyte *data = (GLubyte*)malloc(dataLength * sizeof(GLubyte));
//   
//	// Read pixel data from the framebuffer
//	glPixelStorei(GL_PACK_ALIGNMENT, 4);
//	glReadPixels(x, y, width, height, GL_RGBA, GL_UNSIGNED_BYTE, data);
//   
//	// Create a CGImage with the pixel data
//	// If your OpenGL ES content is opaque, use kCGImageAlphaNoneSkipLast to ignore the alpha channel
//	// otherwise, use kCGImageAlphaPremultipliedLast
//	CGDataProviderRef ref = CGDataProviderCreateWithData(NULL, data, dataLength, NULL);
//	CGColorSpaceRef colorspace = CGColorSpaceCreateDeviceRGB();
//	CGImageRef iref = CGImageCreate(width, height, 8, 32, width * 4, colorspace,
//                                   (kCGBitmapByteOrder32Big | kCGImageAlphaPremultipliedLast),
//                                   //	kCGBitmapByteOrderDefault,
//                                   ref, NULL, true,
//                                   //kCGRenderingIntentPerceptual);
//                                   kCGRenderingIntentDefault);
//   
//	// OpenGL ES measures data in PIXELS
//	// Create a graphics context with the target size measured in POINTS
//	NSInteger widthInPoints, heightInPoints;
//	if (NULL != UIGraphicsBeginImageContextWithOptions)
//	{
//		// On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
//		// Set the scale parameter to your OpenGL ES view's contentScaleFactor
//		// so that you get a high-resolution snapshot when its value is greater than 1.0
//		CGFloat scale = self.view.contentScaleFactor;
//		widthInPoints = width / scale;
//		heightInPoints = height / scale;
//		UIGraphicsBeginImageContextWithOptions(CGSizeMake(widthInPoints, heightInPoints), NO, scale);
//	}
//	else
//   {
//		// On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
//		widthInPoints = width;
//		heightInPoints = height;
//		UIGraphicsBeginImageContext(CGSizeMake(widthInPoints, heightInPoints));
//	}
//   
//	CGContextRef cgcontext = UIGraphicsGetCurrentContext();
//   
//	// UIKit coordinate system is upside down to GL/Quartz coordinate system
//	// Flip the CGImage by rendering it to the flipped bitmap context
//	// The size of the destination area is measured in POINTS
//	CGContextSetBlendMode(cgcontext, kCGBlendModeCopy);
//	CGContextDrawImage(cgcontext, CGRectMake(0.0, 0.0, widthInPoints, heightInPoints), iref);
//   
//	// Retrieve the UIImage from the current context
//	UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
//   
//	UIGraphicsEndImageContext();
//   
//	// Clean up
//	free(data);
//	CFRelease(ref);
//	CFRelease(colorspace);
//	CGImageRelease(iref);
//   
//   if (viewImage)
//      UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
}

- (void)handleTouch:(UITouch *)touch
{
   if (![_generalHudLayer containsPoint:[touch locationInNode:self]] &&
       ![_colorHudLayer containsPoint:[touch locationInNode:self]])
   {
      [self toggleLivingForTileAtTouch:touch];
   }
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
   UITouch *touch = touches.allObjects.lastObject;
   _firstLocationOfTouch = [touch locationInNode:self];
   if (!_running)
   {
      [self handleTouch:touches.allObjects.lastObject];
   }
}

- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event
{
   UITouch *touch = touches.allObjects.lastObject;
   if (!_running &&
       ![_generalHudLayer containsPoint:_firstLocationOfTouch] &&
       ![_colorHudLayer containsPoint:_firstLocationOfTouch])
   {
      [self toggleLivingForTileAtTouch:touch];
   }

   if ([_colorHudLayer containsPoint:_firstLocationOfTouch])
   {
      [_colorHudLayer handleTouch:touch moved:YES];
   }
   else if ([_generalHudLayer containsPoint:_firstLocationOfTouch])
   {
      [_generalHudLayer handleTouch:touch moved:YES];
   }
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
   UITouch *touch = touches.allObjects.lastObject;
   if ([_generalHudLayer containsPoint:_firstLocationOfTouch] &&
       [_generalHudLayer containsPoint:[touch locationInNode:self]])
   {
      [self generalHudPressedWithTouch:touch];
   }
   else if ([_colorHudLayer containsPoint:_firstLocationOfTouch] &&
            [_colorHudLayer containsPoint:[touch locationInNode:self]])
   {
      [self colorHudPressedWithTouch:touch];
   }

   _currentTileBeingTouched = nil;
}

- (void)colorHudPressedWithTouch:(UITouch *)touch
{
   if (!_colorHudIsAnimating)
      [_colorHudLayer handleTouch:touch moved:NO];
}

- (void)generalHudPressedWithTouch:(UITouch *)touch
{
   if (!_generalHudIsAnimating)
      [_generalHudLayer handleTouch:touch moved:NO];
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

- (int)getLiveCountAtIndex:(int)index
{
   int liveCount = ((GLTileNode *)[_tiles objectAtIndex:index]).isLiving;
   liveCount += [self getNorthSouthLiveCountForTileAtIndex:index];
   liveCount += [self getEastBlockLiveCountForTileAtIndex:index];
   liveCount += [self getWestBlockLiveCountForTileAtIndex:index];
   return liveCount;
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

- (void)updateNextGeneration:(CFTimeInterval)currentTime
{
   _lastGenerationTime = currentTime;
   for (int i = 0; i < _tiles.count; ++i)
      _nextGenerationTileStates[i] = [self getIsLivingForNextGenerationAtIndex:i];
   
   for (int i = 0; i < _tiles.count; ++i)
      ((GLTileNode *)[_tiles objectAtIndex:i]).isLiving = _nextGenerationTileStates[i];
   
   [self updateColorCenter];
}

-(void)update:(CFTimeInterval)currentTime
{
   if (_running && currentTime - _lastGenerationTime > .8)
      [self updateNextGeneration:currentTime];
}

- (void)colorHudWillExpand
{
   _colorHudIsAnimating = YES;
   SKAction *reposition = [SKAction moveByX:-100 y:0 duration:.25];
   [_generalHudLayer runAction:reposition];
}

- (void)generalHudWillExpand
{
   _generalHudIsAnimating = YES;
   SKAction *reposition = [SKAction moveByX:100 y:0 duration:.25];
   [_colorHudLayer runAction:reposition];
}

- (void)colorHudDidExpand
{
   _colorHudIsAnimating = NO;
}

- (void)generalHudDidExpand
{
   _generalHudIsAnimating = NO;
}

- (void)colorHudWillCollapse
{
   _colorHudIsAnimating = YES;
   SKAction *reposition = [SKAction moveByX:100 y:0 duration:.25];
   [_generalHudLayer runAction:reposition];
}

- (void)generalHudWillCollapse
{
   _generalHudIsAnimating = YES;
   SKAction *reposition = [SKAction moveByX:-100 y:0 duration:.25];
   [_colorHudLayer runAction:reposition];
}

- (void)colorHudDidCollapse
{
   _colorHudIsAnimating = NO;
}

- (void)generalHudDidCollapse
{
   _generalHudIsAnimating = NO;
}

- (SKColor *)currentColor
{
   return _currentColor;
}

- (void)hudWillExpand:(GLHud *)hud
{
   if (hud == _colorHudLayer)
      [self colorHudWillExpand];
   else if (hud == _generalHudLayer)
      [self generalHudWillExpand];
}

- (void)hudDidExpand:(GLHud *)hud
{
   if (hud == _colorHudLayer)
      [self colorHudDidExpand];
   else if (hud == _generalHudLayer)
      [self generalHudDidExpand];
}

- (void)hudWillCollapse:(GLHud *)hud
{
   if (hud == _colorHudLayer)
      [self colorHudWillCollapse];
   else if (hud == _generalHudLayer)
      [self generalHudWillCollapse];
}

- (void)hudDidCollapse:(GLHud *)hud
{
   if (hud == _colorHudLayer)
      [self colorHudDidCollapse];
   else if (hud == _generalHudLayer)
      [self generalHudDidCollapse];
}

- (void)setCurrentColor:(SKColor *)currentColor
{
   _currentColor = currentColor;
   for (GLTileNode *tile in _tiles)
      [tile updateColor];
}

@end
