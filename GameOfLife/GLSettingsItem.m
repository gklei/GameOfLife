//
//  GLSettingsItem.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/15/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLSettingsItem.h"
#import "GLUIControl.h"

#define TOP_TITLE_LABEL_PADDING 10
#define LEFT_TITLE_LABEL_PADDING 10
#define RIGHT_STATUS_LABEL_LABEL_PADDING 30
#define STATUS_LABEL_CONTROL_PADDING 20

#define TITLE_LABEL_FONT_SIZE 15
#define STATUS_LABEL_FONT_SIZE 13

@interface GLSettingsItem() <GLUIControlValueChangedDelegate>
{
   SKLabelNode *_itemTitleLabel;
   SKLabelNode *_itemStatusLabel;
   GLUIControl *_itemUIControl;
}
@end

@implementation GLSettingsItem

- (id)initWithTitle:(NSString *)title
            control:(GLUIControl *)control
{
   if (self = [super init])
   {
      [self setupTitle:title];
      [self setupStatusLabel:control.stringValue];
      [self setupControl:control];
   }
   return self;
}

- (NSString *)futurizedString:(NSString *)string
{
   NSMutableString *futurizedString = [NSMutableString string];
   for (int i = 0; i < string.length - 1; ++i)
   {
      int ascii = [string characterAtIndex:i];
      [futurizedString appendFormat:@"%c ", ascii];
   }
   int lastASCII = [string characterAtIndex:string.length - 1];
   [futurizedString appendFormat:@"%c", lastASCII];

   return futurizedString;
}

- (void)setupTitle:(NSString *)title
{
   _itemTitleLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedMedium"];

   _itemTitleLabel.text = [self futurizedString:title];
   _itemTitleLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
   _itemTitleLabel.colorBlendFactor = 1.0;
   _itemTitleLabel.color = [SKColor whiteColor];
   _itemTitleLabel.alpha = 1;
   _itemTitleLabel.fontSize = TITLE_LABEL_FONT_SIZE;
   _itemTitleLabel.position =
      CGPointMake(CGRectGetWidth(_itemTitleLabel.calculateAccumulatedFrame)/2 +
                  LEFT_TITLE_LABEL_PADDING, 0);

   [self addChild:_itemTitleLabel];
}

- (void)setupStatusLabel:(NSString *)statusLabel
{
   _itemStatusLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedMedium"];
   _itemStatusLabel.text = [self futurizedString:statusLabel];
   _itemStatusLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
   _itemStatusLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
   _itemStatusLabel.colorBlendFactor = 1.0;
   _itemStatusLabel.color = [SKColor whiteColor];
   _itemStatusLabel.alpha = 1;
   _itemStatusLabel.fontSize = STATUS_LABEL_FONT_SIZE;

   _itemStatusLabel.position =
      CGPointMake(CGRectGetWidth([UIScreen mainScreen].bounds) -
                  CGRectGetWidth(_itemStatusLabel.calculateAccumulatedFrame)/2 -
                  RIGHT_STATUS_LABEL_LABEL_PADDING, 0);

   [self addChild:_itemStatusLabel];

}

- (void)setupControl:(GLUIControl *)control
{
   _itemUIControl = control;
   _itemUIControl.delegate = self;

   _itemUIControl.position =
   CGPointMake(_itemStatusLabel.position.x -
               CGRectGetWidth(_itemStatusLabel.calculateAccumulatedFrame)/2 -
               CGRectGetWidth(_itemUIControl.calculateAccumulatedFrame)/2, 0);

   [self addChild:_itemUIControl];
}

- (void)controlValueChanged
{
   _itemStatusLabel.text = [self futurizedString:_itemUIControl.stringValue];
}

@end
