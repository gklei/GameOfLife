//
//  GLColorHud.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/23/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLColorHud.h"
#import "GLColorGrid.h"
#import "GLGridScene.h"
#import "GLColorDropButton.h"
#import "GLColorSelectionLayer.h"
#import "GLColorPaletteManager.h"
#import "GLLockControl.h"

#define HUD_BUTTON_EDGE_PADDING 48
#define COLOR_DROP_PADDING 42
#define COLOR_DROP_CAPACITY 5
#define COLOR_DROP_SCALE .75
#define SELECTED_COLOR_DROP_SCALE 1.15
#define HIT_DIST_FROM_POSITION 4

#define BACKGROUND_ALPHA_SETTINGS_COLLAPSED .7
#define BACKGROUND_ALPHA_SETTINGS_EXPANDED .85

#define BOTTOM_BAR_HEIGHT 60
#define SETTINGS_HEIGHT BOTTOM_BAR_HEIGHT * 6 - 40
#define SETTINGS_EXPAND_COLLAPSE_DUATION .25
#define BOTTOM_BAR_EXPAND_COLLAPSE_DURATION .5
#define REPOSITION_BUTTONS_DURATION .25
#define WAIT_BEFORE_COLORIZE_DURATION .25

@interface GLColorHud() <GLColorGridDelegate>
{
   CGSize _defaultSize;
   SKSpriteNode *_backgroundLayer;

   GLUIActionButton  *_splashButton;
   GLUIActionButton  *_paletteButton;
   GLColorDropButton *_currentColorDrop;

   NSMutableArray *_colorDrops;
   GLLockControl *_lockControl;

   BOOL _shouldPlaySound;
   SKAction *_colorDropButtonSound;
   SKAction *_expandColorGridSound;
   SKAction *_collapseColorGridSound;

   GLColorSelectionLayer *_colorSelectionLayer;

   BOOL _shouldRunSplashButtonColorChangingAnimation;
   NSArray *_splashButtonColors;
   NSUInteger _splashButtonColorIndex;
}
@end

@implementation GLColorHud

- (void)observeSoundFxChanges
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"SoundFX"];
}

- (id)init
{
   if (self = [super init])
   {
      [self setupVariables];
      [self setupBackgorundWithSize:_defaultSize];
      [self setupColorSelectionLayerWithSize:_defaultSize];
      [self setupSplashButton];
      [self setupSplashButtonColorChangingAnimation];
      [self addColorDrops];
      [self setupPaletteButton];

      [_colorSelectionLayer.colorGrid updateSelectedColorName:_currentColorName];
      [self runSplashButtonColorChangeAnimation];
      [self observeSoundFxChanges];
   }
   return self;
}

- (void)setupVariables
{
   _defaultSize = CGSizeMake(CGRectGetWidth([UIScreen mainScreen].bounds),
                             CGRectGetHeight([UIScreen mainScreen].bounds));
   _colorDropButtonSound = [SKAction playSoundFileNamed:@"color.change.wav" waitForCompletion:NO];
   _expandColorGridSound = [SKAction playSoundFileNamed:@"settings.expand.2.wav" waitForCompletion:NO];
   _collapseColorGridSound = [SKAction playSoundFileNamed:@"settings.collapse.2.wav" waitForCompletion:NO];
}

- (void)setupBackgorundWithSize:(CGSize)size
{
   _backgroundLayer = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor]
                                                   size:_defaultSize];
   _backgroundLayer.colorBlendFactor = 1.0;
   _backgroundLayer.alpha = .8;
   _backgroundLayer.anchorPoint = CGPointMake(0, 1);
   _backgroundLayer.position = CGPointMake(0, 60);
   _backgroundLayer.name = @"color_hud_background";
   [self addChild:_backgroundLayer];
}

- (void)setupColorSelectionLayerWithSize:(CGSize)size
{
   CGSize colorSelectionLayerSize = CGSizeMake(size.width, SETTINGS_HEIGHT);
   _colorSelectionLayer = [[GLColorSelectionLayer alloc] initWithSize:colorSelectionLayerSize
                                                          anchorPoint:_backgroundLayer.anchorPoint];
   _colorSelectionLayer.alpha = 5;
   _colorSelectionLayer.hidden = YES;
   _colorSelectionLayer.name = @"color_selection_layer";
   _colorSelectionLayer.colorGrid.colorGridDelegate = self;
   [_backgroundLayer addChild:_colorSelectionLayer];
}

