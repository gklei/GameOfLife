//
//  GLColorHud.h
//  GameOfLife
//
//  Created by Gregory Klein on 11/23/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GLHud.h"
#import "GLHUDSettingsManager.h"
#import "UIColor+Crayola.h"

@protocol GLColorHudDelegate <GLHudDelegate>
   - (void)setCurrentColorName:(CrayolaColorName)colorName;
   - (void)colorGridWillExpandWithRepositioningAction:(SKAction *)action;
   - (void)colorGridDidExpand;
   - (void)colorGridWillCollapseWithRepositioningAction:(SKAction *)action;
   - (void)colorGridDidCollapse;
@end

@interface GLColorHud : GLHud<HUDSettingsObserver>

@property (readonly, nonatomic) BOOL colorGridIsExpanded;
@property (assign, nonatomic) CrayolaColorName currentColorName;
@property (strong, nonatomic) id<GLColorHudDelegate> delegate;

- (void)setColorDropsHidden:(BOOL)hidden;

@end
