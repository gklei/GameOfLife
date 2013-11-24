//
//  GLColorHud.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/23/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLColorHud.h"
#import "UIColor+Crayola.h"

#define HUD_BUTTON_EDGE_PADDING 48

@interface GLColorHud()
{
   SKSpriteNode *_backgroundLayer;
   SKSpriteNode *_expandButton;
   CGSize _defaultSize;

   BOOL _isExpanded;
}
@end

@implementation GLColorHud

- (id)init
{
   if (self = [super init])
   {
      _defaultSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 60.0);
      [self setupBackgorundWithSize:_defaultSize];
      [self setupButtons];
   }
   return self;
}

- (void)setupBackgorundWithSize:(CGSize)size
{
   _backgroundLayer = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor]
                                                   size:_defaultSize];
   _backgroundLayer.colorBlendFactor = 1.0;
   _backgroundLayer.alpha = .65;
   _backgroundLayer.anchorPoint = CGPointMake(0, 1);
   _backgroundLayer.position = CGPointMake(0, 60);
   _backgroundLayer.name = @"color_hud_background";

   [self addChild:_backgroundLayer];
}

- (void)setupButtons
{
   _expandButton = [SKSpriteNode spriteNodeWithImageNamed:@"expand_left"];
   [_expandButton setColor:[SKColor crayolaBlackCoralPearlColor]];
   _expandButton.colorBlendFactor = 1.0;
   _expandButton.alpha = _backgroundLayer.alpha;
   [_expandButton setScale:.25];
   _expandButton.position = CGPointMake(HUD_BUTTON_EDGE_PADDING - _expandButton.size.width/2.0,
                                        HUD_BUTTON_EDGE_PADDING - _expandButton.size.height/2.0);
   _expandButton.name = @"color_hud_expand";
   [self addChild:_expandButton];
}

- (void)handleTouch:(UITouch *)touch
{
   SKNode *node = [self nodeAtPoint:[touch locationInNode:self]];

   if ([node.name isEqualToString:@"color_hud_expand"])
      [self toggle];
}

- (void)expand
{
   [_delegate colorHudWillExpand];

   SKAction *slide = [SKAction moveTo:CGPointMake(0,0)
                                duration:.5];
   SKAction *changeHudColor = [SKAction colorizeWithColor:[SKColor crayolaBlackCoralPearlColor]
                                      colorBlendFactor:1.0
                                              duration:.5];
   SKAction *changeButtonColor = [SKAction colorizeWithColor:[SKColor whiteColor]
                                            colorBlendFactor:1.0
                                                    duration:.5];
   SKAction *changeButtonAlpha = [SKAction fadeAlphaTo:1.0
                                              duration:.5];
   SKAction *maintainPosition = [SKAction moveByX:(_defaultSize.width - 60) y:0
                                         duration:.5];
   SKAction *rotate = [SKAction rotateByAngle:-M_PI
                                     duration:.5];

   slide.timingMode = SKActionTimingEaseInEaseOut;
   changeHudColor.timingMode = SKActionTimingEaseInEaseOut;
   changeButtonColor.timingMode = SKActionTimingEaseInEaseOut;
   changeButtonAlpha.timingMode = SKActionTimingEaseInEaseOut;
   maintainPosition.timingMode = SKActionTimingEaseInEaseOut;
   rotate.timingMode = SKActionTimingEaseInEaseOut;

   SKAction *buttonActions = [SKAction group:@[changeButtonColor, maintainPosition, rotate]];
   SKAction *buttonSequence = [SKAction sequence:@[buttonActions, changeButtonAlpha]];

   _isExpanded = YES;
   [self runAction:slide];
   [_backgroundLayer runAction:changeHudColor];
   [_expandButton runAction:buttonSequence];
}

- (void)collapse
{
   [_delegate colorHudWillCollapse];

   SKAction *wait = [SKAction waitForDuration:.25];
   SKAction *slide = [SKAction moveTo:CGPointMake(_defaultSize.width - 60, 0)
                                    duration:.5];
   SKAction *maintainPosition = [SKAction moveByX:-(_defaultSize.width - 60) y:0
                                         duration:.5];
   SKAction *rotate = [SKAction rotateByAngle:M_PI duration:.5];
   SKAction *changeHudColor = [SKAction colorizeWithColor:[SKColor clearColor]
                                      colorBlendFactor:1.0
                                              duration:.25];
   SKAction *changeButtonColor = [SKAction colorizeWithColor:[SKColor crayolaBlackCoralPearlColor]
                                            colorBlendFactor:1.0
                                                    duration:.25];
   SKAction *changeButtonAlpha = [SKAction fadeAlphaTo:_backgroundLayer.alpha
                                              duration:.25];

   slide.timingMode = SKActionTimingEaseInEaseOut;
   maintainPosition.timingMode = SKActionTimingEaseInEaseOut;
   rotate.timingMode = SKActionTimingEaseInEaseOut;
   changeHudColor.timingMode = SKActionTimingEaseInEaseOut;
   changeButtonColor.timingMode = SKActionTimingEaseInEaseOut;
   changeButtonAlpha.timingMode = SKActionTimingEaseInEaseOut;

   SKAction *hudBackgroundColorSequence = [SKAction sequence:@[wait, changeHudColor]];
   SKAction *buttonColorAnimations = [SKAction group:@[changeButtonColor, changeButtonAlpha]];
   SKAction *buttonAnimations = [SKAction group:@[maintainPosition, rotate]];
   SKAction *buttonColorSequence = [SKAction sequence:@[wait, buttonColorAnimations]];
   SKAction *buttonActions = [SKAction group:@[buttonAnimations, buttonColorSequence]];

   _isExpanded = NO;
   [self runAction:slide];
   [_backgroundLayer runAction:hudBackgroundColorSequence];
   [_expandButton runAction:buttonActions];
}

- (void)toggle
{
   if (!_isExpanded)
      [self expand];
   else
      [self collapse];
}

@end