- (BOOL)usingRetinaDisplay
{
   return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
           ([UIScreen mainScreen].scale == 2.0));
}

- (void)setupSplashButton
{
   _splashButton = [GLUIActionButton spriteNodeWithImageNamed:@"splash2_48.png"];
   [_splashButton setScale:.66666666667];
   _splashButton.colorBlendFactor = 1.0;
   _splashButton.position = CGPointMake(HUD_BUTTON_EDGE_PADDING - _splashButton.size.width/2.0 - 2,
                                        HUD_BUTTON_EDGE_PADDING - _splashButton.size.height/2.0);
   _splashButton.name = @"splash";
   ActionBlock splashButtonActionBlock = ^
   {
      if (!self.isAnimating)
         [self toggle];
   };
   _splashButton.actionBlock = splashButtonActionBlock;


   [self addChild:_splashButton];
}

- (void)setupSplashButtonColorChangingAnimation
{
   _shouldRunSplashButtonColorChangingAnimation = YES;
   _splashButtonColorIndex = 0;
   _splashButtonColors = @[[SKColor crayolaFreshAirColor], [SKColor crayolaCeruleanColor], [SKColor crayolaBlueColor],
                           [SKColor crayolaIndigoColor], [SKColor crayolaOceanBluePearlColor], [SKColor crayolaGrannySmithAppleColor],
                           [SKColor crayolaScreaminGreenColor], [SKColor crayolaMagicMintColor] , [SKColor crayolaCaribbeanGreenColor],
                           [SKColor crayolaMetallicSeaweedColor], [SKColor crayolaPeachColor], [SKColor crayolaKeyLimePearlColor],
                           [SKColor crayolaLimeColor], [SKColor crayolaChocolateColor], [SKColor crayolaDandelionColor],
                           [SKColor crayolaSunglowColor], [SKColor crayolaMangoTangoColor], [SKColor crayolaOrangeRedColor],
                           [SKColor crayolaBigDipORubyColor], [SKColor crayolaMelonColor], [SKColor crayolaMauvelousColor],
                           [SKColor crayolaOrchidColor], [SKColor crayolaPinkFlamingoColor], [SKColor crayolaWinterSkyColor]];
}

- (void)runSplashButtonColorChangeAnimation
{
   if (_shouldRunSplashButtonColorChangingAnimation)
   {
      SKColor *nextColor = [_splashButtonColors objectAtIndex:(_splashButtonColorIndex++ % _splashButtonColors.count)];
      SKAction *changeColor = [SKAction colorizeWithColor:nextColor colorBlendFactor:1.0 duration:1.5];
      [_splashButton runAction:changeColor
                    completion:
       ^{
          [self runSplashButtonColorChangeAnimation];
       }];
   }
   else
   {
      SKAction *colorizeToWhite = [SKAction colorizeWithColor:[SKColor whiteColor]
                                             colorBlendFactor:1.0
                                                     duration:.25];
      [_splashButton runAction:colorizeToWhite];
   }
}

- (void)setupPaletteButton
{
   _paletteButton = [GLUIActionButton spriteNodeWithImageNamed:@"palette_48.png"];
   _paletteButton.colorBlendFactor = 1.0;
   _paletteButton.alpha = 1.0;
   _paletteButton.color = [SKColor whiteColor];
   [_paletteButton setScale:.66666666667];
   _paletteButton.position = CGPointMake(HUD_BUTTON_EDGE_PADDING - _splashButton.size.width/2.0 - 2,
                                         -_splashButton.size.height/2.0);
   _paletteButton.name = @"palette";

   ActionBlock paletteButtonActionBlock = ^
   {
      if (!self.isAnimating)
         [self toggleColorGrid];
   };
   _paletteButton.actionBlock = paletteButtonActionBlock;
   
   [self addChild:_paletteButton];
}

