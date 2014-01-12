//
//  GLLabelControl.h
//  GameOfLife
//
//  Created by Leif Alton on 1/11/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GLUIButton.h"
#import "GLHUDSettingsManager.h"

@interface GLLabelControl : GLUIButton<HUDSettingsObserver>

- (id)initWithHUDItemDescription:(HUDItemDescription *)item;

@end
