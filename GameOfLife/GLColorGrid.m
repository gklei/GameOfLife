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
   NSArray *_colorSwatches;
   GLColorSwatch *_selectedColorSwatch;
   SKSpriteNode *_swatchSelectionRing;

   SKAction *_upSoundFX;
   SKAction *_downSoundFX;
   SKAction *_singleMovementSoundFX;
   SKAction *_noMovementSoundFX;

   BOOL _shouldPlaySound;
}
@end

@implementation GLColorGrid

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

- (id)initWithSize:(CGSize)size
{
   if (self = [super init])
   {
      _dimensions.columns = size.height;
      _dimensions.rows = size.width;
      _soundEnabled = YES;

      [self setupColorSwatches];
      [self setupSelectionRing];
      [self setupSoundFX];
      [self observeSoundFxChanges];
   }
   return self;
}

- (void)setupSoundFX
{
   _upSoundFX = [SKAction playSoundFileNamed:@"color.grid.up.wav" waitForCompletion:NO];
   _downSoundFX = [SKAction playSoundFileNamed:@"color.grid.down.wav" waitForCompletion:NO];
   _singleMovementSoundFX = [SKAction playSoundFileNamed:@"color.grid.single.wav" waitForCompletion:NO];
   _noMovementSoundFX = [SKAction playSoundFileNamed:@"button.press.wav" waitForCompletion:NO];
}

- (void)setupColorGridColors
{
   // a 5x5 color grid
   _colorGridColors =
   {
      CCN_crayolaGoldenrodColor,  CCN_crayolaBittersweetColor,    CCN_crayolaTurquoiseBlueColor, CCN_crayolaMagicMintColor,        CCN_crayolaTanColor,
      CCN_crayolaSunglowColor,    CCN_crayolaWildWatermelonColor, CCN_crayolaCeruleanColor,      CCN_crayolaGrannySmithAppleColor, CCN_crayolaYellowColor,
      CCN_crayolaMangoTangoColor, CCN_crayolaFuchsiaColor,        CCN_crayolaBlueColor,          CCN_crayolaCaribbeanGreenColor,   CCN_crayolaElectricLimeColor,
      CCN_crayolaRedOrangeColor,  CCN_crayolaPinkFlamingoColor,   CCN_crayolaIndigoColor,        CCN_crayolaGreenColor,            CCN_crayolaScreaminGreenColor,
      CCN_crayolaBrickRedColor,   CCN_crayolaWinterSkyColor,      CCN_crayolaPurpleHeartColor,   CCN_crayolaPineGreenColor,        CCN_crayolaGrayColor
   };
}

- (void)setupColorSwatches
{
   if (_colorSwatches == nil)
   {
      [self setupColorGridColors];
      NSMutableArray * swatches = [[NSMutableArray alloc] initWithCapacity:_colorGridColors.size()];
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
            swatch.colorName = _colorGridColors[colorIndex++];
            [swatches addObject:swatch];

            [self addChild:swatch];
         }
      }
      
      _colorSwatches = [NSArray arrayWithArray:swatches];
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

   SKAction *playSound = _noMovementSoundFX;
   if (_selectedColorSwatch.position.y < swatch.position.y)
   {
      playSound = (_selectedColorSwatch.position.x == swatch.position.x)?
                   _singleMovementSoundFX : _upSoundFX;
   }
   else if (_selectedColorSwatch.position.y > swatch.position.y)
   {
      playSound = (_selectedColorSwatch.position.x == swatch.position.x)?
                   _singleMovementSoundFX : _downSoundFX;
   }
   else if (_selectedColorSwatch.position.x != swatch.position.x)
   {
      playSound = _singleMovementSoundFX;
   }

   _selectedColorSwatch = swatch;
   SKAction *moveX = [SKAction moveToX:_selectedColorSwatch.position.x
                              duration:(sameX)? 0 : .2];
   SKAction *moveY = [SKAction moveToY:_selectedColorSwatch.position.y
                              duration:(sameY)? 0 : .2];

   moveX.timingMode = SKActionTimingEaseInEaseOut;
   moveY.timingMode = SKActionTimingEaseInEaseOut;

   if (!self.parent.hidden && _soundEnabled && _shouldPlaySound)
      [self runAction:playSound];

   [_swatchSelectionRing runAction:[SKAction sequence:@[moveX, moveY]]];
   _soundEnabled = YES;
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
      
      [_colorGridDelegate colorGridColorNameChanged:_selectedColorSwatch.colorName];
      return;
   }

   [self moveSelectionRingToSwatch:swatch];
   [_colorGridDelegate colorGridColorNameChanged:_selectedColorSwatch.colorName];
}

- (void)updateSelectedColorName:(CrayolaColorName)colorName
{
   GLColorSwatch *nextSwatch = nil;
   for (GLColorSwatch *swatch in _colorSwatches)
      if (swatch.colorName == colorName)
      {
         nextSwatch = swatch;
         break;
      }
   
   if (nextSwatch)
      [self swatchSelected:nextSwatch];
}

@end