- (void)initCurrentColorDrop
{
   // get the current color name
   CrayolaColorName colorName = [[[NSUserDefaults standardUserDefaults]
                                  objectForKey:@"GridLiveColorName"]
                                 unsignedIntValue];
   
   // find a drop with that color
   if ([SKColor colorForCrayolaColorName:colorName])
   {
      for (GLColorDropButton * drop in _colorDrops)
      {
         if (drop.colorName == colorName)
         {
            _currentColorDrop = drop;
            _currentColorName = colorName;
            return;
         }
      }
   }
   
   // no match, so just pick the first drop and use that color
   NSLog(@"Failed to find a color drop with the color:%d", colorName);
   _currentColorDrop = _colorDrops.firstObject;
   [self updateCurrentColorName:_currentColorDrop.colorName];
}

- (void)addColorDrops
{
   NSArray *colorDropColors = nil;
   _colorDrops = [NSMutableArray arrayWithCapacity:COLOR_DROP_CAPACITY];
   if ([GLColorPaletteManager sharedManager].hasStoredPalette)
   {
      colorDropColors = [GLColorPaletteManager sharedManager].storedColorPalette;
   }
   else
   {
      colorDropColors = @[[NSNumber numberWithUnsignedInt:CCN_crayolaCeruleanColor],
                          [NSNumber numberWithUnsignedInt:CCN_crayolaCaribbeanGreenColor],
                          [NSNumber numberWithUnsignedInt:CCN_crayolaLimeColor],
                          [NSNumber numberWithUnsignedInt:CCN_crayolaOrangeRedColor],
                          [NSNumber numberWithUnsignedInt:CCN_crayolaPinkFlamingoColor]];

      [GLColorPaletteManager sharedManager].storedColorPalette = colorDropColors;
   }

   for (int i = 0; i < COLOR_DROP_CAPACITY; ++i)
   {
      if (i == COLOR_DROP_CAPACITY - 1)
      {
         _lockControl = [[GLLockControl alloc] init];
         _lockControl.position = CGPointMake(i*COLOR_DROP_PADDING + 78,
                                             -_lockControl.size.height/2.0 - 5);
         [_colorDrops insertObject:_lockControl atIndex:i];
         [self addChild:_lockControl];
      }
      else
      {
         GLColorDropButton *drop = ([self usingRetinaDisplay]) ?
            [GLColorDropButton spriteNodeWithImageNamed:@"droplet@2x.png"] :
            [GLColorDropButton spriteNodeWithImageNamed:@"droplet.png"];
         
         [drop setScale:COLOR_DROP_SCALE];
         drop.position = CGPointMake(i*COLOR_DROP_PADDING + 78, -drop.size.height/2.0 - 5);
         drop.colorBlendFactor = 1.0;
         drop.colorName = [((NSNumber *)[colorDropColors objectAtIndex:i]) unsignedIntValue];
         drop.alpha = .75;
         drop.hitBox.size = CGSizeMake(drop.hitBox.size.width, drop.hitBox.size.height + 10);

         ActionBlock colorDropActionBlock = ^{[self updateCurrentColorDrop:drop];};
         drop.actionBlock = colorDropActionBlock;

         [_colorDrops insertObject:drop atIndex:i];
         [self addChild:drop];
      }
   }
   
   [self initCurrentColorDrop];
}

- (void)setColorDropsHidden:(BOOL)hidden
{
   for (GLUIButton *node in _colorDrops)
      node.hidden = hidden;

   _paletteButton.hidden = hidden;
}

- (void)updateCurrentColorDrop:(GLColorDropButton *)colorDropButton
{
   if (_currentColorDrop != colorDropButton)
   {
      if (_shouldPlaySound) [self runAction:_colorDropButtonSound];
      
      SKAction *selectScaleAction = [SKAction scaleTo:SELECTED_COLOR_DROP_SCALE duration:.15];
      SKAction *deselectScaleAction = [SKAction scaleTo:COLOR_DROP_SCALE duration:.15];

      SKAction *selectAlphaAction = [SKAction fadeAlphaTo:1.0 duration:.15];
      SKAction *deselectAlphaAction = [SKAction fadeAlphaTo:.75 duration:.15];

      SKAction *selectAnimation = [SKAction group:@[selectScaleAction, selectAlphaAction]];
      SKAction *deselectAnimation = [SKAction group:@[deselectScaleAction, deselectAlphaAction]];

      [_currentColorDrop runAction:deselectAnimation];
      [colorDropButton runAction:selectAnimation];

      _currentColorDrop = colorDropButton;
      _currentColorName = _currentColorDrop.colorName;
      [_colorSelectionLayer.colorGrid updateSelectedColorName:_currentColorName];
   }
}

