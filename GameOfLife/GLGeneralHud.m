//
//  GLGeneralHud.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/24/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLGeneralHud.h"
#import "GLGridScene.h"

#import "GLUIActionButton.h"
#import "GLUITextButton.h"

#import "GLSettingsLayer.h"
#import "UIColor+Crayola.h"

#import "GLPageCollectionLayer.h"
#import "GLPageCollection.h"
#import "GLPageLayer.h"

#include <AssetsLibrary/AssetsLibrary.h>

#define CORE_FUNCTION_BUTTON_PADDING 52
#define HUD_BUTTON_EDGE_PADDING 48
#define HUD_BUTTON_PADDING 50

#define BACKGROUND_ALPHA_SETTINGS_COLLAPSED .7
#define BACKGROUND_ALPHA_SETTINGS_EXPANDED .85

#define BOTTOM_BAR_HEIGHT 60
#define SETTINGS_HEIGHT_IPHONE_4 [UIScreen mainScreen].bounds.size.height - BOTTOM_BAR_HEIGHT
#define SETTINGS_HEIGHT_IPHONE_5 (BOTTOM_BAR_HEIGHT * 7) + 20
#define SETTINGS_EXPAND_COLLAPSE_DUATION .25
#define BOTTOM_BAR_EXPAND_COLLAPSE_DURATION .5
#define REPOSITION_BUTTONS_DURATION .25
#define WAIT_BEFORE_COLORIZE_DURATION .25

@interface GLGeneralHud()
{
   CGSize _defaultSize;
   CGFloat _settingsHeight;

   SKSpriteNode *_backgroundLayer;
   GLSettingsLayer *_settingsLayer;

   NSArray *_coreFunctionButtons;
   NSArray *_buttonHitBoxes;

   GLUIActionButton *_expandCollapseButton;
   GLUIActionButton*_clearButton;
   GLUIActionButton *_restoreButton;
   GLUIActionButton *_startStopButton;
   GLUIActionButton *_cameraButton;
   GLUIActionButton *_settingsButton;

   GLUIActionButton *_aboutButton;

   BOOL _shouldPlaySound;
   SKAction *_expandSettingsSound;
   SKAction *_collapseSettingsSound;
   SKAction *_startAlgorithmSound;
   SKAction *_stopAlgorithmSound;
   SKAction *_clearSound;
   SKAction *_restoreSound;

   SKEmitterNode *_particleGenerator;
}
@end

@implementation GLGeneralHud

- (void)observeSoundFxChanges
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"SoundFX"];
}

- (id)init
{
   if (self = [super init])
   {
      NSString *sparkPath = [[NSBundle mainBundle] pathForResource:@"Spark" ofType:@"sks"];
      _particleGenerator = [NSKeyedUnarchiver unarchiveObjectWithFile:sparkPath];

      // hack: this happens to be where the settings button winds up when the bottom
      // bar is expanded.
      _particleGenerator.position = CGPointMake(550, 30);

      _defaultSize = [UIScreen mainScreen].bounds.size;
      _settingsHeight =
         (fabs((double)CGRectGetHeight([UIScreen mainScreen].bounds) - (double)568) < DBL_EPSILON)?
         SETTINGS_HEIGHT_IPHONE_5 : SETTINGS_HEIGHT_IPHONE_4;

      [self setupSoundFX];
      [self setupBackgroundWithSize:_defaultSize];
      [self setupSettingsWithSize:_defaultSize];
      [self setupButtons];
      [self observeSoundFxChanges];
   }
   return self;
}

- (void)setupSoundFX
{
   _expandSettingsSound = [SKAction playSoundFileNamed:@"settings.expand.2.wav" waitForCompletion:NO];
   _collapseSettingsSound = [SKAction playSoundFileNamed:@"settings.collapse.2.wav" waitForCompletion:NO];
   _startAlgorithmSound = [SKAction playSoundFileNamed:@"start.algorithm.2.wav" waitForCompletion:NO];
   _stopAlgorithmSound = [SKAction playSoundFileNamed:@"stop.algorithm.2.wav" waitForCompletion:NO];
   _clearSound = [SKAction playSoundFileNamed:@"clear.1.wav" waitForCompletion:NO];
   _restoreSound = [SKAction playSoundFileNamed:@"reset.1.wav" waitForCompletion:NO];

   [super setupSoundFX];
}

