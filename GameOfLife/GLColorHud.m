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
#define COLOR_DROP_PADDING 44
#define COLOR_DROP_NUMBER 6
#define COLOR_DROP_SCALE .22

@interface GLColorHud()
{
   SKSpriteNode *_backgroundLayer;
   SKSpriteNode *_splashButton;
   NSMutableArray *_colorDrops;
   NSArray *_colorDropColors;
   int _colorDropVerticalOffset;
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
      [self addColorDrops];
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
   _splashButton = [SKSpriteNode spriteNodeWithImageNamed:@"splash"];
   [_splashButton setColor:[SKColor crayolaBlackCoralPearlColor]];
   _splashButton.colorBlendFactor = 1.0;
   _splashButton.alpha = _backgroundLayer.alpha;
   [_splashButton setScale:.25];
   _splashButton.position = CGPointMake(HUD_BUTTON_EDGE_PADDING - _splashButton.size.width/2.0,
                                        HUD_BUTTON_EDGE_PADDING - _splashButton.size.height/2.0);
   _splashButton.name = @"splash";
   [self addChild:_splashButton];
}

-(void)addColorDrops
{
   _colorDrops = [NSMutableArray arrayWithCapacity:COLOR_DROP_NUMBER];
   _colorDropColors = @[[SKColor crayolaCaribbeanGreenColor],
                        [SKColor crayolaBlueColor],
                        [SKColor crayolaRazzleDazzleRoseColor],
                        [SKColor crayolaSizzlingRedColor],
                        [SKColor crayolaNeonCarrotColor],
                        [SKColor crayolaLemonYellowColor]];

   for (int i=0; i<COLOR_DROP_NUMBER; ++i)
   {
      SKSpriteNode *drop = [SKSpriteNode spriteNodeWithImageNamed:@"drop"];
      [drop setScale:COLOR_DROP_SCALE];
      drop.position = CGPointMake(i*COLOR_DROP_PADDING + 23, -drop.size.height/2.0);
      drop.colorBlendFactor = 1.0;
      drop.color = _colorDropColors[i];
      [_colorDrops insertObject:drop atIndex:i];
      [self addChild:drop];
   }
}

- (void)setColorDropsHidden:(BOOL)hidden
{
   for (SKNode *node in _colorDrops)
      node.hidden = hidden;
}

- (void)handleTouch:(UITouch *)touch
{
   SKNode *node = [self nodeAtPoint:[touch locationInNode:self]];

   if ([node.name isEqualToString:@"splash"])
      [self toggle];
   else if ([_colorDrops containsObject:node])
      _splashButton.color = ((SKSpriteNode *)node).color;
}

- (void)expand
{
   [_delegate colorHudWillExpand];

   SKAction *slide = [SKAction moveTo:CGPointMake(0,0)
                                duration:.5];
   SKAction *changeHudColor = [SKAction colorizeWithColor:[SKColor crayolaBlackCoralPearlColor]
                                      colorBlendFactor:1.0
                                              duration:.5];
   SKAction *changeButtonColor = [SKAction colorizeWithColor:[SKColor crayolaFieryRoseColor]
                                            colorBlendFactor:1.0
                                                    duration:.5];
   SKAction *changeButtonAlpha = [SKAction fadeAlphaTo:1.0
                                              duration:.5];
   SKAction *maintainPosition = [SKAction moveByX:(_defaultSize.width - 60) y:0
                                         duration:.5];
   SKAction *rotate = [SKAction rotateByAngle:-M_PI*2
                                     duration:.5];

   slide.timingMode = SKActionTimingEaseInEaseOut;
   changeHudColor.timingMode = SKActionTimingEaseInEaseOut;
   changeButtonColor.timingMode = SKActionTimingEaseInEaseOut;
   changeButtonAlpha.timingMode = SKActionTimingEaseInEaseOut;
   maintainPosition.timingMode = SKActionTimingEaseInEaseOut;
   rotate.timingMode = SKActionTimingEaseInEaseOut;

   SKAction *buttonActions = [SKAction group:@[//changeButtonColor,
                                               changeButtonAlpha,
                                               maintainPosition,
                                               rotate]];
   _isExpanded = YES;
   [self runAction:slide];
   [_backgroundLayer runAction:changeHudColor];
   [_splashButton runAction:buttonActions
                 completion:^
   {
      SKAction *moveDrop = [SKAction moveByX:0 y:HUD_BUTTON_EDGE_PADDING duration:.25];
      for (SKNode *drop in _colorDrops)
      {
         drop.hidden = NO;
         [drop runAction:moveDrop];
      }

      [_delegate colorHudDidExpand];
   }];
}

- (void)collapse
{
   [_delegate colorHudWillCollapse];

   SKAction *wait = [SKAction waitForDuration:.25];
   SKAction *slide = [SKAction moveTo:CGPointMake(_defaultSize.width - 60, 0)
                                    duration:.5];
   SKAction *changeHudColor = [SKAction colorizeWithColor:[SKColor clearColor]
                                      colorBlendFactor:1.0
                                              duration:.25];
   SKAction *changeButtonColor = [SKAction colorizeWithColor:[SKColor crayolaBlackCoralPearlColor]
                                            colorBlendFactor:1.0
                                                    duration:.25];
   SKAction *changeButtonAlpha = [SKAction fadeAlphaTo:.85
                                              duration:.25];
   SKAction *maintainPosition = [SKAction moveByX:-(_defaultSize.width - 60) y:0
                                         duration:.5];
   SKAction *rotate = [SKAction rotateByAngle:M_PI*2 duration:.5];

   slide.timingMode = SKActionTimingEaseInEaseOut;
   changeHudColor.timingMode = SKActionTimingEaseInEaseOut;
   changeButtonColor.timingMode = SKActionTimingEaseInEaseOut;
   changeButtonAlpha.timingMode = SKActionTimingEaseInEaseOut;
   maintainPosition.timingMode = SKActionTimingEaseInEaseOut;
   rotate.timingMode = SKActionTimingEaseInEaseOut;

   SKAction *hudBackgroundColorSequence = [SKAction sequence:@[wait, changeHudColor]];
   SKAction *buttonAnimations = [SKAction group:@[maintainPosition, rotate]];
   SKAction *buttonColorSequence = [SKAction sequence:@[wait, changeButtonAlpha]];
   SKAction *buttonActions = [SKAction group:@[buttonAnimations, buttonColorSequence]];

   _isExpanded = NO;
   [self setColorDropsHidden:YES];
   [self runAction:slide];
   [_splashButton runAction:buttonActions];
   [_backgroundLayer runAction:hudBackgroundColorSequence
                    completion:^
   {
      SKAction *moveDrop = [SKAction moveByX:0 y:-HUD_BUTTON_EDGE_PADDING duration:.25];
      for (SKNode *drop in _colorDrops)
         [drop runAction:moveDrop];

      [_delegate colorHudDidCollapse];
   }];
}

- (void)toggle
{
   if (!_isExpanded)
      [self expand];
   else
      [self collapse];
}

@end
