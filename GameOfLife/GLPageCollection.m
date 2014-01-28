//
//  GLPageCollection.m
//  GameOfLife
//
//  Created by Gregory Klein on 1/25/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLPageCollection.h"
#import "GLPageLayer.h"

@interface GLPageCollection()
{
   NSMutableArray *_pages;
}
@end

@implementation GLPageCollection

- (id)init
{
   if (self = [super init])
   {
      _pages = [NSMutableArray new];
   }
   return self;
}

+ (instancetype)pageCollectionWithPages:(NSArray *)pages
{
   GLPageCollection *pageCollection = [[GLPageCollection alloc] init];

// TODO: need to figure out a way to assert that objects passed in INHERIT from GLPageLayer
//   for (GLPageLayer *page in pages)
//      NSAssert(page.class == [GLPageLayer class],
//               @"must instantiate GLPageCollection with GLPageLayer objects");

   if (pages) pageCollection.pages = pages;
   return pageCollection;
}

- (void)addPage:(GLPageLayer *)page;
{
   [_pages addObject:page];
}

- (GLPageLayer *)firstPage
{
   return _pages.firstObject;
}

- (GLPageLayer *)lastPage
{
   return _pages.lastObject;
}

- (GLPageLayer *)pageAtIndex:(NSInteger)index
{
   return [_pages objectAtIndex:index];
}

- (NSInteger)indexOfPage:(GLPageLayer *)page
{
   return [_pages indexOfObject:page];
}

- (void)removePage:(GLPageLayer *)page
{
   [_pages removeObject:page];
}

- (void)removeFirstPage
{
   if (_pages.count) [_pages removeObjectAtIndex:0];
}

- (void)removeLastPage
{
   [_pages removeLastObject];
}

@end
