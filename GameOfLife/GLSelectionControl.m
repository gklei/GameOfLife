//
//  GLSelectionControl.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/18/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLSelectionControl.h"
#import "GLUIButton.h"

@interface GLSelectionControl()
{
   NSMutableArray *_selectableItems;
}
@end

@implementation GLSelectionControl

- (id)initWithSelectableItems:(NSArray *)items
{
   for (NSObject *item in items)
      NSAssert([item isKindOfClass:[GLUIButton class]], @"GLSelectionControl must use GLUIButtons");
   
   if (self = [super init])
   {
      _selectableItems = [NSMutableArray arrayWithArray:items];
      self.glowEnabled = NO;
   }
   return self;
}

@end
