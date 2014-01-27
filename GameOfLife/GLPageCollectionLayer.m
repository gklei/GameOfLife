//
//  GLPageCollectionLayer.m
//  GameOfLife
//
//  Created by Gregory Klein on 1/25/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLPageCollectionLayer.h"
#import "GLPageCollection.h"
#import "GLPageLayer.h"

#import "GLUITextButton.h"

#define PAGE_NAVIGATION_AREA_HEIGHT 50

@interface GLPageCollectionLayer()
{
   GLUITextButton *_primaryButton;
   GLUITextButton *_secondaryButton;

   GLMenuLayer *_pageContainter;
   GLPageLayer *_currentPage;

   ActionBlock _nextPageActionBlock;
   ActionBlock _previousPageActionBlock;

   CGFloat _pageHorizontalPadding;
}
@end

@implementation GLPageCollectionLayer

- (id)initWithSize:(CGSize)size
       anchorPoint:(CGPoint)anchorPoint
    pageCollection:(GLPageCollection *)pageCollection
{
   if (self = [super initWithSize:size anchorPoint:anchorPoint])
   {
      _pageCollection = (pageCollection)? pageCollection : [GLPageCollection new];
      _currentPage = _pageCollection.firstPage;

      [self setupVariables];

      [self setPageSizesAndPositions];
      [self setupPageContainer];
      [self addPagesToContainer];

      [self setupNavigationButtons];
   }
   return self;
}

- (id)initWithSize:(CGSize)size pageCollection:(GLPageCollection *)pageCollection
{
   if (self = [self initWithSize:size
                     anchorPoint:CGPointMake(0, 1)
                  pageCollection:pageCollection])
   {
   }
   return self;
}

#pragma mark - Helper Methods
- (void)setupVariables
{
   _pageHorizontalPadding = CGRectGetWidth([UIScreen mainScreen].bounds);

   SKAction *nextPageAnimation = [SKAction moveByX:-_pageHorizontalPadding y:0 duration:.2];
   SKAction *previousPageAnimation = [SKAction moveByX:_pageHorizontalPadding y:0 duration:.2];

   nextPageAnimation.timingMode = SKActionTimingEaseInEaseOut;
   previousPageAnimation.timingMode = SKActionTimingEaseInEaseOut;

   ActionBlock nextPageBlock =
   ^(NSTimeInterval interval)
   {
      if (_currentPage == _pageCollection.lastPage)
         return;

      [_pageContainter runAction:nextPageAnimation completion:^
      {
         if (_currentPage == _pageCollection.lastPage)
         {
            _primaryButton.buttonTitle = @"OK";
            _secondaryButton.buttonTitle = @"BACK";
         }
         else
         {
            _primaryButton.buttonTitle = @"NEXT";
            _secondaryButton.buttonTitle = (_currentPage == _pageCollection.firstPage)? @"CANCEL" : @"BACK";
         }
      }];
      _currentPage = [_pageCollection pageAtIndex:([_pageCollection indexOfPage:_currentPage] + 1)];
   };
   _nextPageActionBlock = nextPageBlock;

   ActionBlock prevPageBlock =
   ^(NSTimeInterval interval)
   {
      if (_currentPage == _pageCollection.firstPage)
         return;

      [_pageContainter runAction:previousPageAnimation
                      completion:^
       {
          if (_currentPage == _pageCollection.firstPage)
          {
             _primaryButton.buttonTitle = @"NEXT";
             _secondaryButton.buttonTitle = @"CANCEL";
          }
          else
          {
             _primaryButton.buttonTitle = (_currentPage == _pageCollection.lastPage)? @"OK" : @"NEXT";
             _secondaryButton.buttonTitle = @"BACK";
          }
       }];
      _currentPage = [_pageCollection pageAtIndex:([_pageCollection indexOfPage:_currentPage] - 1)];
   };
   _previousPageActionBlock = prevPageBlock;
}

- (void)setPageSizesAndPositions
{
   NSAssert(self.size.height - PAGE_NAVIGATION_AREA_HEIGHT > 0,
            @"Page collection layer size not large enough for navigation buttons");

   CGPoint nextPagePosition = CGPointZero;
   for (GLPageLayer *page in _pageCollection.pages)
   {
      page.size = CGSizeMake(self.size.width,
                             self.size.height - PAGE_NAVIGATION_AREA_HEIGHT);

      page.position = nextPagePosition;
      nextPagePosition = CGPointMake(page.position.x + _pageHorizontalPadding,
                                     page.position.y);
   }
}

- (void)setupPageContainer
{
   _pageContainter = [[GLMenuLayer alloc] initWithSize:CGSizeMake(_pageCollection.pages.count *
                                                                  _pageCollection.firstPage.size.width,
                                                                  _pageCollection.firstPage.size.height)
                                           anchorPoint:self.anchorPoint];
   [self addChild:_pageContainter];
}

- (void)addPagesToContainer
{
   for (GLPageLayer *page in _pageCollection.pages)
   {
//      page.alpha = .8;
//      page.color = [SKColor redColor];
      page.hidden = NO;
      [_pageContainter addChild:page];
   }
}

- (void)setupNavigationButtons
{
   _primaryButton = [GLUITextButton textButtonWithTitle:(_pageCollection.pages.count > 1)? @"NEXT" : @"OK"];
   _secondaryButton = [GLUITextButton textButtonWithTitle:@"CANCEL"];

   _primaryButton.actionBlock = _nextPageActionBlock;
   _secondaryButton.actionBlock = _previousPageActionBlock;

   [self setNavigationButtonPositions];

   [self addChild:_primaryButton];
   [self addChild:_secondaryButton];
}

- (void)setNavigationButtonPositions
{
   CGFloat primaryX = (self.size.width * .5) + (_primaryButton.size.width * .5) + 10;
   CGFloat secondaryX = (self.size.width * .5) - (_primaryButton.size.width * .5) - 10;
   CGFloat yPos = -self.size.height + (_primaryButton.size.height * .5);

   _primaryButton.position = CGPointMake(primaryX, yPos);
   _secondaryButton.position = CGPointMake(secondaryX, yPos);
}

@end
