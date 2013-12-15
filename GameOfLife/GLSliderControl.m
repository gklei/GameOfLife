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

      self.userInteractionEnabled = YES;
   }
   return self;
}

- (void)setupLeftTrack
{
   _leftTrack = [SKSpriteNode spriteNodeWithImageNamed:@"slider-end-4x4@2x.png"];
   _leftTrack.anchorPoint = CGPointMake(1, .5);
   _leftTrack.position = CGPointMake(-15, 0);
   _leftTrack.centerRect = CGRectMake(.75, .25, .25, .5);
   _leftTrack.xScale = 20;

   [self addChild:_leftTrack];
}

- (void)setupRightTrack
{
   _rightTrack = [SKSpriteNode spriteNodeWithImageNamed:@"slider-end-4x4@2x.png"];
   [_rightTrack setZRotation:M_PI];
   _rightTrack.anchorPoint = CGPointMake(1, .5);
   _rightTrack.position = CGPointMake(15, 0);
   _rightTrack.centerRect = CGRectMake(.5, .25, .5, .5);
   _rightTrack.xScale = 20;

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
   self.hitBox.size = CGSizeMake(_knob.size.width + 9,
                                 _knob.size.height + 9);
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
   float deltaX = [touch locationInNode:self].x - [touch previousLocationInNode:self].x;
   [self moveKnobByDeltaX:deltaX];
}

- (void)handleTouchEnded:(UITouch *)touch
{
   self.hitBox.position = _knob.position;
   [super handleTouchEnded:touch];
}

@end
