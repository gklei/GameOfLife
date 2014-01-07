//
//  GLSettingsLayer.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/1/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLSettingsLayer.h"

#import "GLHUDSettingsManager.h"
#import "GLPickerControl.h"
#import "GLSettingsItem.h"
#import "GLSliderControl.h"
#import "GLToggleControl.h"
#import "GLSettingsItem.h"
#import "UIColor+Crayola.h"

#import "GLAppDelegate.h"

@interface GLSettingsLayer()
{
   CGPoint _nextControlPosition;
}
@end

@implementation GLSettingsLayer

- (void)addToggleControl:(HUDItemDescription *)item
{
   GLToggleControl *toggleControl = [[GLToggleControl alloc] initWithPreferenceKey:item.keyPath];
   GLSettingsItem *toggleItem = [[GLSettingsItem alloc] initWithTitle:item.label
                                                              control:toggleControl];
   toggleItem.position = _nextControlPosition;
   _nextControlPosition.y -= toggleControl.controlHeight;
   
   [self addChild:toggleItem];
}

- (void)addSliderControl:(HUDItemDescription *)item
{
   GLSliderControl * sliderControl = [[GLSliderControl alloc] initWithLength:180
                                                                       range:item.range
                                                            andPreferenceKey:item.keyPath];
   GLSettingsItem * sliderItem = [[GLSettingsItem alloc] initWithTitle:item.label
                                                               control:sliderControl];
   sliderItem.position = _nextControlPosition;
   _nextControlPosition.y -= sliderControl.controlHeight;
   
   [self addChild:sliderItem];
}

- (void)addPickerControl:(HUDItemDescription *)item
{
   GLPickerControl * pickerControl =
      [[GLPickerControl alloc] initWithHUDPickerItemDescription:(HUDPickerItemDescription *)item];
   
   GLSettingsItem * pickerItem = [[GLSettingsItem alloc] initWithTitle:item.label
                                                               control:pickerControl];
   pickerItem.position = _nextControlPosition;
   _nextControlPosition.y -= pickerControl.controlHeight;
   
   [self addChild:pickerItem];
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
      default:
         NSLog(@"WARNING: Undefined HUD item type requested - not building UI");
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
   if (self = [super initWithSize:size
                      anchorPoint:anchorPoint])
   {
      [self setupSettingsLabel];
      NSArray * keyPaths = [NSArray arrayWithObjects:@"GridImages",
                                                     @"GenerationDuration",
                                                     @"SoundFX",
                                                     @"SmartMenu",
                                                     @"LoopDetection",
                                                     //@"GridImages",
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
   
   _nextControlPosition = CGPointMake(0, -(TOP_PADDING * 2 + HEADING_FONT_SIZE * 2));
}

@end
