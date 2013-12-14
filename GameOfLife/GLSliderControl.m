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
   SKSpriteNode *_leftTrackEnd;

   SKSpriteNode *_rightTrack;
   SKSpriteNode *_rightTackEnd;

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
   }
   return self;
}

- (void)setupLeftTrack
{
   _leftTrackEnd = [SKSpriteNode spriteNodeWithImageNamed:@"slider-end@2x.png"];
   _leftTrackEnd.anchorPoint = CGPointMake(1, .5);
   _leftTrackEnd.position = CGPointMake(-70, 0);
   [_leftTrackEnd setScale:.125];

   _leftTrack = [SKSpriteNode spriteNodeWithImageNamed:@"slider-middle@2x.png"];
   _leftTrack.anchorPoint = CGPointMake(0, .5);
   _leftTrack.position = _leftTrackEnd.position;
   _leftTrack.yScale = .125;
   _leftTrack.xScale = 28;

   [self addChild:_leftTrackEnd];
   [self addChild:_leftTrack];
}

- (void)setupRightTrack
{
   _rightTackEnd = [SKSpriteNode spriteNodeWithImageNamed:@"slider-end@2x.png"];
   _rightTackEnd.anchorPoint = CGPointMake(1, .5);
   _rightTackEnd.position = CGPointMake(70, 0);
   [_rightTackEnd setZRotation:M_PI];
   [_rightTackEnd setScale:.125];

   _rightTrack = [SKSpriteNode spriteNodeWithImageNamed:@"slider-middle@2x.png"];
   _rightTrack.yScale = .125;
   _rightTrack.xScale = 28;
   _rightTrack.anchorPoint = CGPointMake(1, .5);
   _rightTrack.position = _rightTackEnd.position;

   [self addChild:_rightTackEnd];
   [self addChild:_rightTrack];
}

- (void)setupKnob
{
   _knob = [SKSpriteNode spriteNodeWithImageNamed:@"radio-unchecked@2x.png"];
   [_knob setScale:.6];

   [self addChild:_knob];
}

@end
