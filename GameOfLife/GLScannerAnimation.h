//
//  GLScannerAnimation.h
//  GameOfLife
//
//  Created by Gregory Klein on 1/28/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class GLScannerAnimation;
@protocol GLScannerDelegate <NSObject>
   - (void)scannerAnimation:(GLScannerAnimation *)animation
        scannedOverDistance:(CGFloat)distance;
@end

@interface GLScannerAnimation : SKSpriteNode

@property (nonatomic, assign) NSTimeInterval duration;
@property (nonatomic, assign) CGFloat startY;
@property (nonatomic, assign) CGFloat endY;

@property (nonatomic, strong) NSObject<GLScannerDelegate> *scannerDelegate;
@property (nonatomic, assign) CGFloat updateIncrement;

- (id)initWithScannerDelegate:(NSObject<GLScannerDelegate> *)delegate;

- (id)initWithSize:(CGSize)size;

- (id)initWithSize:(CGSize)size
       anchorPoint:(CGPoint)anchorPoint
            startY:(CGFloat)start
              endY:(CGFloat)end;

- (void)runAnimationOnParent:(SKNode *)parent withCompletionBlock:(void (^)())completionBlock;
@end
