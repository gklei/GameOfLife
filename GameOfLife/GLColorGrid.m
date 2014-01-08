//
//  GLColorGrid.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/24/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLColorGrid.h"
#import "GLColorSwatch.h"
#import "UIColor+Crayola.h"

#include <vector>

#define COLOR_SWATCH_X_PADDING 18
#define COLOR_SWATCH_Y_PADDING 10
#define COLOR_SWATCH_SIZE CGSizeMake(40, 40)

@interface GLColorGrid() <GLColorSwatchSelection>
{
   std::vector<CrayolaColorName> _colorGridColors;
   NSMutableArray *_colorSwatches;
   GLColorSwatch *_selectedColorSwatch;
   SKSpriteNode *_swatchSelectionRing;
}
@end

@implementation GLColorGrid

- (id)initWithSize:(CGSize)size
{
   if (self = [super init])
   {
      _dimensions.columns = size.height;
      _dimensions.rows = size.width;
      [self setupColorGridColors];
      [self setupColorSwatches];
      [self setupSelectionRing];
   }
   return self;
}

- (void)setupColorGridColors
{
   _colorGridColors =
   {
      CCN_crayolaFreshAirColor, CCN_crayolaGrannySmithAppleColor, CCN_crayolaPeachColor, CCN_crayolaDandelionColor, CCN_crayolaMelonColor,
      CCN_crayolaCeruleanColor, CCN_crayolaScreaminGreenColor, CCN_crayolaKeyLimePearlColor, CCN_crayolaSunglowColor, CCN_crayolaMauvelousColor,
      CCN_crayolaBlueColor, CCN_crayolaMagicMintColor, CCN_crayolaElectricLimeColor, CCN_crayolaMangoTangoColor, CCN_crayolaOrchidColor,
      CCN_crayolaIndigoColor, CCN_crayolaCaribbeanGreenColor, CCN_crayolaLimeColor, CCN_crayolaOrangeRedColor, CCN_crayolaPinkFlamingoColor,
      CCN_crayolaOceanBluePearlColor, CCN_crayolaMetallicSeaweedColor, CCN_crayolaChocolateColor,  CCN_crayolaWinterSkyColor, CCN_crayolaBigDipORubyColor
   };
}

- (void)setupColorSwatches
{
   _colorSwatches = [[NSMutableArray alloc] initWithCapacity:_colorGridColors.size()];
   int colorIndex = 0;
   for (int yPos = 0; yPos < _dimensions.rows * (COLOR_SWATCH_SIZE.height + COLOR_SWATCH_Y_PADDING);
        yPos += COLOR_SWATCH_SIZE.height + COLOR_SWATCH_Y_PADDING)
   {
      for (int xPos = 0; xPos < _dimensions.columns * (COLOR_SWATCH_SIZE.width + COLOR_SWATCH_X_PADDING);
           xPos += COLOR_SWATCH_SIZE.width + COLOR_SWATCH_X_PADDING)
      {
         GLColorSwatch *swatch = [[GLColorSwatch alloc] init];
         swatch.swatchSelectionDelegate = self;
         swatch.position = CGPointMake(xPos, yPos);
         swatch.color = [SKColor colorForCrayolaColorName:_colorGridColors[colorIndex++]];
         [_colorSwatches addObject:swatch];

         [self addChild:swatch];
      }
   }
}

- (void)setupSelectionRing
{
   _swatchSelectionRing = [SKSpriteNode spriteNodeWithImageNamed:@"color-swatch-ring-outer.png"];
   [_swatchSelectionRing setScale:.7];

   SKEffectNode *glowEffect = [SKEffectNode node];
   CIFilter *filter = [CIFilter filterWithName:@"CIBloom"];
   [filter setValue:[NSNumber numberWithFloat:2.0f] forKey:@"inputIntensity"];
   [filter setValue:[NSNumber numberWithFloat:2.5f] forKey:@"inputRadius"];

   glowEffect.filter = filter;
   glowEffect.shouldEnableEffects = YES;
   [glowEffect addChild:_swatchSelectionRing];

   [self addChild:glowEffect];
}

- (void)moveSelectionRingToSwatch:(GLColorSwatch *)swatch
{
   BOOL sameX = (_selectedColorSwatch.position.x == swatch.position.x);
   BOOL sameY = (_selectedColorSwatch.position.y == swatch.position.y);

   _selectedColorSwatch = swatch;
   SKAction *moveX = [SKAction moveToX:_selectedColorSwatch.position.x
                              duration:(sameX)? 0 : .2];
   SKAction *moveY = [SKAction moveToY:_selectedColorSwatch.position.y
                              duration:(sameY)? 0 : .2];

   moveX.timingMode = SKActionTimingEaseInEaseOut;
   moveY.timingMode = SKActionTimingEaseInEaseOut;

   [_swatchSelectionRing runAction:[SKAction sequence:@[moveX, moveY]]];
}

- (void)swatchSelected:(GLColorSwatch *)swatch
{
   if (_selectedColorSwatch == swatch)
      return;

   if (_selectedColorSwatch == nil)
   {
      _selectedColorSwatch = swatch;
      _swatchSelectionRing.position = _selectedColorSwatch.position;
      _swatchSelectionRing.hidden = NO;
      [_colorGridDelegate colorGridColorChanged:_selectedColorSwatch.color];
      return;
   }

   [self moveSelectionRingToSwatch:swatch];
   [_colorGridDelegate colorGridColorChanged:_selectedColorSwatch.color];
}

- (void)updateSelectedColor:(UIColor *)newColor
{
   GLColorSwatch *nextSwatch = nil;
   for (GLColorSwatch *swatch in _colorSwatches)
      if ([swatch.color isEqual:newColor])
      {
         nextSwatch = swatch;
         break;
      }

   if (nextSwatch)
      [self swatchSelected:nextSwatch];
}

@end
