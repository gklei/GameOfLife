//
//  GLGeneralHud.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/24/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLGeneralHud.h"
#import "GLGridScene.h"

#import "GLUIButton.h"

#import "GLSettingsLayer.h"
#import "UIColor+Crayola.h"

#define CORE_FUNCTION_BUTTON_PADDING 52
#define HUD_BUTTON_EDGE_PADDING 48
#define HUD_BUTTON_PADDING 50
#define HEADING_FONT_SIZE 25

#define BACKGROUND_ALPHA_SETTINGS_COLLAPSED .7
#define BACKGROUND_ALPHA_SETTINGS_EXPANDED .8

#define BOTTOM_BAR_HEIGHT 60
#define SETTINGS_HEIGHT (BOTTOM_BAR_HEIGHT * 5)
#define SETTINGS_EXPAND_COLLAPSE_DUATION .25
#define BOTTOM_BAR_EXPAND_COLLAPSE_DURATION .5
#define REPOSITION_BUTTONS_DURATION .25
#define WAIT_BEFORE_COLORIZE_DURATION .25


@interface GLGeneralHud()
{
   CGSize _defaultSize;
   SKSpriteNode *_backgroundLayer;
   GLSettingsLayer *_settingsLayer;

   NSArray *_coreFunctionButtons;
   NSArray *_buttonHitBoxes;

   GLUIButton *_expandCollapseButton;

   GLUIButton*_clearButton;
   SKSpriteNode *_clearButtonHitBox;

   GLUIButton *_restoreButton;
   SKSpriteNode *_restoreButtonHitBox;

   GLUIButton *_startStopButton;
   SKSpriteNode *_startStopButtonHitBox;

   GLUIButton *_cameraButton;
   SKSpriteNode *_cameraButtonHitBox;

   GLUIButton *_settingsButton;
   SKSpriteNode *_settingsButtonHitBox;

   SKAction *_expandSettingsSound;
   SKAction *_collapseSettingsSound;
   SKAction *_startAlgorithmSound;
   SKAction *_stopAlgorithmSound;
}
@end

@implementation GLGeneralHud

- (id)init
{
   if (self = [super init])
   {
      _defaultSize = [UIScreen mainScreen].bounds.size;
      [self setupSoundFX];
      [self setupBackgroundWithSize:_defaultSize];
      [self setupSettingsWithSize:_defaultSize];
      [self setupButtons];
   }
   return self;
}

- (void)setupSoundFX
{
   _expandSettingsSound = [SKAction playSoundFileNamed:@"settings.expand.2.wav" waitForCompletion:NO];
   _collapseSettingsSound = [SKAction playSoundFileNamed:@"settings.collapse.2.wav" waitForCompletion:NO];
   _startAlgorithmSound = [SKAction playSoundFileNamed:@"start.algorithm.2.wav" waitForCompletion:NO];
   _stopAlgorithmSound = [SKAction playSoundFileNamed:@"stop.algorithm.2.wav" waitForCompletion:NO];

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

- (GLUIButton *)buttonWithFilename:(NSString *)fileName buttonName:(NSString *)buttonName
{
   if ([self usingRetinaDisplay])
      fileName = [fileName stringByAppendingString:@"@2x"];

   GLUIButton *button = [GLUIButton spriteNodeWithImageNamed:fileName];
   button.color = [SKColor whiteColor];
   button.colorBlendFactor = 1.0;
   [button setScale:.85];
   button.name = buttonName;

   return button;
}

- (SKSpriteNode *)hitBoxForButton:(GLUIButton *)button
{
   CGSize hitBoxSize = CGSizeMake(button.size.width + 20, BOTTOM_BAR_HEIGHT);
   SKSpriteNode *buttonHitBox = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor]
                                                             size:hitBoxSize];
   return buttonHitBox;
}

- (void)setupHitBoxForButton:(GLUIButton *)button
{
   CGSize hitBoxSize = CGSizeMake(button.size.width + 20, BOTTOM_BAR_HEIGHT);
   SKSpriteNode *buttonHitBox = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor]
                                                             size:hitBoxSize];
   button.hitBox = buttonHitBox;
   [button addChild:button.hitBox];
//   button.hitBox.size = CGSizeMake(button.size.width + 20, BOTTOM_BAR_HEIGHT);
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
   CGSize settingsSize = CGSizeMake(size.width, SETTINGS_HEIGHT);
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
}

