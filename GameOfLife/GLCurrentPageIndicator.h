//
//  GLCurrentPageIndicator.h
//  GameOfLife
//
//  Created by Gregory Klein on 2/6/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLUIButton.h"

typedef NS_ENUM(NSUInteger, CurrentPageIndicatorType)
{
   e_CURRENT_PAGE_INDICATOR_DOTS,
   e_CUURENT_PAGE_INDICATOR_FRACTION
};

@interface GLCurrentPageIndicator : SKSpriteNode

- (id)initWithPageCount:(NSUInteger)count
       currentPageIndex:(NSUInteger)index
          indicatorType:(CurrentPageIndicatorType)type;

- (void)setCurrentPageIndicatorWithIndex:(NSUInteger)index;

@end
