//
//  GLUIActionButton.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/21/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLUIActionButton.h"

@interface GLUIActionButton()
{
   NSTimeInterval _touchPressTime;
   BOOL _delayedFocusActionBlockExecuted;
}

@end;

@implementation GLUIActionButton

- (id)init
{
   if (self = [super init])
   {
      _delayBeforeFocusActionBlock = 1.0;
   }
   return self;
}

+ (instancetype)spriteNodeWithImageNamed:(NSString *)name
{
   GLUIActionButton *button = [[super alloc] init];
   SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:name];

   button.hitBox.size = CGSizeMake(CGRectGetWidth(sprite.frame) + 20,
                                   CGRectGetHeight(sprite.frame) + 20);
   button.hitBox.position = sprite.position;
   button.sprite = sprite;
   button.delayBeforeFocusActionBlock = 1.0;
   [button addChild:sprite];
   [button addChild:button.hitBox];
   return button;
}

- (void)handleTouchBegan:(UITouch *)touch
{
   _touchPressTime = touch.timestamp;
   
   if (_beganFocusActionBlock)
      _beganFocusActionBlock();

   if (_delayedFocusActionBlock)
   {
      if (_delayBeforeFocusActionBlock)
         [NSTimer scheduledTimerWithTimeInterval:_delayBeforeFocusActionBlock
                                          target:self
                                        selector:@selector(executeDelayedFocusActionBlock)
                                        userInfo:nil
                                         repeats:NO];
      else
         _delayedFocusActionBlock();
   }

   [super handleTouchBegan:touch];
}

- (void)handleTouchEnded:(UITouch *)touch
{
   CGPoint convertedPoint = [touch locationInNode:self];
   NSTimeInterval touchHoldTime = (touch.timestamp - _touchPressTime);
   
   if ([self.hitBox containsPoint:convertedPoint] &&
       !_delayedFocusActionBlockExecuted &&
       _actionBlock)
   {
      _actionBlock(touchHoldTime);
   }

   if (_loseFocusActionBlock)
      _loseFocusActionBlock();

   // reset this variable to NO for the next press
   _delayedFocusActionBlockExecuted = NO;
   [super handleTouchEnded:touch];
}

#pragma mark - Helper Methods
- (void)executeDelayedFocusActionBlock
{
   if (_delayedFocusActionBlock && self.hasFocus)
   {
      _delayedFocusActionBlock();
      _delayedFocusActionBlockExecuted = YES;
   }
   [self handleTouchEnded:nil];
}

@end
