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
}

@end;

@implementation GLUIActionButton

+ (instancetype)spriteNodeWithImageNamed:(NSString *)name
{
   GLUIActionButton *button = [[super alloc] init];
   SKSpriteNode *sprite = [SKSpriteNode spriteNodeWithImageNamed:name];

//   button.hitBox.color = [SKColor redColor];
//   button.hitBox.alpha = .5;
   button.hitBox.size = CGSizeMake(CGRectGetWidth(sprite.frame) + 20,
                                   CGRectGetHeight(sprite.frame) + 20);
   button.hitBox.position = sprite.position;
   button.sprite = sprite;
   [button addChild:sprite];
   [button addChild:button.hitBox];
   return button;
}

- (void)handleTouchBegan:(UITouch *)touch
{
   _touchPressTime = touch.timestamp;
   
   if (_beganFocusActionBlock)
      _beganFocusActionBlock();

   [super handleTouchBegan:touch];
}

- (void)handleTouchEnded:(UITouch *)touch
{
   CGPoint convertedPoint = [touch locationInNode:self];
   NSTimeInterval touchHoldTime = (touch.timestamp - _touchPressTime);
   
   if ([self.hitBox containsPoint:convertedPoint] && _actionBlock)
      _actionBlock(touchHoldTime);

   if (_loseFocusActionBlock)
      _loseFocusActionBlock();

   [super handleTouchEnded:touch];
}

@end
