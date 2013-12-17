//
//  GLSettingsLayer.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/1/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLSettingsLayer.h"

#import "GLSettingsItem.h"
#import "GLSliderControl.h"
#import "GLToggleControl.h"
#import "UIColor+Crayola.h"

#define TOP_PADDING 10
#define HEADING_FONT_SIZE 16

@interface GLSettingsLayer()
{
   SKSpriteNode *_backgroundLayer;

   CGSize _defaultSize;
   CGPoint _defaultAnchorPoint;

   GLToggleControl *_toggleControl;
   GLSliderControl *_sliderControl;
}
@end

@implementation GLSettingsLayer

- (id)initWithSize:(CGSize)size
       anchorPoint:(CGPoint)anchorPoint
{
   if (self = [super init])
   {
      _defaultSize = size;
      _defaultAnchorPoint = anchorPoint;
      [self setupSettingsLabel];
      [self setupSoundFXItem];
      [self setupSmartMenuItem];
      [self setupSpeedSliderItem];
   }
   return self;
}

- (void)setupBackground
{
   _backgroundLayer = [SKSpriteNode spriteNodeWithColor:[SKColor crayolaBlackCoralPearlColor]
                                                   size:_defaultSize];
   _backgroundLayer.colorBlendFactor = 1.0;
   _backgroundLayer.alpha = .7;
   _backgroundLayer.anchorPoint = _defaultAnchorPoint;
   _backgroundLayer.name = @"settings_background";

   [self addChild:_backgroundLayer];
}

- (void)setupSettingsLabel
{
   SKLabelNode *settingsLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-Medium"];

   settingsLabel.text = @"S E T T I N G S";
   settingsLabel.colorBlendFactor = 1.0;
   settingsLabel.color = [SKColor whiteColor];
   settingsLabel.alpha = 1;
   settingsLabel.fontSize = HEADING_FONT_SIZE;
   settingsLabel.position = CGPointMake(_defaultSize.width * 0.5,
                                        -(HEADING_FONT_SIZE + TOP_PADDING));
   [self addChild:settingsLabel];
}

- (void)setupSoundFXItem
{
   GLToggleControl *toggleControl = [[GLToggleControl alloc] init];
   GLSettingsItem *soundFXItem = [[GLSettingsItem alloc] initWithTitle:@"SOUND FX"
                                                               control:toggleControl];
   soundFXItem.position = CGPointMake(0, -(HEADING_FONT_SIZE + TOP_PADDING + 50));
   [self addChild:soundFXItem];
}

- (void)setupSmartMenuItem
{
   GLToggleControl *toggleControl = [[GLToggleControl alloc] init];
   GLSettingsItem *smartMenuItem = [[GLSettingsItem alloc] initWithTitle:@"SMART MENU"
                                                                 control:toggleControl];
   smartMenuItem.position = CGPointMake(0, -(HEADING_FONT_SIZE + TOP_PADDING + 100));
   [self addChild:smartMenuItem];
}

- (void)setupSpeedSliderItem
{
   GLSliderControl *sliderControl = [[GLSliderControl alloc] initWithLength:180 value:.5];
   GLSettingsItem *speedSliderItem = [[GLSettingsItem alloc] initWithTitle:@"SPEED"
                                                                   control:sliderControl];
   speedSliderItem.position = CGPointMake(0, -(HEADING_FONT_SIZE + TOP_PADDING + 150));
   [self addChild:speedSliderItem];
}

@end
