//
//  GLSliderControl.h
//  GameOfLife
//
//  Created by Gregory Klein on 12/13/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLUIButton.h"

@interface GLSliderControl : GLUIButton

@property (nonatomic, readwrite) float sliderValue;

- (id)initWithLength:(int)length;
- (id)initWithValue:(float)value;
- (id)initWithLength:(int)length value:(float)value;
- (id)initWithLength:(int)length range:(NSRange)range andPreferenceKey:(NSString *)prefKey;

@end