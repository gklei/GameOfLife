//
//  GLGrid.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/29/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLGrid.h"
#import "GLTileNode.h"

#define LIVING YES
#define DEAD   NO
#define TILESIZE CGSizeMake(20, 20)

@interface GLGrid() <GLTileColorDelegate>
{
}
@end

@implementation GLGrid

- (id)initWithSize:(CGSize)size
{
   if (self = [super init])
   {
      [self setupGridWithSize:size];
   }
   return self;
}

- (void)setupGridWithSize:(CGSize)size
{
   _dimensions.rows = size.width/TILESIZE.width;
   _dimensions.columns = size.width/TILESIZE.width;

   for (int yPos = 0; yPos < size.height; yPos += TILESIZE.height)
   {
      for (int xPos = 0; xPos < size.width; xPos += TILESIZE.width)
      {
         GLTileNode *tile = [GLTileNode tileWithRect:CGRectMake(xPos + 0.5,
                                                                yPos + 0.5,
                                                                TILESIZE.width - 1,
                                                                TILESIZE.height - 1)];
         tile.colorDelegate = self;
         [self addChild:tile];
      }
   }
   _tiles = [NSArray arrayWithArray:self.children];

   CGPoint boardCenter = CGPointMake(_dimensions.columns * TILESIZE.width * 0.5,
                                     _dimensions.rows * TILESIZE.height * 0.5);
   float maxBoardDistance = sqrt(size.width * size.width + size.height * size.height);
   for (GLTileNode *tile in _tiles)
   {
      tile.boardMaxDistance = maxBoardDistance;
      [tile setColorCenter:boardCenter];
   }
}

- (GLTileNode *)tileAtTouch:(UITouch *)touch
{
   CGPoint location = [touch locationInNode:self];

   int row = location.y / TILESIZE.height;
   int col = location.x / TILESIZE.width;
   int arrayIndex = row*_dimensions.columns + col;

   if (arrayIndex >= 0 && arrayIndex < _tiles.count)
      return [_tiles objectAtIndex:arrayIndex];

   return nil;
}

- (SKColor *)currentTileColor
{
   return nil;
}

@end
