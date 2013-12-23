//
//  GLColorHud.h
//  GameOfLife
//
//  Created by Gregory Klein on 11/23/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GLHud.h"

@protocol GLColorHudDelegate <GLHudDelegate>
   - (void)setCurrentColor:(SKColor *)color;
   - (void)colorGridWillExpandWithRepositioningAction:(SKAction *)action;
   - (void)colorGridDidExpand;
   - (void)colorGridWillCollapseWithRepositioningAction:(SKAction *)action;
   - (void)colorGridDidCollapse;
@end

@interface GLColorHud : GLHud

@property (readonly, nonatomic) BOOL colorGridIsExpanded;
@property (strong, nonatomic) SKColor *currentColor;
@property (strong, nonatomic) id<GLColorHudDelegate> delegate;

- (void)setColorDropsHidden:(BOOL)hidden;

@end
