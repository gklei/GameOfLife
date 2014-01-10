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
   // the header and body will be an array of label nodes
   NSMutableArray *_header;
   NSMutableArray *_body;
}
@end

@implementation GLAlertLayer

- (id)initWithSize:(CGSize)size
       anchorPoint:(CGPoint)anchorPoint
{
   if (self = [super initWithSize:size
                      anchorPoint:anchorPoint])
   {
      [self setupHeader];
      [self setupBody];
   }
   return self;
}

- (void)setupHeader
{
   _header = [NSMutableArray new];
}

- (void)setupBody
{
   _body = [NSMutableArray new];

}

- (void)setHeaderText:(NSString *)headerText
{
   _headerText = headerText;
}

- (void)setBodyText:(NSString *)bodyText
{
   _bodyText = bodyText;
}

- (SKLabelNode *)bodyLabelNode
{
   SKLabelNode *bodyLabelNode = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedMedium"];
   bodyLabelNode.colorBlendFactor = 1.0;
   bodyLabelNode.color = [SKColor whiteColor];
   bodyLabelNode.alpha = 5;
   bodyLabelNode.fontSize = BODY_FONT_SIZE;

   return bodyLabelNode;
}

- (SKLabelNode *)headerLabelNode
{
   SKLabelNode *headerLabelNode = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedExtraBold"];
   headerLabelNode.colorBlendFactor = 1.0;
   headerLabelNode.color = [SKColor whiteColor];
   headerLabelNode.alpha = 5;
   headerLabelNode.fontSize = BODY_FONT_SIZE;

   return headerLabelNode;
}

@end
