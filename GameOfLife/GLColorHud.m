//
//  GLColorHud.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/23/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLColorHud.h"
#import "UIColor+Crayola.h"

#define HUD_BUTTON_EDGE_PADDING 48
#define COLOR_DROP_PADDING 44
#define COLOR_DROP_CAPACITY 6
#define COLOR_DROP_SCALE .23
#define SELECTED_COLOR_DROP_SCALE .3
#define HIT_DIST_FROM_POSITION 4

@interface GLColorHud()
{
   CGSize _defaultSize;
   SKSpriteNode *_backgroundLayer;
   SKSpriteNode *_splashButton;
   SKSpriteNode *_currentColorDrop;

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
      [self addColorDropHitBoxes];
   }
   return self;
}

- (void)setupBackgorundWithSize:(CGSize)size
{
   _backgroundLayer = [SKSpriteNode spriteNodeWithColor:[SKColor clearColor]
                                                   size:_defaultSize];
   _backgroundLayer.colorBlendFactor = 1.0;
   _backgroundLayer.alpha = .7;
   _backgroundLayer.anchorPoint = CGPointMake(0, 1);
   _backgroundLayer.position = CGPointMake(0, 60);
   _backgroundLayer.name = @"color_hud_background";
   [self addChild:_backgroundLayer];
}

- (void)setupButtons
{
   _splashButton = [SKSpriteNode spriteNodeWithImageNamed:@"splash"];
   [_splashButton setColor:[SKColor crayolaBlackCoralPearlColor]];
   _splashButton.colorBlendFactor = 1.0;
   _splashButton.alpha = _backgroundLayer.alpha;
   [_splashButton setScale:.25];
   _splashButton.position = CGPointMake(HUD_BUTTON_EDGE_PADDING - _splashButton.size.width/2.0,
                                        HUD_BUTTON_EDGE_PADDING - _splashButton.size.height/2.0);
   _splashButton.name = @"splash";
   [self addChild:_splashButton];
}

-(void)addColorDrops
{
   _colorDrops = [NSMutableArray arrayWithCapacity:COLOR_DROP_CAPACITY];
   NSArray *colorDropColors = @[[SKColor crayolaCaribbeanGreenColor],
                                [SKColor crayolaBlueColor],
                                [SKColor crayolaRazzleDazzleRoseColor],
                                [SKColor crayolaSizzlingRedColor],
                                [SKColor crayolaNeonCarrotColor],
                                [SKColor crayolaLemonYellowColor]];

   for (int i=0; i<COLOR_DROP_CAPACITY; ++i)
   {
      SKSpriteNode *drop = [SKSpriteNode spriteNodeWithImageNamed:@"drop"];
      [drop setScale:COLOR_DROP_SCALE];
      drop.position = CGPointMake(i*COLOR_DROP_PADDING + 23, -drop.size.height/2.0);
      drop.colorBlendFactor = 1.0;
      drop.color = colorDropColors[i];
      drop.alpha = .75;
      [_colorDrops insertObject:drop atIndex:i];
      [self addChild:drop];
   }
   _currentColorDrop = _colorDrops.firstObject;
   _currentColor = _currentColorDrop.color;
}

- (void)addColorDropHitBoxes
{
   _colorDropHitBoxes = [NSMutableArray arrayWithCapacity:COLOR_DROP_CAPACITY];
   for (int i=0; i<COLOR_DROP_CAPACITY; ++i)
   {
      SKSpriteNode *dropHitBox =
         [SKSpriteNode spriteNodeWithColor:[SKColor crayolaSizzlingRedColor]
                                      size:CGSizeMake(_defaultSize.width/(_colorDrops.count + 2),
                                                      60)];
      
      dropHitBox.position = CGPointMake(i*COLOR_DROP_PADDING + 23, -dropHitBox.size.height/2.0);
      dropHitBox.colorBlendFactor = 1.0;
      dropHitBox.color = ((SKSpriteNode *)_colorDrops[i]).color;
      dropHitBox.alpha = 0;
      [_colorDropHitBoxes insertObject:dropHitBox atIndex:i];
      [self addChild:dropHitBox];
   }
}

- (void)setColorDropsHidden:(BOOL)hidden
{
   for (SKNode *node in _colorDrops)
      node.hidden = hidden;
}

