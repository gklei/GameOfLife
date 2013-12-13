//
//  GLToggleButton.h
//  GameOfLife
//
//  Created by Gregory Klein on 12/11/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef NS_ENUM(int, GL_TOGGLE_BUTTON_STATE)
{
   e_TOGGLE_BUTTON_ENABLED,
   e_TOGGLE_BUTTON_DISABLED
};

@interface GLToggleButton : SKSpriteNode

@property (nonatomic, readonly) GL_TOGGLE_BUTTON_STATE state;
@property (nonatomic, readonly) SKSpriteNode *hitBox;

- (void)toggle;

@end
