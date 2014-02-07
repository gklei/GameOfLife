//
//  GLCurrentPageIndicator.m
//  GameOfLife
//
//  Created by Gregory Klein on 2/6/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLCurrentPageIndicator.h"

#define PAGE_DOT_SIZE CGSizeMake(10, 10)
#define HORIZONTAL_DOT_PADDING 5

@interface GLCurrentPageIndicator()
{
   NSMutableArray *_pageDotArray;
   SKSpriteNode *_currentPageDot;
}
@end

@implementation GLCurrentPageIndicator

- (id)initWithPageCount:(NSUInteger)count currentPageIndex:(NSUInteger)index
{
   if (self = [super init])
   {
      self.size = CGSizeMake(count * (PAGE_DOT_SIZE.width + HORIZONTAL_DOT_PADDING) -
                             (PAGE_DOT_SIZE.width * .5),
                             PAGE_DOT_SIZE.height);
      self.anchorPoint = CGPointMake(0, .5);
      [self setupPageDots:count currentPageIndex:index];
   }
   return self;
}

- (void)setupPageDots:(NSUInteger)count currentPageIndex:(NSUInteger)index
{
   _pageDotArray = [NSMutableArray new];
   for (int i = 0; i < count; ++i)
   {
      SKSpriteNode *pageDot = [SKSpriteNode spriteNodeWithImageNamed:@"page.dot.png"];
      pageDot.position = CGPointMake(i * (PAGE_DOT_SIZE.width + HORIZONTAL_DOT_PADDING) +
                                     (PAGE_DOT_SIZE.width * .5),
                                     0);
      if (i == index)
      {
         _currentPageDot = pageDot;
         pageDot.alpha = 5.;
      }
      else
      {
         pageDot.alpha = .5;
      }

      [_pageDotArray addObject:pageDot];
      [self addChild:pageDot];
   }
}

- (void)setCurrentPageIndicatorWithIndex:(NSUInteger)index
{
   NSAssert(index < _pageDotArray.count, @"page index out of bounds");
   
   _currentPageDot.alpha = .5;
   _currentPageDot = _pageDotArray[index];
   _currentPageDot.alpha = 5.;
}

@end
