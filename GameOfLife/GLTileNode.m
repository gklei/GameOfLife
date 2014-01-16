//
//  GLTileNode.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/7/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLTileNode.h"

#define TILE_SCALE_DEFAULT       1
#define TILE_SCALE_FOCUSED       1.3
#define LIVE_COLOR_BLEND_FACTOR  0.95
#define DEAD_COLOR_BLEND_FACTOR  0.0

@implementation GLTileNode

+ (id)tileWithTexture:(SKTexture *)texture rect:(CGRect)rect andRotation:(double)rotation
{
   GLTileNode *tile = [GLTileNode spriteNodeWithTexture:texture size:rect.size];
   tile.deadTexture = texture;
   tile.position = CGPointMake(rect.origin.x + rect.size.width * 0.5,
                               rect.origin.y + rect.size.height * 0.5);
   tile.size = rect.size;
   tile.colorBlendFactor = LIVE_COLOR_BLEND_FACTOR;
   [tile setIsLiving:NO];
   tile.scalesOnTouch = NO;
   tile.liveRotation = rotation;

   BeganFocusActionBlock beganFocusActionBlock = ^
   {
      if (!tile.isLiving)
      {
         SKNode *parent = tile.parent;
         [tile removeFromParent];
         [parent addChild:tile];
         SKAction *rotateRight = [SKAction rotateByAngle:tile.liveRotation duration:.2];
         SKAction *scaleUp = [SKAction scaleTo:TILE_SCALE_FOCUSED duration:.2];

         rotateRight.timingMode = SKActionTimingEaseInEaseOut;
         scaleUp.timingMode = SKActionTimingEaseInEaseOut;
         
         // uncomment both tile.isLiving statements to to make tiles animate
         // in the living color, regardless of the _trackGeneration flag
//         tile.isLiving = YES;
         [tile restoreAsLiving];
//         tile.isLiving = NO;

         [tile runAction:[SKAction group:@[rotateRight, scaleUp]]
              completion:^
         {
            [tile setScale:TILE_SCALE_FOCUSED];
            tile.zRotation = tile.liveRotation;
         }];
      }
   };

   tile.beganFocusActionBlock = beganFocusActionBlock;

   LoseFocusActionBlock loseFocusActionBlock = ^
   {
      if (tile.isLiving)
      {
         SKAction *scaleDown = [SKAction scaleTo:TILE_SCALE_DEFAULT duration:.2];
         scaleDown.timingMode = SKActionTimingEaseInEaseOut;
         [tile runAction:scaleDown
              completion:^
         {
            if (tile.xScale != TILE_SCALE_DEFAULT || tile.yScale != TILE_SCALE_DEFAULT)
               [tile setScale:TILE_SCALE_DEFAULT];

            [tile restoreAsLiving];
         }];
      }
      else
      {
         [tile restoreAsDead];
      }
   };

   tile.loseFocusActionBlock = loseFocusActionBlock;
   
   return tile;
}

- (void)updateColor
{
   SKColor * newColor = ([self isLiving])? [_colorProvider liveColorForNode:self] :
                                           [_colorProvider deadColorForNode:self];
   
   float duration = ([self isLiving])? _birthingDuration : _dyingDuration;
   
   SKAction *changeColor = [SKAction colorizeWithColor:newColor
                                      colorBlendFactor:LIVE_COLOR_BLEND_FACTOR
                                              duration:duration];
   
   changeColor.timingMode = SKActionTimingEaseIn;
   [self runAction:changeColor];
}

- (void)swapTextures
{
   if ([self dualTextures])
      self.texture = ([self isLiving])? _liveTexture : _deadTexture;
   else
      self.zRotation = ([self isLiving])? _liveRotation : _deadRotation;
}

- (bool)dualTextures
{
   return !(_liveTexture == nil || _deadTexture == nil);
}

- (BOOL)isLiving
{
   return (_generationCount > 0);
}

- (void)setIsLiving:(BOOL)living
{
   _generationCount = (living)? _generationCount + 1 : 0;
   [self swapTextures];
   [self updateColor];
}

- (void)setLiveRotation:(double)rotation
{
   _liveRotation = rotation;
   if ([self isLiving])
      self.zRotation = _liveRotation;
}

- (void)setDeadRotation:(double)rotation
{
   _deadRotation = rotation;
   if (![self isLiving])
      self.zRotation = _deadRotation;
}

- (void)updateTextures
{
   if (![self dualTextures])
      self.texture = _deadTexture;
   
   [self swapTextures];
}

- (void)setLiveTexture:(SKTexture *) liveTexture
{
   _liveTexture = liveTexture;
   [self updateTextures];
}

- (void)setDeadTexture:(SKTexture *) deadTexture
{
   _deadTexture = deadTexture;
   [self updateTextures];
}

- (void)clearTile
{
   self.isLiving = NO;
   
   SKColor * deadColor = [_colorProvider deadColorForNode:self];
   SKAction * changeColor = [SKAction colorizeWithColor:deadColor
                                       colorBlendFactor:DEAD_COLOR_BLEND_FACTOR
                                               duration:.15];
   changeColor.timingMode = SKActionTimingEaseInEaseOut;
   [self runAction:changeColor];
}

- (void)restoreAsLiving
{
   self.color = [_colorProvider liveColorForNode:self];
   self.colorBlendFactor = LIVE_COLOR_BLEND_FACTOR;
}

- (void)restoreAsDead
{
   self.color = [_colorProvider deadColorForNode:self];
   self.colorBlendFactor = DEAD_COLOR_BLEND_FACTOR;
}

- (void)clearActionsAndRestore:(BOOL)resetGenerations
{
   [self removeAllActions];
   
   if (resetGenerations && _generationCount) _generationCount = 1;
   
   if ([self isLiving])
      [self restoreAsLiving];
   else
      [self restoreAsDead];
}

@end
