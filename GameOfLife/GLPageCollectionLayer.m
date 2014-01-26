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
      [self setPageSizes];
      [self addPagesToLayer];

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
- (void)setPageSizes
{
   NSAssert(self.size.height - PAGE_NAVIGATION_AREA_HEIGHT > 0,
            @"Page collection layer size not large enough for navigation buttons");
   
   for (GLPageLayer *page in _pageCollection.pages)
      page.size = CGSizeMake(self.size.width,
                             self.size.height - PAGE_NAVIGATION_AREA_HEIGHT);
}

- (void)addPagesToLayer
{
   for (GLPageLayer *page in _pageCollection.pages)
   {
      page.hidden = NO;
//      page.alpha = .8;
//      page.color = [SKColor redColor];
      [self addChild:page];
   }
}

- (void)setupNavigationButtons
{
   _primaryButton = [GLUITextButton textButtonWithTitle:@"OK"];
   _secondaryButton = [GLUITextButton textButtonWithTitle:@"CANCEL"];

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