- (void)setupExpandCollapseButton
{
   if ([self usingRetinaDisplay])
      _expandCollapseButton = [GLUIButton spriteNodeWithImageNamed:@"arrow-right@2x"];
   else
      _expandCollapseButton = [GLUIButton spriteNodeWithImageNamed:@"arrow-right"];

   _expandCollapseButton.color = [SKColor crayolaBlackCoralPearlColor];
   _expandCollapseButton.alpha = _backgroundLayer.alpha;
   _expandCollapseButton.colorBlendFactor = 1.0;
   [_expandCollapseButton setScale:.85];

   _expandCollapseButton.position =
      CGPointMake(_defaultSize.width - _expandCollapseButton.size.width/2 - 15,
                  HUD_BUTTON_EDGE_PADDING - _expandCollapseButton.size.height/2);

   _expandCollapseButton.name = @"expand_collapse";
   [self addChild:_expandCollapseButton];
}

- (void)setButtonPositionsAndAddToLayer:(NSArray *)buttons
{
   int multiplier = -1;
   for (GLUIButton *button in buttons)
   {
      [self addChild:button];
      button.position = CGPointMake(++multiplier * CORE_FUNCTION_BUTTON_PADDING + 120,
                                    -button.size.height / 2.0);
   }
}

- (void)setupCoreFunctionButtons
{
   _clearButton = [self buttonWithFilename:@"cancel-circle" buttonName:@"clear"];
   _clearButtonHitBox = [self hitBoxForButton:_clearButton];

   _restoreButton = [self buttonWithFilename:@"undo2" buttonName:@"restore"];
   _restoreButtonHitBox = [self hitBoxForButton:_restoreButton];

   _startStopButton = [self buttonWithFilename:@"play2" buttonName:@"start_stop"];
   _startStopButton.color = [SKColor crayolaLimeColor];
   _startStopButtonHitBox = [self hitBoxForButton:_startStopButton];

   _cameraButton = [self buttonWithFilename:@"camera2" buttonName:@"camera"];
   _cameraButtonHitBox = [self hitBoxForButton:_cameraButton];

   _settingsButton = [self buttonWithFilename:@"cog" buttonName:@"settings"];
   _settingsButtonHitBox = [self hitBoxForButton:_settingsButton];

   _coreFunctionButtons = @[_clearButton,
                            _restoreButton,
                            _startStopButton,
                            _cameraButton,
                            _settingsButton];

//   for (GLUIButton *button in _coreFunctionButtons)
//      [self setupHitBoxForButton:button];

//   _buttonHitBoxes = @[_clearButtonHitBox,
//                       _restoreButtonHitBox,
//                       _startStopButtonHitBox,
//                       _cameraButtonHitBox,
//                       _settingsButtonHitBox];

   _buttonHitBoxes = @[_clearButton.hitBox,
                       _restoreButton.hitBox,
                       _startStopButton.hitBox,
                       _clearButton.hitBox,
                       _settingsButton.hitBox];

   [self setButtonPositionsAndAddToLayer:_coreFunctionButtons];
}

- (void)updateStartStopButtonForState:(GL_GAME_STATE)state
{
   switch (state)
   {
      case GL_RUNNING:
         [self runAction:_startAlgorithmSound];
         _startStopButton.texture = [SKTexture textureWithImageNamed:@"pause"];
         _startStopButton.color = [SKColor crayolaRadicalRedColor];
         break;
      case GL_STOPPED:
         [self runAction:_stopAlgorithmSound];
         _startStopButton.texture = [SKTexture textureWithImageNamed:@"play2"];
         _startStopButton.color = [SKColor crayolaLimeColor];
         break;
      default:
         break;
   }
}

- (void)setCoreFunctionButtonsHidden:(BOOL)hidden
{
   for (GLUIButton *button in _coreFunctionButtons)
      button.hidden = hidden;
}

#pragma mark HUD Toggling Methods
- (void)expandSettingsWithCompletionBlock:(void (^)())completionBlock
{
   _settingsAreExpanded = YES;

   SKAction *expand = [SKAction moveByX:0
                                      y:SETTINGS_HEIGHT
                               duration:SETTINGS_EXPAND_COLLAPSE_DUATION];
   SKAction *spin = [SKAction rotateByAngle:M_PI
                                   duration:SETTINGS_EXPAND_COLLAPSE_DUATION];

   SKAction *changeColor = [SKAction colorizeWithColor:[SKColor crayolaRobinsEggBlueColor]
                                      colorBlendFactor:1.0
                                              duration:SETTINGS_EXPAND_COLLAPSE_DUATION];

   SKAction *changeBackgroundAlpha = [SKAction fadeAlphaTo:BACKGROUND_ALPHA_SETTINGS_EXPANDED
                                                  duration:SETTINGS_EXPAND_COLLAPSE_DUATION];

   SKAction *buttonActions = [SKAction group:@[spin, changeColor]];
   SKAction *backgroundActions = [SKAction group:@[expand, changeBackgroundAlpha]];

   expand.timingMode = SKActionTimingEaseInEaseOut;
   spin.timingMode = SKActionTimingEaseInEaseOut;
   changeColor.timingMode = SKActionTimingEaseInEaseOut;
   changeBackgroundAlpha.timingMode = SKActionTimingEaseInEaseOut;

   [self.delegate settingsWillExpandWithRepositioningAction:expand];

   [self runAction:_expandSettingsSound];
   [_backgroundLayer runAction:backgroundActions
                    completion:
    ^{
       [self.delegate settingsDidExpand];
    }];

   [_settingsButton runAction:buttonActions completion:completionBlock];

}

