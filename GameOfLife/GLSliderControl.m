//
//  GLSliderControl.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/13/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

@import AVFoundation;

#import "GLSliderControl.h"
#import "UIColor+Crayola.h"


#define DEFAULT_LENGTH 180

// These are dependant on the knob image and track end image sizes
#define FULLY_EXTENDED_TRACK_SCALE_FACTOR .5 //.503318573
#define HALF_EXTENDED_TRACK_SCALE_FACTOR .225

// These assure that the correct regions of the track end images are
// stretched when adjusting the xScale property
#define LEFT_TRACK_CENTER_RECT CGRectMake(.75, .25, .25, .5)
#define RIGHT_TRACK_CENTER_RECT CGRectMake(0, .25, .25, .5)

#define DEFAULT_KNOB_SCALE .6
#define SELECTED_KNOB_SCALE .74

@interface GLSliderControl()
{
   SKSpriteNode *_leftTrack;
   SKSpriteNode *_rightTrack;

   SKSpriteNode *_knob;

   float _leftXBound;
   float _rightXBound;

   float _sliderPosition;
   
   int _sliderLength;
   float _knobSlidingRange;
   float _knobOffsetInAccumulatedFrame;

   SKAction *_grow;
   SKAction *_shrink;

   BOOL _shouldPlaySound;
   SKAction *_pressReleaseSoundFX;
   
   NSString *_preferenceKey;
   HUDItemRange _range;
}
@end

@implementation GLSliderControl

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
      [self setupLeftTrack];
      [self setupRightTrack];
      [self setupKnob];
      [self setupHitBox];
      [self setupVariables];
      [self setupSoundFX];
      [self observeSoundFxChanges];
   }
   return self;
}

- (id)initWithLength:(int)length
{
   _sliderLength = length;
   return [self init];
}

- (id)initWithLength:(int)length range:(HUDItemRange)range andPreferenceKey:(NSString *)prefKey
{
   if (self = [self initWithLength:length])
   {
      _preferenceKey = prefKey;
      _range = range;
      NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
      float value = [defaults floatForKey:_preferenceKey];
      self.sliderValue = value;
   }
   
   return self;
}

- (NSString *)stringValue
{
   return [NSString stringWithFormat:@"%d%%", (int)(_sliderPosition * 100)];
}

- (NSString *)longestPossibleStringValue
{
   return @"100%";
}

- (CGRect)largestPossibleAccumulatedFrame
{
   float currentPosition = _sliderPosition;
   _sliderPosition = 1;
   CGRect largestPossibleAccumulatedFrame = self.calculateAccumulatedFrame;
   _sliderPosition = currentPosition;
   return largestPossibleAccumulatedFrame;
}

- (void)setupSoundFX
{
   _pressReleaseSoundFX = [SKAction playSoundFileNamed:@"toggle.1.wav" waitForCompletion:NO];
}

- (void)setupLeftTrack
{
   _leftTrack = [SKSpriteNode spriteNodeWithImageNamed:@"slider-end-left.png"];
   _leftTrack.anchorPoint = CGPointMake(0, .5);
   _leftTrack.position = CGPointMake((_sliderLength) ? -_sliderLength / 2.0 : -DEFAULT_LENGTH / 2.0, 0);

   _leftTrack.centerRect = LEFT_TRACK_CENTER_RECT;
   _leftTrack.xScale = fabs(_leftTrack.position.x * HALF_EXTENDED_TRACK_SCALE_FACTOR);

   [self addChild:_leftTrack];
}

- (void)setupRightTrack
{
   _rightTrack = [SKSpriteNode spriteNodeWithImageNamed:@"slider-end-right.png"];
   _rightTrack.colorBlendFactor = 1.0;
   _rightTrack.color = [SKColor crayolaCadetBlueColor];
   _rightTrack.anchorPoint = CGPointMake(1, .5);
   _rightTrack.position = CGPointMake((_sliderLength)? _sliderLength / 2.0 : DEFAULT_LENGTH / 2.0, 0);

   _rightTrack.centerRect = RIGHT_TRACK_CENTER_RECT;
   _rightTrack.xScale = _rightTrack.position.x * HALF_EXTENDED_TRACK_SCALE_FACTOR;

   [self addChild:_rightTrack];
}

- (void)setupKnob
{
   _knob = [SKSpriteNode spriteNodeWithImageNamed:@"radio-unchecked@2x.png"];
   _knob.colorBlendFactor = 1;
   _knob.color = [SKColor crayolaRobinsEggBlueColor];
   [_knob setScale:.6];

   [self addChild:_knob];
}

- (void)setupHitBox
{
   self.hitBox.size = CGSizeMake(_knob.size.width + 30, _knob.size.height + 30);
   self.hitBox.position = _knob.position;
   [self addChild:self.hitBox];
}

