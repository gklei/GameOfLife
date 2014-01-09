//
//  GLColorGrid.h
//  GameOfLife
//
//  Created by Gregory Klein on 12/24/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "UIColor+Crayola.h"

@class GLColorSwatch;

typedef struct {
   int rows;
   int columns;
} ColorGridDimensions;

@protocol GLColorGridDelegate <NSObject>
- (void)colorGridColorNameChanged:(CrayolaColorName)colorName;
@end

@interface GLColorGrid : SKNode

@property (nonatomic, readonly) ColorGridDimensions dimensions;
@property (nonatomic, retain) id<GLColorGridDelegate> colorGridDelegate;

- (id)initWithSize:(CGSize)size;
- (void)updateSelectedColorName:(CrayolaColorName)colorName;

@end
