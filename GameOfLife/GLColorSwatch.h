//
//  GLColorSwatch.h
//  GameOfLife
//
//  Created by Gregory Klein on 12/24/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLUIActionButton.h"

typedef NS_ENUM(int, GL_COLOR_SWATCH_STATE)
{
   e_COLOR_SWATCH_DISABLED = 0,
   e_COLOR_SWATCH_ENABLED
};

@interface GLColorSwatch : GLUIActionButton
@end
