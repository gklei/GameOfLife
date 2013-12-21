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
#import "GLUIButton.h"
#import "GLSettingsLayer.h"
#import "GLTileNode.h"
#import "UIColor+Crayola.h"

#include <OpenGLES/ES1/glext.h>

#define DEFAULT_GENERATION_DURATION 0.8

@interface GLGridScene() <GLGeneralHudDelegate, GLColorHudDelegate>
{
   GLGrid *_grid;

   GLTileNode *_currentTileBeingTouched;
   BOOL _oneTileTouched;

   GLGeneralHud *_generalHudLayer;
   GLColorHud *_colorHudLayer;

   BOOL _generalHudIsAnimating;
   BOOL _colorHudIsAnimating;
   BOOL _running;
   BOOL _autoShowHideHudForStartStop;
   BOOL _generalHudShouldExpand;

   SKAction *_fingerDownSoundFX;
   SKAction *_fingerUpSoundFX;
   SKAction *_flashSound;

   CFTimeInterval _lastGenerationTime;
   CFTimeInterval _generationDuration;

   SKSpriteNode *_flashLayer;
   SKAction *_flashAnimation;
   BOOL _firstScreenShotTaken;

   GLUIButton *_focusedButton;
   
// BEGIN: tmp code to change generation speed from 0.1 <-> 1.0
BOOL _decreasing;
// END: tmp code to change generation speed from 0.1 <-> 1.0
}
@end

#pragma mark GLGridScene
@implementation GLGridScene

- (void)registerDefaultValues
{
   NSDictionary * defaults =
      [NSDictionary dictionaryWithObjectsAndKeys:
       [NSNumber numberWithBool:YES], @"SoundFX",
       [NSNumber numberWithInt:YES], @"SmartMenu",
       [NSNumber numberWithFloat:DEFAULT_GENERATION_DURATION], @"GenerationDuration",
       nil];
   
   [[NSUserDefaults standardUserDefaults] registerDefaults:defaults];
}

#pragma mark Initializer Method
- (id)initWithSize:(CGSize)size
{
   if (self = [super initWithSize:size])
   {
      [self setupGridWithSize:size];
      [self setupGeneralHud];
      [self setupColorHud];
      [self setupSoundFX];
      [self setupFlashLayerAndAnimation];

      // set background color for the scene
      self.backgroundColor = [SKColor crayolaPeriwinkleColor];

      self.userInteractionEnabled = YES;
      
      // register a set of default values
      [self registerDefaultValues];
      
      // now load in the current values
      [self settingsValueChangedForKey:@"SoundFX"];
      [self settingsValueChangedForKey:@"SmartMenu"];
      [self settingsValueChangedForKey:@"GenerationDuration"];
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
   _generalHudLayer.userInteractionEnabled = YES;
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

- (void)setupSoundFX
{
   _fingerUpSoundFX = [SKAction playSoundFileNamed:@"up.finger.off.tile.wav" waitForCompletion:NO];
   _fingerDownSoundFX = [SKAction playSoundFileNamed:@"down.finger.on.tile.wav" waitForCompletion:NO];
   _flashSound = [SKAction playSoundFileNamed:@"flash.wav" waitForCompletion:NO];
}

- (void)setupFlashLayerAndAnimation
{
   _flashLayer = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:self.size];
   _flashLayer.name = @"flashLayer";
   _flashLayer.colorBlendFactor = 1.0;
   _flashLayer.alpha = 0;
   _flashLayer.anchorPoint = CGPointZero;
   _flashLayer.position = CGPointZero;

   SKAction *flashIn = [SKAction fadeAlphaTo:1 duration:0.125 * _generationDuration];
   SKAction *flashOut = [SKAction fadeAlphaTo:0 duration:0.625 * _generationDuration];
   _flashAnimation = [SKAction sequence:@[flashIn, flashOut]];

   [self addChild:_flashLayer];
}

- (void)expandGeneralHUD
{
   [_generalHudLayer expand];
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
   if (![_grid currentStateIsRunnable] && !_running)
      return;
   
   float duration = (_running)? 0.1875 * _generationDuration : 0.4375 * _generationDuration;
   [_grid setTilesBirthingDuration:duration
                     dyingDuration:duration];

   [_grid toggleRunning:!_running];
   _running = !_running;
   [_generalHudLayer updateStartStopButtonForState:(_running)? GL_RUNNING : GL_STOPPED];
   
   if (_autoShowHideHudForStartStop)
   {
      if (_running)
         [_generalHudLayer collapse];
      else if (!_generalHudIsAnimating)
         [_generalHudLayer expand];
      else
         _generalHudShouldExpand = YES;
   }
}

- (void)screenShotButtonPressed
{
   // weird work around for the first screen shot that's taken being slow
   [self runAction:_flashSound];
   if (!_firstScreenShotTaken)
   {
      [_flashLayer runAction:_flashAnimation
                  completion:^
       {
          CGFloat scale = self.view.contentScaleFactor;
          UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, scale);
          [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];

          UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
          UIGraphicsEndImageContext();

          if (viewImage)
             UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
          
          _firstScreenShotTaken = YES;
      }];
   }
   else
   {
      CGFloat scale = self.view.contentScaleFactor;
      UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, scale);
      [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:YES];

      UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
      UIGraphicsEndImageContext();

      if (viewImage)
         UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);

      [_flashLayer runAction:_flashAnimation];
   }
}

