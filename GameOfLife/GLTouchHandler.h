//
//  GLTouchHandler.h
//  GameOfLife
//
//  Created by Gregory Klein on 12/15/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

// This is currently a workaround for the bug in SpriteKit that prevents any of the UIResponder
// touch methods from being called in SKNode subclasses

#import <Foundation/Foundation.h>

@protocol GLTouchHandler <NSObject>

- (void)handleTouchBegan:(UITouch *)touch;
- (void)handleTouchMoved:(UITouch *)touch;
- (void)handleTouchEnded:(UITouch *)touch;

@end
