//
//  GLHud.h
//  GameOfLife
//
//  Created by Gregory Klein on 11/26/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class GLHud;

@protocol GLHudDelegate <NSObject>
   - (void)hudWillExpand:(GLHud *)hud;
   - (void)hudDidExpand:(GLHud *)hud;
   - (void)hudWillCollapse:(GLHud *)hud;
   - (void)hudDidCollapse:(GLHud *)hud;
@end

@interface GLHud : SKNode

@property (strong, nonatomic) id<GLHudDelegate> delegate;

- (void)handleTouch:(UITouch *)touch moved:(BOOL)moved;

@end
