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
   SKLabelNode *_currentPageLabel;
   NSUInteger _totalPages;
   CurrentPageIndicatorType _type;
}
@end

@implementation GLCurrentPageIndicator

- (id)initWithPageCount:(NSUInteger)count
       currentPageIndex:(NSUInteger)index
          indicatorType:(CurrentPageIndicatorType)type
{
   if (self = [super init])
   {
      _totalPages = count;
      _type = type;

      switch (type)
      {
         case e_CURRENT_PAGE_INDICATOR_DOTS:
            [self setupPageDots:_totalPages currentPageIndex:index];
            break;
         case e_CUURENT_PAGE_INDICATOR_FRACTION:
            [self setupLabelWithIndex:index];
            break;
         default:
            NSLog(@"Unsupported current page indicator type: %u", (unsigned)type);
            break;
      }
   }
   return self;
}

- (void)setupLabelWithIndex:(NSUInteger)index
{
   _currentPageLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedExtraBold"];
   _currentPageLabel.text = [NSString stringWithFormat:@"%@   /   %@",
                             @(index + 1).stringValue,
                             @(_totalPages).stringValue];
   _currentPageLabel.fontSize = LABEL_FONT_SIZE;

   [self addChild:_currentPageLabel];
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

   self.anchorPoint = CGPointMake(0, .5);
   self.size = CGSizeMake(count * (PAGE_DOT_SIZE.width + HORIZONTAL_DOT_PADDING) -
                          (PAGE_DOT_SIZE.width * .5),
                          PAGE_DOT_SIZE.height);
}

- (void)adjustCurrentDotWithIndex:(NSUInteger)index
{
   NSAssert(index < _pageDotArray.count, @"page index out of bounds");

   _currentPageDot.alpha = .5;
   _currentPageDot = _pageDotArray[index];
   _currentPageDot.alpha = 5.;
}

- (void)adjustLabelWithIndex:(NSUInteger)index
{
   _currentPageLabel.text = [NSString stringWithFormat:@"%@   /   %@",
                             @(index + 1).stringValue,
                             @(_totalPages).stringValue];
}

- (void)setCurrentPageIndicatorWithIndex:(NSUInteger)index
{
   switch (_type)
   {
      case e_CURRENT_PAGE_INDICATOR_DOTS:
         [self adjustCurrentDotWithIndex:index];
         break;
      case e_CUURENT_PAGE_INDICATOR_FRACTION:
         [self adjustLabelWithIndex:index];
         break;
      default:
         NSLog(@"Unsupported type: %u", (unsigned)_type);
         break;
   }
}

@end
