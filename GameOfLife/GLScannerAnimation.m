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

      _duration = 1;
      _startY = self.size.height + (_scannerBeam.size.height * .5);
      _endY = -_scannerBeam.size.height * .5;

      [self addChild:_scannerBeam];
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
- (void)setupScannerBeam
{
   _scannerBeam = [SKSpriteNode spriteNodeWithImageNamed:@"slider-middle"];
   _scannerBeam.xScale = CGRectGetWidth([UIScreen mainScreen].bounds) * 2.0;
   _scannerBeam.colorBlendFactor = 1.0;
   _scannerBeam.alpha = .8;
   _scannerBeam.color = [SKColor redColor];
   _scannerBeam.position = CGPointMake(self.size.width * .5,
                                       self.size.height);
}

- (void)runAnimationOnParent:(SKNode *)parent
{
   [parent addChild:self];
   [_scannerBeam runAction:[SKAction moveToY:_endY duration:_duration]
                completion:^
   {
      [self removeFromParent];
   }];
}

@end
