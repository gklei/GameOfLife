//
//  GLUIButton.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/13/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLUIButton.h"

#define ON_TOUCH_SCALE 1.15
#define OFF_TOUCH_SCALE 1.0/ON_TOUCH_SCALE
#define SCALING_ANIMATION_DURATION .1

@interface GLUIButton()
{
   SKEffectNode *_glowEffect;
   SKAction *_scaleUp;
   SKAction *_scaleDown;

   CGFloat _defaultXScale;
   CGFloat _defaultYScale;
}
@end

@implementation GLUIButton

- (id)init
{
   if (self = [super init])
   {
      _hitBox = [SKSpriteNode node];
      _hitBox.name = @"ui_control_hit_box";
      _glowEnabled = YES;
      _scalesOnTouch = YES;
      _scaleUp = [SKAction scaleBy:ON_TOUCH_SCALE duration:SCALING_ANIMATION_DURATION];
      _scaleDown = [SKAction scaleBy:OFF_TOUCH_SCALE duration:SCALING_ANIMATION_DURATION];

      _defaultXScale = 1.0;
      _defaultYScale = 1.0;

      [self setupGlowEffect];
   }
   return self;
}

+ (instancetype)spriteNodeWithImageNamed:(NSString *)name
{
   GLUIButton *button = [[self alloc] init];
   SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:name];

//   button.hitBox.color = [SKColor orangeColor];
//   button.hitBox.alpha = .5;
   button.hitBox.size = CGSizeMake(CGRectGetWidth(sprite.frame) + 20,
                                   CGRectGetHeight(sprite.frame) + 20);
   button.hitBox.position = sprite.position;
   button.sprite = sprite;
   [button addChild:sprite];
   [button addChild:button.hitBox];
   return button;
}

- (void)setupGlowEffect
{
   _glowEffect = [SKEffectNode node];
   CIFilter *filter = [CIFilter filterWithName:@"CIBloom"];
   [filter setValue:[NSNumber numberWithFloat:2.0f] forKey:@"inputIntensity"];

   // Large radius makes result EVEN SMALLER:
   [filter setValue:[NSNumber numberWithFloat:2.5f] forKey:@"inputRadius"];

   _glowEffect.filter = filter;
   _glowEffect.shouldEnableEffects = NO;
   [super addChild:_glowEffect];
}

- (void)addChild:(SKNode *)node
{
   [_glowEffect addChild:node];
}

- (NSString *)stringValue
{
   return nil;
}

- (NSString *)longestPossibleStringValue
{
   return nil;
}

- (CGRect)largestPossibleAccumulatedFrame
{
   return self.calculateAccumulatedFrame;
}

- (void)glow
{
   _glowEffect.shouldEnableEffects = YES;
}

- (void)loseFocus
{
   _glowEffect.shouldEnableEffects = NO;
   _hasFocus = NO;
}

- (void)handleTouchBegan:(UITouch *)touch
{
   if (_scalesOnTouch)
      [self runAction:_scaleUp];

   _glowEffect.shouldEnableEffects = (_glowEnabled)? YES : NO;
   _hasFocus = YES;
}

- (void)handleTouchEnded:(UITouch *)touch
{
   if (_hasFocus && _scalesOnTouch)
      [self runAction:_scaleDown];

   _glowEffect.shouldEnableEffects = (_persistGlow)? YES : NO;
   _hasFocus = NO;
}

- (void)handleTouchMoved:(UITouch *)touch
{
   if (_hasFocus && ![self.hitBox containsPoint:[touch locationInNode:self]])
   {
      if (_scalesOnTouch)
         [self runAction:_scaleDown];

      _glowEffect.shouldEnableEffects = (_persistGlow)? YES : NO;
      _hasFocus = NO;
   }
}

- (void)setColor:(UIColor *)color
{
   if (_sprite)
   {
      _sprite.color = color;
      return;
   }
   [super setColor:color];
}

- (UIColor *)color
{
   if (_sprite)
      return _sprite.color;
   return [super color];
}

- (void)runAction:(SKAction *)action
{
   if (_sprite)
   {
      [_sprite runAction:action];
      return;
   }
   [super runAction:action];
}

- (void)runAction:(SKAction *)action completion:(void (^)())block
{
   if (_sprite)
   {
      [_sprite runAction:action completion:block];
      return;
   }
   [super runAction:action completion:block];
}

- (void)setAlpha:(CGFloat)alpha
{
   if (_sprite)
   {
      _sprite.alpha = alpha;
      return;
   }
   super.alpha = alpha;
}

- (CGFloat)alpha
{
   if (_sprite)
      return _sprite.alpha;
   return super.alpha;
}

- (void)setColorBlendFactor:(CGFloat)colorBlendFactor
{
   if (_sprite)
   {
      _sprite.colorBlendFactor = colorBlendFactor;
      return;
   }
   super.colorBlendFactor = colorBlendFactor;
}

- (CGFloat)colorBlendFactor
{
   if (_sprite)
      return _sprite.colorBlendFactor;
   return super.colorBlendFactor;
}

- (void)setSize:(CGSize)size
{
   if (_sprite)
   {
      _sprite.size = size;
      return;
   }
   super.size = size;
}

- (CGSize)size
{
   if (_sprite)
      return _sprite.size;
   return super.size;
}

- (void)setScale:(CGFloat)scale
{
   _defaultXScale = scale;
   _defaultYScale = scale;

   [self.hitBox setScale:scale];
   if (_sprite)
   {
      [_sprite setScale:scale];
      return;
   }
   [super setScale:scale];
}

- (void)setXScale:(CGFloat)xScale
{
   _defaultXScale = xScale;

   self.hitBox.xScale = xScale;
   if (_sprite)
   {
      _sprite.xScale = xScale;
      return;
   }
   super.xScale = xScale;
}

- (CGFloat)xScale
{
   if (_sprite)
      return _sprite.xScale;
   return super.xScale;
}

- (void)setYScale:(CGFloat)yScale
{
   _defaultYScale = yScale;

   self.hitBox.yScale = yScale;
   if (_sprite)
   {
      _sprite.yScale = yScale;
      return;
   }
   super.yScale = yScale;
}

- (CGFloat)yScale
{
   if (_sprite)
      return _sprite.yScale;
   return super.yScale;
}

- (void)setTexture:(SKTexture *)texture
{
   if (_sprite)
   {
      _sprite.texture = texture;
      return;
   }
   super.texture = texture;
}

- (SKTexture *)texture
{
   if (_sprite)
      return _sprite.texture;
   return [super texture];
}

@end
