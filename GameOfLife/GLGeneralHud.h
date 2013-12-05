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
   - (void)clearButtonPressed;
   - (void)restoreButtonPressed;
   - (void)toggleRunningButtonPressed;
   - (void)screenShotButtonPressed;

   - (void)settingsWillExpandWithRepositioningAction:(SKAction *)action;
   - (void)settingsDidExpand;
   - (void)settingsWillCollapseWithRepositioningAction:(SKAction *)action;
   - (void)settingsDidCollapse;
@end

@interface GLGeneralHud : GLHud

@property (readonly, nonatomic) BOOL settingsAreExpanded;
@property (strong, nonatomic) id<GLGeneralHudDelegate> delegate;

- (void)updateStartStopButtonForState:(GL_GAME_STATE)state;
- (void)collapse;
- (void)expand;

- (NSArray *)coreFunctionButtons;
- (void)setCoreFunctionButtonsHidden:(BOOL)hidden;

@end
