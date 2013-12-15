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

@interface GLSliderControl()
{
   SKSpriteNode *_leftTrack;
   SKSpriteNode *_rightTrack;

   SKSpriteNode *_knob;

   float _leftXBound;
   float _rightXBound;

   int _sliderLength;
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

      _leftXBound = _leftTrack.position.x + CGRectGetWidth(_knob.frame)/2;
      _rightXBound = _rightTrack.position.x - CGRectGetWidth(_knob.frame)/2;
   }
   return self;
}

- (id)initWithLength:(int)length
{
   _sliderLength = length;
   return [self init];
}

- (void)setupLeftTrack
{
   _leftTrack = [SKSpriteNode spriteNodeWithImageNamed:@"slider-end-left.png"];
   _leftTrack.anchorPoint = CGPointMake(0, .5);
   _leftTrack.position = CGPointMake((_sliderLength) ? -_sliderLength/2.0 : -DEFAULT_LENGTH/2.0, 0);

   _leftTrack.centerRect = CGRectMake(.75, .25, .25, .5);
   _leftTrack.xScale = fabs(_leftTrack.position.x * .23);

   [self addChild:_leftTrack];
}

- (void)setupRightTrack
{
   _rightTrack = [SKSpriteNode spriteNodeWithImageNamed:@"slider-end-right.png"];
   _rightTrack.anchorPoint = CGPointMake(1, .5);
   _rightTrack.position = CGPointMake((_sliderLength)? _sliderLength/2.0 : DEFAULT_LENGTH/2.0, 0);

   _rightTrack.centerRect = CGRectMake(0, .25, .25, .5);
   _rightTrack.xScale = _rightTrack.position.x * .23;

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

- (void)moveKnobByDeltaX:(float)deltaX
{
   if (_leftTrack.xScale + deltaX * .25 > 0)
      _leftTrack.xScale += deltaX * .25;
   else
      _leftTrack.xScale = 0;

   if (_rightTrack.xScale - deltaX * .25 > 0)
      _rightTrack.xScale -= deltaX * .25;
   else
      _rightTrack.xScale = 0;

   _knob.position = CGPointMake((_knob.position.x + deltaX),
                                _knob.position.y);
}

- (void)handleTouchMoved:(UITouch *)touch
{
   float convertedX = [touch locationInNode:self].x;
   float convertedPreviousX = [touch previousLocationInNode:self].x;
   float deltaX = convertedX - convertedPreviousX;

   if (_knob.position.x + deltaX <= _leftXBound ||
       convertedX <= _leftXBound)
   {
      _knob.position = CGPointMake(_leftXBound, _leftTrack.position.y);
      _leftTrack.xScale = 0;
//      _rightTrack.xScale = 45.5;
      _rightTrack.xScale = _rightXBound * .503318573;
      return;
   }

   if (_knob.position.x + deltaX >= _rightXBound ||
       convertedX >= _rightXBound)
   {
      _knob.position = CGPointMake(_rightXBound, _rightTrack.position.y);
//      _leftTrack.xScale = 45.5;
      _leftTrack.xScale = fabs(_leftXBound * .503318573);
      _rightTrack.xScale = 0;
      return;
   }

   [self moveKnobByDeltaX:deltaX];
   [super handleTouchMoved:touch];
}

- (void)handleTouchEnded:(UITouch *)touch
{
   self.hitBox.position = _knob.position;
   [super handleTouchEnded:touch];
}

@end
