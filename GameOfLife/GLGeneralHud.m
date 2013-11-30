//
//  GLGeneralHud.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/24/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLGeneralHud.h"
#import "UIColor+Crayola.h"

#define CORE_FUNCTION_BUTTON_PADDING 52
#define HUD_BUTTON_EDGE_PADDING 48
#define HUD_BUTTON_PADDING 50

@interface GLGeneralHud()
{
   CGSize _defaultSize;
   SKSpriteNode *_backgroundLayer;
   NSArray *_coreFunctionButtons;
   NSArray *_buttonHitBoxes;

   SKSpriteNode *_expandCollapseButton;
   SKSpriteNode *_expandCollapseButtonBackground;

   SKSpriteNode *_clearButton;
   SKSpriteNode *_clearButtonHitBox;

   SKSpriteNode *_restoreButton;
   SKSpriteNode *_restoreButtonHitBox;

   SKSpriteNode *_startStopButton;
   SKSpriteNode *_startStopButtonHitBox;

   SKSpriteNode *_cameraButton;
   SKSpriteNode *_cameraButtonHitBox;

   SKSpriteNode *_settingsButton;
   SKSpriteNode *_settingsButtonHitBox;

   BOOL _settingsAreExpanded;
}
@end

@implementation GLGeneralHud

- (id)init
{
   if (self = [super init])
   {
      _defaultSize = [UIScreen mainScreen].bounds.size;
      [self setupBackgroundWithSize:_defaultSize];
      [self setupButtons];
   }
   return self;
}

- (NSArray *)coreFunctionButtons
{
   return _coreFunctionButtons;
}

- (SKSpriteNode *)buttonWithFilename:(NSString *)fileName buttonName:(NSString *)buttonName
{
   SKSpriteNode *button = [SKSpriteNode spriteNodeWithImageNamed:fileName];
   button.color = [SKColor whiteColor];
   button.colorBlendFactor = 1.0;
   [button setScale:.20];
   button.name = buttonName;

   return button;
}

- (SKSpriteNode *)hitBoxForButton:(SKSpriteNode *)button
{
   CGSize hitBoxSize = CGSizeMake(button.size.width + 20, 60);
   SKSpriteNode *buttonHitBox = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor]
                                                             size:hitBoxSize];
   return buttonHitBox;
}

#pragma mark Setup Methods
- (void)setupBackgroundWithSize:(CGSize)size
{
   _backgroundLayer = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor]
                                                   size:size];
   _backgroundLayer.colorBlendFactor = 1.0;
   _backgroundLayer.alpha = .7;
   _backgroundLayer.anchorPoint = CGPointMake(0, 1);
   _backgroundLayer.position = CGPointMake(0, 60);
   _backgroundLayer.name = @"general_hud_background";

   [self addChild:_backgroundLayer];
}

- (void)setupButtons
{
   [self setupExpandCollapseButton];
   [self setupCoreFunctionButtons];
}

- (void)setupExpandCollapseButton
{
   _expandCollapseButton = [SKSpriteNode spriteNodeWithImageNamed:@"expand_right"];
   _expandCollapseButton.color = [SKColor crayolaBlackCoralPearlColor];
   _expandCollapseButton.alpha = _backgroundLayer.alpha;
   _expandCollapseButton.colorBlendFactor = 1.0;
   [_expandCollapseButton setScale:.23];

   _expandCollapseButton.position =
   CGPointMake(_defaultSize.width - _expandCollapseButton.size.width/2 - 15,
               HUD_BUTTON_EDGE_PADDING - _expandCollapseButton.size.height/2);

   _expandCollapseButton.name = @"expand_collapse";
   [self addChild:_expandCollapseButton];
}

- (void)setButtonPositionsAndAddToLayer:(NSArray *)buttons
{
   int multiplier = 0;
   for (SKSpriteNode *button in buttons)
   {
      [self addChild:button];
      button.position = CGPointMake((multiplier++)*CORE_FUNCTION_BUTTON_PADDING + 80,
                                    -button.size.height/2.0);
   }
}

