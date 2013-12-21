//
//  GLUIButton.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/13/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLUIButton.h"

@interface GLUIButton()
{
   SKEffectNode *_glowEffect;
}
@end

@implementation GLUIButton

- (id)init
{
   if (self = [super init])
   {
      _hitBox = [SKSpriteNode node];
      _hitBox.name = @"ui_control_hit_box";

      [self setupGlowEffect];
   }
   return self;
}

- (id)initWithImageNamed:(NSString *)name
{
   if (self = [super initWithImageNamed:name])
   {
   }
   return self;
}

- (void)setupGlowEffect
{
   _glowEffect = [SKEffectNode node];
   CIFilter *filter = [CIFilter filterWithName:@"CIBloom"];
   [filter setValue:[NSNumber numberWithFloat:1.5f] forKey:@"inputIntensity"];

   // Large radius makes result EVEN SMALLER:
   [filter setValue:[NSNumber numberWithFloat:10.f] forKey:@"inputRadius"];

   _glowEffect.filter = filter;
   _glowEffect.shouldEnableEffects = NO;
   [super addChild:_glowEffect];
}

- (void)addChild:(SKNode *)node
{
   [_glowEffect addChild:node];
}

- (NSString *)stringValue
{
   return nil;
}

- (NSString *)longestPossibleStringValue
{
   return nil;
}

- (CGRect)largestPossibleAccumulatedFrame
{
   return self.calculateAccumulatedFrame;
}

- (void)handleTouchBegan:(UITouch *)touch
{
   _glowEffect.shouldEnableEffects = YES;
   _hasFocus = YES;
}

- (void)handleTouchEnded:(UITouch *)touch
{
   _glowEffect.shouldEnableEffects = NO;
   _hasFocus = NO;
}

- (void)handleTouchMoved:(UITouch *)touch
{
}

@end
