//
//  GLAlertLayer.m
//  GameOfLife
//
//  Created by Gregory Klein on 1/9/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLAlertLayer.h"

@interface GLAlertLayer()
{
}
@end

@implementation GLAlertLayer

- (id)initWithSize:(CGSize)size
       anchorPoint:(CGPoint)anchorPoint
{
   if (self = [super initWithSize:size
                      anchorPoint:anchorPoint])
   {
      _header = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedExtraBold"];
      _body = [SKLabelNode labelNodeWithFontNamed:@"Futura-Medium"];
   }
   return self;
}

@end
