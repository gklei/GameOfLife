//
//  GLAlertLayer.m
//  GameOfLife
//
//  Created by Gregory Klein on 1/9/14. (Made in Mexico)
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLAlertLayer.h"

@interface GLAlertLayer()
{
   BOOL _shouldHide;
}
@end

@implementation GLAlertLayer

- (void)showWithParent:(SKNode *)parent
{
   self.hidden = NO;

   if (_animatesIn)
      self.position = CGPointMake(self.position.x - self.size.width,
                                  self.position.y);
   [parent addChild:self];

   if (_animatesIn)
      [self animateInWithCompletion:
       ^{
          _animating = NO;
       }];
}

- (void)hide
{
   if (_animating)
   {
      _shouldHide = YES;
      return;
   }

   [self hideAndRemoveFromParent];
}

- (void)animateInWithCompletion:(void (^)())completion
{
   if (!self.parent)
      return;

   SKAction *slideRight = [SKAction moveTo:CGPointMake(0, self.position.y) duration:.2];
   slideRight.timingMode = SKActionTimingEaseInEaseOut;

   _animating = YES;
   [self runAction:slideRight completion:
    ^{
       completion();
       if (_shouldHide)
          [self hideAndRemoveFromParent];
    }];
}

- (void)hideAndRemoveFromParent
{
   self.hidden = YES;
   if (self.parent)
      [self removeFromParent];

   _shouldHide = NO;
}

@end
