//
//  GLAlertLayer.m
//  GameOfLife
//
//  Created by Gregory Klein on 1/9/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLAlertLayer.h"
#import "NSString+Additions.h"

@interface GLAlertLayer()
{
   // the header and body will be an array of label nodes
   NSMutableArray *_header;
   NSMutableArray *_body;
}
@end

@implementation GLAlertLayer

#pragma mark - Init methods
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

#pragma mark - Setup Methods
- (void)setupHeader
{
   _header = [NSMutableArray new];
   [_header addObject:[self headerLabelNode]];
}

- (void)setupBody
{
   _body = [NSMutableArray new];
   [_body addObject:[self bodyLabelNode]];
}

#pragma mark - Setter Methods
- (void)setHeaderText:(NSString *)headerText
{
   _headerText = [NSString futurizedString:headerText];
   [self addHeaderTextToLayer:_headerText];
}

- (void)setBodyText:(NSString *)bodyText
{
   _bodyText = [NSString futurizedString:bodyText];
   [self addBodyTextToLayer:_bodyText];
}

#pragma mark - Helper Methods
- (SKLabelNode *)headerLabelNode
{
   SKLabelNode *headerLabelNode = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedExtraBold"];
   headerLabelNode.colorBlendFactor = 1.0;
   headerLabelNode.color = [SKColor whiteColor];
   headerLabelNode.alpha = 5;
   headerLabelNode.fontSize = HEADING_FONT_SIZE;

   return headerLabelNode;
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

- (void)addHeaderTextToLayer:(NSString *)headerText
{
}

- (void)addBodyTextToLayer:(NSString *)bodyText
{
}

@end
