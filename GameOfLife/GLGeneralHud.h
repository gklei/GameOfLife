//
//  GLGeneralHud.h
//  GameOfLife
//
//  Created by Gregory Klein on 11/24/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GLHud.h"

typedef NS_ENUM(int, GL_GAME_STATE) {
   GL_RUNNING,
   GL_STOPPED
};

@protocol GLGeneralHudDelegate <GLHudDelegate>
   - (void)clear;
   - (void)restore;
   - (void)toggleRunning;
   - (void)grabScreenShot;
@end

@interface GLGeneralHud : GLHud

@property (strong, nonatomic) id<GLGeneralHudDelegate> delegate;

- (void)updateStartStopButtonForState:(GL_GAME_STATE)state;

@end
