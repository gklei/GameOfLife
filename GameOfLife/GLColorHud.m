//
//  GLColorHud.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/23/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLColorHud.h"
#import "UIColor+Crayola.h"
#import "GLColorGrid.h"
#import "GLGridScene.h"
#import "GLUIActionButton.h"
#import "GLColorSelectionLayer.h"

#define HUD_BUTTON_EDGE_PADDING 48
#define COLOR_DROP_PADDING 42
#define COLOR_DROP_CAPACITY 5
#define COLOR_DROP_SCALE .75
#define SELECTED_COLOR_DROP_SCALE 1.15
#define HIT_DIST_FROM_POSITION 4

#define BACKGROUND_ALPHA_SETTINGS_COLLAPSED .7
#define BACKGROUND_ALPHA_SETTINGS_EXPANDED .85

#define BOTTOM_BAR_HEIGHT 60
#define SETTINGS_HEIGHT BOTTOM_BAR_HEIGHT * 6//CGRectGetHeight([UIScreen mainScreen].bounds) - BOTTOM_BAR_HEIGHT
#define SETTINGS_EXPAND_COLLAPSE_DUATION .25
#define BOTTOM_BAR_EXPAND_COLLAPSE_DURATION .5
#define REPOSITION_BUTTONS_DURATION .25
#define WAIT_BEFORE_COLORIZE_DURATION .25

@interface GLColorHud() <GLColorGridDelegate>
{
   CGSize _defaultSize;
   SKSpriteNode *_backgroundLayer;

   GLUIActionButton *_splashButton;
   GLUIActionButton *_paletteButton;
   GLUIActionButton *_currentColorDrop;

   NSMutableArray *_colorDrops;
   NSMutableArray *_colorDropHitBoxes;

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

      [_colorSelectionLayer.colorGrid updateSelectedColor:_currentColor];
      [self runSplashButtonColorChangeAnimation];
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
   [_splashButton setColor:[SKColor crayolaBlackCoralPearlColor]];
   [_splashButton setScale:.66666666667];
   _splashButton.colorBlendFactor = 1.0;
   _splashButton.position = CGPointMake(HUD_BUTTON_EDGE_PADDING - _splashButton.size.width/2.0 - 2,
                                        HUD_BUTTON_EDGE_PADDING - _splashButton.size.height/2.0);
   _splashButton.name = @"splash";
   void (^splashButtonActionBlock)() = ^
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
                           [SKColor crayolaElectricLimeColor], [SKColor crayolaLimeColor], [SKColor crayolaChocolateColor],
                           [SKColor crayolaDandelionColor], [SKColor crayolaSunglowColor], [SKColor crayolaMangoTangoColor],
                           [SKColor crayolaOrangeRedColor], [SKColor crayolaBigDipORubyColor], [SKColor crayolaMelonColor],
                           [SKColor crayolaMauvelousColor], [SKColor crayolaOrchidColor], [SKColor crayolaPinkFlamingoColor],
                           [SKColor crayolaWinterSkyColor]];
}

