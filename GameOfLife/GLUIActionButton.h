//
//  GLUIActionButton.h
//  GameOfLife
//
//  Created by Gregory Klein on 12/21/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLUIButton.h"

typedef void (^ActionBlock)(NSTimeInterval);
typedef void (^BeganFocusActionBlock)();
typedef void (^LoseFocusActionBlock)();

@interface GLUIActionButton : GLUIButton

@property (readwrite, copy) ActionBlock actionBlock;
@property (readwrite, copy) BeganFocusActionBlock beganFocusActionBlock;
@property (readwrite, copy) LoseFocusActionBlock loseFocusActionBlock;

@end
