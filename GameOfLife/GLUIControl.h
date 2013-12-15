//
//  GLUIControl.h
//  GameOfLife
//
//  Created by Gregory Klein on 12/13/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GLTouchHandler.h"

@interface GLUIControl : SKSpriteNode <GLTouchHandler>

@property (nonatomic, readwrite) SKSpriteNode *hitBox;
@property (nonatomic, readwrite) BOOL hasFocus;

@end