- (void)setupVariables
{
   _leftXBound = _leftTrack.position.x + CGRectGetWidth(_knob.frame) / 2;
   _rightXBound = _rightTrack.position.x - CGRectGetWidth(_knob.frame) / 2;

   _knobSlidingRange = CGRectGetWidth(self.calculateAccumulatedFrame) - CGRectGetWidth(_knob.frame);
   _knobOffsetInAccumulatedFrame = CGRectGetWidth(self.calculateAccumulatedFrame) / 2 -
                                   CGRectGetWidth(_knob.frame) / 2;

   _grow = [SKAction scaleTo:SELECTED_KNOB_SCALE duration:.1];
   _grow.timingMode = SKActionTimingEaseInEaseOut;

   _shrink = [SKAction scaleTo:DEFAULT_KNOB_SCALE duration:.1];
   _shrink.timingMode = SKActionTimingEaseInEaseOut;
}

- (void)setSliderValue:(float)value
{
   if (_sliderValue != value)
   {
      _sliderValue = value;
      _sliderPosition = [self valueToPosition:value];
      
      float newKnobPositionX = (_sliderPosition * _knobSlidingRange) - _knobOffsetInAccumulatedFrame;
      [self moveKnobByDeltaX:(newKnobPositionX - _knob.position.x)];
   }
}

- (void)updateUserDefaults:(float)position
{
   NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
   [defaults setFloat:[self positionToValue:position] forKey:_preferenceKey];
   [defaults synchronize];
}

- (float)valueToPosition:(float)value
{
   if (_range.length)
      return (value - _range.location) / _range.length;
   
   return 0;
}

- (float)positionToValue:(float)position
{
   return position * _range.length + _range.location;
}

- (void)updateKnobPositionX:(float)x
{
   _knob.position = CGPointMake(x, _knob.position.y);
   self.hitBox.position = _knob.position;
   _sliderPosition = (_knob.position.x + _knobOffsetInAccumulatedFrame) / _knobSlidingRange;
   
   [self.delegate controlValueChangedForKey:_preferenceKey];
   [self updateUserDefaults:_sliderPosition];
}

- (void)moveKnobByDeltaX:(float)deltaX
{
   float scaleAddition = deltaX * .25;
   if (_leftTrack.xScale + scaleAddition > 0)
      _leftTrack.xScale += scaleAddition;
   else
      _leftTrack.xScale = 0;

   if (_rightTrack.xScale - scaleAddition > 0)
      _rightTrack.xScale -= scaleAddition;
   else
      _rightTrack.xScale = 0;

   [self updateKnobPositionX:(_knob.position.x + deltaX)];
}

- (void)handleTouchBegan:(UITouch *)touch
{
   if (_shouldPlaySound) [self runAction:_pressReleaseSoundFX];
   [_knob runAction:_grow];
   [super handleTouchBegan:touch];
}

- (void)handleTouchMoved:(UITouch *)touch
{
   float convertedX = [touch locationInNode:self].x;
   float convertedPreviousX = [touch previousLocationInNode:self].x;
   float deltaX = convertedX - convertedPreviousX;

   if (_knob.position.x + deltaX <= _leftXBound)
   {
      [self updateKnobPositionX:_leftXBound];
      _leftTrack.xScale = 0;
      _rightTrack.xScale = _rightXBound * FULLY_EXTENDED_TRACK_SCALE_FACTOR;
      return;
   }

   if (_knob.position.x + deltaX >= _rightXBound)
   {
      [self updateKnobPositionX:_rightXBound];
      _leftTrack.xScale = fabs(_leftXBound * FULLY_EXTENDED_TRACK_SCALE_FACTOR);
      _rightTrack.xScale = 0;
      return;
   }

   [self moveKnobByDeltaX:deltaX];

   // Currently this does not need to be called
   //   [super handleTouchMoved:touch];
}

- (void)handleTouchEnded:(UITouch *)touch
{
   if (_shouldPlaySound) [self runAction:_pressReleaseSoundFX];
   self.hitBox.position = _knob.position;

   [_knob runAction:_shrink];
   _knob.texture = [SKTexture textureWithImageNamed:@"radio-unchecked@2x.png"];
   [super handleTouchEnded:touch];
   
   [self updateUserDefaults:_sliderPosition];
}

- (void)settingChanged:(NSNumber *)value ofType:(HUDValueType)type forKeyPath:(NSString *)keyPath
{
   if ([keyPath compare:@"SoundFX"] == NSOrderedSame)
   {
      assert(type == HVT_BOOL);
      _shouldPlaySound = [value boolValue];
   }
}

@end
