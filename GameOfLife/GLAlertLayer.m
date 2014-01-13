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
#define HEADER_BODY_VERTICAL_SEPARATION 20
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

   // arrays to store off the headers and bodies in the alert
   NSMutableArray *_headers;
   NSMutableArray *_bodies;
}
@end

@implementation GLAlertLayer

#pragma mark - Init methods
- (id)init
{
   if (self = [super init])
   {
      // default size and anchor point
      self.size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 0);
      self.anchorPoint = CGPointMake(0, 1);

      // default color and alpha
      self.color = [SKColor crayolaBlackCoralPearlColor];
      self.alpha = .8;

      _firstLabelPosition = CGPointZero;
      _lastLabelPosition = CGPointZero;

      _headers = [NSMutableArray new];
      _bodies = [NSMutableArray new];
   }
   return self;
}

- (id)initWithSize:(CGSize)size
       anchorPoint:(CGPoint)anchorPoint
{
   if (self = [super initWithSize:size
                      anchorPoint:anchorPoint])
   {
      // default color and alpha
      self.color = [SKColor crayolaBlackCoralPearlColor];
      self.alpha = .8;

      _headers = [NSMutableArray new];
      _bodies = [NSMutableArray new];

      _firstLabelPosition = CGPointZero;
      _lastLabelPosition = CGPointZero;
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

#pragma mark - Setter Methods
- (void)setHeaderText:(NSString *)headerText
{
   if (!headerText)
      return;

   [self addHeaderText:[NSString futurizedString:headerText.uppercaseString]];
   [self dynamicallySetSize];
}

- (void)setBodyText:(NSString *)bodyText
{
   if (!bodyText)
      return;

   [self addBodyText:[NSString futurizedString:bodyText]];
   [self dynamicallySetSize];
}

#pragma mark - Instance Methods
- (void)addHeaderText:(NSString *)headerText
{
   if (CGPointEqualToPoint(_firstLabelPosition, CGPointZero))
   {
      _firstLabelPosition = CGPointMake(self.size.width * .5,
                                        -(TOP_PADDING + HEADING_FONT_SIZE * .5));
   }
   GLHeaderLabel *header = [GLHeaderLabel new];
   [header addLine];
   [_headers addObject:header];

   [self addHeaderTextToLayer:[NSString futurizedString:headerText.uppercaseString]];
   [self dynamicallySetSize];
}

- (void)addBodyText:(NSString *)bodyText
{
   if (CGPointEqualToPoint(_firstLabelPosition, CGPointZero))
   {
      _firstLabelPosition = CGPointMake(self.size.width * .5,
                                        -(TOP_PADDING + BODY_FONT_SIZE * .5));
   }
   GLBodyLabel *body = [GLBodyLabel new];
   [body addLine];
   [_bodies addObject:body];

   [self addBodyTextToLayer:[NSString futurizedString:bodyText]];
   [self dynamicallySetSize];
}

#pragma mark - Helper Methods
- (CGPoint)nextPositionForHeader
{
   return CGPointMake(self.size.width * .5,
                      _lastLabelPosition.y -
                      (HEADING_FONT_SIZE * .5) -
                      HEADER_BODY_VERTICAL_SEPARATION);
}

- (CGPoint)nextPositionForBody
{
   return CGPointMake(SIDE_MARGIN_SPACE,
                      _lastLabelPosition.y -
                      (BODY_FONT_SIZE * .5) -
                      HEADER_BODY_VERTICAL_SEPARATION);
}

- (void)addHeaderTextToLayer:(NSString *)headerText
{
   // separate words by two spaces because the string is FUTURIZED
   NSArray *headerTextWords = [headerText componentsSeparatedByString:@"  "];
   int lineIndex = 0;

   GLHeaderLabel *header = _headers.lastObject;

   [header lineAtIndex:lineIndex].text = [headerTextWords objectAtIndex:0];

   // initial check to see if the first word in the header text is too large to display
   if (![self labelFitsInFrame:[header lineAtIndex:lineIndex]])
   {
      NSLog(@"GLAlertLayer: cannot set header text becuase the word '%@' will not fit",
            [headerTextWords objectAtIndex:0]);
      return;
   }

   for (NSString *word in headerTextWords)
   {
      if ([word isEqual:headerTextWords.firstObject]) continue;

      NSString *currentStr = [header lineAtIndex:lineIndex].text;
      NSString *nextStr = [currentStr stringByAppendingString:[NSString stringWithFormat:@"  %@", word]];
      [header lineAtIndex:lineIndex].text = nextStr;

      if (![self labelFitsInFrame:[header lineAtIndex:lineIndex]])
      {
         [header lineAtIndex:lineIndex].text = currentStr;
         [header addLine];
         [header lineAtIndex:++lineIndex].text = word;
      }
   }

   [self setPositionsForLinesInHeader:header];
}

- (void)addBodyTextToLayer:(NSString *)bodyText
{
   // separate words by two spaces because the string is FUTURIZED
   NSArray *bodyTextWords = [bodyText componentsSeparatedByString:@"  "];
   int lineIndex = 0;

   GLBodyLabel *body = _bodies.lastObject;

   [body lineAtIndex:lineIndex].text = [bodyTextWords objectAtIndex:0];

   // initial check to see if the first word in the header text is too large to display
   if (![self labelFitsInFrame:[body lineAtIndex:lineIndex]])
   {
      NSLog(@"GLAlertLayer: cannot set header text becuase the word '%@' will not fit",
            [bodyTextWords objectAtIndex:0]);
      return;
   }

   for (NSString *word in bodyTextWords)
   {
      if ([word isEqual:bodyTextWords.firstObject]) continue;

      NSString *currentStr = [body lineAtIndex:lineIndex].text;
      NSString *nextStr = [currentStr stringByAppendingString:[NSString stringWithFormat:@"  %@", word]];
      [body lineAtIndex:lineIndex].text = nextStr;

      if (![self labelFitsInFrame:[body lineAtIndex:lineIndex]])
      {
         [body lineAtIndex:lineIndex].text = currentStr;
         [body addLine];
         [body lineAtIndex:++lineIndex].text = word;
      }
   }

   [self setPositionsForLinesInBody:body];
}

- (void)setPositionsForLinesInHeader:(GLHeaderLabel *)header
{

   CGPoint headerLinePosition = [self nextPositionForHeader];
   for (SKLabelNode *headerLine in header.lines)
   {
      headerLine.position = headerLinePosition;
      [self addChild:headerLine];

      if (![headerLine isEqual:header.lastLine])
         headerLinePosition = CGPointMake(self.size.width * .5,
                                          headerLine.position.y - HEADING_FONT_SIZE);
   }
   _lastLabelPosition = headerLinePosition;
}

- (void)setPositionsForLinesInBody:(GLBodyLabel *)body
{
   CGPoint bodyLinePosition = [self nextPositionForBody];
   for (SKLabelNode *bodyLine in body.lines)
   {
      bodyLine.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
      bodyLine.position = bodyLinePosition;
      [self addChild:bodyLine];

      if (![bodyLine isEqual:body.lastLine])
         bodyLinePosition = CGPointMake(SIDE_MARGIN_SPACE,
                                        bodyLine.position.y - BODY_FONT_SIZE * 1.25);
   }
   _lastLabelPosition = bodyLinePosition;
}

- (void)dynamicallySetSize
{
   CGFloat height = fabs(_firstLabelPosition.y - _lastLabelPosition.y) + TOP_PADDING * 2.5;
   self.size = CGSizeMake(self.size.width, height);
}

- (BOOL)labelFitsInFrame:(SKLabelNode *)label
{
   return label.calculateAccumulatedFrame.size.width <= (self.size.width - (SIDE_MARGIN_SPACE * 2));
}

@end
