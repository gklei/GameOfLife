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

@interface GLLabelCollection : NSObject

@property (nonatomic, readonly) NSMutableArray *lines;
@property (nonatomic, readonly) SKLabelNode *firstLine;
@property (nonatomic, readonly) SKLabelNode *lastLine;

- (void)addLine;
- (SKLabelNode *)lineAtIndex:(unsigned)index;
- (SKLabelNode *)labelNode;
@end

@implementation GLLabelCollection
- (id)init
{
   if (self = [super init])
      _lines = [NSMutableArray new];

   return self;
}

- (SKLabelNode *)firstLine
{
   return _lines.firstObject;
}

- (SKLabelNode *)lastLine
{
   return _lines.lastObject;
}

- (void)addLine
{
   [_lines addObject:[self labelNode]];
}

- (SKLabelNode *)lineAtIndex:(unsigned int)index
{
   return [_lines objectAtIndex:index];
}

- (SKLabelNode *)labelNode
{
   return nil;
}
@end

@interface GLHeaderLabel : GLLabelCollection
@end

@implementation GLHeaderLabel
- (SKLabelNode *)labelNode
{
   SKLabelNode *headerLabelNode = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedExtraBold"];
   headerLabelNode.colorBlendFactor = 1.0;
   headerLabelNode.color = [SKColor whiteColor];
   headerLabelNode.alpha = 5;
   headerLabelNode.fontSize = HEADING_FONT_SIZE;

   return headerLabelNode;
}
@end

@interface GLBodyLabel : GLLabelCollection
@end

@implementation GLBodyLabel
- (SKLabelNode *)labelNode
{
   SKLabelNode *bodyLabelNode = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedMedium"];
   bodyLabelNode.colorBlendFactor = 1.0;
   bodyLabelNode.color = [SKColor whiteColor];
   bodyLabelNode.alpha = 5;
   bodyLabelNode.fontSize = BODY_FONT_SIZE;

   return bodyLabelNode;
}
@end

@interface GLAlertLayer()
{
   CGPoint _firstLabelPosition;
   CGPoint _lastLabelPosition;

   // the header and body will be an array of label nodes
   GLHeaderLabel *_header;
   GLBodyLabel *_body;

   NSMutableArray *_headers;
   NSMutableArray *_bodies;
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

      _firstLabelPosition = CGPointZero;
      _lastLabelPosition = CGPointZero;
      
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
      [self setHeaderText:header];
      [self setBodyText:body];
   }
   return self;
}

#pragma mark - Setup Methods
- (void)setupHeader
{
   _header = [GLHeaderLabel new];
   [_header addLine];
}

- (void)setupBody
{
   _body = [GLBodyLabel new];
   [_body addLine];
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
      return;

   [self addHeaderTextToLayer:[NSString futurizedString:headerText.uppercaseString]];
   [self dynamicallySetSize];
}

- (void)setBodyText:(NSString *)bodyText
{
   if (!bodyText)
      return;

   [self addBodyTextToLayer:[NSString futurizedString:bodyText]];
   [self dynamicallySetSize];
}

#pragma mark - Helper Methods
- (void)addHeaderTextToLayer:(NSString *)headerText
{
   // separate words by two spaces because the string is FUTURIZED
   NSArray *headerTextWords = [headerText componentsSeparatedByString:@"  "];
   int lineIndex = 0;

   [_header lineAtIndex:lineIndex].text = [headerTextWords objectAtIndex:0];

   // initial check to see if the first word in the header text is too large to display
   if (![self labelFitsInFrame:[_header lineAtIndex:lineIndex]])
   {
      NSLog(@"GLAlertLayer: cannot set header text becuase the word '%@' will not fit",
            [headerTextWords objectAtIndex:0]);
      return;
   }

   for (NSString *word in headerTextWords)
   {
      if ([word isEqual:headerTextWords.firstObject]) continue;

      NSString *currentStr = [_header lineAtIndex:lineIndex].text;
      NSString *nextStr = [currentStr stringByAppendingString:[NSString stringWithFormat:@"  %@", word]];
      [_header lineAtIndex:lineIndex].text = nextStr;

      if (![self labelFitsInFrame:[_header lineAtIndex:lineIndex]])
      {
         [_header lineAtIndex:lineIndex].text = currentStr;
         [_header addLine];
         [_header lineAtIndex:++lineIndex].text = word;
      }
   }

   [self setPositionsForLinesInHeader];
}

- (void)addBodyTextToLayer:(NSString *)bodyText
{
   // separate words by two spaces because the string is FUTURIZED
   NSArray *bodyTextWords = [bodyText componentsSeparatedByString:@"  "];
   int lineIndex = 0;

   [_body lineAtIndex:lineIndex].text = [bodyTextWords objectAtIndex:0];

   // initial check to see if the first word in the header text is too large to display
   if (![self labelFitsInFrame:[_body lineAtIndex:lineIndex]])
   {
      NSLog(@"GLAlertLayer: cannot set header text becuase the word '%@' will not fit",
            [bodyTextWords objectAtIndex:0]);
      return;
   }

   for (NSString *word in bodyTextWords)
   {
      if ([word isEqual:bodyTextWords.firstObject]) continue;

      NSString *currentStr = [_body lineAtIndex:lineIndex].text;
      NSString *nextStr = [currentStr stringByAppendingString:[NSString stringWithFormat:@"  %@", word]];
      [_body lineAtIndex:lineIndex].text = nextStr;

      if (![self labelFitsInFrame:[_body lineAtIndex:lineIndex]])
      {
         [_body lineAtIndex:lineIndex].text = currentStr;
         [_body addLine];
         [_body lineAtIndex:++lineIndex].text = word;
      }
   }

   [self setPositionsForLinesInBody];
}

- (void)setPositionsForLinesInHeader
{
   CGPoint headerLinePosition = CGPointMake(self.size.width * .5,
                                            -(TOP_PADDING + HEADING_FONT_SIZE * .5));
   for (SKLabelNode *headerLine in _header.lines)
   {
      headerLine.position = headerLinePosition;
      [self addChild:headerLine];

      if (![headerLine isEqual:_header.lastLine])
         headerLinePosition = CGPointMake(self.size.width * .5,
                                          headerLine.position.y - HEADING_FONT_SIZE);
   }
}

- (void)setPositionsForLinesInBody
{
   CGFloat yValue = _header.lastLine.position.y - HEADING_FONT_SIZE * 2;
   CGPoint bodyLinePosition = CGPointMake(SIDE_MARGIN_SPACE, yValue);
   for (SKLabelNode *bodyLine in _body.lines)
   {
      bodyLine.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
      bodyLine.position = bodyLinePosition;
      [self addChild:bodyLine];

      if (![bodyLine isEqual:_body.lastLine])
         bodyLinePosition = CGPointMake(SIDE_MARGIN_SPACE,
                                        bodyLine.position.y - BODY_FONT_SIZE * 1.25);
   }
}

- (void)dynamicallySetSize
{
   CGFloat height = fabs(_header.firstLine.position.y +
                         (_header.firstLine ? (HEADING_FONT_SIZE * .5) : 0) -
                         _body.lastLine.position.y +
                         (_body.lastLine ? (BODY_FONT_SIZE * .5) : 0)) +
                         TOP_PADDING * 1.5;

   self.size = CGSizeMake(self.size.width, height);
}

- (BOOL)labelFitsInFrame:(SKLabelNode *)label
{
   return label.calculateAccumulatedFrame.size.width <= (self.size.width - SIDE_MARGIN_SPACE);
}

@end
