//
//  GLToggleControl.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/11/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLToggleControl.h"
#import "UIColor+Crayola.h"

#define TOGGLE_ANIMATION_DURATION .1
#define TOGGLE_COLOR_ANIMATION_DURATION .2
#define INNER_RING_OFFSET_FROM_CENTER 8
#define INNER_RING_X_ANIMATION 16

@interface GLToggleControl()
{
   SKSpriteNode *_innerRing;
   SKSpriteNode *_outerRing;

   SKAction *_enableAnimation;
   SKAction *_disableAnimation;

   BOOL _animating;
   BOOL _firstTouchInHitBox;
}
@end

@implementation GLToggleControl

- (id)init
{
   if (self = [super init])
   {
      _state = e_TOGGLE_CONTROL_DISABLED;
      [self setupButtonImages];
      [self setupHitBox];
   }
   return self;
}

- (void)setupButtonImages
{
   _outerRing = [SKSpriteNode spriteNodeWithImageNamed:@"toggle-ring-outer@2x.png"];
   _outerRing.colorBlendFactor = 1.0;
   _outerRing.color = [SKColor crayolaVioletRedColor];

   _innerRing = [SKSpriteNode spriteNodeWithImageNamed:@"radio-unchecked@2x.png"];
   [_innerRing setScale:.6];
   _innerRing.colorBlendFactor = 1.0;
   _innerRing.color = [SKColor crayolaCottonCandyColor];
   _innerRing.position = CGPointMake(_outerRing.position.x - INNER_RING_OFFSET_FROM_CENTER,
                                    _outerRing.position.y);
   [self addChild:_innerRing];
   [self addChild:_outerRing];
}

- (void)setupHitBox
{
   _hitBox = [SKSpriteNode node];
   _hitBox.size = _outerRing.size;
   _hitBox.position = _outerRing.position;
   _hitBox.name = @"toggle_hit_box";
   [self addChild:_hitBox];
}

- (void)runEnableAnimations
{
   SKAction *enableSlide = [SKAction moveByX:INNER_RING_X_ANIMATION
                                           y:0
                                    duration:TOGGLE_ANIMATION_DURATION];

   SKAction *enableInnerRingColor = [SKAction colorizeWithColor:[SKColor crayolaLimeColor]
                                               colorBlendFactor:1
                                                       duration:TOGGLE_COLOR_ANIMATION_DURATION];
   SKAction *enableOuterRingColor = [SKAction colorizeWithColor:[SKColor crayolaCaribbeanGreenPearlColor]
                                               colorBlendFactor:1
                                                       duration:TOGGLE_COLOR_ANIMATION_DURATION];

   enableSlide.timingMode = SKActionTimingEaseInEaseOut;
   enableInnerRingColor.timingMode = SKActionTimingEaseInEaseOut;
   enableOuterRingColor.timingMode = SKActionTimingEaseInEaseOut;

   _animating = YES;
   [_innerRing runAction:enableSlide
              completion:
    ^{
       [_innerRing runAction:enableInnerRingColor];
       [_outerRing runAction:enableOuterRingColor
                  completion:
        ^{
           _animating = NO;
        }];
    }];
}

- (void)runDisableAnimations
{
   SKAction *disableSlide = [SKAction moveByX:-INNER_RING_X_ANIMATION
                                            y:0
                                     duration:TOGGLE_ANIMATION_DURATION];
   
   SKAction *disableInnerRingColor = [SKAction colorizeWithColor:[SKColor crayolaCottonCandyColor]
                                                colorBlendFactor:1
                                                        duration:TOGGLE_COLOR_ANIMATION_DURATION];
   SKAction *disableOuterRingColor = [SKAction colorizeWithColor:[SKColor crayolaVioletRedColor]
                                                colorBlendFactor:1
                                                        duration:TOGGLE_COLOR_ANIMATION_DURATION];
   
   disableSlide.timingMode = SKActionTimingEaseInEaseOut;
   disableInnerRingColor.timingMode = SKActionTimingEaseInEaseOut;
   disableOuterRingColor.timingMode = SKActionTimingEaseInEaseOut;

   _animating = YES;
   [_innerRing runAction:disableSlide
              completion:
    ^{
       [_innerRing runAction:disableInnerRingColor];
       [_outerRing runAction:disableOuterRingColor
                  completion:
        ^{
           _animating = NO;
        }];
    }];
}

- (void)toggle
{
   if (_animating)
      return;

   if (_state == e_TOGGLE_CONTROL_DISABLED)
   {
      [self runEnableAnimations];
      _state = e_TOGGLE_CONTROL_ENABLED;
   }
   else
   {
      [self runDisableAnimations];
      _state = e_TOGGLE_CONTROL_DISABLED;
   }
}

@end
