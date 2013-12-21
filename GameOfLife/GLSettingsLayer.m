//
//  GLSettingsLayer.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/1/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLSettingsLayer.h"

#import "GLHUDSettingsManager.h"
#import "GLSettingsItem.h"
#import "GLSliderControl.h"
#import "GLToggleControl.h"
#import "GLSettingsItem.h"
#import "UIColor+Crayola.h"

#import "GLAppDelegate.h"

#define TOP_PADDING 10
#define HEADING_FONT_SIZE 16
#define CONTROL_HEIGHT 50

@interface GLSettingsLayer()
{
   SKSpriteNode *_backgroundLayer;

   CGSize _defaultSize;
   CGPoint _defaultAnchorPoint;

   CGPoint _nextControlPosition;
   
   id<GLSettingsItemValueChangedDelegate> _settingsDelegate;
}
@end

@implementation GLSettingsLayer

- (void)addToggleControl:(HUDItemDescription *)item
{
   GLToggleControl *toggleControl = [[GLToggleControl alloc] initWithPreferenceKey:item.keyPath];
   GLSettingsItem *toggleItem = [[GLSettingsItem alloc] initWithTitle:item.label
                                                              control:toggleControl];
   toggleItem.position = _nextControlPosition;
   _nextControlPosition.y -= CONTROL_HEIGHT;
   
   toggleItem.delegate = _settingsDelegate;
   [self addChild:toggleItem];
}

- (void)addSliderControl:(HUDItemDescription *)item
{
   GLSliderControl * sliderControl = [[GLSliderControl alloc]
                                      initWithLength:180 preferenceKey:item.keyPath];
   GLSettingsItem * sliderItem = [[GLSettingsItem alloc] initWithTitle:item.label
                                                               control:sliderControl];
   sliderItem.position = _nextControlPosition;
   _nextControlPosition.y -= CONTROL_HEIGHT;
   
   sliderItem.delegate = _settingsDelegate;
   [self addChild:sliderItem];
}

- (void)addPickerControl:(HUDItemDescription *)item
{
   _nextControlPosition.y -= CONTROL_HEIGHT;
}

- (void)addItemToSettings:(HUDItemDescription *)item
{
   if (item == nil)
      return;

   switch (item.type)
   {
      case HIT_TOGGLER:
         [self addToggleControl:item];
         break;
      case HIT_SLIDER:
         [self addSliderControl:item];
         break;
      case HIT_PICKER:
         [self addPickerControl:item];
         break;
   }
}

- (void)setupHudItemsforKeys:(NSArray *)keyPaths
 {
    GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
    NSDictionary * hudItems = [hudManager getHudItemsforKeyPaths:keyPaths];
    
    for (NSString * keyPath in keyPaths)
       [self addItemToSettings:(HUDItemDescription *)[hudItems objectForKey:keyPath]];
 }

- (id)initWithSize:(CGSize)size
       anchorPoint:(CGPoint)anchorPoint
{
   if (self = [super init])
   {
      _settingsDelegate =
         ((id<GLSettingsItemValueChangedDelegate>)[[UIApplication sharedApplication] delegate]);
      
      _defaultSize = size;
      _defaultAnchorPoint = anchorPoint;
      [self setupSettingsLabel];
      
      NSArray * keyPaths = [NSArray arrayWithObjects:@"GenerationDuration",
                                                     @"SoundFX",
                                                     @"SmartMenu",
                                                     nil];
      [self setupHudItemsforKeys:keyPaths];
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
   
   _nextControlPosition = CGPointMake(0, -(HEADING_FONT_SIZE + TOP_PADDING + CONTROL_HEIGHT));
}

@end
