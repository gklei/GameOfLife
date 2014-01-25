//
//  GLSettingsLayer.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/1/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLSettingsLayer.h"

#import "GLHUDSettingsManager.h"
#import "GLLabelControl.h"
#import "GLPickerControl.h"
#import "GLSettingsItem.h"
#import "GLSliderControl.h"
#import "GLToggleControl.h"
#import "GLUIActionButton.h"
#import "UIColor+Crayola.h"

#import "GLAppDelegate.h"

@interface GLSettingsLayer()
{
   GLUIButton *_lastControl;
   CGPoint _nextControlPosition;

   GLUIActionButton *_aboutButton;
}
@end

@implementation GLSettingsLayer

- (BOOL)controlIsStartOfGroup:(GLUIButton *)control
{
   return ![control isKindOfClass:_lastControl.class];
}

- (void)addLabelControl:(HUDItemDescription *)item
{
   GLLabelControl * labelControl = [[GLLabelControl alloc] initWithHUDItemDescription:item];
   GLSettingsItem * labelItem = [[GLSettingsItem alloc] initWithTitle:item.label
                                                              control:labelControl];
   labelItem.usesStatusLabel = YES;
   _nextControlPosition.y -= ([self controlIsStartOfGroup:labelControl])? 5 : 0;
   labelItem.position = _nextControlPosition;
   _nextControlPosition.y -= labelControl.controlHeight;

   _lastControl = labelControl;
   [self addChild:labelItem];
}

- (void)addToggleControl:(HUDItemDescription *)item
{
   GLToggleControl * toggleControl = [[GLToggleControl alloc] initWithPreferenceKey:item.keyPath];
   GLSettingsItem * toggleItem = [[GLSettingsItem alloc] initWithTitle:item.label
                                                               control:toggleControl];
   _nextControlPosition.y -= ([self controlIsStartOfGroup:toggleControl])? 5 : 0;
   toggleItem.position = _nextControlPosition;
   _nextControlPosition.y -= toggleControl.controlHeight;

   _lastControl = toggleControl;
   [self addChild:toggleItem];
}

- (void)addSliderControl:(HUDItemDescription *)item
{
   GLSliderControl * sliderControl = [[GLSliderControl alloc] initWithLength:210
                                                                       range:item.range
                                                            andPreferenceKey:item.keyPath];
   GLSettingsItem * sliderItem = [[GLSettingsItem alloc] initWithTitle:item.label
                                                               control:sliderControl];
   _nextControlPosition.y -= ([self controlIsStartOfGroup:sliderControl])? 5 : 0;
   sliderItem.position = _nextControlPosition;
   _nextControlPosition.y -= sliderControl.controlHeight;

   _lastControl = sliderControl;
   [self addChild:sliderItem];
}

- (void)addPickerControl:(HUDItemDescription *)item
{
   GLPickerControl * pickerControl =
      [[GLPickerControl alloc] initWithHUDPickerItemDescription:(HUDPickerItemDescription *)item];
   
   GLSettingsItem * pickerItem = [[GLSettingsItem alloc] initWithTitle:item.label
                                                               control:pickerControl];

   _nextControlPosition.y -= ([self controlIsStartOfGroup:pickerControl])? 5 : 0;
   pickerItem.position = _nextControlPosition;
   _nextControlPosition.y -= pickerControl.controlHeight;

   _lastControl = pickerControl;
   [self addChild:pickerItem];
}

- (void)addItemToSettings:(HUDItemDescription *)item
{
   if (item == nil)
      return;

   switch (item.type)
   {
      case HIT_LABEL:
         [self addLabelControl:item];
         break;
      case HIT_TOGGLER:
         [self addToggleControl:item];
         break;
      case HIT_SLIDER:
         [self addSliderControl:item];
         break;
      case HIT_PICKER:
         [self addPickerControl:item];
         break;
      default:
         NSLog(@"WARNING: Undefined HUD item type requested - not building UI");
   }
}

- (void)setupHudItemsforKeys:(NSArray *)keyPaths
 {
    GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
    NSDictionary * hudItems = [hudManager getHudItemsforKeyPaths:keyPaths];
    
    for (NSString * keyPath in keyPaths)
       [self addItemToSettings:[hudItems objectForKey:keyPath]];
 }

- (id)initWithSize:(CGSize)size
       anchorPoint:(CGPoint)anchorPoint
{
   if (self = [super initWithSize:size
                      anchorPoint:anchorPoint])
   {
      [self setupSettingsLabel];
      NSArray * keyPaths = [NSArray arrayWithObjects:@"HighScore",
                                                     @"GridImageIndex",
                                                     @"GenerationDuration",
                                                     @"SoundFX",
                                                     @"SmartMenu",
                                                     @"LoopDetection",
                                                     @"TileGenerationTracking",
                                                     nil];
      [self setupHudItemsforKeys:keyPaths];
   }
   return self;
}

- (void)setupSettingsLabel
{
   SKLabelNode *settingsLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedExtraBold"];

   settingsLabel.text = @"S  E  T  T  I  N  G  S";
   settingsLabel.colorBlendFactor = 1.0;
   settingsLabel.color = [SKColor whiteColor];
   settingsLabel.alpha = 1;
   settingsLabel.fontSize = HEADING_FONT_SIZE;
   settingsLabel.position = CGPointMake(self.size.width * 0.5,
                                        -(HEADING_FONT_SIZE + TOP_PADDING));
   [self addChild:settingsLabel];

   _nextControlPosition = CGPointMake(0, -(TOP_PADDING + 5 + HEADING_FONT_SIZE * 3));
}

- (void)setHidden:(BOOL)hidden
{
   super.hidden = hidden;
   for (SKNode *node in self.children)
      node.hidden = hidden;
}

@end
