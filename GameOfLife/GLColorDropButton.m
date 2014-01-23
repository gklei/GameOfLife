//
//  GLColorDropButton.m
//  GameOfLife
//
//  Created by Leif Alton on 1/8/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLColorDropButton.h"

@implementation GLColorDropButton

+ (id)spriteNodeWithImageNamed:(NSString *)name
{
   GLColorDropButton *button = [super spriteNodeWithImageNamed:name];
   NSString *splashPath = [[NSBundle mainBundle] pathForResource:@"Splash" ofType:@"sks"];

   button.particleEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:splashPath];
   button.particleEmitter.particleColor = [SKColor redColor];

   return button;
}

- (void)handleTouchEnded:(UITouch *)touch
{
   [_particleEmitter resetSimulation];
   [super handleTouchEnded:touch];
}

- (void)setColorName:(CrayolaColorName)colorName
{
   _colorName = colorName;
   self.color = [SKColor colorForCrayolaColorName:_colorName];
}

@end