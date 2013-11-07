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

   return tile;
}

- (void)setIsLiving:(BOOL)living
{
   _isLiving = living;
   self.color = (_isLiving) ? [SKColor crayolaSpringFrostColor] :
                              [SKColor crayolaCoconutColor];
}

@end
