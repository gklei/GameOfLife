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

@interface GLTileNode : GLUIActionButton

@property (nonatomic, assign, setter = setIsLiving:) BOOL isLiving;
@property (nonatomic, assign) float birthingDuration;
@property (nonatomic, assign) float dyingDuration;
@property (nonatomic, assign, setter = setLiveRotation:) double liveRotation;
@property (nonatomic, assign, setter = setDeadRotation:) double deadRotation;

@property (nonatomic, assign) CrayolaColorName deadColorName;

@property (nonatomic, retain) SKTexture * liveTexture;
@property (nonatomic, retain) SKTexture * deadTexture;

@property (nonatomic, assign) float boardMaxDistance; // should be global, not per tile
@property (nonatomic, assign) float maxColorDistance;
@property (nonatomic, assign) CGPoint colorCenter;

+ (id)tileWithTexture:(SKTexture *)texture rect:(CGRect)rect andRotation:(double)rotation;

- (void)clearTile;
- (void)updateTextures;
- (void)clearActionsAndRestore;

@end
