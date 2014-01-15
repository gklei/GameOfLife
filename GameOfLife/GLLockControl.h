//
//  GLLockControl.h
//  GameOfLife
//
//  Created by Gregory Klein on 1/15/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLUIActionButton.h"

typedef NS_ENUM(int, GL_LOCK_CONTROL_STATE)
{
   e_LOCK_CONTROL_LOCKED = 0,
   e_LOCK_CONTROL_UNLOCKED
};

@interface GLLockControl : GLUIActionButton
@property (readonly, assign) GL_LOCK_CONTROL_STATE state;
@end
