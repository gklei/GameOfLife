//
//  GLSoundFXToggle.m
//  GameOfLife
//
//  Created by Gregory Klein on 2/3/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLSoundFXToggle.h"

@implementation GLSoundFXToggle

- (void)toggle:(BOOL)switchState
{
   self.shouldPlaySound = !self.shouldPlaySound;
   [super toggle:switchState];
}

@end
