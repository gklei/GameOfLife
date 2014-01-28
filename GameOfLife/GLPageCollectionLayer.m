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
#define PAGE_HORIZONTAL_OFFSET CGRectGetWidth([UIScreen mainScreen].bounds)

@interface GLPageCollectionLayer()
{
   GLUITextButton *_primaryButton;
   GLUITextButton *_secondaryButton;

   GLMenuLayer *_pageContainter;
   GLPageLayer *_currentPage;
   GLPageLayer *_previousPage;

   ActionBlock _nextPageActionBlock;
   ActionBlock _previousPageActionBlock;

   ActionBlock _primaryButtonPreCompletionBlock;
   ActionBlock _secondaryButtonPreCompletionBlock;
}
@end

@implementation GLPageCollectionLayer

#pragma mark - Init Methods
- (id)initWithSize:(CGSize)size
       anchorPoint:(CGPoint)anchorPoint
    pageCollection:(GLPageCollection *)pageCollection
{
   if (self = [super initWithSize:size
                      anchorPoint:anchorPoint])
   {
      _pageCollection = (pageCollection)? pageCollection : [GLPageCollection new];
      _currentPage = _pageCollection.firstPage;

      [self setupVariables];
      [self setupNavigationButtons];

      [self setPageSizesAndPositions];
      [self setupPageContainer];
      [self addPagesToContainer];

   }
   return self;
}

- (id)initWithSize:(CGSize)size
    pageCollection:(GLPageCollection *)pageCollection
{
   return [self initWithSize:size
                 anchorPoint:CGPointMake(0, 1)
              pageCollection:pageCollection];
}

#pragma mark - Setup Methods
- (void)setupVariables
{
   SKAction *nextPageAnimation = [SKAction moveByX:-PAGE_HORIZONTAL_OFFSET y:0 duration:.2];
   SKAction *previousPageAnimation = [SKAction moveByX:PAGE_HORIZONTAL_OFFSET y:0 duration:.2];

   nextPageAnimation.timingMode = SKActionTimingEaseInEaseOut;
   previousPageAnimation.timingMode = SKActionTimingEaseInEaseOut;

   ActionBlock nextPageBlock =
   ^(NSTimeInterval interval)
   {
      if (_currentPage == _pageCollection.lastPage)
         return;

      [_pageContainter runAction:nextPageAnimation
                      completion:^
      {
         [self postPageMovementWork];
      }];
      _previousPage = _currentPage;
      _currentPage = [_pageCollection pageAtIndex:([_pageCollection indexOfPage:_currentPage] + 1)];
      _currentPage.hidden = NO;
   };

   ActionBlock previousPageBlock =
   ^(NSTimeInterval interval)
   {
      if (_currentPage == _pageCollection.firstPage)
         return;

      [_pageContainter runAction:previousPageAnimation
                      completion:^
       {
          [self postPageMovementWork];
       }];
      _previousPage = _currentPage;
      _currentPage = [_pageCollection pageAtIndex:([_pageCollection indexOfPage:_currentPage] - 1)];
      _currentPage.hidden = NO;
   };

   ActionBlock primaryButtonCompletionBlock =
   ^(NSTimeInterval interval)
   {
      if (_preDismissalAction)
         [self runAction:_preDismissalAction
              completion:^
         {
            [self resetPagePositionsAndExecuteBlock:_primaryButtonCompletionBlock];
         }];
      else
         [self resetPagePositionsAndExecuteBlock:_primaryButtonCompletionBlock];
   };

   ActionBlock secondaryButtonCompletionBlock =
   ^(NSTimeInterval interval)
   {
      if (_preDismissalAction)
         [self runAction:_preDismissalAction
              completion:^
          {
             [self resetPagePositionsAndExecuteBlock:_secondaryButtonCompletionBlock];
          }];
      else
         [self resetPagePositionsAndExecuteBlock:_secondaryButtonCompletionBlock];
   };

   _nextPageActionBlock = nextPageBlock;
   _previousPageActionBlock = previousPageBlock;
   _primaryButtonPreCompletionBlock = primaryButtonCompletionBlock;
   _secondaryButtonPreCompletionBlock = secondaryButtonCompletionBlock;
}

#pragma mark - Navigation Button Setup and Helper Methods
- (void)setupNavigationButtons
{
   _primaryButton = [GLUITextButton textButtonWithTitle:(_pageCollection.pages.count > 1)? @"NEXT" : @"OK"];
   _secondaryButton = [GLUITextButton textButtonWithTitle:@"CANCEL"];

   _primaryButton.actionBlock = _nextPageActionBlock;
   _secondaryButton.actionBlock = _secondaryButtonPreCompletionBlock;

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

- (void)setButtonTitlesAndBlocksForCurrentPage
{
   if (_currentPage == _pageCollection.firstPage)
   {
      _primaryButton.buttonTitle = @"NEXT";
      _secondaryButton.buttonTitle = @"CANCEL";

      _primaryButton.actionBlock = _nextPageActionBlock;
      _secondaryButton.actionBlock = _secondaryButtonPreCompletionBlock;
   }
   else if (_currentPage == _pageCollection.lastPage)
   {
      _primaryButton.buttonTitle = @"OK";
      _secondaryButton.buttonTitle = @"BACK";

      _primaryButton.actionBlock = _primaryButtonPreCompletionBlock;
      _secondaryButton.actionBlock = _previousPageActionBlock;
   }
   else
   {
      _primaryButton.buttonTitle = @"NEXT";
      _secondaryButton.buttonTitle = @"BACK";

      _primaryButton.actionBlock = _nextPageActionBlock;
      _secondaryButton.actionBlock = _previousPageActionBlock;
   }
}

#pragma mark - Page Setup and Helper Methods
- (void)setPageSizesAndPositions
{
   NSAssert(self.size.height - PAGE_NAVIGATION_AREA_HEIGHT > _primaryButton.controlHeight,
            @"Page collection layer size not large enough for navigation buttons");

   CGPoint nextPagePosition = CGPointZero;
   for (GLPageLayer *page in _pageCollection.pages)
   {
      page.size = CGSizeMake(self.size.width,
                             self.size.height - PAGE_NAVIGATION_AREA_HEIGHT);

      page.position = nextPagePosition;
      nextPagePosition = CGPointMake(page.position.x + PAGE_HORIZONTAL_OFFSET,
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

- (void)resetPagePositionsAndCurrentPage
{
   self.hidden = YES;
   _pageContainter.position = CGPointZero;
   _currentPage = _pageCollection.firstPage;
   [self setButtonTitlesAndBlocksForCurrentPage];
}

- (void)postPageMovementWork
{
   [self setButtonTitlesAndBlocksForCurrentPage];
   _previousPage.hidden = YES;
}

- (void)resetPagePositionsAndExecuteBlock:(PageCollectionLayerCompletionBlock)block
{
   [self resetPagePositionsAndCurrentPage];
   if (block) block();
}

- (void)addPagesToContainer
{
   for (GLPageLayer *page in _pageCollection.pages)
      [_pageContainter addChild:page];

   _pageCollection.firstPage.hidden = NO;
}

#pragma mark - Overridden Methods
- (void)removeFromParent
{
   [self resetPagePositionsAndCurrentPage];
   [super removeFromParent];
}

@end