//
//  GLTileNode.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/7/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLTileNode.h"
#import "UIColor+Crayola.h"

@implementation GLTileNode

+ (id)tileWithRect:(CGRect)rect
{
   GLTileNode *tile = [GLTileNode node];

   tile.size = rect.size;
   tile.anchorPoint = CGPointZero;
   tile.position = rect.origin;
   tile.isLiving = NO;
   tile.color = [SKColor crayolaCoconutColor];

   return tile;
}

- (void)setIsLiving:(BOOL)living
{
   if (_isLiving == living)
      return;

   _isLiving = living;
   float duration = (_isLiving) ? _birthingDuration :
                                  _dyingDuration;

   SKColor *newColor = (_isLiving) ? [SKColor crayolaMulberryColor] :
                                     [SKColor crayolaCoconutColor];

   SKAction *changeColor = [SKAction colorizeWithColor:newColor
                                      colorBlendFactor:0.0
                                              duration:duration];
   
   changeColor.timingMode = SKActionTimingEaseInEaseOut;
   [self runAction:changeColor];
}

@end
