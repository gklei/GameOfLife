//
//  GLColorSelectionLayer.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/22/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLColorSelectionLayer.h"

@implementation GLColorSelectionLayer

- (id)initWithSize:(CGSize)size
       anchorPoint:(CGPoint)anchorPoint
{
   if (self = [super initWithSize:size
                      anchorPoint:anchorPoint])
   {
      [self setupTitleLabel];
   }
   return self;
}

- (void)setupTitleLabel
{
   SKLabelNode *titleLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-Medium"];

   titleLabel.text = @"S E L E C T  A  C O L O R";
   titleLabel.colorBlendFactor = 1.0;
   titleLabel.color = [SKColor whiteColor];
   titleLabel.alpha = 1;
   titleLabel.fontSize = HEADING_FONT_SIZE;
   titleLabel.position = CGPointMake(self.size.width * 0.5,
                                        -(HEADING_FONT_SIZE + TOP_PADDING));
   [self addChild:titleLabel];
}

@end
