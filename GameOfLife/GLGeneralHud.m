//
//  GLGeneralHud.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/24/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLGeneralHud.h"
#import "UIColor+Crayola.h"

#define HUD_BUTTON_EDGE_PADDING 48
#define HUD_BUTTON_PADDING 50

@interface GLGeneralHud()
{
   CGSize _defaultSize;
   SKSpriteNode *_backgroundLayer;
   NSMutableArray *_coreFunctionButtons;
   SKSpriteNode *_expandCollapseButton;

   BOOL _isExpanded;
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
   _expandCollapseButton = [SKSpriteNode spriteNodeWithImageNamed:@"expand_right"];
   _expandCollapseButton.color = [SKColor crayolaBlackCoralPearlColor];
   _expandCollapseButton.alpha = _backgroundLayer.alpha;
   _expandCollapseButton.colorBlendFactor = 1.0;
   [_expandCollapseButton setScale:.23];
   _expandCollapseButton.position = CGPointMake(_defaultSize.width - _expandCollapseButton.size.width/2 - 15,
                                            HUD_BUTTON_EDGE_PADDING - _expandCollapseButton.size.height/2);
   _expandCollapseButton.name = @"expand_collapse";
   [self addChild:_expandCollapseButton];
}

- (void)handleTouch:(UITouch *)touch moved:(BOOL)moved
{
   SKNode *node = [self nodeAtPoint:[touch locationInNode:self]];

   if ([node.name isEqualToString:@"expand_collapse"] && !moved)
      [self toggle];
}

- (void)toggle
{
   if (!_isExpanded)
      [self expand];
   else
      [self collapse];
}

- (void)expand
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
       [self.delegate hudDidExpand:self];
    }];
}

- (void)collapse
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
   [self runAction:slide];
   [_expandCollapseButton runAction:buttonActions];
   [_backgroundLayer runAction:hudBackgroundColorSequence
                    completion:^
    {
       [self.delegate hudDidCollapse:self];
    }];
}

@end
