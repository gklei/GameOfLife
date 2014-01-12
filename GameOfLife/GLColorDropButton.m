//
//  GLColorDropButton.m
//  GameOfLife
//
//  Created by Leif Alton on 1/8/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLColorDropButton.h"

@implementation GLColorDropButton

- (void)setColorName:(CrayolaColorName)colorName
{
   _colorName = colorName;
   self.color = [SKColor colorForCrayolaColorName:_colorName];
}

@end