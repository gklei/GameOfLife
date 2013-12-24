//
//  GLGrid.h
//  GameOfLife
//
//  Created by Gregory Klein on 11/29/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

typedef struct {
   int rows;
   int columns;
} GridDimensions;

@class GLTileNode;

@interface GLGrid : SKNode

@property (nonatomic, readonly) NSUInteger generationCount;
@property (nonatomic, assign) GridDimensions dimensions;
@property (nonatomic, strong) NSArray *tiles;
@property (nonatomic, readonly, getter = isInContinuousLoop) BOOL inContinuousLoop;
@property (nonatomic, readwrite) BOOL considersContinuousBiLoops;

- (id)initWithSize:(CGSize)size;
- (GLTileNode *)tileAtTouch:(UITouch *)touch;
- (void)updateNextGeneration;
- (void)storeGridState;
- (void)restoreGrid;
- (void)clearGrid;
- (void)toggleRunning:(BOOL)starting;

- (void)setCurrentColor:(SKColor *)color;

- (void)setTilesBirthingDuration:(float)bDuration
                   dyingDuration:(float)dDuration;

- (BOOL)currentStateIsRunnable;

@end
