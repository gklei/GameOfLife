//
//  GLMenuLayer.h
//  GameOfLife
//
//  Created by Gregory Klein on 12/22/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

#define TOP_PADDING 18
#define HEADING_FONT_SIZE 16
#define BODY_FONT_SIZE 14
#define NEW_LINE_HEIGHT -10

@interface GLMenuLayer : SKSpriteNode

- (id)initWithSize:(CGSize)size
       anchorPoint:(CGPoint)anchorPoint;

@end