- (NSArray *)coreFunctionButtons
{
   return _coreFunctionButtons;
}

- (BOOL)usingRetinaDisplay
{
   return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
           ([UIScreen mainScreen].scale == 2.0));
}

- (GLUIActionButton *)buttonWithFilename:(NSString *)fileName
                              buttonName:(NSString *)buttonName
{
   if ([self usingRetinaDisplay])
      fileName = [fileName stringByAppendingString:@"@2x"];

   GLUIActionButton *button = [GLUIActionButton spriteNodeWithImageNamed:fileName];
   button.color = [SKColor whiteColor];
   button.colorBlendFactor = 1.0;
   [button setScale:.85];
   button.name = buttonName;

   return button;
}

#pragma mark Setup Methods
- (void)setupBackgroundWithSize:(CGSize)size
{
   _backgroundLayer = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor]
                                                   size:size];
   _backgroundLayer.colorBlendFactor = 1.0;
   _backgroundLayer.alpha = BACKGROUND_ALPHA_SETTINGS_COLLAPSED;
   _backgroundLayer.anchorPoint = CGPointMake(0, 1);
   _backgroundLayer.position = CGPointMake(0, BOTTOM_BAR_HEIGHT);
   _backgroundLayer.name = @"general_hud_background";
   
   [self addChild:_backgroundLayer];
}

- (void)setupSettingsWithSize:(CGSize)size
{
   CGSize settingsSize = CGSizeMake(size.width, _settingsHeight);
   _settingsLayer = [[GLSettingsLayer alloc] initWithSize:settingsSize
                                              anchorPoint:_backgroundLayer.anchorPoint];
   _settingsLayer.alpha = 5;
   _settingsLayer.hidden = YES;
   _settingsLayer.name = @"settings_layer";
   [_backgroundLayer addChild:_settingsLayer];
}

- (void)setupButtons
{
   [self setupExpandCollapseButton];
   [self setupCoreFunctionButtons];
   [self setupAboutButton];
   [self addChild:_particleGenerator];
}

- (void)setupExpandCollapseButton
{
   if ([self usingRetinaDisplay])
      _expandCollapseButton = [GLUIActionButton spriteNodeWithImageNamed:@"arrow-right@2x"];
   else
      _expandCollapseButton = [GLUIActionButton spriteNodeWithImageNamed:@"arrow-right"];

   _expandCollapseButton.color = [SKColor crayolaBlackCoralPearlColor];
   _expandCollapseButton.colorBlendFactor = 1.0;
   [_expandCollapseButton setScale:.85];

   _expandCollapseButton.position =
      CGPointMake(_defaultSize.width - _expandCollapseButton.size.width/2 - 15,
                  HUD_BUTTON_EDGE_PADDING - _expandCollapseButton.size.height/2 - 4);

   _expandCollapseButton.name = @"expand_collapse";

   ActionBlock expandCollapseActionBlock =
      ^(NSTimeInterval holdTime) { if (!self.isAnimating) [self toggle]; };
   
   _expandCollapseButton.actionBlock = expandCollapseActionBlock;
   [self addChild:_expandCollapseButton];
}

- (void)setButtonPositionsAndAddToLayer:(NSArray *)buttons
{
   int multiplier = -1;
   for (GLUIActionButton *button in buttons)
   {
      [self addChild:button];
      button.position = CGPointMake(++multiplier * CORE_FUNCTION_BUTTON_PADDING + 82,
                                    -button.size.height);
   }
}