- (void)collapseSettingsWithCompletionBlock:(void (^)())completionBlock
{
   _settingsAreExpanded = NO;
   _settingsLayer.hidden = YES;

   SKAction *collapse = [SKAction moveByX:0
                                        y:-(SETTINGS_HEIGHT)
                                 duration:SETTINGS_EXPAND_COLLAPSE_DUATION];
   SKAction *spin = [SKAction rotateByAngle:-M_PI
                                   duration:SETTINGS_EXPAND_COLLAPSE_DUATION];

   SKAction *changeColor = [SKAction colorizeWithColor:[SKColor whiteColor]
                                      colorBlendFactor:1.0
                                              duration:SETTINGS_EXPAND_COLLAPSE_DUATION];

   SKAction *changeBackgroundAlpha = [SKAction fadeAlphaTo:BACKGROUND_ALPHA_SETTINGS_COLLAPSED
                                                  duration:SETTINGS_EXPAND_COLLAPSE_DUATION];

   SKAction *buttonActions = [SKAction group:@[spin, changeColor]];
   SKAction *backgroundActions = [SKAction group:@[collapse, changeBackgroundAlpha]];

   collapse.timingMode = SKActionTimingEaseInEaseOut;
   spin.timingMode = SKActionTimingEaseInEaseOut;
   changeColor.timingMode = SKActionTimingEaseInEaseOut;
   changeBackgroundAlpha.timingMode = SKActionTimingEaseInEaseOut;

   [self.delegate settingsWillCollapseWithRepositioningAction:collapse];

   [self runAction:_collapseSettingsSound];
   [_backgroundLayer runAction:backgroundActions completion:^{[self.delegate settingsDidCollapse];}];
   [_settingsButton runAction:buttonActions completion:completionBlock];
}

- (void)toggleSettings
{
   if (_settingsAreExpanded)
      [self collapseSettingsWithCompletionBlock:^
       {
          _settingsButton.color = [SKColor whiteColor];
          _settingsLayer.hidden = YES;
       }];
   else
      [self expandSettingsWithCompletionBlock:^
       {
          if (_settingsAreExpanded)
          {
             _settingsButton.color = [SKColor crayolaRobinsEggBlueColor];
             _settingsLayer.hidden = NO;
          }
       }];
}

- (void)expandBottomBar
{
   CFTimeInterval waitPeriod = 0.0;
   [self.delegate hud:self willExpandAfterPeriod:&waitPeriod];

   SKAction *wait = [SKAction waitForDuration:waitPeriod];
   SKAction *slide = [SKAction moveByX:_defaultSize.width - 60
                                     y:0
                              duration:BOTTOM_BAR_EXPAND_COLLAPSE_DURATION];
   SKAction *changeHudColor = [SKAction colorizeWithColor:[SKColor crayolaBlackCoralPearlColor]
                                         colorBlendFactor:1.0
                                                 duration:BOTTOM_BAR_EXPAND_COLLAPSE_DURATION];
   SKAction *changeButtonAlpha = [SKAction fadeAlphaTo:1.0
                                              duration:BOTTOM_BAR_EXPAND_COLLAPSE_DURATION];
   SKAction *changeButtonColor = [SKAction colorizeWithColor:[SKColor whiteColor]
                                            colorBlendFactor:1.0
                                                    duration:BOTTOM_BAR_EXPAND_COLLAPSE_DURATION];
   SKAction *rotate = [SKAction rotateByAngle:M_PI
                                     duration:BOTTOM_BAR_EXPAND_COLLAPSE_DURATION];

   slide.timingMode = SKActionTimingEaseInEaseOut;
   changeHudColor.timingMode = SKActionTimingEaseInEaseOut;
   changeButtonAlpha.timingMode = SKActionTimingEaseInEaseOut;
   rotate.timingMode = SKActionTimingEaseInEaseOut;

   SKAction *buttonActions = [SKAction group:@[changeButtonAlpha,
                                               changeButtonColor,
                                               rotate]];
   self.expanded = YES;
   [self runAction:wait
        completion:^
   {
      [self runAction:self.defaultExpandingSoundFX];
      [_backgroundLayer runAction:slide];
      
      for (GLUIButton *button in _coreFunctionButtons)
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

          for (GLUIButton *button in _coreFunctionButtons)
          {
             button.hidden = NO;
             [button runAction:moveButton];
             [button.hitBox runAction:moveButtonHitBox];
          }

          [self.delegate hudDidExpand:self];
       }];
   }];
}

