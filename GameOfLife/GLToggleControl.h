//
//  GLToggleControl.h
//  GameOfLife
//
//  Created by Gregory Klein on 12/11/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GLUIButton.h"
#import "GLHUDSettingsManager.h"

typedef NS_ENUM(int, GL_TOGGLE_CONTROL_STATE)
{
   e_TOGGLE_CONTROL_DISABLED = 0,
   e_TOGGLE_CONTROL_ENABLED
};

@interface GLToggleControl : GLUIButton<HUDSettingsObserver>

@property (nonatomic, readonly) GL_TOGGLE_CONTROL_STATE state;

- (id)initWithPreferenceKey:(NSString *)key;
- (void)toggle:(BOOL)switchState;

@end
