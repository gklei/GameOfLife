//
//  GLSliderControl.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/13/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

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

   int _sliderLength;
   float _knobSlidingRange;
   float _knobOffsetInAccumulatedFrame;

   SKAction *_grow;
   SKAction *_shrink;
}
@end

@implementation GLSliderControl

- (id)init
{
   if (self = [super init])
   {
      [self setupLeftTrack];
      [self setupRightTrack];
      [self setupKnob];
      [self setupHitBox];
      [self setupVariables];
   }
   return self;
}

- (id)initWithLength:(int)length
{
   _sliderLength = length;
   return [self init];
}

- (id)initWithValue:(float)value
{
   if (self = [self init])
   {
      if (value < 0 || value > 1)
         value = 0;

      self.sliderValue = value;
   }
   return self;
}

- (id)initWithLength:(int)length value:(float)value
{
   if (self = [self initWithLength:length])
   {
      if (value < 0 || value > 1)
         value = 0;

      self.sliderValue = value;
   }
   return self;
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
   self.hitBox.size = CGSizeMake(_knob.size.width + 9, _knob.size.height + 9);
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

- (void)setSliderValue:(float)sliderValue
{
   if (sliderValue < 0 || sliderValue > 1)
      return;

   float newKnobPositionX = (sliderValue * _knobSlidingRange) - _knobOffsetInAccumulatedFrame;
   [self moveKnobByDeltaX:(newKnobPositionX - _knob.position.x)];
}

- (void)updateKnobPositionX:(float)x
{
   _knob.position = CGPointMake(x, _knob.position.y);
   self.hitBox.position = _knob.position;
   _sliderValue = (_knob.position.x + _knobOffsetInAccumulatedFrame) / _knobSlidingRange;
   NSLog(@"slider value: %f", _sliderValue);
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
   self.hitBox.position = _knob.position;
   [_knob runAction:_shrink];
   [super handleTouchEnded:touch];
}

@end
