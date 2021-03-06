//
//  GLGeneralHud.h
//  GameOfLife
//
//  Created by Gregory Klein on 11/24/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GLHud.h"
#import "GLHUDSettingsManager.h"

#import <AssetsLibrary/AssetsLibrary.h>

typedef NS_ENUM(int, GL_GAME_STATE) {
   GL_RUNNING,
   GL_STOPPED
};

@protocol GLGeneralHudDelegate <GLHudDelegate>
   - (void)clearButtonPressed;
   - (void)restoreButtonPressed:(NSTimeInterval)holdTime buttonPosition:(CGPoint)position;
   - (void)toggleRunningButtonPressed:(NSTimeInterval)holdTime buttonPosition:(CGPoint)position;
   - (void)screenShotButtonPressed:(NSTimeInterval)holdTime buttonPosition:(CGPoint)position;
   - (void)updatePhotoAuthorizationStatus:(ALAuthorizationStatus)status;

   - (void)settingsWillExpandWithRepositioningAction:(SKAction *)action;
   - (void)settingsDidExpand;
   - (void)settingsWillCollapseWithRepositioningAction:(SKAction *)action;
   - (void)settingsDidCollapse;
@end

@interface GLGeneralHud : GLHud<HUDSettingsObserver>

@property (readonly, nonatomic) BOOL settingsAreExpanded;
@property (strong, nonatomic) id<GLGeneralHudDelegate> delegate;

- (void)updateStartStopButtonForState:(GL_GAME_STATE)state
                            withSound:(BOOL)sound;
- (void)collapse;
- (void)expand;
- (void)toggleSettingsWithCompletion:(void (^)())completion;

- (NSArray *)coreFunctionButtons;
- (void)setCoreFunctionButtonsHidden:(BOOL)hidden;

@end
