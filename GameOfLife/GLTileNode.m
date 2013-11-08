//
//  GLTileNode.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/7/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLTileNode.h"


@implementation GLTileNode

+ (id)tileWithRect:(CGRect)rect
{
   GLTileNode *tile = [GLTileNode node];

   tile.size = rect.size;
   tile.anchorPoint = CGPointZero;
   tile.position = rect.origin;
   tile.isLiving = NO;
   tile.color = [SKColor crayolaCoconutColor];

   [tile setLiveColorName:CCN_crayolaMulberryColor - 1];
   [tile setDeadColorName:CCN_crayolaCoconutColor];
   
   return tile;
}

- (float)colorDistance
{
   CGPoint origin = self.position;
   float dist = sqrt(origin.x * origin.x + origin.y * origin.y);
   dist /= sqrt(320 * 320 + 480 * 480);
   return dist;
}

- (SKColor *)getNextColor:(CrayolaColorName *)colorName
{
//   *colorName = [SKColor getNextColorName:*colorName];
//   if (*colorName == _deadColorName)
//      *colorName = [SKColor getNextColorName:*colorName];
//   
//   return [SKColor colorForCrayolaColorName:*colorName];
   
//   return [SKColor colorWithHue:[self colorDistance]
//                     saturation:(arc4random()/((float)RAND_MAX * 2)) + 0.25
//                     brightness:1.0
//                          alpha:1.0];
   return [SKColor colorWithRed:0.2 green:0.2 blue:[self colorDistance] alpha:1.0];
}

- (void)setIsLiving:(BOOL)living
{
   if (_isLiving == living)
      return;

   _isLiving = living;
   float duration = (_isLiving)? _birthingDuration : _dyingDuration;

   SKColor *newColor = (_isLiving)? [self getNextColor:&_liveColorName] :
                                    [SKColor colorForCrayolaColorName:_deadColorName];

   SKAction *changeColor = [SKAction colorizeWithColor:newColor
                                      colorBlendFactor:0.0
                                              duration:duration];
   
   changeColor.timingMode = SKActionTimingEaseInEaseOut;
   [self runAction:changeColor];
}

@end
