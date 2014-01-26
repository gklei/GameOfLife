//
//  GLPageCollectionLayer.h
//  GameOfLife
//
//  Created by Gregory Klein on 1/25/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLMenuLayer.h"

typedef void (^PrimaryButtonActionBlock)();
typedef void (^SecondaryButtonActionBlock)();

@class GLPageCollection;
@interface GLPageCollectionLayer : GLMenuLayer

@property (nonatomic, strong) GLPageCollection *pageCollection;
@property (nonatomic, copy) PrimaryButtonActionBlock primaryButtonActionBlock;
@property (nonatomic, copy) SecondaryButtonActionBlock secondaryButtonActionBlock;

- (id)initWithSize:(CGSize)size
       anchorPoint:(CGPoint)anchorPoint
    pageCollection:(GLPageCollection *)pageCollection;

- (id)initWithSize:(CGSize)size
    pageCollection:(GLPageCollection *)pageCollection;
@end
