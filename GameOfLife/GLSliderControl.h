//
//  GLSliderControl.h
//  GameOfLife
//
//  Created by Gregory Klein on 12/13/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLUIControl.h"

@interface GLSliderControl : GLUIControl

@property (nonatomic, readwrite) float sliderValue;

- (id)initWithLength:(int)length;

@end