- (void)setupCoreFunctionButtons
{
   _clearButton = [self buttonWithFilename:@"cancel-circle" buttonName:@"clear"];
   ActionBlock clearButtonActionBlock = ^(NSTimeInterval holdTime)
   {
      if (_shouldPlaySound) [self runAction:_clearSound];
      [self.delegate clearButtonPressed];
   };
   _clearButton.actionBlock = clearButtonActionBlock;

   _restoreButton = [self buttonWithFilename:@"undo2" buttonName:@"restore"];
   ActionBlock restoreButtonActionBlock = ^(NSTimeInterval holdTime)
   {
      if (_shouldPlaySound) [self runAction:_restoreSound];
      [self.delegate restoreButtonPressed];
   };
   _restoreButton.actionBlock = restoreButtonActionBlock;

   _startStopButton = [self buttonWithFilename:@"play2" buttonName:@"start_stop"];
   _startStopButton.color = [SKColor crayolaLimeColor];
   ActionBlock startStopButtonActionBlock =
      ^(NSTimeInterval holdTime) { [self.delegate toggleRunningButtonPressed]; };
   
   _startStopButton.actionBlock = startStopButtonActionBlock;

   _cameraButton = [self buttonWithFilename:@"camera2" buttonName:@"camera"];
   _cameraButton.alpha =
      ([ALAssetsLibrary authorizationStatus] == ALAuthorizationStatusAuthorized)? 1 : .5;

   DelayedFocusActionBlock cameraDelayedFocusActionBlock =
   ^{
      [self.delegate screenShotButtonPressed:2 buttonPosition:_cameraButton.position];
   };
   _cameraButton.delayedFocusActionBlock = cameraDelayedFocusActionBlock;
   ActionBlock cameraButtonActionBlock = ^(NSTimeInterval holdTime)
   {
      void (^completionBlock)() =
         ^{[self.delegate screenShotButtonPressed:0 buttonPosition:_cameraButton.position];};
      
      if (_settingsAreExpanded)
         [self toggleSettingsWithCompletion:completionBlock];
      else
         completionBlock();
   };
   _cameraButton.actionBlock = cameraButtonActionBlock;

   _settingsButton = [self buttonWithFilename:@"cog" buttonName:@"settings"];
   
   ActionBlock settingsButtonActionBlock =
      ^(NSTimeInterval holdTime) {if (!self.isAnimating) [self toggleSettingsWithCompletion:nil];};
   
   _settingsButton.actionBlock = settingsButtonActionBlock;

   _coreFunctionButtons = @[_clearButton,
                            _restoreButton,
                            _startStopButton,
                            _cameraButton,
                            _settingsButton];

   _buttonHitBoxes = @[_clearButton.hitBox,
                       _restoreButton.hitBox,
                       _startStopButton.hitBox,
                       _clearButton.hitBox,
                       _settingsButton.hitBox];

   [self setButtonPositionsAndAddToLayer:_coreFunctionButtons];
}

- (void)setupAboutButton
{
   _aboutButton = [GLUIActionButton spriteNodeWithImageNamed:@"question.png"];

   _aboutButton.color = [SKColor whiteColor];
   _aboutButton.colorBlendFactor = 1.0;
   [_aboutButton setScale:.70];

   _aboutButton.position = CGPointMake(22, -30);
   _aboutButton.hidden = YES;

//   ActionBlock aboutActionBlock =
//   ^(NSTimeInterval interval)
//   {
//      SKAction *moveRight = [SKAction moveBy:CGVectorMake(_settingsLayer.size.width, 0)
//                                    duration:.2];
//      [_settingsLayer runAction:moveRight
//                     completion:^
//      {
//         GLPageLayer *page1 = [GLPageLayer new];
//         [page1 addHeaderText:@"HOW TO PLAY"];
//         [page1 addNewLines:1];
//         [page1 addBodyText:@"Rules of the game:"];
//         [page1 addBodyText:@"1. blah blah blah blah blah"];
//
//         GLPageCollection *pageCollection = [GLPageCollection pageCollectionWithPages:@[page1]];
//         GLPageCollectionLayer *pageCollectionLayer = [[GLPageCollectionLayer alloc] initWithSize:CGSizeMake(_settingsLayer.size.width - 30,
//                                                                                                             _settingsLayer.size.height)
//                                                                                      anchorPoint:_backgroundLayer.anchorPoint
//                                                                                   pageCollection:pageCollection];
//
//         pageCollectionLayer.position = CGPointMake((_backgroundLayer.size.width - pageCollectionLayer.size.width) * .5, -HEADING_FONT_SIZE*.5);
//         [_backgroundLayer addChild:pageCollectionLayer];
//      }];
//   };
//   _aboutButton.actionBlock = aboutActionBlock;
   [_backgroundLayer addChild:_aboutButton];
}

