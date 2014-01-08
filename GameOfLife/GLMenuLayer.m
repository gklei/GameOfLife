//
//  GLMenuLayer.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/22/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLMenuLayer.h"
#import "GLUIButton.h"

@implementation GLMenuLayer

- (id)initWithSize:(CGSize)size
       anchorPoint:(CGPoint)anchorPoint
{
   if (self = [super init])
   {
      self.size = size;
      self.anchorPoint = anchorPoint;
   }
   return self;
}

- (void)setHidden:(BOOL)hidden
{
   for (GLUIButton *button in self.children)
      button.hidden = hidden;
   
   super.hidden = hidden;
}

@end
