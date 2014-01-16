//
//  GLTileNode.h
//  GameOfLife
//
//  Created by Gregory Klein on 11/7/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "UIColor+Crayola.h"
#import "GLUIActionButton.h"

// forward declarations
@class GLTileNode;


@protocol GLTileColorProvider <NSObject>

- (SKColor *)liveColorForNode:(GLTileNode *)node;
- (SKColor *)deadColorForNode:(GLTileNode *)node;

@end


@interface GLTileNode : GLUIActionButton

@property (nonatomic, assign) float birthingDuration;
@property (nonatomic, assign) float dyingDuration;
@property (nonatomic, assign, setter = setLiveRotation:) double liveRotation;
@property (nonatomic, assign, setter = setDeadRotation:) double deadRotation;

@property (nonatomic, retain, setter = setLiveTexture:) SKTexture * liveTexture;
@property (nonatomic, retain, setter = setDeadTexture:) SKTexture * deadTexture;

@property (nonatomic, readonly) NSUInteger generationCount;

@property (nonatomic, assign) id<GLTileColorProvider> colorProvider;

+ (id)tileWithTexture:(SKTexture *)texture rect:(CGRect)rect andRotation:(double)rotation;

- (BOOL)isLiving;
- (void)setIsLiving:(BOOL)living;
- (void)clearTile;
- (void)clearActionsAndRestore:(BOOL)resetGenerations;

@end
