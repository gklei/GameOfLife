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
#define INNER_RING_X_ANIMATION 18

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
   float _innerRingSlidingRange;

   BOOL _animating;
   BOOL _stateSetFromSlide;

   BOOL _shouldPlaySound;
   SKAction * _toggleSound;
   NSString * _preferenceKey;
}
@end

@implementation GLToggleControl

- (void)observeSoundFxChanges
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"SoundFX"];
}

- (id)init
{
   if (self = [super init])
   {
      self.scalesOnTouch = NO;
      [self setupVariables];
      [self setupButtonImages];
      [self setupHitBox];
      [self observeSoundFxChanges];
   }
   return self;
}

- (void)setupVariables
{
   _state = e_TOGGLE_CONTROL_DISABLED;
   _toggleSound = [SKAction playSoundFileNamed:@"toggle.1.wav" waitForCompletion:NO];
   _leftXBound = -INNER_RING_OFFSET_FROM_CENTER;
   _rightXBound = INNER_RING_OFFSET_FROM_CENTER;

   _innerRingDisabledColor = [SKColor crayolaCottonCandyColor];
   _innerRingEnabledColor = [SKColor crayolaLimeColor];

   _outerRingDisabledColor = [SKColor crayolaVioletRedColor];
   _outerRingEnabledColor = [SKColor crayolaCaribbeanGreenPearlColor];

   _innerRingSlidingRange = INNER_RING_OFFSET_FROM_CENTER * 2;
}

- (id)initWithPreferenceKey:(NSString *)key
{
   if ([self init])
   {
      _preferenceKey = key;
      
      NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
      BOOL state = [defaults boolForKey:_preferenceKey];
      if (state == e_TOGGLE_CONTROL_ENABLED)
      {
         _toggleSound = nil;
         [self toggle:YES];
         _toggleSound = [SKAction playSoundFileNamed:@"toggle.1.wav" waitForCompletion:NO];
      }
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
      if (_shouldPlaySound) [self runAction:_toggleSound];
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
   SKAction *enableSlide = [SKAction moveToX:INNER_RING_X_ANIMATION - CGRectGetWidth(_innerRing.calculateAccumulatedFrame)/2
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
   SKAction *disableSlide = [SKAction moveToX:-INNER_RING_X_ANIMATION + CGRectGetWidth(_innerRing.calculateAccumulatedFrame)/2
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

- (void)toggle:(BOOL)switchState
{
   if (_animating)
      return;

   void (^completion) (void) = ^{[self.delegate controlValueChangedForKey:_preferenceKey];};

   if (_state == e_TOGGLE_CONTROL_DISABLED)
   {
      if (switchState)
         [self runEnableAnimationsWithCompletion:completion];
      [self setState:(switchState)? e_TOGGLE_CONTROL_ENABLED : e_TOGGLE_CONTROL_DISABLED];
   }
   else
   {
      if (switchState)
         [self runDisableAnimationsWithCompletion:completion];
      [self setState:(switchState)? e_TOGGLE_CONTROL_DISABLED : e_TOGGLE_CONTROL_ENABLED];
   }
}

- (void)updateInnerRingPositionX:(float)x
{
   _innerRing.position = CGPointMake(x, _innerRing.position.y);
   self.hitBox.position = _innerRing.position;
}

- (UIColor *)colorLerpFromStartColor:(UIColor *)start
                          toEndColor:(UIColor *)end
                        withDuration:(float)t
{
   t = (t < 0.0f)? 0.0f : t;
   t = (t > 1.0f)? 1.0f : t;

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
   float duration =
      (_innerRing.position.x + INNER_RING_OFFSET_FROM_CENTER) / _innerRingSlidingRange;

   _innerRing.color = [self colorLerpFromStartColor:_innerRingDisabledColor
                                         toEndColor:_innerRingEnabledColor
                                       withDuration:duration];
   _outerRing.color = [self colorLerpFromStartColor:_outerRingDisabledColor
                                         toEndColor:_outerRingEnabledColor
                                       withDuration:duration];

   _stateSetFromSlide = NO;
   [self updateInnerRingPositionX:_innerRing.position.x + deltaX];
}

- (void)handleTouchBegan:(UITouch *)touch
{
   _stateSetFromSlide = NO;
   [super handleTouchBegan:touch];
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

      if (_state != e_TOGGLE_CONTROL_DISABLED)
         _stateSetFromSlide = YES;

      self.state = e_TOGGLE_CONTROL_DISABLED;
      [self.delegate controlValueChangedForKey:_preferenceKey];
      return;
   }

   if (_innerRing.position.x + deltaX >= _rightXBound)
   {
      _innerRing.color = _innerRingEnabledColor;
      _outerRing.color = _outerRingEnabledColor;
      [self updateInnerRingPositionX:_rightXBound];

      if (_state != e_TOGGLE_CONTROL_ENABLED)
         _stateSetFromSlide = YES;

      self.state = e_TOGGLE_CONTROL_ENABLED;
      [self.delegate controlValueChangedForKey:_preferenceKey];
      return;
   }

   [self moveInnerRingByDeltaX:deltaX];
}

- (void)handleTouchEnded:(UITouch *)touch
{
   float touchX = [touch locationInNode:self].x;
   if (touchX < -CGRectGetWidth(self.calculateAccumulatedFrame) * .5 ||
       touchX > CGRectGetWidth(self.calculateAccumulatedFrame) * .5)
   {
      [super handleTouchEnded:touch];
      return;
   }

   [self toggle:(_stateSetFromSlide)? NO : YES];
   [super handleTouchEnded:touch];
}

- (void)settingChanged:(NSNumber *)value ofType:(HUDValueType)type forKeyPath:(NSString *)keyPath
{
   if ([keyPath compare:@"SoundFX"] == NSOrderedSame)
   {
      assert(type == HVT_BOOL);
      _shouldPlaySound = [value boolValue];
   }
}

- (NSUInteger)controlHeight
{
   return 40;
}

@end
