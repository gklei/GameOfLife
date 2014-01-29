//
//  GLScannerAnimation.m
//  GameOfLife
//
//  Created by Gregory Klein on 1/28/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLScannerAnimation.h"
#import <SpriteKit/SpriteKit.h>

@interface GLScannerAnimation()
{
   SKSpriteNode *_scannerBeam;
   SKEffectNode *_glowEffect;
}
@end

@implementation GLScannerAnimation

#pragma mark - Init Methods
- (id)init
{
   if (self = [super init])
   {
      // default size and property values
      self.size = [UIScreen mainScreen].bounds.size;

      [self setupScannerBeam];
      [self setupGlowEffect];

      _duration = 1;
      _startY = self.size.height + (_scannerBeam.size.height * .5);
      _endY = -_scannerBeam.size.height * .5;

      [_glowEffect addChild:_scannerBeam];
   }
   return self;
}

- (id)initWithSize:(CGSize)size
{
   if (self = [self init])
   {
      self.size = size;
   }
   return self;
}

- (id)initWithSize:(CGSize)size
       anchorPoint:(CGPoint)anchorPoint
            startY:(CGFloat)start
              endY:(CGFloat)end
{
   if (self = [self init])
   {
      self.size = size;
      self.anchorPoint = anchorPoint;
      _startY = start;
      _endY = end;
   }
   return self;
}

#pragma mark - Setup Methods
- (void)setupGlowEffect
{
   _glowEffect = [SKEffectNode node];
   CIFilter *filter = [CIFilter filterWithName:@"CIBloom"];
   [filter setValue:[NSNumber numberWithFloat:3.0f] forKey:@"inputIntensity"];
   [filter setValue:[NSNumber numberWithFloat:3.0f] forKey:@"inputRadius"];

   _glowEffect.filter = filter;
   _glowEffect.shouldEnableEffects = YES;
   [self addChild:_glowEffect];
}

- (void)setupScannerBeam
{
   _scannerBeam = [SKSpriteNode spriteNodeWithImageNamed:@"slider-middle"];
   _scannerBeam.xScale = CGRectGetWidth([UIScreen mainScreen].bounds) * 2.0;
   _scannerBeam.colorBlendFactor = 1.0;
   _scannerBeam.alpha = .5;
   _scannerBeam.color = [SKColor whiteColor];
   _scannerBeam.position = CGPointMake(self.size.width * .5,
                                       self.size.height);
}

- (void)runAnimationOnParent:(SKNode *)parent
{
   [parent addChild:self];
   SKAction *pulsate = [SKAction customActionWithDuration:_duration
                                              actionBlock:
   ^(SKNode *node, CGFloat elapsedTime)
   {
      NSNumber *inputRadius = [((SKEffectNode *)node).filter valueForKey:@"inputRadius"];
      CGFloat newInputRadius = inputRadius.floatValue + sin(elapsedTime * 5);
      [((SKEffectNode *)node).filter setValue:[NSNumber numberWithFloat:newInputRadius]
                                       forKey:@"inputRadius"];

//      NSNumber *inputIntensity = [((SKEffectNode *)node).filter valueForKey:@"inputIntensity"];
//      CGFloat newInputIntensity = inputIntensity.floatValue + sin(elapsedTime);
//      [((SKEffectNode *)node).filter setValue:[NSNumber numberWithFloat:newInputIntensity]
//                                       forKey:@"inputIntensity"];
   }];

   [_glowEffect runAction:pulsate];
   [_scannerBeam runAction:[SKAction moveToY:_endY duration:_duration]
                completion:^
   {
      [self removeFromParent];
   }];
}

@end
