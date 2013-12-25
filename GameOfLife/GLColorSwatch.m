//
//  GLColorSwatch.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/24/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLColorSwatch.h"

#define COLOR_SWATCH_OUTER_RING_SCALE .60
#define COLOR_SWATCH_INNER_FILL_SCALE .60
#define COLOR_SWATCH_FILL_EMPTY_DURATION .25

@interface GLColorSwatch()
{
   SKSpriteNode *_outerRing;
   SKSpriteNode *_innerFill;

   SKAction *_fillAnimation;
   SKAction *_emptyAnimation;
}
@end

@implementation GLColorSwatch

- (id)init
{
   if (self = [super init])
   {
      _state = e_COLOR_SWATCH_DISABLED;
      [self setupSwatchImages];
      [self setupAnmations];
      [self setupHitBox];
   }
   return self;
}

- (void)setupAnmations
{
   _fillAnimation = [SKAction scaleTo:COLOR_SWATCH_INNER_FILL_SCALE
                             duration:COLOR_SWATCH_FILL_EMPTY_DURATION];
   _fillAnimation.timingMode = SKActionTimingEaseInEaseOut;

   _emptyAnimation = [SKAction scaleTo:0
                              duration:COLOR_SWATCH_FILL_EMPTY_DURATION];
   _emptyAnimation.timingMode = SKActionTimingEaseInEaseOut;
}

- (void)setupSwatchImages
{
   _outerRing = [SKSpriteNode spriteNodeWithImageNamed:@"color-swatch-ring-outer.png"];
   _outerRing.colorBlendFactor = 1.0;
   _outerRing.color = [SKColor whiteColor];
   [_outerRing setScale:COLOR_SWATCH_OUTER_RING_SCALE];

   _innerFill = [SKSpriteNode spriteNodeWithImageNamed:@"color-swatch-fill.png"];
   _innerFill.colorBlendFactor = 1.0;
   _innerFill.color = [SKColor whiteColor];
   _innerFill.position = _outerRing.position;
   [_innerFill setScale:COLOR_SWATCH_INNER_FILL_SCALE];

//   [self addChild:_outerRing];
   [self addChild:_innerFill];
}

- (void)setupHitBox
{
   self.hitBox.size = _outerRing.size;
   self.hitBox.position = _outerRing.position;
   [self addChild:self.hitBox];
}

- (void)setColor:(UIColor *)color
{
//   _outerRing.color = color;
   _innerFill.color = color;
}

- (UIColor *)color
{
   return _outerRing.color;
}

- (void)toggle
{
   if (_state == e_COLOR_SWATCH_DISABLED)
   {
      _state = e_COLOR_SWATCH_ENABLED;
//      [_innerFill runAction:_fillAnimation];
//      self.persistGlow = YES;
   }
   else
   {
      _state = e_COLOR_SWATCH_DISABLED;
//      [_innerFill runAction:_emptyAnimation];
//      self.persistGlow = NO;
   }
}

- (void)handleTouchEnded:(UITouch *)touch
{
   if ([self.hitBox containsPoint:[touch locationInNode:self]])
   {
      [self toggle];
   }
   [super handleTouchEnded:touch];
}

@end