- (void)expandColorGridWithCompletionBlock:(void (^)())completionBlock
{
   self.animating = YES;
   _colorGridIsExpanded = YES;

   SKAction *expand = [SKAction moveByX:0
                                      y:SETTINGS_HEIGHT
                               duration:SETTINGS_EXPAND_COLLAPSE_DUATION];
   SKAction *spin = [SKAction rotateByAngle:-M_PI
                                   duration:SETTINGS_EXPAND_COLLAPSE_DUATION];
   SKAction *changeBackgroundAlpha = [SKAction fadeAlphaTo:BACKGROUND_ALPHA_SETTINGS_EXPANDED
                                                  duration:SETTINGS_EXPAND_COLLAPSE_DUATION];

   SKAction *backgroundActions = [SKAction group:@[expand, changeBackgroundAlpha]];

   expand.timingMode = SKActionTimingEaseInEaseOut;
   spin.timingMode = SKActionTimingEaseInEaseOut;
   changeBackgroundAlpha.timingMode = SKActionTimingEaseInEaseOut;
   
   if (_shouldPlaySound) [self runAction:_expandColorGridSound];

   [_backgroundLayer runAction:backgroundActions
                    completion:
    ^{
       [self.delegate colorGridDidExpand];
       self.animating = NO;
    }];

   [self.delegate colorGridWillExpandWithRepositioningAction:expand];
   [_paletteButton runAction:spin completion:completionBlock];
}

- (void)collapseColorGridWithCompletionBlock:(void (^)())completionBlock
{
   self.animating = YES;
   _colorGridIsExpanded = NO;
   _colorSelectionLayer.hidden = YES;

   SKAction *collapse = [SKAction moveByX:0
                                        y:-(SETTINGS_HEIGHT)
                                 duration:SETTINGS_EXPAND_COLLAPSE_DUATION];
   SKAction *spin = [SKAction rotateByAngle:M_PI
                                   duration:SETTINGS_EXPAND_COLLAPSE_DUATION];
   SKAction *changeBackgroundAlpha = [SKAction fadeAlphaTo:BACKGROUND_ALPHA_SETTINGS_COLLAPSED
                                                  duration:SETTINGS_EXPAND_COLLAPSE_DUATION];

   SKAction *backgroundActions = [SKAction group:@[collapse, changeBackgroundAlpha]];

   collapse.timingMode = SKActionTimingEaseInEaseOut;
   spin.timingMode = SKActionTimingEaseInEaseOut;
   changeBackgroundAlpha.timingMode = SKActionTimingEaseInEaseOut;
   
   if (_shouldPlaySound) [self runAction:_collapseColorGridSound];
   
   [_backgroundLayer runAction:backgroundActions
                    completion:
    ^{
       [self.delegate colorGridDidExpand];
       self.animating = NO;
    }];

   [self.delegate colorGridWillCollapseWithRepositioningAction:collapse];
   [_paletteButton runAction:spin completion:completionBlock];
}

- (void)toggleColorGrid
{
   if (_colorGridIsExpanded)
   {
      _paletteButton.persistGlow = NO;
      [self collapseColorGridWithCompletionBlock:^
       {
          _colorSelectionLayer.hidden = YES;
       }];
   }
   else
   {
      _paletteButton.persistGlow = YES;
      [self expandColorGridWithCompletionBlock:^
       {
          if (_colorGridIsExpanded)
             _colorSelectionLayer.hidden = NO;
       }];
   }
}

