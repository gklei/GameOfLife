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

   SKColor *_innerRingDisabledColor;
   SKColor *_innerRingEnabledColor;

   SKColor *_outerRingDisabledColor;
   SKColor *_outerRingEnabledColor;

   float _leftXBound;
   float _rightXBound;

   BOOL _animating;
   BOOL _firstTouchInHitBox;

   SKAction * _toggleSound;
   NSString * _preferenceKey;

   float _innerRingOffsetInAccumulatedFrame;
   float _innerRingSlidingRange;
}
@end

@implementation GLToggleControl

- (id)init
{
   if (self = [super init])
   {
      [self setupVariables];
      [self setupButtonImages];
      [self setupHitBox];
   }
   return self;
}

- (void)setupVariables
{
   _state = e_TOGGLE_CONTROL_DISABLED;
   _toggleSound = [SKAction playSoundFileNamed:@"button.press.wav" waitForCompletion:NO];
   _leftXBound = -INNER_RING_OFFSET_FROM_CENTER;
   _rightXBound = INNER_RING_OFFSET_FROM_CENTER;

   _innerRingDisabledColor = [SKColor crayolaCottonCandyColor];
   _innerRingEnabledColor = [SKColor crayolaLimeColor];

   _outerRingDisabledColor = [SKColor crayolaVioletRedColor];
   _outerRingEnabledColor = [SKColor crayolaCaribbeanGreenPearlColor];

   _innerRingSlidingRange = INNER_RING_OFFSET_FROM_CENTER * 2;
   _innerRingOffsetInAccumulatedFrame = INNER_RING_OFFSET_FROM_CENTER;
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
   _outerRing.color = _outerRingDisabledColor;

   _innerRing = [SKSpriteNode spriteNodeWithImageNamed:@"radio-unchecked@2x.png"];
   [_innerRing setScale:.6];
   _innerRing.colorBlendFactor = 1.0;
   _innerRing.color = _innerRingDisabledColor;
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

- (NSString *)longestPossibleStringValue
{
   return @"OFF";
}

- (CGRect)largestPossibleAccumulatedFrame
{
   float x = self.calculateAccumulatedFrame.origin.x;
   float y = self.calculateAccumulatedFrame.origin.y;
   float largeWidth = CGRectGetWidth(self.calculateAccumulatedFrame) + 25;
   float largeHeight = CGRectGetHeight(self.calculateAccumulatedFrame);

   return CGRectMake(x, y, largeWidth, largeHeight);
}

- (void)runEnableAnimationsWithCompletion:(void (^)())completion
{
   SKAction *enableSlide = [SKAction moveByX:INNER_RING_X_ANIMATION
                                           y:0
                                    duration:TOGGLE_ANIMATION_DURATION];

   SKAction *enableInnerRingColor = [SKAction colorizeWithColor:_innerRingEnabledColor
                                               colorBlendFactor:1
                                                       duration:TOGGLE_COLOR_ANIMATION_DURATION];
   SKAction *enableOuterRingColor = [SKAction colorizeWithColor:_outerRingEnabledColor
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
   
   SKAction *disableInnerRingColor = [SKAction colorizeWithColor:_innerRingDisabledColor
                                                colorBlendFactor:1
                                                        duration:TOGGLE_COLOR_ANIMATION_DURATION];
   SKAction *disableOuterRingColor = [SKAction colorizeWithColor:_outerRingDisabledColor
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
}

- (void)updateInnerRingPositionX:(float)x
{
   _innerRing.position = CGPointMake(x, _innerRing.position.y);
   self.hitBox.position = _innerRing.position;
}

- (UIColor *)colorLerpFrom:(UIColor *)start
                        to:(UIColor *)end
              withDuration:(float)t
{
   if(t < 0.0f) t = 0.0f;
   if(t > 1.0f) t = 1.0f;

   const CGFloat *startComponent = CGColorGetComponents(start.CGColor);
   const CGFloat *endComponent = CGColorGetComponents(end.CGColor);

   float startAlpha = CGColorGetAlpha(start.CGColor);
   float endAlpha = CGColorGetAlpha(end.CGColor);

   float r = startComponent[0] + (endComponent[0] - startComponent[0]) * t;
   float g = startComponent[1] + (endComponent[1] - startComponent[1]) * t;
   float b = startComponent[2] + (endComponent[2] - startComponent[2]) * t;
   float a = startAlpha + (endAlpha - startAlpha) * t;

   return [UIColor colorWithRed:r green:g blue:b alpha:a];
}

- (void)moveInnerRingByDeltaX:(float)deltaX
{
   float percentage = (_innerRing.position.x + _innerRingOffsetInAccumulatedFrame) / _innerRingSlidingRange;
   if (deltaX > 0)
   {
      _innerRing.color = [self colorLerpFrom:_innerRingDisabledColor
                                          to:_innerRingEnabledColor
                                withDuration:percentage];
      _outerRing.color = [self colorLerpFrom:_outerRingDisabledColor
                                          to:_outerRingEnabledColor
                                withDuration:percentage];
   }
   else
   {
      _innerRing.color = [self colorLerpFrom:_innerRingEnabledColor
                                          to:_innerRingDisabledColor
                                withDuration:percentage];
      _outerRing.color = [self colorLerpFrom:_outerRingEnabledColor
                                          to:_outerRingDisabledColor
                                withDuration:percentage];
   }

   [self updateInnerRingPositionX:_innerRing.position.x + deltaX];
}

- (void)handleTouchMoved:(UITouch *)touch
{
   float convertedX = [touch locationInNode:self].x;
   float convertedPreviousX = [touch previousLocationInNode:self].x;
   float deltaX = convertedX - convertedPreviousX;

   if (_innerRing.position.x + deltaX <= _leftXBound)
   {
      _innerRing.color = _innerRingDisabledColor;
      _outerRing.color = _outerRingDisabledColor;
      [self updateInnerRingPositionX:_leftXBound];
      self.state = e_TOGGLE_CONTROL_DISABLED;
      return;
   }

   if (_innerRing.position.x + deltaX >= _rightXBound)
   {
      _innerRing.color = _innerRingEnabledColor;
      _outerRing.color = _outerRingEnabledColor;
      [self updateInnerRingPositionX:_rightXBound];
      self.state = e_TOGGLE_CONTROL_ENABLED;
      return;
   }

   [self moveInnerRingByDeltaX:deltaX];
}

- (void)handleTouchEnded:(UITouch *)touch
{
   [self runAction:_toggleSound];
   
   if ([self.hitBox containsPoint:[touch locationInNode:self]])
      [self toggle];

   [super handleTouchEnded:touch];
}

@end
