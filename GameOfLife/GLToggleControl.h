//
//  GLToggleControl.h
//  GameOfLife
//
//  Created by Gregory Klein on 12/11/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GLUIControl.h"

typedef NS_ENUM(int, GL_TOGGLE_CONTROL_STATE)
{
   e_TOGGLE_CONTROL_ENABLED,
   e_TOGGLE_CONTROL_DISABLED
};

@interface GLToggleControl : GLUIControl

@property (nonatomic, readonly) GL_TOGGLE_CONTROL_STATE state;
@property (nonatomic, readonly) SKSpriteNode *hitBox;

- (void)toggle;

@end
