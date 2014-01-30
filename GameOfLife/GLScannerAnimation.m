//
//  GLScannerAnimation.m
//  GameOfLife
//
//  Created by Gregory Klein on 1/28/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLScannerAnimation.h"
#import "UIColor+Crayola.h"

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

- (id)initWithScannerDelegate:(NSObject<GLScannerDelegate> *)delegate
{
   if (self = [self init])
   {
      _scannerDelegate = delegate;
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
   _scannerBeam.xScale = CGRectGetWidth([UIScreen mainScreen].bounds) * 2.5;
   _scannerBeam.yScale = .75;
   _scannerBeam.colorBlendFactor = 1.0;
   _scannerBeam.alpha = .8;
   _scannerBeam.color = [SKColor crayolaPeriwinkleColor];
   _scannerBeam.position = CGPointMake(self.size.width * .5,
                                       self.size.height);
}

#pragma mark - Instance Methods
- (void)runAnimationOnParent:(SKNode *)parent
{
   [parent addChild:self];
   SKAction *pulsate = [SKAction customActionWithDuration:_duration
                                              actionBlock:
   ^(SKNode *node, CGFloat elapsedTime)
   {
      NSNumber *inputRadius = [((SKEffectNode *)node).filter valueForKey:@"inputRadius"];
      CGFloat newInputRadius = inputRadius.floatValue + .25*sin(elapsedTime * 5);
      [((SKEffectNode *)node).filter setValue:[NSNumber numberWithFloat:newInputRadius]
                                       forKey:@"inputRadius"];
   }];

   SKAction *moveScanner = [SKAction moveToY:_endY duration:_duration];
   moveScanner.timingMode = SKActionTimingEaseInEaseOut;

   CGFloat __block lastY = _scannerBeam.position.y;
   CGFloat __block currentY = _scannerBeam.position.y;
   CGFloat __block distance = 0;
   int __block callbackCount = 0;
   SKAction *callDelegate = [SKAction customActionWithDuration:moveScanner.duration
                                                   actionBlock:
   ^(SKNode *node, CGFloat elapsedTime)
   {
      currentY = node.position.y;
      distance = lastY - currentY;
      if (distance >= _updateIncrement)
      {
         lastY = self.size.height - (++callbackCount * _updateIncrement);
         [_scannerDelegate distanceScanned:distance];
      }
   }];

   SKAction *scan = [SKAction group:@[moveScanner, callDelegate]];

   [_glowEffect runAction:pulsate];
   [_scannerBeam runAction:scan
                completion:^
   {
      [self removeFromParent];
   }];
}

@end