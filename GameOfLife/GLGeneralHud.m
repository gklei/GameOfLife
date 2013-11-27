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

   SKSpriteNode *_expandCollapseButton;
   SKSpriteNode *_clearButton;
   SKSpriteNode *_refreshButton;
   SKSpriteNode *_startStopButton;
   SKSpriteNode *_cameraButton;
   SKSpriteNode *_settingsButton;

   BOOL _isExpanded;
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

- (void)setupBackgroundWithSize:(CGSize)size
{
   _backgroundLayer = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor]
                                                   size:size];
   _backgroundLayer.colorBlendFactor = 1.0;
   _backgroundLayer.alpha = .65;
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

- (SKSpriteNode *)buttonWithFilename:(NSString *)fileName buttonName:(NSString *)buttonName
{
   SKSpriteNode *button = [SKSpriteNode spriteNodeWithImageNamed:fileName];
   button.color = [SKColor whiteColor];
   button.colorBlendFactor = 1.0;
   [button setScale:.20];
   button.name = buttonName;

   return button;
}

- (void)setCoreFunctionButtonPositionsAndAddToLayer
{
   int multiplier = 0;
   for (SKSpriteNode *button in _coreFunctionButtons)
   {
      [self addChild:button];
      button.position = CGPointMake((multiplier++)*CORE_FUNCTION_BUTTON_PADDING + 80,
                                    -button.size.height/2.0);
   }
}

- (void)setupCoreFunctionButtons
{
   _clearButton = [self buttonWithFilename:@"clear" buttonName:@"clear"];
   _refreshButton = [self buttonWithFilename:@"refresh" buttonName:@"refresh"];
   _startStopButton = [self buttonWithFilename:@"start" buttonName:@"start_stop"];
   _cameraButton = [self buttonWithFilename:@"camera" buttonName:@"camera"];
   _settingsButton = [self buttonWithFilename:@"gear" buttonName:@"settings"];

   _coreFunctionButtons = @[_clearButton,
                            _refreshButton,
                            _startStopButton,
                            _cameraButton,
                            _settingsButton];

   [self setCoreFunctionButtonPositionsAndAddToLayer];
}

- (void)setCoreFunctionButtonsHidden:(BOOL)hidden
{
   for (SKSpriteNode *button in _coreFunctionButtons)
      button.hidden = hidden;
}

- (void)expandBottomBar
{
   [self.delegate hudWillExpand:self];

   SKAction *slide = [SKAction moveTo:CGPointMake(0,0)
                             duration:.5];
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
                                               maintainPosition,
                                               rotate]];
   _isExpanded = YES;
   [self runAction:slide];
   [_backgroundLayer runAction:changeHudColor];
   [_expandCollapseButton runAction:buttonActions
                 completion:^
    {
       SKAction *moveButton = [SKAction moveByX:0 y:HUD_BUTTON_EDGE_PADDING duration:.25];
       moveButton.timingMode = SKActionTimingEaseInEaseOut;
       for (SKNode *button in _coreFunctionButtons)
       {
          button.hidden = NO;
          [button runAction:moveButton];
       }
       [self.delegate hudDidExpand:self];
    }];
}

- (void)collapseBottomBar
{
   [self.delegate hudWillCollapse:self];

   SKAction *wait = [SKAction waitForDuration:.25];
   SKAction *slide = [SKAction moveTo:CGPointMake(-_defaultSize.width + 60, 0)
                             duration:.5];
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
   SKAction *buttonAnimations = [SKAction group:@[maintainPosition, rotate]];
   SKAction *buttonColorAnimations = [SKAction group:@[changeButtonAlpha, changeButtonColor]];
   SKAction *buttonColorSequence = [SKAction sequence:@[wait, buttonColorAnimations]];
   SKAction *buttonActions = [SKAction group:@[buttonAnimations, buttonColorSequence]];

   _isExpanded = NO;
   [self setCoreFunctionButtonsHidden:YES];
   [self runAction:slide];
   [_expandCollapseButton runAction:buttonActions];
   [_backgroundLayer runAction:hudBackgroundColorSequence
                    completion:^
    {
       SKAction *moveButton = [SKAction moveByX:0 y:-HUD_BUTTON_EDGE_PADDING duration:.25];
       for (SKNode *button in _coreFunctionButtons)
          [button runAction:moveButton];
       [self.delegate hudDidCollapse:self];
    }];
}

- (void)expandSettings
{
   _settingsAreExpanded = YES;
   SKAction *expand = [SKAction moveByX:0 y:_defaultSize.height - 60 duration:.5];
   expand.timingMode = SKActionTimingEaseInEaseOut;
   [_backgroundLayer runAction:expand];
}

- (void)collapseSettingsWithCompletionBlock:(void (^)())completionBlock
{
   _settingsAreExpanded = NO;
   SKAction *collapse = [SKAction moveByX:0 y:-(_defaultSize.height - 60) duration:.5];
   collapse.timingMode = SKActionTimingEaseInEaseOut;
   [_backgroundLayer runAction:collapse completion:completionBlock];
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
   if (!_isExpanded)
      [self expandBottomBar];
   else
      [self collapse];
}

- (void)handleTouch:(UITouch *)touch moved:(BOOL)moved
{
   SKNode *node = [self nodeAtPoint:[touch locationInNode:self]];

   if ([node isEqual:_expandCollapseButton] && !moved)
      [self toggle];
   else if ([node isEqual:_settingsButton] && !moved)
      [self toggleSettings];
}

@end