- (void)expand
{
   if (![self.delegate hudCanExpand:self])
      return;
   
   self.animating = YES;
   CFTimeInterval waitPeriod = 0.0;
   [self.delegate hud:self willExpandAfterPeriod:&waitPeriod];

   SKAction *wait = [SKAction waitForDuration:waitPeriod];
   SKAction *slide = [SKAction moveByX:-_defaultSize.width + 60 y:0 duration:.5];
   SKAction *changeHudColor = [SKAction colorizeWithColor:[SKColor crayolaBlackCoralPearlColor]
                                      colorBlendFactor:1.0
                                              duration:.5];
   SKAction *changeButtonColor = [SKAction colorizeWithColor:[SKColor whiteColor]
                                            colorBlendFactor:1.0
                                                    duration:.5];
   SKAction *maintainPosition = [SKAction moveByX:(_defaultSize.width - 60) y:0 duration:.5];
   SKAction *rotate = [SKAction rotateByAngle:M_PI*2
                                     duration:.5];

   slide.timingMode = SKActionTimingEaseInEaseOut;
   changeHudColor.timingMode = SKActionTimingEaseInEaseOut;
   maintainPosition.timingMode = SKActionTimingEaseInEaseOut;
   rotate.timingMode = SKActionTimingEaseInEaseOut;

   SKAction *buttonActions = [SKAction group:@[changeButtonColor, rotate]];
   SKAction *backgroundActions = [SKAction group:@[changeHudColor, slide]];
   self.expanded = YES;
   [self runAction:wait
        completion:^
   {
      if (_shouldPlaySound) [self runAction:self.defaultExpandingSoundFX];

      [_backgroundLayer runAction:backgroundActions];

      for (GLUIButton *button in _colorDrops)
      {
         [button runAction:slide];
         [button.hitBox runAction:slide];
      }
      [_paletteButton runAction:slide];
      [_paletteButton.hitBox runAction:slide];

      _shouldRunSplashButtonColorChangingAnimation = NO;
      [_splashButton runAction:buttonActions
                    completion:^
      {
         SKAction *moveDrop = [SKAction moveByX:0 y:HUD_BUTTON_EDGE_PADDING duration:.2];
         moveDrop.timingMode = SKActionTimingEaseInEaseOut;
         for (GLUIButton *drop in _colorDrops)
         {
            drop.hidden = NO;
            [drop runAction:moveDrop];
            [drop.hitBox runAction:moveDrop];
         }

         _paletteButton.hidden = NO;
         [_paletteButton runAction:moveDrop];
         [_paletteButton.hitBox runAction:moveDrop];

         if (_currentColorDrop)
         {
            SKAction *wait = [SKAction waitForDuration:.2];
            SKAction *rescaleSelectedDrop = [SKAction scaleTo:SELECTED_COLOR_DROP_SCALE duration:.15];
            SKAction *scaleSequence = [SKAction sequence:@[wait, rescaleSelectedDrop]];
            [_currentColorDrop runAction:scaleSequence
                              completion:
             ^{
                _splashButton.color = [SKColor whiteColor];
                [self.delegate hudDidExpand:self];
             }];
         }
         else
         {
            _splashButton.color = [SKColor whiteColor];
            [self.delegate hudDidExpand:self];
         }
         self.animating = NO;
      }];
   }];
}

