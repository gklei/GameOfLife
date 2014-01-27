//
//  GLAlertLayer.h
//  GameOfLife
//
//  Created by Gregory Klein on 1/9/14. (made in Mexico)
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLPageLayer.h"

@interface GLAlertLayer : GLPageLayer

@property (nonatomic, readonly) BOOL animating;
@property (nonatomic, assign) BOOL animatesIn;

+ (void)debugAlert:(NSString *)body withParent:(SKNode *)parent andDuration:(NSTimeInterval)seconds;

+ (id)alertWithHeader:(NSString *)header
                 body:(NSString *)body
             position:(CGPoint)position
            andParent:(SKNode *)parent;

- (id)initWithHeader:(NSString *)header
                body:(NSString *)body;

- (void)showWithParent:(SKNode *)parent;
- (void)showWithParent:(SKNode *)parent andPosition:(CGPoint)position;
- (void)hide;

@end