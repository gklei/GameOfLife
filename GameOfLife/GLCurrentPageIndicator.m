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
#define LABEL_FONT_SIZE 10;

@interface GLCurrentPageIndicator()
{
   NSMutableArray *_pageDotArray;
   SKSpriteNode *_currentPageDot;
   SKLabelNode *_numerator;
   SKLabelNode *_denominator;
   SKLabelNode *_slash;
   NSUInteger _totalPages;
}
@end

@implementation GLCurrentPageIndicator

- (id)initWithPageCount:(NSUInteger)count currentPageIndex:(NSUInteger)index
{
   if (self = [super init])
   {
      _totalPages = count;
      _numerator = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedExtraBold"];
      _numerator.text = [NSString stringWithFormat:@"%@   /   %@",
                         @(index + 1).stringValue,
                         @(count).stringValue];
      _numerator.fontSize = LABEL_FONT_SIZE;
      [self addChild:_numerator];
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
   _numerator.text = [NSString stringWithFormat:@"%@   /   %@",
                      @(index + 1).stringValue,
                      @(_totalPages).stringValue];
}

@end
