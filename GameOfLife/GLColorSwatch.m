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
   SKSpriteNode *_swatch;

}
@end

@implementation GLColorSwatch

- (id)init
{
   if (self = [super init])
   {
      _state = e_COLOR_SWATCH_DISABLED;

      ActionBlock actionBlock = ^{[self toggle];};
      self.actionBlock = actionBlock;

      [self setupSwatchImages];
      [self setupHitBox];
   }
   return self;
}

- (void)setupSwatchImages
{
   _swatch = [SKSpriteNode spriteNodeWithImageNamed:@"color-swatch-fill.png"];
   _swatch.colorBlendFactor = 1.0;
   _swatch.color = [SKColor whiteColor];
   [_swatch setScale:COLOR_SWATCH_INNER_FILL_SCALE];

   [self addChild:_swatch];
}

- (void)setupHitBox
{
   self.hitBox.size = _swatch.size;
   self.hitBox.position = _swatch.position;
   [self addChild:self.hitBox];
}

- (void)setColorName:(CrayolaColorName) colorName
{
   _colorName = colorName;
   UIColor * color = [UIColor colorForCrayolaColorName:_colorName];
   if (color)
      self.color = color;
   else
      NSLog(@"no color for _colorName = %d", _colorName);
}

- (void)setColor:(UIColor *)color
{
   _swatch.color = color;
}

- (UIColor *)color
{
   return _swatch.color;
}

- (void)toggle
{
   // if the color selection layer is hidden, return
   if (self.parent.parent.hidden)
      return;

   if (_state == e_COLOR_SWATCH_DISABLED)
      _state = e_COLOR_SWATCH_ENABLED;
   else
      _state = e_COLOR_SWATCH_DISABLED;

   [_swatchSelectionDelegate swatchSelected:self];
}

@end
