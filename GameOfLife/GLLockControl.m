//
//  GLLockControl.m
//  GameOfLife
//
//  Created by Gregory Klein on 1/15/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLLockControl.h"
#import "GLHUDSettingsManager.h"

@interface GLLockControl() <HUDSettingsObserver>
{
   SKTexture *_lockedTexture;
   SKTexture *_unlockedTexture;
   BOOL  _locked;
}
@end

@implementation GLLockControl

- (void)observeLockedColorMode
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"LockedColorMode"];
}

- (id)init
{
   if (self = [super init])
   {
      [self setupVariables];
      [self setupSpriteProperty];
      [self observeLockedColorMode];
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
   
   [super handleTouchEnded:touch];
}

- (void)settingChanged:(NSNumber *)value ofType:(HUDValueType)type forKeyPath:(NSString *)keyPath
{
   if ([keyPath compare:@"LockedColorMode"] == NSOrderedSame)
   {
      assert(type == HVT_BOOL);
      
      [self setTextureForState:[value boolValue] inverted:NO];
   }
}

@end
