//
//  GLUIControl.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/13/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLUIControl.h"

@implementation GLUIControl

- (id)init
{
   if (self = [super init])
   {
      _hitBox = [SKSpriteNode node];
      _hitBox.name = @"ui_control_hit_box";
   }
   return self;
}

- (NSString *)stringValue
{
   return nil;
}

- (void)handleTouchBegan:(UITouch *)touch
{
   _hasFocus = YES;
}

- (void)handleTouchEnded:(UITouch *)touch
{
   _hasFocus = NO;
}

- (void)handleTouchMoved:(UITouch *)touch
{
}

@end
