//
//  GLTileNode.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/7/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLTileNode.h"

#define TILE_SCALE_DEFAULT 1
#define TILE_SCALE_FOCUSED 1.3

@implementation GLTileNode

@synthesize liveColor = _liveColor;

+ (id)tileWithTexture:(SKTexture *)texture rect:(CGRect)rect
{
   GLTileNode *tile = [GLTileNode spriteNodeWithTexture:texture size:rect.size];
   tile.deadTexture = texture;
   tile.position = CGPointMake(rect.origin.x + rect.size.width * 0.5,
                               rect.origin.y + rect.size.height * 0.5);
   
   tile.size = rect.size;
   tile.colorBlendFactor = 1.0;
   tile.isLiving = NO;
   tile.scalesOnTouch = NO;

   BeganFocusActionBlock beganFocusActionBlock = ^
   {
      if (!tile.isLiving)
      {
         SKNode *parent = tile.parent;
         [tile removeFromParent];
         [parent addChild:tile];
         SKAction *rotateRight = [SKAction rotateByAngle:-M_PI_2 duration:.2];
         SKAction *scaleUp = [SKAction scaleTo:TILE_SCALE_FOCUSED duration:.2];

         rotateRight.timingMode = SKActionTimingEaseInEaseOut;
         scaleUp.timingMode = SKActionTimingEaseInEaseOut;

         tile.color = [tile getLivingTileColor];
         tile.originalColor = [tile.tileColorDelegate currentTileColor];
         [tile runAction:[SKAction group:@[rotateRight, scaleUp]]
              completion:^
         {
            [tile setScale:TILE_SCALE_FOCUSED];
            tile.zRotation = -M_PI_2;
         }];
      }
   };

   tile.beganFocusActionBlock = beganFocusActionBlock;

   LoseFocusActionBlock loseFocusActionBlock = ^
   {
      SKAction *scaleDown = [SKAction scaleTo:TILE_SCALE_DEFAULT duration:.2];
      scaleDown.timingMode = SKActionTimingEaseInEaseOut;

      [tile runAction:scaleDown
           completion:^
      {
         if (tile.xScale != TILE_SCALE_DEFAULT || tile.yScale != TILE_SCALE_DEFAULT)
            [tile setScale:TILE_SCALE_DEFAULT];
         
         tile.color = (tile.isLiving)? [tile getLivingTileColor] :
                                       [SKColor colorForCrayolaColorName:tile.deadColorName];
      }];
   };

   tile.loseFocusActionBlock = loseFocusActionBlock;

   tile.color = [SKColor crayolaCoconutColor];
   tile.liveColorName = CCN_crayolaMulberryColor - 1;
   tile.deadColorName = CCN_crayolaCoconutColor;
   tile.boardMaxDistance = 10000;
   tile.maxColorDistance = tile.boardMaxDistance;
   
   return tile;
}

- (float)calcDistanceFromStart:(CGPoint)start toEnd:(CGPoint)end
{
   float dist;// = 0;
//   if ((start.x != end.x) || (start.y != end.y))
      dist = sqrt((start.x - end.x) * (start.x - end.x) +
                  (start.y - end.y) * (start.y - end.y));
   return dist;
}

- (float)colorDistance
{
   float dist = [self calcDistanceFromStart:_colorCenter toEnd:self.position];
   dist /= _maxColorDistance;
   dist = 1.0 - dist;
   return dist;
}

// gets called when turning a tile on
- (SKColor *)getLivingTileColor
{
   float dist = [self colorDistance] * 1.15;

   // uses the current selected swatch color as the base color
   _liveColor = [_tileColorDelegate currentTileColor];

   CGFloat r, g, b;

   if ([_liveColor getRed:&r green:&g blue:&b alpha:0])
      return [SKColor colorWithRed:dist*r green:dist*g blue:dist*b alpha:1.0];
   else
      return [SKColor colorWithHue:[self colorDistance]
                        saturation:(arc4random()/((float)RAND_MAX * 2)) + 0.25
                        brightness:1.0
                             alpha:1.0];
}

// gets called while the algorithm is running
- (SKColor *)getNextColor:(CrayolaColorName *)colorName
{
   float dist = [self colorDistance] * 1.15;

   if (!_liveColor)
      _liveColor = [_tileColorDelegate currentTileColor];

   CGFloat r, g, b;

   if ([_liveColor getRed:&r green:&g blue:&b alpha:0])
      return [SKColor colorWithRed:dist*r green:dist*g blue:dist*b alpha:1.0];
   else
      return [SKColor colorWithHue:[self colorDistance]
                        saturation:(arc4random()/((float)RAND_MAX * 2)) + 0.25
                        brightness:1.0
                             alpha:1.0];
}

- (void)updateColor
{
   float duration = (_isLiving)? _birthingDuration : _dyingDuration;
   
   SKColor *newColor = (_isLiving)? [self getNextColor:&_liveColorName] :
   [SKColor colorForCrayolaColorName:_deadColorName];
   
   SKAction *changeColor = [SKAction colorizeWithColor:newColor
                                      colorBlendFactor:1.0
                                              duration:duration];
   
   changeColor.timingMode = SKActionTimingEaseIn;
   [self runAction:changeColor];
}

- (void)setMaxColorDistance:(float)dist
{
   _maxColorDistance = dist;
   [self updateColor];
}

- (void)setColorCenter:(CGPoint)colorCenter
{
   _colorCenter = colorCenter;
   
   float colorDist = [self calcDistanceFromStart:CGPointZero toEnd:_colorCenter];
   if (colorDist > _boardMaxDistance * 0.5)
      colorDist = _boardMaxDistance - colorDist;
   
   self.maxColorDistance = _boardMaxDistance - colorDist;
}

- (void)swapTextures
{
   if (_liveTexture == nil || _deadTexture == nil)
      self.zRotation = (_isLiving)? M_PI : 0.0;
   else
      self.texture = (_isLiving)? _liveTexture : _deadTexture;
}

- (bool)dualTextures
{
   return !(_liveTexture == nil || _deadTexture == nil);
}

- (void)setIsLiving:(BOOL)living
{
   if (_isLiving == living)
      return;

   if (!living)
      _liveColor = nil;

   _isLiving = living;
   [self swapTextures];
}

- (void)updateLivingAndColor:(BOOL)living
{
   self.isLiving = living;
   [self updateColor];
}

- (void)clearTile
{
   self.isLiving = NO;
   _liveColor = [_tileColorDelegate currentTileColor];

   SKColor *deadColor = [SKColor colorForCrayolaColorName:_deadColorName];
   SKAction *changeColor = [SKAction colorizeWithColor:deadColor
                                      colorBlendFactor:0.0
                                              duration:.15];
   changeColor.timingMode = SKActionTimingEaseInEaseOut;
   [self runAction:changeColor];
}

@end
