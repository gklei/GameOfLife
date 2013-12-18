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

   SKAction * _toggleSound;
   NSString * _preferenceKey;
}
@end

@implementation GLToggleControl

- (id)init
{
   if (self = [super init])
   {
      _state = e_TOGGLE_CONTROL_DISABLED;
      _toggleSound = [SKAction playSoundFileNamed:@"button.press.wav" waitForCompletion:NO];
      [self setupButtonImages];
      [self setupHitBox];
   }
   return self;
}

- (id)initWithPreferenceKey:(NSString *)key
{
   if ([self init])
   {
      _preferenceKey = key;
      
      NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
      BOOL state = [defaults boolForKey:_preferenceKey];
      if (state == e_TOGGLE_CONTROL_ENABLED)
         [self toggle];
   }
   
   return self;
}

- (void)updateUserDefaults:(BOOL)value
{
   NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
   [defaults setBool:value forKey:_preferenceKey];
   [defaults synchronize];
}

- (void)setState:(BOOL)state
{
   if (_state != state)
   {
      _state = state;
      [self updateUserDefaults:_state];
   }
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
   self.hitBox.size = _outerRing.size;
   self.hitBox.position = _outerRing.position;
   [self addChild:self.hitBox];
}

- (NSString *)stringValue
{
   return (_state)? @"ON" : @"OFF";
}

- (void)runEnableAnimationsWithCompletion:(void (^)())completion
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
       completion();
    }];
}

- (void)runDisableAnimationsWithCompletion:(void (^)())completion
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
       completion();
    }];
}

- (void)toggle
{
   if (_animating)
      return;

   void (^completion) (void) = ^{[self.delegate controlValueChangedForKey:_preferenceKey];};

   if (_state == e_TOGGLE_CONTROL_DISABLED)
   {
      [self runEnableAnimationsWithCompletion:completion];
      [self setState:e_TOGGLE_CONTROL_ENABLED];
   }
   else
   {
      [self runDisableAnimationsWithCompletion:completion];
      [self setState:e_TOGGLE_CONTROL_DISABLED];
   }
//   NSLog(@"%@", [self stringValue]);
}

- (void)handleTouchEnded:(UITouch *)touch
{
   [self runAction:_toggleSound];
   
   if ([self.hitBox containsPoint:[touch locationInNode:self]])
      [self toggle];

   [super handleTouchEnded:touch];
}

@end
