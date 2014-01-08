//
//  GLSettingsItem.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/15/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLSettingsItem.h"
#import "GLUIButton.h"

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
   GLUIButton *_itemUIControl;
}
@end

@implementation GLSettingsItem

- (id)initWithTitle:(NSString *)title
            control:(GLUIButton *)control
{
   if (self = [super init])
   {
      [self setupTitle:title];
      [self setupStatusLabelWithControl:control];
      [self setupControl:control];
   }
   return self;
}

- (NSString *)futurizedString:(NSString *)string
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
      CGPointMake(CGRectGetWidth(_itemTitleLabel.calculateAccumulatedFrame) * 0.5 +
                  LEFT_TITLE_LABEL_PADDING, 0);

   [self addChild:_itemTitleLabel];
}

- (void)setupStatusLabelWithControl:(GLUIButton *)control
{
   _itemStatusLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedMedium"];
   _itemStatusLabel.text = control.longestPossibleStringValue;
   _itemStatusLabel.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
   _itemStatusLabel.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
   _itemStatusLabel.colorBlendFactor = 1.0;
   _itemStatusLabel.color = [SKColor whiteColor];
   _itemStatusLabel.alpha = 1;
   _itemStatusLabel.fontSize = STATUS_LABEL_FONT_SIZE;

   _itemStatusLabel.position =
      CGPointMake(CGRectGetWidth([UIScreen mainScreen].bounds) -
                  CGRectGetWidth(_itemStatusLabel.calculateAccumulatedFrame) * 0.5 -
                  RIGHT_STATUS_LABEL_LABEL_PADDING, 0);

   _itemStatusLabel.text = [self futurizedString:control.stringValue];
   [self addChild:_itemStatusLabel];
}

- (void)setupControl:(GLUIButton *)control
{
   _itemUIControl = control;
   _itemUIControl.delegate = self;
   
   _itemStatusLabel.text = [self futurizedString:control.longestPossibleStringValue];
   
   _itemUIControl.position = (_itemStatusLabel.text)?
      CGPointMake(_itemStatusLabel.position.x -
                  CGRectGetWidth(_itemStatusLabel.calculateAccumulatedFrame) * 0.5 -
                  CGRectGetWidth(_itemUIControl.largestPossibleAccumulatedFrame) * 0.5, 0) :
      CGPointMake(CGRectGetWidth(_itemTitleLabel.calculateAccumulatedFrame), 0);
   
   _itemStatusLabel.text = [self futurizedString:control.stringValue];
   [self addChild:_itemUIControl];
}

- (void)controlValueChangedForKey:(NSString *)key;
{
   _itemStatusLabel.text = [self futurizedString:_itemUIControl.stringValue];
}

- (void)setHidden:(BOOL)hidden
{
   _itemUIControl.hidden = hidden;
   super.hidden = hidden;
}

@end