- (void)runSplashButtonColorChangeAnimation
{
   if (_shouldRunSplashButtonColorChangingAnimation)
   {
      SKColor *nextColor = [_splashButtonColors objectAtIndex:(_splashButtonColorIndex++ % _splashButtonColors.count)];
      [_splashButton runAction:[SKAction colorizeWithColor:nextColor
                                          colorBlendFactor:1.0
                                                  duration:1.5]
                    completion:
       ^{
          [self runSplashButtonColorChangeAnimation];
       }];
   }
   else
   {
      [_splashButton runAction:[SKAction colorizeWithColor:[SKColor whiteColor]
                                          colorBlendFactor:1.0
                                                  duration:.25]];
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

   void (^paletteButtonActionBlock)() = ^
   {
      if (!self.isAnimating)
         [self toggleColorGrid];
   };
   _paletteButton.actionBlock = paletteButtonActionBlock;
   
   [self addChild:_paletteButton];
}

-(void)addColorDrops
{
   _colorDrops = [NSMutableArray arrayWithCapacity:COLOR_DROP_CAPACITY];
   NSArray *colorDropColors = @[[SKColor crayolaCeruleanColor],
                                [SKColor crayolaCaribbeanGreenColor],
                                [SKColor crayolaLimeColor],
                                [SKColor crayolaOrangeRedColor],
                                [SKColor crayolaPinkFlamingoColor]];

   for (int i=0; i<COLOR_DROP_CAPACITY; ++i)
   {
      GLUIActionButton *drop = ([self usingRetinaDisplay]) ? [GLUIActionButton spriteNodeWithImageNamed:@"droplet@2x.png"] :
                                                             [GLUIActionButton spriteNodeWithImageNamed:@"droplet.png"];
      [drop setScale:COLOR_DROP_SCALE];
      drop.position = CGPointMake(i*COLOR_DROP_PADDING + 78, -drop.size.height/2.0 - 5);
      drop.colorBlendFactor = 1.0;
      drop.color = colorDropColors[i];
      drop.alpha = .75;
      drop.hitBox.size = CGSizeMake(drop.hitBox.size.width, drop.hitBox.size.height + 10);

      void (^colorDropActionBlock)() = ^{[self updateCurrentColorDrop:drop];};
      drop.actionBlock = colorDropActionBlock;

      [_colorDrops insertObject:drop atIndex:i];
      [self addChild:drop];
   }
   _currentColorDrop = _colorDrops.firstObject;
   _currentColor = _currentColorDrop.color;
}

- (void)setColorDropsHidden:(BOOL)hidden
{
   for (GLUIButton *node in _colorDrops)
      node.hidden = hidden;

   _paletteButton.hidden = hidden;
}

- (void)updateCurrentColorDrop:(GLUIActionButton *)colorDropButton
{
   if (_currentColorDrop != colorDropButton)
   {
      [self runAction:_colorDropButtonSound];
      SKAction *selectScaleAction = [SKAction scaleTo:SELECTED_COLOR_DROP_SCALE duration:.15];
      SKAction *deselectScaleAction = [SKAction scaleTo:COLOR_DROP_SCALE duration:.15];

      SKAction *selectAlphaAction = [SKAction fadeAlphaTo:1.0 duration:.15];
      SKAction *deselectAlphaAction = [SKAction fadeAlphaTo:.75 duration:.15];

      SKAction *selectAnimation = [SKAction group:@[selectScaleAction, selectAlphaAction]];
      SKAction *deselectAnimation = [SKAction group:@[deselectScaleAction, deselectAlphaAction]];

      [_currentColorDrop runAction:deselectAnimation];
      [colorDropButton runAction:selectAnimation];

      _currentColorDrop = colorDropButton;
      _currentColor = _currentColorDrop.color;
      [_colorSelectionLayer.colorGrid updateSelectedColor:_currentColorDrop.color];
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


   [self runAction:_expandColorGridSound];
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


   [self runAction:_collapseColorGridSound];
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
          {
             _colorSelectionLayer.hidden = NO;
          }
       }];
   }
}

- (void)expand
{
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

   SKAction *buttonActions = [SKAction group:@[changeButtonColor,
                                               rotate]];
   SKAction *backgroundActions = [SKAction group:@[changeHudColor,
                                                   slide]];
   self.expanded = YES;
   [self runAction:wait
        completion:^
   {
      [self runAction:self.defaultExpandingSoundFX];

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
   _shouldRunSplashButtonColorChangingAnimation = YES;
   [self runSplashButtonColorChangeAnimation];

   self.animating = YES;
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

   [self runAction:self.defaultCollapsingSoundFX];
   
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

- (void)colorGridColorChanged:(UIColor *)newColor
{
   BOOL colorExistsInCurrentPalette = NO;
   for (GLUIActionButton *drop in _colorDrops)
   {
      if ([drop.color isEqual:newColor])
      {
         colorExistsInCurrentPalette = YES;
         [self updateCurrentColorDrop:drop];
         break;
      }
   }

   if (!colorExistsInCurrentPalette)
      _currentColorDrop.color = newColor;
   
   _currentColor = newColor;
   [self.delegate setCurrentColor:newColor];
}

@end
