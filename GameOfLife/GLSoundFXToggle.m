//
//  GLSoundFXToggle.m
//  GameOfLife
//
//  Created by Gregory Klein on 2/3/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLSoundFXToggle.h"

@implementation GLSoundFXToggle

- (void)setState:(GL_TOGGLE_CONTROL_STATE)state
{
   self.shouldPlaySound = (state != e_TOGGLE_CONTROL_DISABLED);
   [super setState:state];
}

@end
