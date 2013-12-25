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

@protocol GLColorGridDelegate <NSObject>
- (void)colorGridColorChanged:(SKColor *)newColor;
@end

@interface GLColorGrid : SKNode

@property (nonatomic, readonly) ColorGridDimensions dimensions;
//@property (nonatomic, readwrite) GLColorSwatch *selectedSwatch;
@property (nonatomic, retain) id<GLColorGridDelegate> colorGridDelegate;

- (id)initWithSize:(CGSize)size;
- (void)updateSelectedColor:(SKColor *)newColor;

@end