- (void)settingsWillExpandWithRepositioningAction:(SKAction *)action
{
   [_colorHudLayer runAction:action];
}

- (void)settingsDidExpand
{
}

- (void)settingsWillCollapseWithRepositioningAction:(SKAction *)action
{
   [_colorHudLayer runAction:action];
}

- (void)settingsDidCollapse
{
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
      _oneTileTouched = YES;
      [self toggleLivingForTileAtTouch:touch withSoundFX:_fingerDownSoundFX];
   }
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
   UITouch *touch = touches.allObjects.lastObject;
   _locationOfFirstTouch = [touch locationInNode:self];

   for (SKNode *node in [self nodesAtPoint:_locationOfFirstTouch])
      if ([node.name isEqualToString:@"ui_control_hit_box"])
      {
         _focusedButton = (GLUIButton *)node.parent.parent;
         [_focusedButton handleTouchBegan:touch];
         return;
      }

   if (!_running)
   {
      [self handleTouch:touches.allObjects.lastObject];
   }
}

- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event
{
   UITouch *touch = touches.allObjects.lastObject;

   if (_focusedButton)
      [_focusedButton handleTouchMoved:touch];

   if (!_running &&
       ![_generalHudLayer containsPoint:_locationOfFirstTouch] &&
       ![_colorHudLayer containsPoint:_locationOfFirstTouch])
   {
      [self toggleLivingForTileAtTouch:touch withSoundFX:_fingerUpSoundFX];
   }

   if ([_colorHudLayer containsPoint:_locationOfFirstTouch])
   {
      [_colorHudLayer handleTouch:touch moved:YES];
   }
   else if ([_generalHudLayer containsPoint:_locationOfFirstTouch])
   {
      [_generalHudLayer handleTouch:touch moved:YES];
   }
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
   UITouch *touch = touches.allObjects.lastObject;

   if (_focusedButton)
   {
      [_focusedButton handleTouchEnded:touch];
   }

   if ([_generalHudLayer containsPoint:_locationOfFirstTouch] &&
       [_generalHudLayer containsPoint:[touch locationInNode:self]])
   {
//      [self generalHudPressedWithTouch:touch focusedNode:_focusedButton];
      [_generalHudLayer handleTouch:touch forButton:_focusedButton];
   }
   if ([_colorHudLayer containsPoint:_locationOfFirstTouch] &&
       [_colorHudLayer containsPoint:[touch locationInNode:self]])
   {
      [self colorHudPressedWithTouch:touch];
   }

   if (_oneTileTouched)
   {
      [self runAction:_fingerUpSoundFX];
      _oneTileTouched = NO;
   }
   _currentTileBeingTouched = nil;
   _focusedButton = nil;
}