- (void)updateCurrentColorDrop:(SKSpriteNode *)hitBox
{
   SKSpriteNode *drop = _colorDrops[[_colorDropHitBoxes indexOfObject:hitBox]];
   if (_currentColorDrop != drop)
   {
      [self runAction:_colorDropButtonSound];
      SKAction *selectScaleAction = [SKAction scaleTo:SELECTED_COLOR_DROP_SCALE duration:.15];
      SKAction *deselectScaleAction = [SKAction scaleTo:COLOR_DROP_SCALE duration:.15];

      SKAction *selectAlphaAction = [SKAction fadeAlphaTo:1.0 duration:.15];
      SKAction *deselectAlphaAction = [SKAction fadeAlphaTo:.75 duration:.15];

      SKAction *selectAnimation = [SKAction group:@[selectScaleAction, selectAlphaAction]];
      SKAction *deselectAnimation = [SKAction group:@[deselectScaleAction, deselectAlphaAction]];

      [_currentColorDrop runAction:deselectAnimation];
      [drop runAction:selectAnimation];
      _currentColorDrop = drop;
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

- (void)handleTouch:(UITouch *)touch moved:(BOOL)moved
{
   SKNode * node = [self nodeAtPoint:[touch locationInNode:self]];

   if ([node.name isEqualToString:@"splash"] && !moved)
   {
      [self toggle];
   }
   else if ([_colorDropHitBoxes containsObject:node] && self.isExpanded)
   {
//      CGPoint touchPt = [touch locationInNode:self];
//      if (fabs(node.position.x - touchPt.x) < HIT_DIST_FROM_POSITION &&
//          [_colorDropHitBoxes containsObject:node])
//      {
         [self updateCurrentColorDrop:(SKSpriteNode *)node];
//      }
//      else
//      {
//         NSUInteger nearestIdx;
//         NSUInteger neighborIdx;
//         CGFloat distance = [self getDistanceFromNearest:&nearestIdx
//                                             andNeighbor:&neighborIdx
//                                               FromTouch:touchPt];
//         if (neighborIdx != UINT_MAX)
//            [self.delegate setCurrentColor:[self interpolatedColorFromIndex:nearestIdx
//                                                                andDistance:distance
//                                                                 toNeighbor:neighborIdx]];
//      }
   }
}

- (void)expand
{
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

      for (SKNode *button in _colorDrops)
         [button runAction:slide];

      for (SKNode *hitBox in _colorDropHitBoxes)
         [hitBox runAction:slide];

      [_splashButton runAction:buttonActions
                    completion:^
      {
         SKAction *moveDrop = [SKAction moveByX:0 y:HUD_BUTTON_EDGE_PADDING duration:.2];
         SKAction *moveDropHitBox = [SKAction moveByX:0 y:HUD_BUTTON_EDGE_PADDING + 12 duration:.2];
         moveDrop.timingMode = SKActionTimingEaseInEaseOut;
         for (SKNode *drop in _colorDrops)
         {
            drop.hidden = NO;
            [drop runAction:moveDrop];
         }

         for (SKNode *hitBox in _colorDropHitBoxes)
            [hitBox runAction:moveDropHitBox];

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
      }];
   }];
}

- (void)collapse
{
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

   for (SKNode *button in _colorDrops)
      [button runAction:slide];

   for (SKNode *hitBox in _colorDropHitBoxes)
      [hitBox runAction:slide];

   [self runAction:self.defaultCollapsingSoundFX];
   
   [_backgroundLayer runAction:hudBackgroundActions
                    completion:^
   {
      [_currentColorDrop setScale:COLOR_DROP_SCALE];
      SKAction *moveDrop = [SKAction moveByX:0 y:-HUD_BUTTON_EDGE_PADDING duration:.25];
      SKAction *moveDropHitBox = [SKAction moveByX:0 y:-(HUD_BUTTON_EDGE_PADDING + 12) duration:.2];
      for (SKNode *drop in _colorDrops)
         [drop runAction:moveDrop];

      for (SKNode *hitBox in _colorDropHitBoxes)
         [hitBox runAction:moveDropHitBox];

      [self.delegate hudDidCollapse:self];
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
