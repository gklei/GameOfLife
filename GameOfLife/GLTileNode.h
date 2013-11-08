//
//  GLTileNode.h
//  GameOfLife
//
//  Created by Gregory Klein on 11/7/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "UIColor+Crayola.h"

@interface GLTileNode : SKSpriteNode

+ (id)tileWithRect:(CGRect)rect;
- (void)setIsLiving:(BOOL)living;

@property (nonatomic, assign, setter = setIsLiving:) BOOL isLiving;
@property (nonatomic, assign) float birthingDuration;
@property (nonatomic, assign) float dyingDuration;
@property (nonatomic, assign) CrayolaColorName liveColorName;
@property (nonatomic, assign) CrayolaColorName deadColorName;

@end
