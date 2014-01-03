//
//  GLSliderControl.h
//  GameOfLife
//
//  Created by Gregory Klein on 12/13/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLUIButton.h"
#import "GLHUDSettingsManager.h"

@interface GLSliderControl : GLUIButton<HUDSettingsObserver>

@property (nonatomic, readwrite) float sliderValue;

- (id)initWithLength:(int)length range:(HUDItemRange)range andPreferenceKey:(NSString *)prefKey;

@end