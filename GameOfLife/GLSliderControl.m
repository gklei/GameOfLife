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
   SKSpriteNode *_knobHitBox;
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
   }
   return self;
}

- (void)setupLeftTrack
{
   _leftTrack = [SKSpriteNode spriteNodeWithImageNamed:@"slider-end-4x4@2x.png"];
   _leftTrack.anchorPoint = CGPointMake(1, .5);
   _leftTrack.position = CGPointMake(-12, 0);
   _leftTrack.centerRect = CGRectMake(.75, .25, .25, .5);
   _leftTrack.xScale = 15;

   [self addChild:_leftTrack];
}

- (void)setupRightTrack
{
   _rightTrack = [SKSpriteNode spriteNodeWithImageNamed:@"slider-end-4x4@2x.png"];
   [_rightTrack setZRotation:M_PI];
   _rightTrack.anchorPoint = CGPointMake(1, .5);
   _rightTrack.position = CGPointMake(12, 0);
   _rightTrack.centerRect = CGRectMake(.5, .25, .5, .5);
   _rightTrack.xScale = 15;

   [self addChild:_rightTrack];
}

- (void)setupKnob
{
   _knob = [SKSpriteNode spriteNodeWithImageNamed:@"radio-unchecked@2x.png"];
   [_knob setScale:.6];

   CGSize knobHitBoxSize = CGSizeMake(_knob.size.width + 9,
                                      _knob.size.height + 9);

   _knobHitBox = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor]
                                              size:knobHitBoxSize];
   _knobHitBox.position = _knob.position;
   _knobHitBox.name = @"slider_knob_hit_box";
   _knobHitBox.alpha = .05;

   [self addChild:_knob];
   [self addChild:_knobHitBox];
}

@end
