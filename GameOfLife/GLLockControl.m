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

   BOOL _shouldPlaySound;

   SKAction *_playLockSound;
   SKAction *_playUnlockSound;
}
@end

@implementation GLLockControl

- (void)observeLockedColorMode
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"LockedColorMode"];
}

- (void)observeSoundFxChanges
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"SoundFX"];
}

- (id)init
{
   if (self = [super init])
   {
      [self setupVariables];
      [self setupSpriteProperty];
      [self observeLockedColorMode];
      [self observeSoundFxChanges];
   }
   return self;
}

- (void)setupVariables
{
   _locked = YES;
   _lockedTexture = [SKTexture textureWithImageNamed:@"lock.png"];
   _unlockedTexture = [SKTexture textureWithImageNamed:@"unlock.png"];

   _playLockSound = [SKAction playSoundFileNamed:@"lock.wav" waitForCompletion:NO];
   _playUnlockSound = [SKAction playSoundFileNamed:@"unlock.wav" waitForCompletion:NO];
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
{
   self.texture = (locked)? _lockedTexture : _unlockedTexture;
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
   {
      [self toggleState];
      if (_shouldPlaySound) [self runAction:(_locked)? _playLockSound : _playUnlockSound];
   }
   
   [super handleTouchEnded:touch];
}

- (void)settingChanged:(NSNumber *)value ofType:(HUDValueType)type forKeyPath:(NSString *)keyPath
{
   if ([keyPath compare:@"LockedColorMode"] == NSOrderedSame)
   {
      assert(type == HVT_BOOL);

      _locked = value.boolValue;
      [self setTextureForState:value.boolValue];
   }
   if ([keyPath compare:@"SoundFX"] == NSOrderedSame)
   {
      assert(type == HVT_BOOL);
      _shouldPlaySound = [value boolValue];
   }
}

@end
