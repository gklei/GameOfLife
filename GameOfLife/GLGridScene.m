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
   BOOL _autoHideHUDLayersForScreenshot;
   BOOL _generalHudShouldExpand;

   BOOL _shouldPlaySound;
   SKAction *_fingerDownSoundFX;
   SKAction *_fingerUpSoundFX;
   SKAction *_flashSound;

   CFTimeInterval _lastGenerationTime;
   CFTimeInterval _generationDuration;

   SKSpriteNode *_flashLayer;
   SKAction *_flashAnimation;
   BOOL _firstScreenShotTaken;

   GLUIButton *_focusedButton;

   CGPoint _locationOfFirstTouch;
   NSArray * _gridImagePairs;
}
@end

#pragma mark GLGridScene
@implementation GLGridScene

#pragma mark - registration methods
- (void)registerGeneralDurationHUD
{
   HUDItemDescription * hudItem = [[HUDItemDescription alloc] init];
   hudItem.keyPath = @"GenerationDuration";
   hudItem.label = @"SPEED";
   hudItem.range = HUDItemRangeMake(1.0, -0.9);
   hudItem.type = HIT_SLIDER;
   hudItem.defaultvalue = [NSNumber numberWithFloat:DEFAULT_GENERATION_DURATION];
   hudItem.valueType = HVT_FLOAT;
   
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addHudItem:hudItem];
}

- (void)registerGridImagePickerHUD:(NSArray *)imagePairs
{
   assert(imagePairs.count > 0);
   assert((imagePairs.count % 2) == 0);
   
   HUDPickerItemDescription * hudItem = [[HUDPickerItemDescription alloc] init];
   hudItem.keyPath = @"GridImageIndex";
   hudItem.label = @"IMAGES";
   hudItem.type = HIT_PICKER;
   hudItem.valueType = HVT_ULONG;
   hudItem.imagePairs = imagePairs;
   hudItem.range = HUDItemRangeMake(0, imagePairs.count - 1);
   hudItem.defaultvalue = [NSNumber numberWithFloat:0];
   
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addHudItem:hudItem];
}

- (void)registerToggleItemWithLabel:(NSString *)label andKeyPath:(NSString *)keyPath
{
   HUDItemDescription * hudItem = [[HUDItemDescription alloc] init];
   hudItem.keyPath = keyPath;
   hudItem.label = label;
   hudItem.range = HUDItemRangeMake(0, 1);
   hudItem.type = HIT_TOGGLER;
   hudItem.defaultvalue = [NSNumber numberWithBool:YES];
   hudItem.valueType = HVT_BOOL;
   
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addHudItem:hudItem];
}

- (void)registerSoundFxHUD
{
   [self registerToggleItemWithLabel:@"SOUND FX" andKeyPath:@"SoundFX"];
}

- (void)registerSmartMenuHUD
{
   [self registerToggleItemWithLabel:@"SMART MENU" andKeyPath:@"SmartMenu"];
}

- (void)registerLoopDetectionHUD
{
   [self registerToggleItemWithLabel:@"LOOP DETECTION" andKeyPath:@"LoopDetection"];
}

- (void)registerHudParameters
{
   [self registerSoundFxHUD];
   [self registerSmartMenuHUD];
   [self registerGeneralDurationHUD];
   [self registerLoopDetectionHUD];
   [self registerGridImagePickerHUD:_gridImagePairs];
}

#pragma mark - observation methods
- (void)observeSoundFxChanges
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"SoundFX"];
}

- (void)observeSmartMenuChanges
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"SmartMenu"];
}

- (void)observeLoopDetectionChanges
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"LoopDetection"];
}

- (void)observeGeneralDurationChanges
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"GenerationDuration"];
}

- (void)observeGridImageIndexChanges
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"GridImageIndex"];
}

- (void)observeHudParameterChanges
{
   [self observeSoundFxChanges];
   [self observeSmartMenuChanges];
   [self observeLoopDetectionChanges];
   [self observeGeneralDurationChanges];
   [self observeGridImageIndexChanges];
}

