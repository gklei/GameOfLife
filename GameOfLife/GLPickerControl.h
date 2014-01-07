//
//  GLPickerControl.h
//  GameOfLife
//
//  Created by Leif Alton on 1/6/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLUIButton.h"
#import "GLHUDSettingsManager.h"

@interface GLPickerControl : GLUIButton<HUDSettingsObserver>

@property (nonatomic, readwrite) NSUInteger imageIndex;

- (id)initWithHUDPickerItemDescription:(HUDPickerItemDescription *)itemDesc;

@end