- (void)setupCoreFunctionButtons
{
   _clearButton = [self buttonWithFilename:@"clear" buttonName:@"clear"];
   _clearButtonHitBox = [self hitBoxForButton:_clearButton];

   _restoreButton = [self buttonWithFilename:@"restore" buttonName:@"restore"];
   _restoreButtonHitBox = [self hitBoxForButton:_restoreButton];

   _startStopButton = [self buttonWithFilename:@"start" buttonName:@"start_stop"];
   _startStopButton.color = [SKColor crayolaLimeColor];
   _startStopButtonHitBox = [self hitBoxForButton:_startStopButton];

   _cameraButton = [self buttonWithFilename:@"camera" buttonName:@"camera"];
   _cameraButtonHitBox = [self hitBoxForButton:_cameraButton];

   _settingsButton = [self buttonWithFilename:@"gear" buttonName:@"settings"];
   _settingsButtonHitBox = [self hitBoxForButton:_settingsButton];

   _coreFunctionButtons = @[_clearButton,
                            _restoreButton,
                            _startStopButton,
                            _cameraButton,
                            _settingsButton];

   _buttonHitBoxes = @[_clearButtonHitBox,
                          _restoreButtonHitBox,
                          _startStopButtonHitBox,
                          _cameraButtonHitBox,
                          _settingsButtonHitBox];

   [self setButtonPositionsAndAddToLayer:_coreFunctionButtons];
   [self setButtonPositionsAndAddToLayer:_buttonHitBoxes];
}

- (void)updateStartStopButtonForState:(GL_GAME_STATE)state
{
   switch (state)
   {
      case GL_RUNNING:
         _startStopButton.texture = [SKTexture textureWithImageNamed:@"stop"];
         _startStopButton.color = [SKColor crayolaSizzlingRedColor];
         break;
      case GL_STOPPED:
         _startStopButton.texture = [SKTexture textureWithImageNamed:@"start"];
         _startStopButton.color = [SKColor crayolaLimeColor];
         break;
      default:
         break;
   }
}

- (void)setCoreFunctionButtonsHidden:(BOOL)hidden
{
   for (SKSpriteNode *button in _coreFunctionButtons)
      button.hidden = hidden;
   
   for (SKSpriteNode *button in _buttonHitBoxes)
      button.hidden = hidden;
}

#pragma mark HUD Toggling Methods
- (void)expandBottomBar
{
   CFTimeInterval waitPeriod = 0.0;
   [self.delegate hud:self willExpandAfterPeriod:&waitPeriod];

   SKAction *wait = [SKAction waitForDuration:waitPeriod];
   SKAction *slide = [SKAction moveByX:_defaultSize.width - 60 y:0 duration:.5];
   SKAction *changeHudColor = [SKAction colorizeWithColor:[SKColor crayolaBlackCoralPearlColor]
                                         colorBlendFactor:1.0
                                                 duration:.5];
   SKAction *changeButtonAlpha = [SKAction fadeAlphaTo:1.0
                                              duration:.5];
   SKAction *changeButtonColor = [SKAction colorizeWithColor:[SKColor whiteColor]
                                            colorBlendFactor:1.0
                                                    duration:.5];
   SKAction *maintainPosition = [SKAction moveByX:-(_defaultSize.width - 60) y:0
                                         duration:.5];
   SKAction *rotate = [SKAction rotateByAngle:M_PI
                                     duration:.5];

   slide.timingMode = SKActionTimingEaseInEaseOut;
   changeHudColor.timingMode = SKActionTimingEaseInEaseOut;
   changeButtonAlpha.timingMode = SKActionTimingEaseInEaseOut;
   maintainPosition.timingMode = SKActionTimingEaseInEaseOut;
   rotate.timingMode = SKActionTimingEaseInEaseOut;

   SKAction *buttonActions = [SKAction group:@[changeButtonAlpha,
                                               changeButtonColor,
                                               rotate]];
   self.expanded = YES;
   [self runAction:wait completion:^{
      [_backgroundLayer runAction:slide];
      for (SKNode *button in _coreFunctionButtons)
         [button runAction:slide];

      for (SKNode *button in _buttonHitBoxes)
         [button runAction:slide];

      [_backgroundLayer runAction:changeHudColor];
      [_expandCollapseButton runAction:buttonActions
                    completion:^
       {
          SKAction *moveButton = [SKAction moveByX:0 y:HUD_BUTTON_EDGE_PADDING duration:.25];
          SKAction *moveButtonHitBox = [SKAction moveByX:0 y:HUD_BUTTON_EDGE_PADDING + 10 duration:.25];
          moveButton.timingMode = SKActionTimingEaseInEaseOut;
          for (SKNode *button in _coreFunctionButtons)
          {
             button.hidden = NO;
             [button runAction:moveButton];
          }

          for (SKNode *button in _buttonHitBoxes)
          {
             button.hidden = NO;
             [button runAction:moveButtonHitBox];
          }

          [self.delegate hudDidExpand:self];
       }];
   }];
}