#pragma mark - Initializer Method
- (id)initWithSize:(CGSize)size
{
   if (self = [super initWithSize:size])
   {
      //                  live image,            dead image
      _gridImagePairs = @[@"",                   @"tile.square.png",
                          @"",                   @"tile.ring.png",
                          @"",                   @"tile.ring3d.png",
                          @"",                   @"tile.circle.png",
                          @"",                   @"tile.cylinder.png",
                          @"",                   @"tile.spiral.png",
                          @"",                   @"tile.buldge.png",
                          @"tile.smiley.png",    @"tile.frowny.png",
                          @"tile.snowflake.png", @"tile.clear.png"];
      
      [self setupGridWithSize:size];

      [self registerHudParameters];
      [self observeHudParameterChanges];

      [self setupGeneralHud];
      [self setupColorHud];
      [self setupSoundFX];
      [self setupFlashLayerAndAnimation];
      
      // set background color for the scene
      self.backgroundColor = [SKColor crayolaPeriwinkleColor];
      self.userInteractionEnabled = YES;

      if (![self firstTimeRunning])
         [self loadLastGrid];
   }
   return self;
}

#pragma mark - Setup Methods
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

   SKAction *flashIn = [SKAction fadeAlphaTo:1 duration:0.125];
   SKAction *flashOut = [SKAction fadeAlphaTo:0 duration:0.625];
   _flashAnimation = [SKAction sequence:@[flashIn, flashOut]];

   [self addChild:_flashLayer];
}

- (void)expandGeneralHUD
{
   [_generalHudLayer expand];
}

- (void)loadLastGrid
{
   [_grid loadStoredTileStates];
   [self restoreButtonPressed];
}

- (BOOL)firstTimeRunning
{
   BOOL retVal = NO;
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   if (![defaults objectForKey:@"firstRun"])
   {
      retVal = YES;
      [defaults setObject:[NSDate date] forKey:@"firstRun"];
   }

   [[NSUserDefaults standardUserDefaults] synchronize];
   return retVal;
}

- (void)setDefaultGridAttributes
{
   [_grid clearGrid];
}

#pragma mark - GLGeneralHud Delegate Methods
- (void)clearButtonPressed
{
   if (_running)
   {
      [self updateGenerationDuration:_generationDuration];

      [_grid toggleRunning:!_running];
      _running = !_running;
      [_generalHudLayer updateStartStopButtonForState:(_running)? GL_RUNNING : GL_STOPPED
                                            withSound:NO];
   }
   [_grid clearGrid];
}

- (void)restoreButtonPressed
{
   if (_running)
   {
      [self updateGenerationDuration:_generationDuration];

      [_grid toggleRunning:!_running];
      _running = !_running;
      [_generalHudLayer updateStartStopButtonForState:(_running)? GL_RUNNING : GL_STOPPED
                                            withSound:NO];
   }
   
   [_grid restoreGrid];
}

- (void)updateGenerationDuration:(float)duration
{
   float bdDuration = (_running)? 0.1875 * duration : 0.4375 * duration;
   [_grid setTilesBirthingDuration:bdDuration
                     dyingDuration:bdDuration];
   
   _generationDuration = duration;
}

