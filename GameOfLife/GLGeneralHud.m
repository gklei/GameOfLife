//
//  GLGeneralHud.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/24/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLGeneralHud.h"
#import "UIColor+Crayola.h"

@interface GLGeneralHud()
{
   CGSize _defaultSize;
   SKSpriteNode *_backgroundLayer;
}
@end

@implementation GLGeneralHud

- (id)init
{
   if (self = [super init])
   {
      _defaultSize = [UIScreen mainScreen].bounds.size;
      [self setupBackgroundWithSize:_defaultSize];
   }
   return self;
}

- (void)setupBackgroundWithSize:(CGSize)size
{
   _backgroundLayer = [SKSpriteNode spriteNodeWithColor:[SKColor crayolaBlackCoralPearlColor]
                                                   size:size];
   _backgroundLayer.colorBlendFactor = 1.0;
   _backgroundLayer.alpha = .65;
   _backgroundLayer.anchorPoint = CGPointMake(0, 1);
   _backgroundLayer.position = CGPointMake(0, 60);
   _backgroundLayer.name = @"general_hud_background";
   [self addChild:_backgroundLayer];
}

@end