- (void)collapseBottomBar
{
   [self.delegate hudWillCollapse:self];

   SKAction *wait = [SKAction waitForDuration:.25];
   SKAction *slide = [SKAction moveByX:-_defaultSize.width + 60 y:0 duration:.5];
   SKAction *changeHudColor = [SKAction colorizeWithColor:[SKColor clearColor]
                                         colorBlendFactor:1.0
                                                 duration:.25];
   SKAction *changeButtonColor = [SKAction colorizeWithColor:[SKColor crayolaBlackCoralPearlColor]
                                            colorBlendFactor:1.0
                                                    duration:.25];
   SKAction *changeButtonAlpha = [SKAction fadeAlphaTo:_backgroundLayer.alpha
                                              duration:.25];
   SKAction *maintainPosition = [SKAction moveByX:_defaultSize.width - 60 y:0
                                         duration:.5];
   SKAction *rotate = [SKAction rotateByAngle:-M_PI duration:.5];

   slide.timingMode = SKActionTimingEaseInEaseOut;
   changeHudColor.timingMode = SKActionTimingEaseInEaseOut;
   changeButtonColor.timingMode = SKActionTimingEaseInEaseOut;
   changeButtonAlpha.timingMode = SKActionTimingEaseInEaseOut;
   maintainPosition.timingMode = SKActionTimingEaseInEaseOut;
   rotate.timingMode = SKActionTimingEaseInEaseOut;

   SKAction *hudBackgroundColorSequence = [SKAction sequence:@[wait, changeHudColor]];
   SKAction *buttonColorAnimations = [SKAction group:@[changeButtonAlpha, changeButtonColor]];
   SKAction *buttonColorSequence = [SKAction sequence:@[wait, buttonColorAnimations]];
   SKAction *buttonActions = [SKAction group:@[rotate, buttonColorSequence]];

   self.expanded = NO;
   [self setCoreFunctionButtonsHidden:YES];
   
   [_backgroundLayer runAction:slide];
   for (SKNode *button in _coreFunctionButtons)
      [button runAction:slide];

   for (SKNode *button in _buttonHitBoxes)
      [button runAction:slide];

   [_expandCollapseButton runAction:buttonActions];
   [_backgroundLayer runAction:hudBackgroundColorSequence
                    completion:^
    {
       SKAction *moveButton = [SKAction moveByX:0 y:-HUD_BUTTON_EDGE_PADDING duration:.25];
       SKAction *moveButtonHitBox = [SKAction moveByX:0 y:-(HUD_BUTTON_EDGE_PADDING + 10) duration:.25];
       for (SKNode *button in _coreFunctionButtons)
          [button runAction:moveButton];

       for (SKNode *button in _buttonHitBoxes)
          [button runAction:moveButtonHitBox];

       [self.delegate hudDidCollapse:self];
    }];
}

- (void)expandSettings
{
   _settingsAreExpanded = YES;

   SKAction *expand = [SKAction moveByX:0 y:_defaultSize.height - 60 duration:.5];
   SKAction *spin = [SKAction rotateByAngle:M_PI*2 duration:.5];
   expand.timingMode = SKActionTimingEaseInEaseOut;
   spin.timingMode = SKActionTimingEaseInEaseOut;

   [_backgroundLayer runAction:expand];
   [_settingsButton runAction:spin];
}

- (void)collapseSettingsWithCompletionBlock:(void (^)())completionBlock
{
   _settingsAreExpanded = NO;

   SKAction *collapse = [SKAction moveByX:0 y:-(_defaultSize.height - 60) duration:.5];
   SKAction *spin = [SKAction rotateByAngle:-M_PI*2 duration:.5];
   collapse.timingMode = SKActionTimingEaseInEaseOut;
   spin.timingMode = SKActionTimingEaseInEaseOut;

   [_backgroundLayer runAction:collapse];
   [_settingsButton runAction:spin completion:completionBlock];
}

- (void)toggleSettings
{
   if (_settingsAreExpanded)
      [self collapseSettingsWithCompletionBlock:nil];
   else
      [self expandSettings];
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

- (void)toggle
{
   if (!self.expanded)
      [self expandBottomBar];
   else
      [self collapse];
}

#pragma mark GLHud Touch Method
- (void)handleTouch:(UITouch *)touch moved:(BOOL)moved
{
   if (moved)
      return;
   
   SKNode *node = [self nodeAtPoint:[touch locationInNode:self]];

   // check to see if the bottom bar should expand or collapse
   if (node == _expandCollapseButton)
      [self toggle];

   // if the hud was somehow pressed elsewhere and the bottom bar is not expanded, return
   if (!self.expanded)
      return;

   // we know that the bottom bar is expanded and can now check to see where the hud was pressed
   if (node == _settingsButtonHitBox)
      [self toggleSettings];
   else if (node == _startStopButtonHitBox)
      [self.delegate toggleRunningButtonPressed];
   else if (node == _clearButtonHitBox)
      [self.delegate clearButtonPressed];
   else if (node == _restoreButtonHitBox)
      [self.delegate restoreButtonPressed];
   else if (node == _cameraButtonHitBox)
      [self.delegate screenShotButtonPressed];
}

@end
