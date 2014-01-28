//
//  GLTextButton.m
//  GameOfLife
//
//  Created by Gregory Klein on 1/25/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLUITextButton.h"
#import "NSString+Additions.h"
#import "GLHUDSettingsManager.h"

@interface GLUITextButton() <HUDSettingsObserver>
{
   SKLabelNode *_labelNode;
   GLUIButton *_buttonRing;

   SKAction *_buttonPressSound;
   BOOL _shouldPlaySound;
}
@end

@implementation GLUITextButton

- (id)init
{
   if (self = [super init])
   {
      _buttonPressSound = [SKAction playSoundFileNamed:@"button.press.wav" waitForCompletion:NO];
      [self setupLabelNode];
      [self setupButtonRing];

      self.hitBox.size = CGSizeMake(_buttonRing.size.width + 10,
                                    _buttonRing.size.width + 10);
      self.size = _buttonRing.size;
      self.scalesOnTouch = NO;
      [self addChild:_labelNode];
      [self addChild:_buttonRing];
      [self addChild:self.hitBox];

      [self observeSoundFxChanges];
   }
   return self;
}

+ (instancetype)textButtonWithTitle:(NSString *)title
{
   GLUITextButton *textButton = [[GLUITextButton alloc] init];
   textButton.buttonTitle = title;
   return textButton;
}

#pragma mark - Setup Methods
- (void)setupLabelNode
{
   _labelNode = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedMedium"];
   _labelNode.fontSize = BUTTON_TITLE_FONT_SIZE;
   _labelNode.color = [SKColor whiteColor];
   _labelNode.colorBlendFactor = 1.0;
   _labelNode.alpha = 5.0;
   _labelNode.verticalAlignmentMode = SKLabelVerticalAlignmentModeCenter;
}

- (void)setupButtonRing
{
   _buttonRing = [GLUIButton spriteNodeWithImageNamed:@"toggle-ring-outer.png"];
   _buttonRing.centerRect = CGRectMake(24.0/50.0, 10.0/32.0, 2.0/50.0, 10.0/32.0);
   _buttonRing.xScale = 2.75;
   _buttonRing.yScale = 1.5;
   _buttonRing.colorBlendFactor = 1.0;
   _buttonRing.color = [SKColor whiteColor];
   _buttonRing.alpha = 1.0;
   _buttonRing.scalesOnTouch = NO;
   _buttonRing.glowEnabled = NO;
}

#pragma mark - Accessor and Setter Methods
- (void)setButtonTitle:(NSString *)buttonTitle
{
   _labelNode.text = [NSString futurizedString:buttonTitle];
}

- (NSString *)buttonTitle
{
   return _labelNode.text;
}

#pragma mark - Settings Observer Protocol Methods
- (void)observeSoundFxChanges
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"SoundFX"];
}

- (void)settingChanged:(NSNumber *)value
                ofType:(HUDValueType)type
            forKeyPath:(NSString *)keyPath
{
   if ([keyPath compare:@"SoundFX"] == NSOrderedSame)
   {
      assert(type == HVT_BOOL);
      _shouldPlaySound = [value boolValue];
   }
}

#pragma mark - Overridden Methods
- (void)handleTouchEnded:(UITouch *)touch
{
   CGPoint convertedPoint = [touch locationInNode:self];
   if ([self.hitBox containsPoint:convertedPoint])
      if (_shouldPlaySound) [self runAction:_buttonPressSound];

   [super handleTouchEnded:touch];
}

- (NSUInteger)controlHeight
{
   return (NSUInteger)_buttonRing.size.height + 8;
}
@end
