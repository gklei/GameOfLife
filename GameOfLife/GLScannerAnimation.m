//
//  GLScannerAnimation.m
//  GameOfLife
//
//  Created by Gregory Klein on 1/28/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLScannerAnimation.h"
#import "UIColor+Crayola.h"
#import "GLHUDSettingsManager.h"

@interface GLScannerAnimation() <HUDSettingsObserver>
{
   SKSpriteNode *_scannerBeam;
   SKEffectNode *_glowEffect;

   SKAction *_playScannerSound;

   BOOL _shouldPlaySound;
}
@end

@implementation GLScannerAnimation

- (void)observeSoundFxChanges
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"SoundFX"];
}

#pragma mark - Init Methods
- (id)init
{
   if (self = [super init])
   {
      // default size
      self.size = [UIScreen mainScreen].bounds.size;

      [self setupScannerBeam];
      [self setupGlowEffect];
      [_glowEffect addChild:_scannerBeam];

      // default property values
      _duration = 1;
      _startY = self.size.height + (_scannerBeam.size.height * .5);
      _endY = -_scannerBeam.size.height * .5;

      _playScannerSound = [SKAction playSoundFileNamed:@"scanner.2.wav" waitForCompletion:NO];
      [self observeSoundFxChanges];
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
   _scannerBeam.yScale = .85;
   _scannerBeam.colorBlendFactor = 1.0;
   _scannerBeam.alpha = 1;
   _scannerBeam.color = [SKColor crayolaPeriwinkleColor];
   _scannerBeam.position = CGPointMake(self.size.width * .5,
                                       self.size.height);
}

#pragma mark - Instance Methods
- (void)runAnimationOnParent:(SKNode *)parent withCompletionBlock:(void (^)())completionBlock
{
   [parent addChild:self];

   // an action to run on the glow effect node
   SKAction *pulsate = [SKAction customActionWithDuration:_duration
                                              actionBlock:
   ^(SKNode *node, CGFloat elapsedTime)
   {
      NSNumber *inputRadius = [((SKEffectNode *)node).filter valueForKey:@"inputRadius"];
      CGFloat newInputRadius = inputRadius.floatValue + .25*sin(elapsedTime * 5);
      [((SKEffectNode *)node).filter setValue:[NSNumber numberWithFloat:newInputRadius]
                                       forKey:@"inputRadius"];
   }];

   // an action to move the scaner beam
   SKAction *moveScanner = [SKAction moveToY:_endY duration:_duration];
   moveScanner.timingMode = SKActionTimingEaseInEaseOut;

   CGFloat __block lastY = _scannerBeam.position.y;
   CGFloat __block currentY = _scannerBeam.position.y;
   CGFloat __block distance = 0;
   int __block callbackCount = 0;

   // an action to callback the delegate during the scanner movement
   SKAction *callDelegate = [SKAction customActionWithDuration:moveScanner.duration
                                                   actionBlock:
   ^(SKNode *node, CGFloat elapsedTime)
   {
      currentY = node.position.y;
      distance = lastY - currentY;
      if (distance >= _updateIncrement)
      {
         lastY = self.size.height - (++callbackCount * _updateIncrement);
         [_scannerDelegate scannerAnimation:self
                        scannedOverDistance:(_updateIncrement * callbackCount)];
      }
   }];

   // group the scanner movement and callback actions together
   SKAction *scan = [SKAction group:@[moveScanner, callDelegate]];

   if (_shouldPlaySound) [self runAction:_playScannerSound];

   // now run these at the same time
   [_glowEffect runAction:pulsate];
   [_scannerBeam runAction:scan
                completion:^
   {
      // remove this class from the parent because it's done scanning
      [self removeFromParent];
      if (completionBlock)
         completionBlock();
   }];
}

#pragma mark - HUD Settings Observer Methods

- (void)settingChanged:(NSNumber *)value ofType:(HUDValueType)type forKeyPath:(NSString *)keyPath
{
   if ([keyPath compare:@"SoundFX"] == NSOrderedSame)
   {
      assert(type == HVT_BOOL);
      _shouldPlaySound = [value boolValue];
   }
}
@end