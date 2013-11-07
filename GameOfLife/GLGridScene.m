//
//  GLGridScene.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/7/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLGridScene.h"
#import "GLTileNode.h"

#define TILESIZE CGSizeMake(20, 20)

@interface GLGridScene()
{
   CGSize _gridDimensions;
}
@end

@implementation GLGridScene

- (void)setupGridWithSize:(CGSize)size
{
   _gridDimensions = CGSizeMake(size.width/TILESIZE.width,
                                size.height/TILESIZE.height);

   NSLog(@"grid dimensions: %@", NSStringFromCGSize(_gridDimensions));

   for (int ypos = 0; ypos < size.height; ypos += TILESIZE.height)
      for (int xpos = 0; xpos < size.width; xpos += TILESIZE.width)
         [self addChild:[GLTileNode tileWithRect:CGRectMake(xpos + 0.5,
                                                            ypos + 0.5,
                                                            TILESIZE.width - 1,
                                                            TILESIZE.height - 1)]];
}

-(id)initWithSize:(CGSize)size {
   if (self = [super initWithSize:size])
   {
      self.backgroundColor = [SKColor colorWithRed:0.77
                                             green:0.82
                                              blue:0.90
                                             alpha:1.0];
      [self setupGridWithSize:size];
   }
   return self;
}

-(void)touchesBegan:(NSSet *)touches
          withEvent:(UIEvent *)event
{
   for (UITouch *touch in touches)
   {
      CGPoint location = [touch locationInNode:self];
      int row = location.y / TILESIZE.height;
      int col = location.x / TILESIZE.width;
      int arrayIndex = row*_gridDimensions.width + col;

      GLTileNode *tile = [[self children] objectAtIndex:arrayIndex];
      tile.lifeState = !tile.lifeState;
   }
}

-(void)update:(CFTimeInterval)currentTime
{
}

@end
