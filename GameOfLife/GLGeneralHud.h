//
//  GLGeneralHud.h
//  GameOfLife
//
//  Created by Gregory Klein on 11/24/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GLHud.h"

@protocol GLGeneralHudDelegate <GLHudDelegate>
- (void)toggleRunning;
@end

@interface GLGeneralHud : GLHud

@property (strong, nonatomic) id<GLGeneralHudDelegate> delegate;

@end