- (void)updateStartStopButtonForState:(GL_GAME_STATE)state
                            withSound:(BOOL)sound
{
   switch (state)
   {
      case GL_RUNNING:
         if (sound && _shouldPlaySound) [self runAction:_startAlgorithmSound];
         _startStopButton.texture = [SKTexture textureWithImageNamed:@"stop2.png"];
         _startStopButton.color = [SKColor crayolaRustyRedColor];
         break;
      case GL_STOPPED:
         if (_shouldPlaySound) [self runAction:_stopAlgorithmSound];
         _startStopButton.texture = [SKTexture textureWithImageNamed:@"play2"];
         _startStopButton.color = [SKColor crayolaLimeColor];
         break;
      default:
         break;
   }
}

- (void)setCoreFunctionButtonsHidden:(BOOL)hidden
{
   for (GLUIActionButton *button in _coreFunctionButtons)
      button.hidden = hidden;
}

#pragma mark HUD Toggling Methods
- (void)expandSettingsWithCompletionBlock:(void (^)())completionBlock
{
   _settingsButton.persistGlow = YES;
   self.animating = YES;
   _settingsAreExpanded = YES;

   SKAction *expand = [SKAction moveByX:0
                                      y:_settingsHeight
                               duration:SETTINGS_EXPAND_COLLAPSE_DUATION];
   SKAction *spin = [SKAction rotateByAngle:M_PI
                                   duration:SETTINGS_EXPAND_COLLAPSE_DUATION];

   SKAction *changeColor = [SKAction colorizeWithColor:[SKColor crayolaRobinsEggBlueColor]
                                      colorBlendFactor:1.0
                                              duration:SETTINGS_EXPAND_COLLAPSE_DUATION];

   SKAction *changeBackgroundAlpha = [SKAction fadeAlphaTo:BACKGROUND_ALPHA_SETTINGS_EXPANDED
                                                  duration:SETTINGS_EXPAND_COLLAPSE_DUATION];

   SKAction *backgroundActions = [SKAction group:@[expand, changeBackgroundAlpha]];

   expand.timingMode = SKActionTimingEaseInEaseOut;
   spin.timingMode = SKActionTimingEaseInEaseOut;
   changeColor.timingMode = SKActionTimingEaseInEaseOut;
   changeBackgroundAlpha.timingMode = SKActionTimingEaseInEaseOut;
   
   if (_shouldPlaySound) [self runAction:_expandSettingsSound];
   
   [_backgroundLayer runAction:backgroundActions
                    completion:
    ^{
       [self.delegate settingsDidExpand];
       self.animating = NO;
    }];

   [self.delegate settingsWillExpandWithRepositioningAction:expand];
   [_settingsButton runAction:spin completion:completionBlock];
}

- (void)collapseSettingsWithCompletionBlock:(void (^)())completionBlock
{
   _settingsButton.persistGlow = NO;
   self.animating = YES;
   _settingsAreExpanded = NO;
   _settingsLayer.hidden = YES;
   _aboutButton.hidden = YES;

   SKAction *collapse = [SKAction moveByX:0
                                        y:-(_settingsHeight)
                                 duration:SETTINGS_EXPAND_COLLAPSE_DUATION];

   SKAction *spin = [SKAction rotateByAngle:-M_PI
                                   duration:SETTINGS_EXPAND_COLLAPSE_DUATION];

   SKAction *changeColor = [SKAction colorizeWithColor:[SKColor whiteColor]
                                      colorBlendFactor:1.0
                                              duration:SETTINGS_EXPAND_COLLAPSE_DUATION];

   SKAction *changeBackgroundAlpha = [SKAction fadeAlphaTo:BACKGROUND_ALPHA_SETTINGS_COLLAPSED
                                                  duration:SETTINGS_EXPAND_COLLAPSE_DUATION];

   SKAction *backgroundActions = [SKAction group:@[collapse, changeBackgroundAlpha]];

   collapse.timingMode = SKActionTimingEaseInEaseOut;
   spin.timingMode = SKActionTimingEaseInEaseOut;
   changeColor.timingMode = SKActionTimingEaseInEaseOut;
   changeBackgroundAlpha.timingMode = SKActionTimingEaseInEaseOut;
   
   if (_shouldPlaySound) [self runAction:_collapseSettingsSound];
   
   [_backgroundLayer runAction:backgroundActions
                    completion:
    ^{
       [self.delegate settingsDidCollapse];
       self.animating = NO;
    }];

   [self.delegate settingsWillCollapseWithRepositioningAction:collapse];
   [_settingsButton runAction:spin completion:completionBlock];
}

