//
//  GLHud.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/26/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLHud.h"
#import "GLUIButton.h"

@implementation GLHud

- (id)init
{
   if (self = [super init])
   {
      [self setupSoundFX];
   }
   return self;
}

- (void)setupSoundFX
{
   _defaultButtonPressSound = [SKAction playSoundFileNamed:@"button.press.wav" waitForCompletion:NO];
   _defaultExpandingSoundFX = [SKAction playSoundFileNamed:@"menu.open.wav" waitForCompletion:NO];
   _defaultCollapsingSoundFX = [SKAction playSoundFileNamed:@"menu.close.wav" waitForCompletion:NO];
}

// empty implementation -- this should be overridden by subclasses
- (void)collapse
{
}

// empty implementation -- this should be overridden by subclasses
- (void)hide
{
}

// empty implementation -- this should be overridden by subclasses
- (void)show
{
}

@end
