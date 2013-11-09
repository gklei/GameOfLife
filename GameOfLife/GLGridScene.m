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

#include <OpenGLES/ES1/glext.h>
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

   SKNode *_hudLayer;
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
   _tiles = [NSArray arrayWithArray:self.children];
}

-(id)initWithSize:(CGSize)size
{
   if (self = [super initWithSize:size])
   {
      [self setupGridWithSize:size];
      [self setupHudWithSize:size];
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

- (void)setupHudWithSize:(CGSize)size
{
   _hudLayer = [SKNode new];

   CGSize bgSize = CGSizeMake(size.width, size.height);
   SKColor *backgroundColor = [SKColor crayolaBlackCoralPearlColor];

   SKSpriteNode *hudBackground = [SKSpriteNode spriteNodeWithColor:backgroundColor
                                                              size:bgSize];
   hudBackground.alpha = 0.5;
   hudBackground.position = CGPointMake(0, 60);
   hudBackground.anchorPoint = CGPointMake(0, 1);
   [_hudLayer addChild:hudBackground];
   [self addChild:_hudLayer];
}

- (void)toggleRunning
{
   float duration = (_running)? .15 : .35;
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

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
   if (_running)
   {
      [self grabScreenShot];
   }
   else
   {
      for (UITouch *touch in touches)
         [self toggleLivingForTileAtTouch:touch];
   }
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
   if (_running && currentTime - _lastGenerationTime > .8)
      [self updateNextGeneration:currentTime];
}

@end
