//
//  GLColorSelectionLayer.h
//  GameOfLife
//
//  Created by Gregory Klein on 12/22/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GLMenuLayer.h"

@class GLColorGrid;
@interface GLColorSelectionLayer : GLMenuLayer

@property (nonatomic, readonly) GLColorGrid *colorGrid;
@end
