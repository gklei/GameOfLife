//
//  GLGridScene.h
//  GameOfLife
//
//  Created by Gregory Klein on 11/7/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#import "GLSettingsItem.h"
#import "GLHUDSettingsManager.h"

@class GLViewController;

@interface GLGridScene : SKScene<HUDSettingsObserver>

+ (instancetype)sceneWithViewController:(GLViewController *)controller;

- (void)expandGeneralHUD;

@end