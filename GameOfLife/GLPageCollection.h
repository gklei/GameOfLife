//
//  GLPageCollection.h
//  GameOfLife
//
//  Created by Gregory Klein on 1/25/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GLPageLayer;
@interface GLPageCollection : NSObject

@property (nonatomic, strong) NSArray *pages;

+ (instancetype)pageCollectionWithPages:(NSArray *)pages;

- (void)addPage:(GLPageLayer *)page;
- (GLPageLayer *)firstPage;
- (GLPageLayer *)lastPage;

- (GLPageLayer *)pageAtIndex:(NSInteger)index;
- (NSInteger)indexOfPage:(GLPageLayer *)page;

- (void)removePage:(GLPageLayer *)page;
- (void)removeFirstPage;
- (void)removeLastPage;
@end
