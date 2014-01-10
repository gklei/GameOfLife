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
   SKLabelNode *_header;

   // the body is an array of SKLabelNodes
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

      [self addChild:_header];
   }
   return self;
}

- (void)setupHeader
{
   _header = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedExtraBold"];
   _header.colorBlendFactor = 1.0;
   _header.color = [SKColor whiteColor];
   _header.alpha = 5;
   _header.fontSize = HEADING_FONT_SIZE;
   _header.position = CGPointMake(self.size.width * 0.5,
                                  -(HEADING_FONT_SIZE + TOP_PADDING));
}

- (void)setupBody
{
   _body = [NSMutableArray new];
}

- (NSString *)futurizedHeaderString:(NSString *)string
{
   if (string == nil)
      return nil;

   NSMutableString *futurizedString = [NSMutableString string];

   for (int i = 0; i < string.length - 1; ++i)
      [futurizedString appendFormat:@"%c ", [string characterAtIndex:i]];

   int lastASCII = [string characterAtIndex:string.length - 1];
   [futurizedString appendFormat:@"%c", lastASCII];

   return futurizedString;
}

- (void)setHeaderText:(NSString *)headerText
{
   _headerText = headerText;
   _header.text = [self futurizedHeaderString:_headerText];
}

@end