- (void)colorHudPressedWithTouch:(UITouch *)touch
{
   if (!_colorHudIsAnimating)
      [_colorHudLayer handleTouch:touch moved:NO];
}

- (void)generalHudPressedWithTouch:(UITouch *)touch focusedNode:(GLUIButton *)focusedNode
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
      *waitPeriod = (_generalHudLayer.settingsAreExpanded)? 0.5 : 0.25;
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

   [_generalHudLayer runAction:[SKAction sequence:@[wait, reposition]]
                    completion:^
   {
      [_generalHudLayer setCoreFunctionButtonsHidden:NO];
   }];
}

- (void)generalHudWillCollapse
{
   _generalHudIsAnimating = YES;

   SKAction *wait = [SKAction waitForDuration:.15];
   SKAction *reposition = [SKAction moveByX:0 y:-60 duration:.25];
   reposition.timingMode = SKActionTimingEaseInEaseOut;

   [_colorHudLayer runAction:[SKAction sequence:@[wait, reposition]]
                  completion:^
   {
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
      [_generalHudLayer runAction:reposition
                       completion:
       ^{
          if (_generalHudShouldExpand)
          {
             _generalHudShouldExpand = NO;
             [_generalHudLayer expand];
          }
       }];
   }
}

#pragma mark Helper Method
- (void)toggleLivingForTileAtTouch:(UITouch *)touch withSoundFX:(SKAction *)soundFX
{
   GLTileNode *tile = [_grid tileAtTouch:touch];
   if (_currentTileBeingTouched != tile)
   {
      _oneTileTouched = (_currentTileBeingTouched == nil);
      _currentTileBeingTouched = tile;
      [self runAction:soundFX];
      [tile updateLivingAndColor:!tile.isLiving];
      [_grid storeGridState];
   }
}

#pragma mark SKScene Overridden Method
-(void)update:(CFTimeInterval)currentTime
{
   if (_running && currentTime - _lastGenerationTime > _generationDuration)
   {
      _lastGenerationTime = currentTime;
      
      if (!_grid.isInContinuousLoop)
         [_grid updateNextGeneration];
      else
         [self toggleRunningButtonPressed];
      
//// BEGIN: tmp code to change generation speed from 0.1 <-> 1.0
////        _generationDuration should be set in the UI
//if ([_grid generationCount] % 10 == 0)
//{
//   _generationDuration += (_decreasing)? -0.1 : 0.1;
//
//   if (_generationDuration < 0.1)
//   {
//      _generationDuration = 0.2;
//      _decreasing = false;
//   }
//   else if (_generationDuration > 1)
//   {
//      _generationDuration = 0.9;
//      _decreasing = true;
//   }
//}
//// END: tmp code to change generation speed from 0.1 <-> 1.0
   }
}

- (void)settingsValueChangedForKey:(NSString *)key
{
   if ([key compare:@"GenerationDuration"] == NSOrderedSame)
   {
      NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
      float value = [defaults floatForKey:key];
      value = fmin(1.0, fmax(0.1, value));
      
//      NSLog(@"settingsValueChangedForKey:key = %@, value = %0.2f", key, value);
      
      _generationDuration = (1.0 - value);
   }
   else if ([key compare:@"SmartMenu"] == NSOrderedSame)
   {
      NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
      BOOL value = [defaults boolForKey:key];
      
//      NSLog(@"settingsValueChangedForKey:key = %@, value = %d", key, value);
      
      _autoShowHideHudForStartStop = value;
   }
   else if ([key compare:@"SoundFX"] == NSOrderedSame)
   {
      NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
      BOOL value = [defaults boolForKey:key];
      
//      NSLog(@"settingsValueChangedForKey:key = %@, value = %d", key, value);
   }
}

@end
