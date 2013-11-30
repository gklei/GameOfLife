//
//  GLGridScene.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/7/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLGridScene.h"
#import "GLGrid.h"
#import "GLColorHud.h"
#import "GLGeneralHud.h"
#import "UIColor+Crayola.h"

#include <OpenGLES/ES1/glext.h>

@interface GLGridScene() <GLColorHudDelegate, GLGeneralHudDelegate>
{
   GLGrid *_grid;

   CGPoint _firstLocationOfTouch;
   GLTileNode *_currentTileBeingTouched;

   GLGeneralHud *_generalHudLayer;
   GLColorHud *_colorHudLayer;

   BOOL _colorHudIsAnimating;
   BOOL _generalHudIsAnimating;
   BOOL _running;

   CFTimeInterval _lastGenerationTime;
}
@end

@implementation GLGridScene

- (void)setupGridWithSize:(CGSize)size
{
   _grid = [[GLGrid alloc] initWithSize:size];
   [self addChild:_grid];
}

-(id)initWithSize:(CGSize)size
{
   if (self = [super initWithSize:size])
   {
      [self setupGridWithSize:size];
      [self setupGeneralHud];
      [self setupColorHud];

      self.backgroundColor = [SKColor crayolaPeriwinkleColor];
   }
   return self;
}

- (void)setupColorHud
{
   _colorHudLayer = [GLColorHud new];
   _colorHudLayer.delegate = self;
   _colorHudLayer.position = CGPointMake(self.size.width - 60, 0);
   
   [_grid setCurrentColor:_colorHudLayer.currentColor];
   [self addChild:_colorHudLayer];
}

- (void)setupGeneralHud
{
   _generalHudLayer = [GLGeneralHud new];
   _generalHudLayer.delegate = self;
   _generalHudLayer.position = CGPointMake(-self.size.width + 60, 0);
   [self addChild:_generalHudLayer];
}

- (void)toggleRunningButtonPressed
{
   float duration = (_running)? .15 : .35;
   [_grid setTilesBirthingDuration:duration
                    dyingDuration:duration];

   _running = !_running;
   [_generalHudLayer updateStartStopButtonForState:(_running)? GL_RUNNING : GL_STOPPED];
}

- (void)restoreButtonPressed
{
   [_grid restoreGrid];
}

- (void)toggleLivingForTileAtTouch:(UITouch *)touch
{
   GLTileNode *tile = [_grid tileAtTouch:touch];
   if (_currentTileBeingTouched != tile)
   {
      _currentTileBeingTouched = tile;
      [tile updateLivingAndColor:!tile.isLiving];
      [_grid storeGridState];
   }
}

- (void)clearButtonPressed
{
   [_grid clearGrid];
}

- (void)screenShotButtonPressed
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

-(void)update:(CFTimeInterval)currentTime
{
   if (_running && currentTime - _lastGenerationTime > .8)
   {
      _lastGenerationTime = currentTime;
      [_grid updateNextGeneration];
   }
}

- (void)colorHudWillExpandWithWaitPeriod:(CFTimeInterval *)waitPeriod
{
   if (_generalHudLayer.isExpanded)
   {
      *waitPeriod = 0.25;
      [_generalHudLayer collapse];
   }
   else
   {
      SKAction *reposition = [SKAction moveByX:0 y:60 duration:.25];
      reposition.timingMode = SKActionTimingEaseInEaseOut;
      [_generalHudLayer setCoreFunctionButtonsHidden:YES];
      [_generalHudLayer runAction:reposition];
   }

   _colorHudIsAnimating = YES;
}

- (void)generalHudWillExpandWithWaitPeriod:(CFTimeInterval *)waitPeriod
{
   if (_colorHudLayer.isExpanded)
   {
      *waitPeriod = 0.25;
      [_colorHudLayer collapse];
   }
   else
   {
      SKAction *reposition = [SKAction moveByX:0 y:60 duration:.25];
      reposition.timingMode = SKActionTimingEaseInEaseOut;
      [_colorHudLayer setColorDropsHidden:YES];
      [_colorHudLayer runAction:reposition];
   }
   
   _generalHudIsAnimating = YES;
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
   SKAction *wait = [SKAction waitForDuration:.15];
   SKAction *reposition = [SKAction moveByX:0 y:-60 duration:.25];
   reposition.timingMode = SKActionTimingEaseInEaseOut;
   [_generalHudLayer runAction:[SKAction sequence:@[wait, reposition]] completion:^{
      [_generalHudLayer setCoreFunctionButtonsHidden:NO];
   }];
}

- (void)generalHudWillCollapse
{
   _generalHudIsAnimating = YES;
   SKAction *wait = [SKAction waitForDuration:.15];
   SKAction *reposition = [SKAction moveByX:0 y:-60 duration:.25];
   reposition.timingMode = SKActionTimingEaseInEaseOut;
   [_colorHudLayer runAction:[SKAction sequence:@[wait, reposition]] completion:^{
      [_colorHudLayer setColorDropsHidden:NO];
   }];
}

- (void)colorHudDidCollapse
{
   _colorHudIsAnimating = NO;

   if (_generalHudIsAnimating)
   {
      SKAction *reposition = [SKAction moveByX:0 y:60 duration:.15];
      reposition.timingMode = SKActionTimingEaseInEaseOut;
      [_colorHudLayer setColorDropsHidden:YES];
      [_colorHudLayer runAction:reposition];
   }
}

- (void)generalHudDidCollapse
{
   _generalHudIsAnimating = NO;

   if (_colorHudIsAnimating)
   {
      SKAction *reposition = [SKAction moveByX:0 y:60 duration:.15];
      reposition.timingMode = SKActionTimingEaseInEaseOut;
      [_generalHudLayer setCoreFunctionButtonsHidden:YES];
      [_generalHudLayer runAction:reposition];
   }
}

//- (void)hudWillExpand:(GLHud *)hud
//{
//   if (hud == _colorHudLayer)
//      [self colorHudWillExpand];
//   else if (hud == _generalHudLayer)
//      [self generalHudWillExpand];
//}

- (void)hud:(GLHud *)hud willExpandAfterPeriod:(CFTimeInterval *)waitPeriod
{
   if (hud == _colorHudLayer)
      [self colorHudWillExpandWithWaitPeriod:waitPeriod];
   else if (hud == _generalHudLayer)
      [self generalHudWillExpandWithWaitPeriod:waitPeriod];
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
   [_grid setCurrentColor:currentColor];
}

@end
