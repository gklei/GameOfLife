//
//  GLColorHud.h
//  GameOfLife
//
//  Created by Gregory Klein on 11/23/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol ColorHudDelegate <NSObject>
- (void)colorHudWillExpand;
- (void)colorHudWillCollapse;
@end

@interface GLColorHud : SKNode

@property (strong, nonatomic) id<ColorHudDelegate> delegate;

- (void)handleTouch:(UITouch *)touch;

@end
