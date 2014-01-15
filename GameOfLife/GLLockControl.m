//
//  GLLockControl.m
//  GameOfLife
//
//  Created by Gregory Klein on 1/15/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLLockControl.h"

@interface GLLockControl()
{
   SKTexture *_lockedTexture;
   SKTexture *_unlockedTexture;
}
@end

@implementation GLLockControl

- (id)init
{
   if (self = [super init])
   {
      [self setupVariables];
      [self setupSpriteProperty];
   }
   return self;
}

- (void)setupVariables
{
   _state = e_LOCK_CONTROL_LOCKED;
   _lockedTexture = [SKTexture textureWithImageNamed:@"lock.png"];
   _unlockedTexture = [SKTexture textureWithImageNamed:@"unlock.png"];
}

- (void)setupSpriteProperty
{
   self.sprite = [SKSpriteNode spriteNodeWithTexture:_lockedTexture];
   [self addChild:self.sprite];
   self.hitBox.size = self.sprite.size;
   [self addChild:self.hitBox];
}

// this is setup this way just in case if we want to change the texture
// before the state is set
- (void)setTextureForState:(GL_LOCK_CONTROL_STATE)state
                  inverted:(BOOL)inverted
{
   switch (state)
   {
      case e_LOCK_CONTROL_UNLOCKED:
         self.texture = (inverted)? _lockedTexture : _unlockedTexture;
         break;
      case e_LOCK_CONTROL_LOCKED:
         self.texture = (inverted)? _unlockedTexture : _lockedTexture;
         break;
      default:
         return;
   }
}

- (void)toggleState
{
   _state = (_state == e_LOCK_CONTROL_LOCKED)? e_LOCK_CONTROL_UNLOCKED : e_LOCK_CONTROL_LOCKED;
}

- (void)handleTouchEnded:(UITouch *)touch
{
   [self toggleState];
   [self setTextureForState:_state inverted:NO];
   [super handleTouchEnded:touch];
}

@end
