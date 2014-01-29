//
//  GLScannerAnimation.h
//  GameOfLife
//
//  Created by Gregory Klein on 1/28/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@interface GLScannerAnimation : SKSpriteNode

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) CGFloat startY;
@property (nonatomic, assign) CGFloat endY;

- (id)initWithSize:(CGSize)size;

- (id)initWithSize:(CGSize)size
       anchorPoint:(CGPoint)anchorPoint
            startY:(CGFloat)start
              endY:(CGFloat)end;

- (void)runAnimationOnParent:(SKNode *)parent;
@end
