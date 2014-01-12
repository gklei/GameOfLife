//
//  GLAlertLayer.h
//  GameOfLife
//
//  Created by Gregory Klein on 1/9/14. (made in Mexico)
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLMenuLayer.h"

@interface GLAlertLayer : GLMenuLayer

- (id)initWithHeader:(NSString *)header
                body:(NSString *)body;

@property (nonatomic, readonly) NSString *headerText;
@property (nonatomic, readonly) NSString *bodyText;

- (void)addHeaderText:(NSString *)headerText;
- (void)addBodyText:(NSString *)bodyText;

@end
