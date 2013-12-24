//
//  GLColorGrid.h
//  GameOfLife
//
//  Created by Gregory Klein on 12/24/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class GLColorSwatch;

typedef struct {
   int rows;
   int columns;
} ColorGridDimensions;

@interface GLColorGrid : SKNode

@property (nonatomic, readonly) ColorGridDimensions dimensions;
@property (nonatomic, readwrite) GLColorSwatch *selectedSwatch;

- (id)initWithSize:(CGSize)size;

@end
