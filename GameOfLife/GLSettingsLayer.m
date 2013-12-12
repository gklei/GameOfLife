//
//  GLSettingsLayer.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/1/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLSettingsLayer.h"
#import "UIColor+Crayola.h"

#define TOP_PADDING 5
#define HEADING_FONT_SIZE 25

@interface GLSettingsLayer()
{
   SKSpriteNode *_backgroundLayer;
   CGSize _defaultSize;
   CGPoint _defaultAnchorPoint;
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
//      [self setupBackground];
      [self setupSettingsLabel];
      [self setupToggleButton];
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
//   NSLog(@"%@", [UIFont fontNamesForFamilyName:@"Futura"]);
   SKLabelNode *settingsLabel = [SKLabelNode labelNodeWithFontNamed:@"Futura-CondensedMedium"];

   settingsLabel.text = @"S E T T I N G S";
   settingsLabel.colorBlendFactor = 1.0;
   settingsLabel.color = [SKColor whiteColor];
   settingsLabel.alpha = 1;
   settingsLabel.fontSize = HEADING_FONT_SIZE;
   settingsLabel.position = CGPointMake(_defaultSize.width * 0.5,
                                        -(HEADING_FONT_SIZE + TOP_PADDING));
   [self addChild:settingsLabel];
}

- (void)setupToggleButton
{
   SKSpriteNode *toggleButton = [SKSpriteNode spriteNodeWithImageNamed:@"toggle-ring-outer@2x.png"];
   toggleButton.position = CGPointMake(_defaultSize.width * 0.5,
                                        -(HEADING_FONT_SIZE + TOP_PADDING + 50));
   SKSpriteNode *innerRing = [SKSpriteNode spriteNodeWithImageNamed:@"radio-unchecked@2x.png"];
   [innerRing setScale:.6];
   innerRing.position = CGPointMake(_defaultSize.width * 0.5 - 8,
                                    -(HEADING_FONT_SIZE + TOP_PADDING + 50));
   [self addChild:innerRing];
   [self addChild:toggleButton];
}

@end
