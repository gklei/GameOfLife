//
//  GLCurrentPageIndicator.h
//  GameOfLife
//
//  Created by Gregory Klein on 2/6/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLUIButton.h"

@interface GLCurrentPageIndicator : SKSpriteNode

- (id)initWithPageCount:(NSUInteger)count currentPageIndex:(NSUInteger)index;
- (void)setCurrentPageIndicatorWithIndex:(NSUInteger)index;

@end
