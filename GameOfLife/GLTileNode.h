//
//  GLTileNode.h
//  GameOfLife
//
//  Created by Gregory Klein on 11/7/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "UIColor+Crayola.h"

@protocol CurrentColorDelegate <NSObject>
- (SKColor *)currentColor;
@end

@interface GLTileNode : SKSpriteNode

+ (id)tileWithRect:(CGRect)rect;
- (void)updateLivingAndColor:(BOOL)living;
- (void)updateColor;
- (void)clearTile;

@property (nonatomic, assign, setter = setIsLiving:) BOOL isLiving;
@property (nonatomic, assign) float birthingDuration;
@property (nonatomic, assign) float dyingDuration;
@property (nonatomic, assign) CrayolaColorName liveColorName;
@property (nonatomic, assign) CrayolaColorName deadColorName;

@property (nonatomic, assign) float boardMaxDistance; // should be global, not per tile

@property (nonatomic, assign) float maxColorDistance;
@property (nonatomic, assign) CGPoint colorCenter;

@property (strong, nonatomic) id<CurrentColorDelegate> delegate;

@end
