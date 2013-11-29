//
//  GLGrid.h
//  GameOfLife
//
//  Created by Gregory Klein on 11/29/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef struct {
   int rows;
   int columns;
} GridDimensions;

@interface GLGrid : NSObject

@property (nonatomic, assign) GridDimensions dimensions;

@end
