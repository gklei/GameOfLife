//
//  GLGrid.h
//  GameOfLife
//
//  Created by Gregory Klein on 11/29/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GLScannerAnimation.h"
#import "UIColor+Crayola.h"

typedef struct {
   int rows;
   int columns;
} GridDimensions;


@class GLTileNode;


@interface GLGrid : SKNode <GLScannerDelegate>

@property (nonatomic, readonly) unsigned long long generationCount;
@property (nonatomic, assign) GridDimensions dimensions;
@property (nonatomic, strong) NSArray *tiles;
@property (nonatomic, readwrite, getter = isInContinuousLoop) BOOL inContinuousLoop;
@property (nonatomic, readwrite) BOOL considerDeeperLoops;
@property (nonatomic, readwrite) BOOL usesMultiColors;

- (id)initWithSize:(CGSize)size;

- (GLTileNode *)tileAtTouch:(UITouch *)touch;
- (void)updateNextGeneration;
- (void)storeGridState;
- (void)loadStoredTileStates;
- (void)loadLifeTileStates;
- (void)restoreGrid;
- (void)clearGrid;
- (void)toggleRunning:(BOOL)starting;

- (void)setTilesBirthingDuration:(float)bDuration
                   dyingDuration:(float)dDuration;

- (BOOL)currentStateIsRunnable;

- (void)setDeadImage:(NSString *)deadImageName;
- (void)setDeadRotation:(double)rotation;
- (void)setLiveImage:(NSString *)liveImageName;
- (void)setLiveRotation:(double)rotation;

- (BOOL)isCleared;
- (BOOL)startedWithLife;

- (void)toggleTileLiving:(GLTileNode *)tile;
- (void)scanImageDataForGameBoard:(NSDictionary *) imageData;
- (void)scanAnimationFinished;

- (void)setGridImageIndex:(NSUInteger)gridIndex;

- (NSString *)generateMetaData;

@end
