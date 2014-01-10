//
//  GLAlertLayer.h
//  GameOfLife
//
//  Created by Gregory Klein on 1/9/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLMenuLayer.h"

@interface GLAlertLayer : GLMenuLayer

@property (nonatomic, strong) SKLabelNode *header;
@property (nonatomic, strong) SKLabelNode *body;

@end
