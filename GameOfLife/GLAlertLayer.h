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

- (id)initWithHeader:(NSString *)header
                body:(NSString *)body;

- (void)showWithParent:(SKNode *)parent;
- (void)hide;

@end