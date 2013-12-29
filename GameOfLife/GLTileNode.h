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

@class GLTileNode;
@protocol GLTileColorDelegate <NSObject>
   - (SKColor *)currentTileColor;
   - (SKColor *)currentTileColorForTile:(GLTileNode *)tile;
@end

@interface GLTileNode : GLUIActionButton

@property (nonatomic, assign, setter = setIsLiving:) BOOL isLiving;
@property (nonatomic, assign) float birthingDuration;
@property (nonatomic, assign) float dyingDuration;

@property (nonatomic, assign) CrayolaColorName liveColorName;
@property (nonatomic, assign) CrayolaColorName deadColorName;

@property (nonatomic, retain) SKColor *liveColor;
@property (nonatomic, retain) SKColor *deadColor;
@property (nonatomic, retain) SKColor *originalColor;

@property (nonatomic, retain) SKTexture * liveTexture;
@property (nonatomic, retain) SKTexture * deadTexture;

@property (nonatomic, assign) float boardMaxDistance; // should be global, not per tile
@property (nonatomic, assign) float maxColorDistance;
@property (nonatomic, assign) CGPoint colorCenter;

@property (strong, nonatomic) id<GLTileColorDelegate> tileColorDelegate;

//+ (id)tileWithRect:(CGRect)rect;
//+ (id)tileWithImageNamed:(NSString *)imageName rect:(CGRect)rect;
+ (id)tileWithTexture:(SKTexture *)texture rect:(CGRect)rect;

- (void)updateLivingAndColor:(BOOL)living;
- (SKColor *)getLivingTileColor;
- (void)updateColor;
- (void)clearTile;

@end
