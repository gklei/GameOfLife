//
//  GLAlertLayer.m
//  GameOfLife
//
//  Created by Gregory Klein on 1/9/14. (made in Mexico)
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLAlertLayer.h"
#import "NSString+Additions.h"
#import "UIColor+Crayola.h"

#define DEFAULT_ALERT_SIZE CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 150);
#define DEFAULT_ALERT_ANCHOR_POINT CGPointMake(0, 1);
#define SIDE_MARGIN_SPACE 10

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
      // default color and alpha
      self.color = [SKColor crayolaBlackCoralPearlColor];
      self.alpha = .8;
      
      [self setupHeader];
      [self setupBody];
   }
   return self;
}

- (id)initWithHeader:(NSString *)header
                body:(NSString *)body
{
   // cannot pass in defines for some reason!
   CGSize defaultSize = DEFAULT_ALERT_SIZE;
   CGPoint defaultAnchorPoint = DEFAULT_ALERT_ANCHOR_POINT;
   if (self = [self initWithSize:defaultSize
                      anchorPoint:defaultAnchorPoint])
   {
      self.headerText = header;
      self.bodyText = body;
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

#pragma mark - Instance Methods
- (void)addHeaderText:(NSString *)headerText
{
}

- (void)addBodyText:(NSString *)bodyText
{
}

#pragma mark - Setter Methods
- (void)setHeaderText:(NSString *)headerText
{
   if (!headerText)
   {
      _headerText = @"";
      return;
   }

   _headerText = [NSString futurizedString:headerText];
   [self addHeaderTextToLayer:_headerText];
   [self dynamicallySetSize];
}

- (void)setBodyText:(NSString *)bodyText
{
   if (!bodyText)
   {
      _bodyText = @"";
      return;
   }

   _bodyText = [NSString futurizedString:bodyText];
   [self addBodyTextToLayer:_bodyText];
   [self dynamicallySetSize];
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
   // separate words by two spaces because the string is FUTURIZED
   NSArray *headerTextWords = [headerText componentsSeparatedByString:@"  "];
   int lineIndex = 0;

   ((SKLabelNode *)[_header objectAtIndex:lineIndex]).text = [headerTextWords objectAtIndex:0];

   // initial check to see if the first word in the header text is too large to display
   if (![self labelFitsInFrame:[_header objectAtIndex:lineIndex]])
   {
      NSLog(@"GLAlertLayer: cannot set header text becuase the word '%@' will not fit",
            [headerTextWords objectAtIndex:0]);
      return;
   }

   for (NSString *word in headerTextWords)
   {
      if ([word isEqual:headerTextWords.firstObject]) continue;

      NSString *currentStr = ((SKLabelNode *)[_header objectAtIndex:lineIndex]).text;
      NSString *nextStr = [currentStr stringByAppendingString:[NSString stringWithFormat:@"  %@", word]];
      ((SKLabelNode *)[_header objectAtIndex:lineIndex]).text = nextStr;

      if (![self labelFitsInFrame:[_header objectAtIndex:lineIndex]])
      {
         ((SKLabelNode *)[_header objectAtIndex:lineIndex]).text = currentStr;
         [_header addObject:[self headerLabelNode]];
         ((SKLabelNode *)[_header objectAtIndex:++lineIndex]).text = word;
      }
   }

   [self setPositionsForLinesInHeader];
}

- (void)addBodyTextToLayer:(NSString *)bodyText
{
   // separate words by two spaces because the string is FUTURIZED
   NSArray *bodyTextWords = [bodyText componentsSeparatedByString:@"  "];
   int lineIndex = 0;

   ((SKLabelNode *)[_body objectAtIndex:lineIndex]).text = [bodyTextWords objectAtIndex:0];

   // initial check to see if the first word in the header text is too large to display
   if (![self labelFitsInFrame:[_body objectAtIndex:lineIndex]])
   {
      NSLog(@"GLAlertLayer: cannot set header text becuase the word '%@' will not fit",
            [bodyTextWords objectAtIndex:0]);
      return;
   }

   for (NSString *word in bodyTextWords)
   {
      if ([word isEqual:bodyTextWords.firstObject]) continue;

      NSString *currentStr = ((SKLabelNode *)[_body objectAtIndex:lineIndex]).text;
      NSString *nextStr = [currentStr stringByAppendingString:[NSString stringWithFormat:@"  %@", word]];
      ((SKLabelNode *)[_body objectAtIndex:lineIndex]).text = nextStr;

      if (![self labelFitsInFrame:[_body objectAtIndex:lineIndex]])
      {
         ((SKLabelNode *)[_body objectAtIndex:lineIndex]).text = currentStr;
         [_body addObject:[self bodyLabelNode]];
         ((SKLabelNode *)[_body objectAtIndex:++lineIndex]).text = word;
      }
   }

   [self setPositionsForLinesInBody];
}

- (void)setPositionsForLinesInHeader
{
   CGPoint headerLinePosition = CGPointMake(self.size.width * .5,
                                            -(TOP_PADDING + HEADING_FONT_SIZE * .5));
   for (SKLabelNode *headerLine in _header)
   {
      headerLine.position = headerLinePosition;
      [self addChild:headerLine];

      if (![headerLine isEqual:_header.lastObject])
         headerLinePosition = CGPointMake(self.size.width * .5,
                                          headerLine.position.y - HEADING_FONT_SIZE);
   }
}

- (void)setPositionsForLinesInBody
{
   CGFloat yValue = ((SKLabelNode *)_header.lastObject).position.y - HEADING_FONT_SIZE * 2;
   CGPoint bodyLinePosition = CGPointMake(SIDE_MARGIN_SPACE, yValue);
   for (SKLabelNode *bodyLine in _body)
   {
      bodyLine.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
      bodyLine.position = bodyLinePosition;
      [self addChild:bodyLine];

      if (![bodyLine isEqual:_body.lastObject])
         bodyLinePosition = CGPointMake(SIDE_MARGIN_SPACE,
                                        bodyLine.position.y - BODY_FONT_SIZE * 1.25);
   }
}

- (void)dynamicallySetSize
{
   CGFloat height = fabs((((SKLabelNode *)_header.firstObject).position.y +
                          (_header.firstObject ? (HEADING_FONT_SIZE * .5) : 0)) -
                         (((SKLabelNode *)_body.lastObject).position.y) +
                         (_body.lastObject ? (BODY_FONT_SIZE * .5) : 0)) +
                         TOP_PADDING * 1.5;

   self.size = CGSizeMake(self.size.width, height);
}

- (BOOL)labelFitsInFrame:(SKLabelNode *)label
{
   return label.calculateAccumulatedFrame.size.width <= (self.size.width - SIDE_MARGIN_SPACE);
}

@end
