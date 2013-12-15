//
//  GLSliderControl.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/13/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLSliderControl.h"

@interface GLSliderControl()
{
   SKSpriteNode *_leftTrack;
   SKSpriteNode *_rightTrack;

   SKSpriteNode *_knob;
   float _leftXBound;
   float _rightXBound;
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

- (void)setupLeftTrack
{
   _leftTrack = [SKSpriteNode spriteNodeWithImageNamed:@"slider-end-left.png"];
   _leftTrack.anchorPoint = CGPointMake(0, .5);
   _leftTrack.position = CGPointMake(-100, 0);
   _leftTrack.centerRect = CGRectMake(.75, .25, .25, .5);
   _leftTrack.xScale = 22;

   [self addChild:_leftTrack];
}

- (void)setupRightTrack
{
   _rightTrack = [SKSpriteNode spriteNodeWithImageNamed:@"slider-end-right.png"];
   _rightTrack.anchorPoint = CGPointMake(1, .5);
   _rightTrack.position = CGPointMake(100, 0);
   _rightTrack.centerRect = CGRectMake(0, .25, .25, .5);
   _rightTrack.xScale = 22;

   [self addChild:_rightTrack];
}

- (void)setupKnob
{
   _knob = [SKSpriteNode spriteNodeWithImageNamed:@"radio-unchecked@2x.png"];
   [_knob setScale:.6];

   [self addChild:_knob];
}

- (void)setupHitBox
{
   self.hitBox.size = CGSizeMake(_knob.size.width + 9, _knob.size.height + 9);
   self.hitBox.position = _knob.position;
   [self addChild:self.hitBox];
}

- (void)decrementByX:(float)x
{
   _knob.position = CGPointMake(_knob.position.x - 1, _knob.position.y);
   self.hitBox.position = CGPointMake(self.hitBox.position.x - 1, self.hitBox.position.y);
}

- (void)incrementByX:(float)x
{
   _knob.position = CGPointMake(_knob.position.x + 1, _knob.position.y);
   self.hitBox.position = CGPointMake(self.hitBox.position.x + 1, self.hitBox.position.y);
}

- (void)moveKnobByDeltaX:(float)deltaX
{
   _knob.position = CGPointMake(_knob.position.x + deltaX, _knob.position.y);
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
      return;
   }

   if (_knob.position.x + deltaX >= _rightXBound ||
       convertedX >= _rightXBound)
   {
      _knob.position = CGPointMake(_rightXBound, _rightTrack.position.y);
      return;
   }

   [self moveKnobByDeltaX:deltaX];
}

- (void)handleTouchEnded:(UITouch *)touch
{
   self.hitBox.position = _knob.position;
   [super handleTouchEnded:touch];
}

@end