- (void)toggleSettingsWithCompletion:(void (^)())completion
{
   [_particleGenerator resetSimulation];
   if (_settingsAreExpanded)
   {
      [_settingsButton loseFocus];
      [self collapseSettingsWithCompletionBlock:^
       {
          _settingsButton.color = [SKColor whiteColor];
          _settingsLayer.hidden = YES;
          _aboutButton.hidden = YES;
          if (completion)
             completion();
       }];
   }
   else
      [self expandSettingsWithCompletionBlock:^
       {
          if (_settingsAreExpanded)
          {
             _settingsLayer.hidden = NO;
             _aboutButton.hidden = NO;
          }
          if (completion)
             completion();
       }];
}

- (void)expandBottomBar
{
   if (![self.delegate hudCanExpand:self])
      return;

   self.animating = YES;
   CFTimeInterval waitPeriod = 0.0;
   [self.delegate hud:self willExpandAfterPeriod:&waitPeriod];

   SKAction *wait = [SKAction waitForDuration:waitPeriod];
   SKAction *slide = [SKAction moveByX:_defaultSize.width - 60
                                     y:0
                              duration:BOTTOM_BAR_EXPAND_COLLAPSE_DURATION];
   SKAction *changeHudColor = [SKAction colorizeWithColor:[SKColor crayolaBlackCoralPearlColor]
                                         colorBlendFactor:1.0
                                                 duration:BOTTOM_BAR_EXPAND_COLLAPSE_DURATION];
   SKAction *changeButtonColor = [SKAction colorizeWithColor:[SKColor whiteColor]
                                            colorBlendFactor:1.0
                                                    duration:BOTTOM_BAR_EXPAND_COLLAPSE_DURATION];
   SKAction *rotate = [SKAction rotateByAngle:M_PI
                                     duration:BOTTOM_BAR_EXPAND_COLLAPSE_DURATION];

   slide.timingMode = SKActionTimingEaseInEaseOut;
   changeHudColor.timingMode = SKActionTimingEaseInEaseOut;
   rotate.timingMode = SKActionTimingEaseInEaseOut;

   SKAction *buttonActions = [SKAction group:@[changeButtonColor, rotate]];
   self.expanded = YES;
   [self runAction:wait
        completion:^
   {
      if (_shouldPlaySound) [self runAction:self.defaultExpandingSoundFX];
      
      [_backgroundLayer runAction:slide];
      
      for (GLUIActionButton *button in _coreFunctionButtons)
      {
         [button runAction:slide];
         [button.hitBox runAction:slide];
      }

      [_backgroundLayer runAction:changeHudColor];
      [_expandCollapseButton runAction:buttonActions
                            completion:^
       {
          SKAction *moveButton = [SKAction moveByX:0
                                                 y:HUD_BUTTON_EDGE_PADDING + 10
                                          duration:REPOSITION_BUTTONS_DURATION];
          SKAction *moveButtonHitBox = [SKAction moveByX:0
                                                       y:HUD_BUTTON_EDGE_PADDING + 10
                                                duration:REPOSITION_BUTTONS_DURATION];
          moveButton.timingMode = SKActionTimingEaseInEaseOut;

          for (GLUIActionButton *button in _coreFunctionButtons)
          {
             button.hidden = NO;
             [button runAction:moveButton];
             [button.hitBox runAction:moveButtonHitBox];
          }

          [self.delegate hudDidExpand:self];
          self.animating = NO;
       }];
   }];
}