- (void)toggleRunningButtonPressed
{
   if (![_grid currentStateIsRunnable] && !_running)
      return;
   
   [self updateGenerationDuration:_generationDuration];

   [_grid toggleRunning:!_running];
   _running = !_running;
   [_generalHudLayer updateStartStopButtonForState:(_running)? GL_RUNNING : GL_STOPPED
                                         withSound:!_autoShowHideHudForStartStop];
   
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
   if (_shouldPlaySound) [self runAction:_flashSound];

   if (_autoHideHUDLayersForScreenshot)
   {
      // hide HUDs
   }
   
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
   
   if (_autoHideHUDLayersForScreenshot)
   {
      // show HUDS
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

#pragma mark GLColorHud Delegate Method
- (void)setCurrentColor:(SKColor *)currentColor
{
   [_grid setCurrentColor:currentColor];
}

- (void)colorGridWillExpandWithRepositioningAction:(SKAction *)action
{
   [_generalHudLayer runAction:action];
}

- (void)colorGridDidExpand
{
}

- (void)colorGridWillCollapseWithRepositioningAction:(SKAction *)action
{
   [_generalHudLayer runAction:action];
}

- (void)colorGridDidCollapse
{
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
   UITouch *touch = touches.allObjects.firstObject;
   _locationOfFirstTouch = [touch locationInNode:self];

   if (_focusedButton)
   {
      [_focusedButton loseFocus];
      _focusedButton = nil;
   }

   for (SKNode *node in [self nodesAtPoint:_locationOfFirstTouch])
      if ([node.name isEqualToString:@"ui_control_hit_box"] && !node.parent.parent.hidden)
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
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
   UITouch *touch = touches.allObjects.lastObject;
   if (_focusedButton)
   {
      [_focusedButton handleTouchEnded:touch];
      _focusedButton = nil;
   }

   if (_oneTileTouched)
   {
      if (_shouldPlaySound) [self runAction:_fingerUpSoundFX];
      _oneTileTouched = NO;
   }

   [_currentTileBeingTouched handleTouchEnded:touch];
   _currentTileBeingTouched = nil;
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
      _generalHudLayer.animating = YES;
      [_generalHudLayer runAction:reposition completion:^{_generalHudLayer.animating = NO;}];
   }
   _colorHudIsAnimating = YES;
}

- (void)generalHudWillExpandWithWaitPeriod:(CFTimeInterval *)waitPeriod
{
   if (_colorHudLayer.isExpanded)
   {
      *waitPeriod = (_colorHudLayer.colorGridIsExpanded)? 0.5 : 0.25;
      [_colorHudLayer collapse];
   }
   else
   {
      SKAction *reposition = [SKAction moveByX:0 y:60 duration:.25];
      reposition.timingMode = SKActionTimingEaseInEaseOut;

      [_colorHudLayer setColorDropsHidden:YES];
      _colorHudLayer.animating = YES;
      [_colorHudLayer runAction:reposition completion:^{_colorHudLayer.animating = NO;}];
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
      [_colorHudLayer setColorDropsHidden:YES];
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
   else if (_generalHudShouldExpand)
   {
      _generalHudShouldExpand = NO;
      [_generalHudLayer expand];
   }
}

#pragma mark Helper Methods
- (void)toggleLivingForTileAtTouch:(UITouch *)touch withSoundFX:(SKAction *)soundFX
{
   GLTileNode *tile = [_grid tileAtTouch:touch];
   if (_currentTileBeingTouched != tile)
   {
      _oneTileTouched = (_currentTileBeingTouched == nil);

      [_currentTileBeingTouched handleTouchEnded:touch];
      [tile handleTouchBegan:touch];
      
      _currentTileBeingTouched = tile;
      if (_shouldPlaySound) [self runAction:soundFX];
      [tile updateLivingAndColor:!tile.isLiving];
      [_grid storeGridState];
   }
}

- (double)rotationForImageIndex:(NSInteger)imageIndex
{
   double result = 0;
   
   switch (imageIndex)
   {
      case 0:
         result = -M_PI_2;
         break;
      case 4:
      case 6:
      case 8:
      case 10:
         result = -M_PI;
         break;
      default:
         result = 0;
   }
   
   return result;
}

#pragma mark - SKScene Overridden Method
-(void)update:(CFTimeInterval)currentTime
{
   if (_running && currentTime - _lastGenerationTime > _generationDuration)
   {
      _lastGenerationTime = currentTime;
      
      if (!_grid.isInContinuousLoop)
         [_grid updateNextGeneration];
      else
         [self toggleRunningButtonPressed];
   }
}

#pragma mark - HUDSettingsObserver protocol
- (void)settingChanged:(NSNumber *)value ofType:(HUDValueType)type forKeyPath:(NSString *)keyPath
{
   if ([keyPath compare:@"GenerationDuration"] == NSOrderedSame)
   {
      assert(type == HVT_FLOAT);
      [self updateGenerationDuration:[value floatValue]];
   }
   else if ([keyPath compare:@"SmartMenu"] == NSOrderedSame)
   {
      assert(type == HVT_BOOL);
      _autoShowHideHudForStartStop = [value boolValue];
   }
   else if ([keyPath compare:@"SoundFX"] == NSOrderedSame)
   {
      assert(type == HVT_BOOL);
      _shouldPlaySound = [value boolValue];
   }
   else if ([keyPath compare:@"LoopDetection"] == NSOrderedSame)
   {
      assert(type == HVT_BOOL);
      _grid.inContinuousLoop = NO;
      _grid.considersContinuousBiLoops = [value boolValue];
   }
   else if ([keyPath compare:@"GridImageIndex"] == NSOrderedSame)
   {
      assert(type == HVT_ULONG);
      NSUInteger imageIndex = [value unsignedLongValue];
      if (imageIndex + 1 >= _gridImagePairs.count)
         return;
      
      [_grid setDeadImage:[_gridImagePairs objectAtIndex:imageIndex + 1]];
      [_grid setDeadRotation:0];
      
      [_grid setLiveImage:[_gridImagePairs objectAtIndex:imageIndex]];
      [_grid setLiveRotation:[self rotationForImageIndex:imageIndex]];
      
      [_grid updateTextures];
   }
}

@end
