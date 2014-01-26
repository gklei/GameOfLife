//
//  GLUITextButton.h
//  GameOfLife
//
//  Created by Gregory Klein on 1/25/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLUIActionButton.h"

#define BUTTON_TITLE_FONT_SIZE 14

@interface GLUITextButton : GLUIActionButton

@property (nonatomic, copy) NSString *buttonTitle;

+ (instancetype)textButtonWithTitle:(NSString *)title;
@end
