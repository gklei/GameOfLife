//
//  GLTileNode.h
//  GameOfLife
//
//  Created by Gregory Klein on 11/7/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GLTileNode : SKSpriteNode

+ (id)tileWithRect:(CGRect)rect;

@property (nonatomic, assign, setter = setIsLiving:) BOOL isLiving;

@end
