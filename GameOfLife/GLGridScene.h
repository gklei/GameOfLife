//
//  GLGridScene.h
//  GameOfLife
//
//  Created by Gregory Klein on 11/7/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GLColorHud.h"
#import "GLTileNode.h"

@interface GLGridScene : SKScene <ColorHudDelegate, CurrentColorDelegate>

typedef struct {
   int rows;
   int columns;
} GridDimensions;

- (void)toggleRunning;

@end