- (void)collapseBottomBar
{
   self.animating = YES;
   _shouldRunSplashButtonColorChangingAnimation = YES;
   [self runSplashButtonColorChangeAnimation];

   [self.delegate hudWillCollapse:self];

   SKAction *wait = [SKAction waitForDuration:.25];
   SKAction *slide = [SKAction moveByX:_defaultSize.width - 60 y:0 duration:.5];
   SKAction *changeHudColor = [SKAction colorizeWithColor:[SKColor clearColor]
                                      colorBlendFactor:1.0
                                              duration:.25];
   SKAction *maintainPosition = [SKAction moveByX:-(_defaultSize.width - 60) y:0
                                         duration:.5];
   SKAction *rotate = [SKAction rotateByAngle:-M_PI*2 duration:.5];

   slide.timingMode = SKActionTimingEaseInEaseOut;
   changeHudColor.timingMode = SKActionTimingEaseInEaseOut;
   maintainPosition.timingMode = SKActionTimingEaseInEaseOut;
   rotate.timingMode = SKActionTimingEaseInEaseOut;

   SKAction *hudBackgroundColorSequence = [SKAction sequence:@[wait, changeHudColor]];
   SKAction *hudBackgroundActions = [SKAction group:@[hudBackgroundColorSequence, slide]];
   SKAction *buttonActions = [SKAction group:@[rotate, wait]];

   self.expanded = NO;
   [self setColorDropsHidden:YES];
   [_splashButton runAction:buttonActions];

   for (GLUIButton *button in _colorDrops)
   {
      [button runAction:slide];
      [button.hitBox runAction:slide];
   }

   [_paletteButton runAction:slide];
   [_paletteButton.hitBox runAction:slide];

   if (_shouldPlaySound) [self runAction:self.defaultCollapsingSoundFX];
   
   [_backgroundLayer runAction:hudBackgroundActions
                    completion:^
   {
      [_currentColorDrop setScale:COLOR_DROP_SCALE];
      SKAction *moveDrop = [SKAction moveByX:0 y:-HUD_BUTTON_EDGE_PADDING duration:.25];
      for (GLUIButton *drop in _colorDrops)
      {
         [drop runAction:moveDrop];
         [drop.hitBox runAction:moveDrop];
      }

      [_paletteButton runAction:moveDrop];
      [_paletteButton.hitBox runAction:moveDrop];

      [self.delegate hudDidCollapse:self];
      self.animating = NO;
   }];
}

- (void)collapse
{
   if (_colorGridIsExpanded)
   {
      [_paletteButton loseFocus];
      SKAction *scaleDown = [SKAction scaleTo:COLOR_DROP_SCALE duration:.15];
      scaleDown.timingMode = SKActionTimingEaseInEaseOut;
      [_currentColorDrop runAction:scaleDown];
      [self collapseColorGridWithCompletionBlock:^
       {
          [self collapseBottomBar];
       }];
   }
   else
   {
      [self collapseBottomBar];
   }
}

- (void)toggle
{
   if (!self.expanded)
      [self expand];
   else
      [self collapse];
}

- (void)hide
{
   [self setColorDropsHidden:YES];
   _backgroundLayer.hidden = YES;
   _splashButton.hidden = YES;
   _paletteButton.hidden = YES;
}

- (void)show
{
   [self setColorDropsHidden:NO];
   _backgroundLayer.hidden = NO;
   _splashButton.hidden = NO;
   _paletteButton.hidden = NO;
}

- (NSArray *)getCurrentDropColorNames
{
   NSMutableArray *dropColors = [NSMutableArray arrayWithCapacity:_colorDrops.count];
   for (GLColorDropButton *drop in _colorDrops)
      [dropColors addObject:[NSNumber numberWithInt:drop.colorName]];

   return [NSArray arrayWithArray:dropColors];
}

- (void)updateCurrentColorName:(CrayolaColorName)colorName
{
   SKColor * color = [SKColor colorForCrayolaColorName:colorName];
   if (color)
   {
      _currentColorName = colorName;
      
      NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
      [defaults setObject:[NSNumber numberWithUnsignedInt:_currentColorName]
                   forKey:@"GridLiveColorName"];
   }
}

- (void)colorGridColorNameChanged:(CrayolaColorName)colorName
{
   BOOL colorExistsInCurrentPalette = NO;
   for (GLColorDropButton *drop in _colorDrops)
   {
      if (drop.colorName == colorName)
      {
         colorExistsInCurrentPalette = YES;
         [self updateCurrentColorDrop:drop];
         break;
      }
   }
   
   if (!colorExistsInCurrentPalette)
   {
      // these two things must happen in this order!
      _currentColorDrop.colorName = colorName;
      [GLColorPaletteManager sharedManager].storedColorPalette = [self getCurrentDropColorNames];
   }
   
   [self updateCurrentColorName:colorName];
}

- (void)settingChanged:(NSNumber *)value ofType:(HUDValueType)type forKeyPath:(NSString *)keyPath
{
   if ([keyPath compare:@"SoundFX"] == NSOrderedSame)
   {
      assert(type == HVT_BOOL);
      _shouldPlaySound = [value boolValue];
   }
}

@end
