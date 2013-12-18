//
//  GLGridScene.h
//  GameOfLife
//
//  Created by Gregory Klein on 11/7/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#import "GLSettingsItem.h"

@interface GLGridScene : SKScene<GLSettingsItemValueChangedDelegate>

@property (nonatomic, readonly) CGPoint locationOfFirstTouch;

- (void)expandGeneralHUD;

@end