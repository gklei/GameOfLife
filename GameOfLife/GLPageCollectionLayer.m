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

#define PAGE_NAVIGATION_AREA_HEIGHT 30

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
      [self addChild:page];
   }
}

- (void)setupNavigationButtons
{
   _primaryButton = [GLUITextButton textButtonWithTitle:@"OK"];
   _secondaryButton = [GLUITextButton textButtonWithTitle:@"CANCEL"];
}

@end
