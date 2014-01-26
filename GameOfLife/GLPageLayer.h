//
//  GLPageLayer.h
//  GameOfLife
//
//  Created by Gregory Klein on 1/25/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GLMenuLayer.h"

typedef NS_ENUM(int, GL_PAGE_TEXT_ELEMENT)
{
   e_PAGE_TEXT_HEADER = 0,
   e_PAGE_TEXT_BODY
};

@interface GLPageLayer : GLMenuLayer

// Defaults to YES
@property (nonatomic, assign) BOOL dynamicallySetsSize;

- (void)addHeaderText:(NSString *)headerText;
- (void)addBodyText:(NSString *)bodyText;
- (void)addNewLines:(NSInteger)lines;

@end
