//
//  GLColorDropButton.h
//  GameOfLife
//
//  Created by Leif Alton on 1/8/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLUIActionButton.h"
#import "UIColor+Crayola.h"

@interface GLColorDropButton : GLUIActionButton

@property (nonatomic, assign, setter = setColorName:) CrayolaColorName colorName;
@property (nonatomic, assign) BOOL usesSplashAnimation;
@property (nonatomic, strong) SKEmitterNode *particleEmitter;

@end