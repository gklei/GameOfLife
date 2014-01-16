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
   BOOL  _locked;
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
   _locked = YES;
   _lockedTexture = [SKTexture textureWithImageNamed:@"lock.png"];
   _unlockedTexture = [SKTexture textureWithImageNamed:@"unlock.png"];
}

- (void)setupSpriteProperty
{
   self.sprite = [SKSpriteNode spriteNodeWithTexture:_lockedTexture];
   self.hitBox.size = CGSizeMake(CGRectGetWidth(self.sprite.frame) + 10,
                                 CGRectGetHeight(self.sprite.frame) + 20);
   [self addChild:self.sprite];
   [self addChild:self.hitBox];
}

// this is setup this way just in case if we want to change the texture
// before the state is set
- (void)setTextureForState:(BOOL)locked
                  inverted:(BOOL)inverted
{
   if (locked)
      self.texture = (inverted)? _unlockedTexture : _lockedTexture;
   else
      self.texture = (inverted)? _lockedTexture : _unlockedTexture;
}

- (void)toggleState
{
   _locked = !_locked;
   
   NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
   [defaults setObject:[NSNumber numberWithBool:_locked] forKey:@"LockedColorMode"];
}

- (BOOL)touchInsideHitBox:(UITouch *)touch
{
   return [self.hitBox containsPoint:[touch locationInNode:self]];
}

- (void)handleTouchEnded:(UITouch *)touch
{
   if ([self touchInsideHitBox:touch])
      [self toggleState];

   [self setTextureForState:_locked inverted:NO];
   [super handleTouchEnded:touch];
}

@end
