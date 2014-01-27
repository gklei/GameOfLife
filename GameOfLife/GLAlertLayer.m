//
//  GLAlertLayer.m
//  GameOfLife
//
//  Created by Gregory Klein on 1/9/14. (Made in Mexico)
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLAlertLayer.h"
#import "UIColor+Crayola.h"
#import "NSString+Additions.h"

@interface GLAlertLayer()
{
   BOOL _shouldHide;
}
@end

@implementation GLAlertLayer

+ (void)debugAlert:(NSString *)body withParent:(SKNode *)parent andDuration:(NSTimeInterval)seconds
{
   GLAlertLayer * alert = [[GLAlertLayer alloc] initWithHeader:@"Debug Message" body:body];
   if (alert)
   {
      alert.position = CGPointMake(0, CGRectGetHeight([UIScreen mainScreen].bounds));
      [alert showWithParent:parent];
      [NSTimer scheduledTimerWithTimeInterval:seconds
                                       target:alert
                                     selector:@selector(endMyLife)
                                     userInfo:nil repeats:NO];
   }
}

+ (id)alertWithHeader:(NSString *)header
                 body:(NSString *)body
             position:(CGPoint)position
            andParent:(SKNode *)parent
{
   GLAlertLayer * layer = [[GLAlertLayer alloc] initWithHeader:header body:body];
   if (layer) [layer showWithParent:parent andPosition:position];
   return layer;
}


- (void)endMyLife
{
   if (self.parent)
      [self removeFromParent];
}

- (id)init
{
   if (self = [super init])
   {
      // default alert color and alpha
      self.color = [SKColor crayolaBlackCoralPearlColor];
      self.alpha = .8;
      self.hidden = YES;
   }
   return self;
}

- (id)initWithHeader:(NSString *)header
                body:(NSString *)body
{
   if (self = [self init])
   {
      [self addHeaderText:[NSString futurizedString:header].uppercaseString];
      [self addBodyText:[NSString futurizedString:body]];
   }
   return self;
}

- (void)showWithParent:(SKNode *)parent
{
   self.hidden = NO;

   if (_animatesIn)
      self.position = CGPointMake(self.position.x - self.size.width,
                                  self.position.y);
   [parent addChild:self];

   if (_animatesIn)
      [self animateInWithCompletion:^{_animating = NO;}];
}

- (void)showWithParent:(SKNode *)parent andPosition:(CGPoint)position
{
   self.position = position;
   [self showWithParent:parent];
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
