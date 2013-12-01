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
   - (void)hud:(GLHud *)hud willExpandAfterPeriod:(CFTimeInterval *)waitPeriod;
   - (void)hudDidExpand:(GLHud *)hud;
   - (void)hudWillCollapse:(GLHud *)hud;
   - (void)hudDidCollapse:(GLHud *)hud;
@end

@interface GLHud : SKNode

@property (strong, nonatomic) id<GLHudDelegate> delegate;
@property (assign, nonatomic, getter = isExpanded) BOOL expanded;
@property (strong, nonatomic) SKAction *defaultExpandingSoundFX;
@property (strong, nonatomic) SKAction *defaultCollapsingSoundFX;

- (void)handleTouch:(UITouch *)touch moved:(BOOL)moved;

@end
