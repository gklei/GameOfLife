//
//  GLTextButton.m
//  GameOfLife
//
//  Created by Gregory Klein on 1/25/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLUITextButton.h"
#import "NSString+Additions.h"

@interface GLUITextButton()
{
   SKLabelNode *_labelNode;
   GLUIButton *_buttonRing;
}
@end

@implementation GLUITextButton

- (id)init
{
   if (self = [super init])
   {
      _labelNode = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedMedium"];
      _labelNode.fontSize = BUTTON_TITLE_FONT_SIZE;
      _labelNode.color = [SKColor whiteColor];
      _labelNode.colorBlendFactor = 1.0;
      _labelNode.alpha = 5.0;
      _labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
      
      _buttonRing = [GLUIButton spriteNodeWithImageNamed:@"toggle-ring-outer.png"];
      _buttonRing.centerRect = CGRectMake(24.0/50.0, 10.0/32.0, 2.0/50.0, 10.0/32.0);
      _buttonRing.xScale = 2.75;
      _buttonRing.yScale = 1.5;
      _buttonRing.colorBlendFactor = 1.0;
      _buttonRing.color = [SKColor whiteColor];
      _buttonRing.alpha = 1.0;
      _buttonRing.scalesOnTouch = NO;

      self.hitBox.size = CGSizeMake(_buttonRing.size.width + 10,
                                    _buttonRing.size.width + 10);
      self.size = _buttonRing.size;

      [self addChild:_labelNode];
      [self addChild:_buttonRing];
      [self addChild:self.hitBox];
   }
   return self;
}

+ (instancetype)textButtonWithTitle:(NSString *)title
{
   GLUITextButton *textButton = [[GLUITextButton alloc] init];
   textButton.buttonTitle = title;
   return textButton;
}

- (void)setButtonTitle:(NSString *)buttonTitle
{
   _labelNode.text = [NSString futurizedString:buttonTitle];
}

- (NSString *)buttonTitle
{
   return _labelNode.text;
}
@end