- (void)collapseBottomBar
{
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
   SKAction *changeButtonAlpha = [SKAction fadeAlphaTo:_backgroundLayer.alpha
                                              duration:BOTTOM_BAR_EXPAND_COLLAPSE_DURATION -
                                                       WAIT_BEFORE_COLORIZE_DURATION];
   SKAction *rotate = [SKAction rotateByAngle:-M_PI
                                     duration:BOTTOM_BAR_EXPAND_COLLAPSE_DURATION];

   slide.timingMode = SKActionTimingEaseInEaseOut;
   changeHudColor.timingMode = SKActionTimingEaseInEaseOut;
   changeButtonColor.timingMode = SKActionTimingEaseInEaseOut;
   changeButtonAlpha.timingMode = SKActionTimingEaseInEaseOut;
   rotate.timingMode = SKActionTimingEaseInEaseOut;

   SKAction *hudBackgroundColorSequence = [SKAction sequence:@[wait, changeHudColor]];
   SKAction *buttonColorAnimations = [SKAction group:@[changeButtonAlpha, changeButtonColor]];
   SKAction *buttonColorSequence = [SKAction sequence:@[wait, buttonColorAnimations]];
   SKAction *buttonActions = [SKAction group:@[rotate, buttonColorSequence]];

   self.expanded = NO;
   [self setCoreFunctionButtonsHidden:YES];

   [self runAction:self.defaultCollapsingSoundFX];
   [_backgroundLayer runAction:slide];

   for (GLUIButton *button in _coreFunctionButtons)
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
       for (GLUIButton *button in _coreFunctionButtons)
       {
          [button runAction:moveButton];
          [button.hitBox runAction:moveButtonHitBox];
       }

       [self.delegate hudDidCollapse:self];
    }];
}

- (void)collapse
{
   if (_settingsAreExpanded)
   {
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

#pragma mark GLHud Touch Method
- (void)handleTouch:(UITouch *)touch moved:(BOOL)moved
{
   if (moved)
      return;
   
   SKNode *node = [self nodeAtPoint:[touch locationInNode:self]];

   // check to see if the bottom bar should expand or collapse
   if (node == _expandCollapseButton)
   {
      [self toggle];
      return;
   }

   // if the hud was somehow pressed elsewhere and the bottom bar is not expanded, return
   if (!self.expanded || ![_coreFunctionButtons containsObject:node])
      return;

   if (node != _settingsButtonHitBox &&
       node != _startStopButtonHitBox &&
       node != _cameraButtonHitBox)
   {
      [self runAction:self.defaultButtonPressSound];
   }

   // we know that the bottom bar is expanded and can now check to see where the hud was pressed
//   if (node == _settingsButtonHitBox)
   if (node == _settingsButton)
      [self toggleSettings];
//   else if (node == _startStopButtonHitBox)
   else if (node == _startStopButton)
      [self.delegate toggleRunningButtonPressed];
//   else if (node == _clearButtonHitBox)
   else if (node == _clearButton)
      [self.delegate clearButtonPressed];
//   else if (node == _restoreButtonHitBox)
   else if (node == _restoreButton)
      [self.delegate restoreButtonPressed];
//   else if (node == _cameraButtonHitBox)
   else if (node == _cameraButton)
      [self.delegate screenShotButtonPressed];
}

- (void)handleTouch:(UITouch *)touch forButton:(GLUIButton *)button
{
   if (button == _expandCollapseButton)
      [self toggle];
   else if (button == _settingsButton)
      [self toggleSettings];
   //   else if (button == _startStopButtonHitBox)
   else if (button == _startStopButton)
      [self.delegate toggleRunningButtonPressed];
   //   else if (button == _clearButtonHitBox)
   else if (button == _clearButton)
      [self.delegate clearButtonPressed];
   //   else if (button == _restoreButtonHitBox)
   else if (button == _restoreButton)
      [self.delegate restoreButtonPressed];
   //   else if (button == _cameraButtonHitBox)
   else if (button == _cameraButton)
      [self.delegate screenShotButtonPressed];
}

@end
