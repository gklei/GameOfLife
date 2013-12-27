//
//  GLColorSelectionLayer.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/22/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLColorSelectionLayer.h"
#import "GLColorGrid.h"

@implementation GLColorSelectionLayer

- (id)initWithSize:(CGSize)size
       anchorPoint:(CGPoint)anchorPoint
{
   if (self = [super initWithSize:size
                      anchorPoint:anchorPoint])
   {
      [self setupTitleLabel];
      [self setupColorGrid];
   }
   return self;
}

- (void)setupTitleLabel
{
   SKLabelNode *titleLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedExtraBold"];

   titleLabel.text = @"C  O  L  O  R  S";
   titleLabel.colorBlendFactor = 1.0;
   titleLabel.color = [SKColor whiteColor];
   titleLabel.alpha = 1;
   titleLabel.fontSize = HEADING_FONT_SIZE;
   titleLabel.position = CGPointMake(self.size.width * 0.5,
                                     -(HEADING_FONT_SIZE + TOP_PADDING));
   [self addChild:titleLabel];
}

- (void)setupColorGrid
{
   _colorGrid = [[GLColorGrid alloc] initWithSize:CGSizeMake(5, 5)];
   _colorGrid.position = CGPointMake(44, -self.size.height + 70);
   [self addChild:_colorGrid];
}

@end
