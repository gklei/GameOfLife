//
//  GLColorHud.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/23/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLColorHud.h"
#import "UIColor+Crayola.h"
#import "GLGridScene.h"
#import "GLUIActionButton.h"

#define HUD_BUTTON_EDGE_PADDING 48
#define COLOR_DROP_PADDING 42
#define COLOR_DROP_CAPACITY 6
#define COLOR_DROP_SCALE .75
#define SELECTED_COLOR_DROP_SCALE 1.15
#define HIT_DIST_FROM_POSITION 4

@interface GLColorHud()
{
   CGSize _defaultSize;
   SKSpriteNode *_backgroundLayer;
   GLUIActionButton *_splashButton;
   GLUIActionButton *_currentColorDrop;

   NSMutableArray *_colorDrops;
   NSMutableArray *_colorDropHitBoxes;

   SKAction *_colorDropButtonSound;

   int _colorDropVerticalOffset;
}
@end

@implementation GLColorHud

- (id)init
{
   if (self = [super init])
   {
      _defaultSize = CGSizeMake([UIScreen mainScreen].bounds.size.width, 60.0);
      _colorDropButtonSound = [SKAction playSoundFileNamed:@"color.change.wav" waitForCompletion:NO];
      [self setupBackgorundWithSize:_defaultSize];
      [self setupButtons];
      [self addColorDrops];
   }
   return self;
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

- (BOOL)usingRetinaDisplay
{
   return ([[UIScreen mainScreen] respondsToSelector:@selector(displayLinkWithTarget:selector:)] &&
           ([UIScreen mainScreen].scale == 2.0));
}

- (void)setupButtons
{
   _splashButton = [GLUIActionButton spriteNodeWithImageNamed:@"splash"];
   [_splashButton setColor:[SKColor crayolaBlackCoralPearlColor]];
   _splashButton.colorBlendFactor = 1.0;
   _splashButton.alpha = _backgroundLayer.alpha;
   [_splashButton setScale:.25];
   _splashButton.position = CGPointMake(HUD_BUTTON_EDGE_PADDING - _splashButton.size.width/2.0,
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

-(void)addColorDrops
{
   _colorDrops = [NSMutableArray arrayWithCapacity:COLOR_DROP_CAPACITY];
   NSArray *colorDropColors = @[[SKColor crayolaCaribbeanGreenColor],
                                [SKColor crayolaRobinsEggBlueColor],
                                [SKColor crayolaRazzleDazzleRoseColor],
                                [SKColor crayolaSizzlingRedColor],
                                [SKColor crayolaNeonCarrotColor],
                                [SKColor crayolaLemonYellowColor]];

   for (int i=0; i<COLOR_DROP_CAPACITY; ++i)
   {
      GLUIActionButton *drop = ([self usingRetinaDisplay]) ? [GLUIActionButton spriteNodeWithImageNamed:@"droplet@2x.png"] :
                                                             [GLUIActionButton spriteNodeWithImageNamed:@"droplet.png"];
      [drop setScale:COLOR_DROP_SCALE];
      drop.position = CGPointMake(i*COLOR_DROP_PADDING + 30, -drop.size.height/2.0 - 5);
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
//      [_currentColorDrop.hitBox runAction:deselectAnimation];

      [colorDropButton runAction:selectAnimation];
//      [colorDropButton.hitBox runAction:selectAnimation];

      _currentColorDrop = colorDropButton;
      [self.delegate setCurrentColor:_currentColorDrop.color];
   }
}

- (CGFloat)horizontalDistanceFromNode:(SKNode *)node toPoint:(CGPoint)touchPt
{
   CGFloat result = FLT_MAX;
   
   if (node)
   {
      CGPoint nodePt = node.position;
      result = fabs(touchPt.x - nodePt.x);
   }
   
   return result;
}

- (CGFloat)getDistanceFromNearest:(NSUInteger *)nearestIdx
                      andNeighbor:(NSUInteger *)neighborIdx
                        FromTouch:(CGPoint)touchPt
{
   // find the nearest and neighbor indeces and the distance to the nearest
   CGFloat result = FLT_MAX;
   *nearestIdx = UINT_MAX;
   *neighborIdx = UINT_MAX;
   for (SKNode *node in _colorDropHitBoxes)
   {
      double thisDist = [self horizontalDistanceFromNode:node toPoint:touchPt];
      if (thisDist < result)
      {
         result = thisDist;
         *nearestIdx = [_colorDropHitBoxes indexOfObject:node];
         
         if (touchPt.x < node.position.x)
            *neighborIdx = (*nearestIdx > 0)? *nearestIdx - 1 : UINT_MAX;
         else
            *neighborIdx = (*nearestIdx < _colorDropHitBoxes.count - 2)? *nearestIdx + 1 : UINT_MAX;
      }
   }
   
   return result;
}

- (SKColor *) interpolatedColorFromIndex:(NSUInteger)idx
                             andDistance:(CGFloat)distance
                             toNeighbor:(NSUInteger)nextIdx
{
   // interpolate a color between two nodes
   SKColor * newClr = nil;
   
   SKNode * nearest = [_colorDropHitBoxes objectAtIndex:idx];
   SKNode * neighbor = [_colorDropHitBoxes objectAtIndex:nextIdx];
   if (nearest && neighbor)
   {
      CGFloat interpolateDist = fabs(distance) / fabs(neighbor.position.x - nearest.position.x);
      
      SKColor * nearClr = ((SKSpriteNode *)_colorDrops[idx]).color;
      SKColor * nextClr = ((SKSpriteNode *)_colorDrops[nextIdx]).color;
      
      CGFloat nearRed, nearGreen, nearBlue;
      CGFloat nextRed, nextGreen, nextBlue;
      
      if ([nearClr getRed:&nearRed green:&nearGreen blue:&nearBlue alpha:nil] &&
          [nextClr getRed:&nextRed green:&nextGreen blue:&nextBlue alpha:nil])
      {
         CGFloat newRed = nearRed + interpolateDist * (nextRed - nearRed);
         CGFloat newGreen = nearGreen + interpolateDist * (nextGreen - nearGreen);
         CGFloat newBlue = nearBlue + interpolateDist * (nextBlue - nearBlue);
         
         newClr = [UIColor colorWithRed:newRed green:newGreen blue:newBlue alpha:1.0];
      }
   }
   
   return newClr;
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
   SKAction *changeButtonAlpha = [SKAction fadeAlphaTo:1.0
                                              duration:.5];
   SKAction *changeButtonColor = [SKAction colorizeWithColor:[SKColor whiteColor]
                                            colorBlendFactor:1.0
                                                    duration:.5];
   SKAction *maintainPosition = [SKAction moveByX:(_defaultSize.width - 60) y:0 duration:.5];
   SKAction *rotate = [SKAction rotateByAngle:M_PI*2
                                     duration:.5];

   slide.timingMode = SKActionTimingEaseInEaseOut;
   changeHudColor.timingMode = SKActionTimingEaseInEaseOut;
   changeButtonAlpha.timingMode = SKActionTimingEaseInEaseOut;
   maintainPosition.timingMode = SKActionTimingEaseInEaseOut;
   rotate.timingMode = SKActionTimingEaseInEaseOut;

   SKAction *buttonActions = [SKAction group:@[changeButtonAlpha,
                                               changeButtonColor,
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

         if (_currentColorDrop)
         {
            SKAction *wait = [SKAction waitForDuration:.2];
            SKAction *rescaleSelectedDrop = [SKAction scaleTo:SELECTED_COLOR_DROP_SCALE duration:.15];
            SKAction *scaleSequence = [SKAction sequence:@[wait, rescaleSelectedDrop]];
            [_currentColorDrop runAction:scaleSequence completion:^{[self.delegate hudDidExpand:self];}];
         }
         else
         {
            [self.delegate hudDidExpand:self];
         }
         self.animating = NO;
      }];
   }];
}

- (void)collapse
{
   self.animating = YES;
   [self.delegate hudWillCollapse:self];

   SKAction *wait = [SKAction waitForDuration:.25];
   SKAction *slide = [SKAction moveByX:_defaultSize.width - 60 y:0 duration:.5];
   SKAction *changeHudColor = [SKAction colorizeWithColor:[SKColor clearColor]
                                      colorBlendFactor:1.0
                                              duration:.25];
   SKAction *changeButtonColor = [SKAction colorizeWithColor:[SKColor crayolaBlackCoralPearlColor]
                                            colorBlendFactor:1.0
                                                    duration:.25];
   SKAction *changeButtonAlpha = [SKAction fadeAlphaTo:_backgroundLayer.alpha
                                              duration:.25];
   SKAction *maintainPosition = [SKAction moveByX:-(_defaultSize.width - 60) y:0
                                         duration:.5];
   SKAction *rotate = [SKAction rotateByAngle:-M_PI*2 duration:.5];

   slide.timingMode = SKActionTimingEaseInEaseOut;
   changeHudColor.timingMode = SKActionTimingEaseInEaseOut;
   changeButtonColor.timingMode = SKActionTimingEaseInEaseOut;
   changeButtonAlpha.timingMode = SKActionTimingEaseInEaseOut;
   maintainPosition.timingMode = SKActionTimingEaseInEaseOut;
   rotate.timingMode = SKActionTimingEaseInEaseOut;

   SKAction *hudBackgroundColorSequence = [SKAction sequence:@[wait, changeHudColor]];
   SKAction *hudBackgroundActions = [SKAction group:@[hudBackgroundColorSequence, slide]];
   SKAction *buttonColorAnimations = [SKAction group:@[changeButtonAlpha, changeButtonColor]];
   SKAction *buttonColorSequence = [SKAction sequence:@[wait, buttonColorAnimations]];
   SKAction *buttonActions = [SKAction group:@[rotate, buttonColorSequence]];

   self.expanded = NO;
   [self setColorDropsHidden:YES];
   [_splashButton runAction:buttonActions];

   for (GLUIButton *button in _colorDrops)
   {
      [button runAction:slide];
      [button.hitBox runAction:slide];
   }

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

      [self.delegate hudDidCollapse:self];
      self.animating = NO;
   }];
}

- (void)toggle
{
   if (!self.expanded)
      [self expand];
   else
      [self collapse];
}

@end
