//
//  GLColorGrid.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/24/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLColorGrid.h"
#import "GLColorSwatch.h"

#define COLOR_SWATCH_X_PADDING 17
#define COLOR_SWATCH_Y_PADDING 5
#define COLOR_SWATCH_SIZE CGSizeMake(40, 40)

@interface GLColorGrid()
{
}
@end

@implementation GLColorGrid

- (id)initWithSize:(CGSize)size
{
   if (self = [super init])
   {
      _dimensions.columns = size.height;
      _dimensions.rows = size.width;
      [self setupColorSwatches];
   }
   return self;
}

- (void)setupColorSwatches
{
   for (int yPos = 0; yPos < _dimensions.rows * COLOR_SWATCH_SIZE.width;
        yPos += COLOR_SWATCH_SIZE.height + COLOR_SWATCH_Y_PADDING)
   {
      for (int xPos = 0; xPos < _dimensions.columns * COLOR_SWATCH_SIZE.height;
           xPos += COLOR_SWATCH_SIZE.width + COLOR_SWATCH_X_PADDING)
      {
         GLColorSwatch *swatch = [[GLColorSwatch alloc] init];
         swatch.position = CGPointMake(xPos, yPos);

         [self addChild:swatch];
      }
   }
}

@end
