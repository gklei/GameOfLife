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

@interface GLColorGrid()
{
   std::vector<CrayolaColorName> _colorGridColors;
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
   }
   return self;
}

- (void)setupColorGridColors
{
   _colorGridColors =
   {CCN_crayolaFreshAirColor, CCN_crayolaGrannySmithAppleColor, CCN_crayolaPeachColor, CCN_crayolaDandelionColor, CCN_crayolaMelonColor, //CCN_crayolaTimberwolfColor,
    CCN_crayolaCeruleanColor, CCN_crayolaScreaminGreenColor, CCN_crayolaKeyLimePearlColor, CCN_crayolaSunglowColor, CCN_crayolaMauvelousColor, //CCN_crayolaPewterBlueColor,
    CCN_crayolaBlueColor, CCN_crayolaMagicMintColor, CCN_crayolaElectricLimeColor, CCN_crayolaMangoTangoColor, CCN_crayolaOrchidColor, //CCN_crayolaSapphireColor,
      CCN_crayolaIndigoColor, CCN_crayolaCaribbeanGreenColor, CCN_crayolaLimeColor, CCN_crayolaOrangeRedColor, CCN_crayolaPinkFlamingoColor,// CCN_crayolaGrapeColor,
      //CCN_crayolaBlueVioletColor, CCN_crayolaRobinsEggBlueColor, CCN_crayolaPeridotColor, CCN_crayolaCherryColor, CCN_crayolaFrostbiteColor, //CCN_crayolaPurplePlumColor,
      CCN_crayolaOceanBluePearlColor, CCN_crayolaMetallicSeaweedColor, CCN_crayolaChocolateColor, CCN_crayolaBigDipORubyColor, CCN_crayolaWinterSkyColor// CCN_crayolaSoapColor
   };
//   vector<int> vec (arr, arr + sizeof(arr) / sizeof(arr[0]) );
}

- (void)setupColorSwatches
{
   int colorIndex = 0;
   for (int yPos = 0; yPos < _dimensions.rows * (COLOR_SWATCH_SIZE.height + COLOR_SWATCH_Y_PADDING);
        yPos += COLOR_SWATCH_SIZE.height + COLOR_SWATCH_Y_PADDING)
   {
      for (int xPos = 0; xPos < _dimensions.columns * (COLOR_SWATCH_SIZE.width + COLOR_SWATCH_X_PADDING);
           xPos += COLOR_SWATCH_SIZE.width + COLOR_SWATCH_X_PADDING)
      {
         GLColorSwatch *swatch = [[GLColorSwatch alloc] init];
         swatch.position = CGPointMake(xPos, yPos);
         swatch.color = [SKColor colorForCrayolaColorName:_colorGridColors[colorIndex++]];

         [self addChild:swatch];
      }
   }
}

@end
