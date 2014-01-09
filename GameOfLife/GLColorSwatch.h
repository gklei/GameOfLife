//
//  GLColorSwatch.h
//  GameOfLife
//
//  Created by Gregory Klein on 12/24/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLUIActionButton.h"
#import "UIColor+Crayola.h"

@class GLColorSwatch;

typedef NS_ENUM(int, GL_COLOR_SWATCH_STATE)
{
   e_COLOR_SWATCH_DISABLED = 0,
   e_COLOR_SWATCH_ENABLED
};

@protocol GLColorSwatchSelection <NSObject>
   - (void)swatchSelected:(GLColorSwatch *)swatch;
@end

@interface GLColorSwatch : GLUIActionButton

@property (nonatomic, readwrite) GL_COLOR_SWATCH_STATE state;
@property (nonatomic, assign) id<GLColorSwatchSelection> swatchSelectionDelegate;
@property (nonatomic, assign, setter = setColorName:) CrayolaColorName colorName;

@end
