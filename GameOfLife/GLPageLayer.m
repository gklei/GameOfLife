//
//  GLPageLayer.m
//  GameOfLife
//
//  Created by Gregory Klein on 1/9/14. (Made in Mexico)
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLPageLayer.h"
#import "NSString+Additions.h"
#import "UIColor+Crayola.h"

#define DEFAULT_ALERT_SIZE CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 150);
#define DEFAULT_ALERT_ANCHOR_POINT CGPointMake(0, 1);
#define HEADER_BODY_VERTICAL_SEPARATION 20
#define SIDE_MARGIN_SPACE 10

@interface GLTextElement : NSObject
@property (nonatomic, readonly) NSMutableArray *lines;
@property (nonatomic, readonly) SKLabelNode *firstLine;
@property (nonatomic, readonly) SKLabelNode *lastLine;
@property (nonatomic, readonly) GL_PAGE_TEXT_ELEMENT type;

- (void)addLine;
- (void)reset;
- (SKLabelNode *)lineAtIndex:(unsigned)index;
- (SKLabelNode *)labelNode;
- (CGFloat)fontSize;
@end

@implementation GLTextElement
- (id)init
{
   if (self = [super init])
   {
      _lines = [NSMutableArray new];
      [self addLine];
   }

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

- (void)reset
{
   [_lines removeAllObjects];
   [self addLine];
}

- (SKLabelNode *)lineAtIndex:(unsigned int)index
{
   return [_lines objectAtIndex:index];
}

- (SKLabelNode *)labelNode
{
   return nil;
}

- (CGFloat)fontSize
{
   return self.labelNode.fontSize;
}

- (GL_PAGE_TEXT_ELEMENT)type
{
   return -1;
}
@end

@interface GLHeaderLabel : GLTextElement
@end

@implementation GLHeaderLabel
- (SKLabelNode *)labelNode
{
   SKLabelNode *headerLabelNode = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedExtraBold"];
   headerLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeCenter;
   headerLabelNode.colorBlendFactor = 1.0;
   headerLabelNode.color = [SKColor whiteColor];
   headerLabelNode.alpha = 5;
   headerLabelNode.fontSize = HEADING_FONT_SIZE;

   return headerLabelNode;
}

- (GL_PAGE_TEXT_ELEMENT)type
{
   return e_PAGE_TEXT_HEADER;
}
@end

@interface GLBodyLabel : GLTextElement
@end

@implementation GLBodyLabel
- (SKLabelNode *)labelNode
{
   SKLabelNode *bodyLabelNode = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedMedium"];
   bodyLabelNode.colorBlendFactor = 1.0;
   bodyLabelNode.color = [SKColor whiteColor];
   bodyLabelNode.alpha = 5;
   bodyLabelNode.fontSize = BODY_FONT_SIZE;
   bodyLabelNode.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;

   return bodyLabelNode;
}

- (GL_PAGE_TEXT_ELEMENT)type
{
   return e_PAGE_TEXT_BODY;
}
@end

@interface GLNewLineLabel : GLTextElement
@end

@implementation GLNewLineLabel

- (SKLabelNode *)labelNode
{
   SKLabelNode *newLineLabelNode = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedMedium"];
   newLineLabelNode.alpha = 0;
   newLineLabelNode.fontSize = BODY_FONT_SIZE - 4;
   return newLineLabelNode;
}

- (GL_PAGE_TEXT_ELEMENT)type
{
   return e_PAGE_TEXT_NEWLINE;
}
@end

@interface GLPageLayer()
{
   CGPoint _firstLabelPosition;
   CGPoint _lastLabelPosition;

   // arrays to store off the headers and bodies in the page
   NSMutableArray *_headers;
   NSMutableArray *_bodies;

   NSMutableArray *_textElements;
   NSMutableArray *_textElementStrings;

   BOOL _rewrappingLines;
}
@end

@implementation GLPageLayer

#pragma mark - Init methods
- (id)init
{
   if (self = [super init])
   {
      // default size and anchor point
      self.size = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds), 0);
      self.anchorPoint = CGPointMake(0, 1);
      self.hidden = YES;

      _dynamicallySetsSize = YES;
      [self setVariables];
   }
   return self;
}

- (id)initWithSize:(CGSize)size
       anchorPoint:(CGPoint)anchorPoint
{
   if (self = [super initWithSize:size
                      anchorPoint:anchorPoint])
   {
      [self setVariables];
   }
   return self;
}

#pragma mark - Setup Methods
- (void)setVariables
{
   _firstLabelPosition = CGPointZero;
   _lastLabelPosition = CGPointZero;

   _headers = [NSMutableArray new];
   _bodies = [NSMutableArray new];
   _textElements = [NSMutableArray new];
   _textElementStrings = [NSMutableArray new];
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
   [_headers addObject:header];

   [self addTextToLayer:[NSString futurizedString:headerText.uppercaseString] forTextElement:header];

   if (_dynamicallySetsSize)
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
   [_bodies addObject:body];

   [self addTextToLayer:[NSString futurizedString:bodyText] forTextElement:body];

   if (_dynamicallySetsSize)
      [self dynamicallySetSize];
}

