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

@interface GLGridScene() <GLGeneralHudDelegate, GLColorHudDelegate>
{
   GLGrid *_grid;

   CGPoint _firstLocationOfTouch;
   GLTileNode *_currentTileBeingTouched;

   GLGeneralHud *_generalHudLayer;
   GLColorHud *_colorHudLayer;

   BOOL _generalHudIsAnimating;
   BOOL _colorHudIsAnimating;
   BOOL _running;

   CFTimeInterval _lastGenerationTime;
}
@end

#pragma mark GLGridScene
@implementation GLGridScene

#pragma mark Initializer Method
-(id)initWithSize:(CGSize)size
{
   if (self = [super initWithSize:size])
   {
      [self setupGridWithSize:size];
      [self setupGeneralHud];
      [self setupColorHud];

      // set background color for the scene
      self.backgroundColor = [SKColor crayolaPeriwinkleColor];
   }
   return self;
}

#pragma mark Setup Methods
- (void)setupGridWithSize:(CGSize)size
{
   _grid = [[GLGrid alloc] initWithSize:size];
   [self addChild:_grid];
}

- (void)setupGeneralHud
{
   _generalHudLayer = [GLGeneralHud new];
   _generalHudLayer.delegate = self;
   _generalHudLayer.position = CGPointMake(-self.size.width + 60, 0);
   [self addChild:_generalHudLayer];
}

- (void)setupColorHud
{
   _colorHudLayer = [GLColorHud new];
   _colorHudLayer.delegate = self;
   _colorHudLayer.position = CGPointMake(self.size.width - 60, 0);
   
   [_grid setCurrentColor:_colorHudLayer.currentColor];
   [self addChild:_colorHudLayer];
}

#pragma mark GLGeneralHud Delegate Methods
- (void)clearButtonPressed
{
   [_grid clearGrid];
}

- (void)restoreButtonPressed
{
   [_grid restoreGrid];
}

- (void)toggleRunningButtonPressed
{
   float duration = (_running)? .15 : .35;
   [_grid setTilesBirthingDuration:duration
                     dyingDuration:duration];

   _running = !_running;
   [_generalHudLayer updateStartStopButtonForState:(_running)? GL_RUNNING : GL_STOPPED];
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
}

#pragma GLColorHud Delegate Method
- (void)setCurrentColor:(SKColor *)currentColor
{
   [_grid setCurrentColor:currentColor];
}

#pragma mark Touch Methods
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

#pragma mark GLHud Delegate Methods
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

#pragma mark Helper HUD Methods
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

#pragma mark Helper Method
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

#pragma mark SKScene Overridden Method
-(void)update:(CFTimeInterval)currentTime
{
   if (_running && currentTime - _lastGenerationTime > .8)
   {
      _lastGenerationTime = currentTime;
      [_grid updateNextGeneration];
   }
}

@end