- (void)collapseBottomBar
{
   self.animating = YES;
   [self.delegate hudWillCollapse:self];

   SKAction *wait = [SKAction waitForDuration:WAIT_BEFORE_COLORIZE_DURATION];
   SKAction *slide = [SKAction moveByX:-_defaultSize.width + 60
                                     y:0
                              duration:BOTTOM_BAR_EXPAND_COLLAPSE_DURATION];
   SKAction *changeHudColor = [SKAction colorizeWithColor:[SKColor clearColor]
                                         colorBlendFactor:1.0
                                                 duration:BOTTOM_BAR_EXPAND_COLLAPSE_DURATION -
                                                          WAIT_BEFORE_COLORIZE_DURATION];
   SKAction *changeButtonColor = [SKAction colorizeWithColor:[SKColor crayolaBlackCoralPearlColor]
                                            colorBlendFactor:1.0
                                                    duration:BOTTOM_BAR_EXPAND_COLLAPSE_DURATION -
                                                             WAIT_BEFORE_COLORIZE_DURATION];
   SKAction *rotate = [SKAction rotateByAngle:-M_PI
                                     duration:BOTTOM_BAR_EXPAND_COLLAPSE_DURATION];

   slide.timingMode = SKActionTimingEaseInEaseOut;
   changeHudColor.timingMode = SKActionTimingEaseInEaseOut;
   changeButtonColor.timingMode = SKActionTimingEaseInEaseOut;
   rotate.timingMode = SKActionTimingEaseInEaseOut;

   SKAction *hudBackgroundColorSequence = [SKAction sequence:@[wait, changeHudColor]];
   SKAction *buttonColorSequence = [SKAction sequence:@[wait, changeButtonColor]];
   SKAction *buttonActions = [SKAction group:@[rotate, buttonColorSequence]];

   self.expanded = NO;
   [self setCoreFunctionButtonsHidden:YES];

   if (_shouldPlaySound) [self runAction:self.defaultCollapsingSoundFX];
   
   [_backgroundLayer runAction:slide];

   for (GLUIActionButton *button in _coreFunctionButtons)
   {
      [button runAction:slide];
      [button.hitBox runAction:slide];
   }

   [_expandCollapseButton runAction:buttonActions];
   [_backgroundLayer runAction:hudBackgroundColorSequence
                    completion:^
    {
       SKAction *moveButton = [SKAction moveByX:0
                                              y:-(HUD_BUTTON_EDGE_PADDING + 10)
                                       duration:REPOSITION_BUTTONS_DURATION];
       SKAction *moveButtonHitBox = [SKAction moveByX:0
                                                    y:-(HUD_BUTTON_EDGE_PADDING + 10)
                                             duration:REPOSITION_BUTTONS_DURATION];
       for (GLUIActionButton *button in _coreFunctionButtons)
       {
          [button runAction:moveButton];
          [button.hitBox runAction:moveButtonHitBox];
       }

       [self.delegate hudDidCollapse:self];
       self.animating = NO;
    }];
}

- (void)collapse
{
   if (_settingsAreExpanded)
   {
      [_settingsButton loseFocus];
      [self collapseSettingsWithCompletionBlock:^
      {
         [self collapseBottomBar];
      }];
   }
   else
   {
      [self collapseBottomBar];
   }
}

- (void)expand
{
   if (!self.expanded)
      [self expandBottomBar];
}

- (void)toggle
{
   if (self.expanded)
      [self collapse];
   else
      [self expandBottomBar];
}

- (void)hide
{
   [self setCoreFunctionButtonsHidden:YES];
   _backgroundLayer.hidden = YES;
   _expandCollapseButton.hidden = YES;
}

- (void)show
{
   [self setCoreFunctionButtonsHidden:NO];
   _backgroundLayer.hidden = NO;
   _expandCollapseButton.hidden = NO;
}

- (void)settingChanged:(NSNumber *)value ofType:(HUDValueType)type forKeyPath:(NSString *)keyPath
{
   if ([keyPath compare:@"SoundFX"] == NSOrderedSame)
   {
      assert(type == HVT_BOOL);
      _shouldPlaySound = [value boolValue];
   }
}

@end