- (void)addNewLines:(NSInteger)lines
{
   if (CGPointEqualToPoint(_firstLabelPosition, CGPointZero))
   {
      _firstLabelPosition = CGPointMake(self.size.width * .5,
                                        -(TOP_PADDING + NEW_LINE_HEIGHT * .5));
   }
   for (int i = 0; i < lines; ++i)
   {
      GLNewLineLabel *newLine = [GLNewLineLabel new];
      [newLine addLine];
      [self addTextToLayer:@"   " forTextElement:newLine];
   }

   if (_dynamicallySetsSize)
      [self dynamicallySetSize];
}

#pragma mark - Helper Methods
- (CGPoint)nextPositionForTextElementType:(GL_PAGE_TEXT_ELEMENT)textElement
{
   switch (textElement)
   {
      case e_PAGE_TEXT_HEADER:
         return CGPointMake(self.size.width * .5,
                            _lastLabelPosition.y -
                            (HEADING_FONT_SIZE * .5) -
                            HEADER_BODY_VERTICAL_SEPARATION);
      case e_PAGE_TEXT_BODY:
         return CGPointMake(SIDE_MARGIN_SPACE,
                            _lastLabelPosition.y -
                            (BODY_FONT_SIZE * .5) -
                            HEADER_BODY_VERTICAL_SEPARATION);
      case e_PAGE_TEXT_NEWLINE:
         return CGPointMake(SIDE_MARGIN_SPACE,
                            _lastLabelPosition.y -
                            (NEW_LINE_HEIGHT * .5) -
                            HEADER_BODY_VERTICAL_SEPARATION);
      default:
         NSLog(@"text element %d not supported", textElement);
         return CGPointZero;
   }
}

- (void)addTextToLayer:(NSString *)text forTextElement:(GLTextElement *)textElement
{
   if (!_rewrappingLines)
   {
      [_textElements addObject:textElement];
      [_textElementStrings addObject:text];
   }

   // separate words by two spaces because the string is FUTURIZED
   NSArray *words = [text componentsSeparatedByString:@"  "];
   int lineIndex = 0;

   [textElement lineAtIndex:lineIndex].text = [words objectAtIndex:0];

   // initial check to see if the first word in the text element text is too large to display
   if (![self labelFitsInFrame:[textElement lineAtIndex:lineIndex]])
   {
      NSLog(@"GLAlertLayer: cannot set header text becuase the word '%@' will not fit",
            [words objectAtIndex:0]);
      return;
   }

   for (NSString *word in words)
   {
      if ([word isEqual:words.firstObject]) continue;

      NSString *currentStr = [textElement lineAtIndex:lineIndex].text;
      NSString *nextStr = [currentStr stringByAppendingString:[NSString stringWithFormat:@"  %@", word]];
      [textElement lineAtIndex:lineIndex].text = nextStr;

      if (![self labelFitsInFrame:[textElement lineAtIndex:lineIndex]])
      {
         [textElement lineAtIndex:lineIndex].text = currentStr;
         [textElement addLine];
         [textElement lineAtIndex:++lineIndex].text = word;
      }
   }

   [self setPositionsForLinesInTextElement:textElement];
}

- (void)setPositionsForLinesInTextElement:(GLTextElement *)textElement
{
   CGPoint linePosition = [self nextPositionForTextElementType:textElement.type];
   for (SKLabelNode *line in textElement.lines)
   {
      line.position = linePosition;
      [self addChild:line];

      if (![line isEqual:textElement.lastLine])
         linePosition = CGPointMake(linePosition.x,
                                    line.position.y - line.fontSize * 1.25);
   }
   _lastLabelPosition = linePosition;
}

- (void)dynamicallySetSize
{
   CGFloat height = fabs(_firstLabelPosition.y - _lastLabelPosition.y) + TOP_PADDING * 2.5;
   super.size = CGSizeMake(self.size.width, height);
}

- (BOOL)labelFitsInFrame:(SKLabelNode *)label
{
   return label.calculateAccumulatedFrame.size.width <= (self.size.width - (SIDE_MARGIN_SPACE * 2));
}

- (void)reAddAllTextElements
{
   _lastLabelPosition = CGPointZero;
   _rewrappingLines = YES;
   for (GLTextElement *textElement in _textElements)
   {
      [textElement reset];
      [self addTextToLayer:[_textElementStrings objectAtIndex:[_textElements indexOfObject:textElement]]
            forTextElement:textElement];
   }
   _rewrappingLines = NO;
}

#pragma mark - Overridden Methods
- (void)setSize:(CGSize)size
{
   super.size = size;
   [self removeAllChildren];
   [self reAddAllTextElements];
}

- (void)setHidden:(BOOL)hidden
{
   for (SKLabelNode *label in self.children)
      label.hidden = hidden;
   
   [super setHidden:hidden];
}

@end
