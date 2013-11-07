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
   tile.lifeState = TLS_DEAD;

   return tile;
}

- (void)setLifeState:(TileLifeState)lifeState
{
   _lifeState = lifeState;
   self.color = (_lifeState == TLS_ALIVE) ? [SKColor crayolaSpringFrostColor] :
                                            [SKColor crayolaCoconutColor];
}

@end
