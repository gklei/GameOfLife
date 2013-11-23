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
   _backgroundLayer = [SKSpriteNode spriteNodeWithColor:[SKColor crayolaBlackCoralPearlColor]
                                                   size:_defaultSize];
   _backgroundLayer.alpha = .65;
   _backgroundLayer.anchorPoint = CGPointMake(0, 1);
   _backgroundLayer.position = CGPointMake(0, 60);
   _backgroundLayer.name = @"color_hud_background";

   [self addChild:_backgroundLayer];
}

- (void)setupButtons
{
   _expandButton = [SKSpriteNode spriteNodeWithImageNamed:@"expand_left"];
   [_expandButton setColor:[SKColor whiteColor]];
   _expandButton.colorBlendFactor = 1.0;
   [_expandButton setScale:.25];
   _expandButton.position = CGPointMake(HUD_BUTTON_EDGE_PADDING - _expandButton.size.width/2.0,
                                        HUD_BUTTON_EDGE_PADDING - _expandButton.size.height/2.0);
   _expandButton.name = @"color_hud_expand";
   [self addChild:_expandButton];
}

@end
