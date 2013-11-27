//
//  GLGeneralHud.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/24/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLGeneralHud.h"
#import "UIColor+Crayola.h"

#define HUD_BUTTON_EDGE_PADDING 48
#define HUD_BUTTON_PADDING 50

@interface GLGeneralHud()
{
   CGSize _defaultSize;
   SKSpriteNode *_backgroundLayer;
   NSMutableArray *_coreFunctionButtons;
}
@end

@implementation GLGeneralHud

- (id)init
{
   if (self = [super init])
   {
      _defaultSize = [UIScreen mainScreen].bounds.size;
      [self setupBackgroundWithSize:_defaultSize];
      [self setupButtons];
   }
   return self;
}

- (void)setupBackgroundWithSize:(CGSize)size
{
   _backgroundLayer = [SKSpriteNode spriteNodeWithColor:[SKColor crayolaBlackCoralPearlColor]
                                                   size:size];
   _backgroundLayer.colorBlendFactor = 1.0;
   _backgroundLayer.alpha = .65;
   _backgroundLayer.anchorPoint = CGPointMake(0, 1);
   _backgroundLayer.position = CGPointMake(0, 60);
   _backgroundLayer.name = @"general_hud_background";
   [self addChild:_backgroundLayer];
}

- (void)setupButtons
{
   SKSpriteNode *expandRightButton = [SKSpriteNode spriteNodeWithImageNamed:@"expand_right"];
   expandRightButton.color = [SKColor whiteColor];
   expandRightButton.alpha = _backgroundLayer.alpha;
   expandRightButton.colorBlendFactor = 1.0;
   [expandRightButton setScale:.23];
   expandRightButton.position = CGPointMake(_defaultSize.width - expandRightButton.size.width/2 - 15,
                                            HUD_BUTTON_EDGE_PADDING - expandRightButton.size.height/2);
   expandRightButton.name = @"expand_right";
   [self addChild:expandRightButton];
//
//   SKSpriteNode *clearButton = [SKSpriteNode spriteNodeWithImageNamed:@"clear"];
//   [clearButton setScale:.25];
//   clearButton.position = CGPointMake(HUD_POSITION_DEFAULT.x - _defaultSize.width +
//                                      HUD_BUTTON_EDGE_PADDING + HUD_BUTTON_PADDING - 5,
//                                      -clearButton.size.height/2.0);
//   clearButton.name = @"clear";
//   [self addChild:clearButton];
//
//   SKSpriteNode *refreshButton = [SKSpriteNode spriteNodeWithImageNamed:@"refresh"];
//   [refreshButton setScale:.25];
//   refreshButton.position = CGPointMake(HUD_POSITION_DEFAULT.x - _defaultSize.width +
//                                        HUD_BUTTON_EDGE_PADDING + HUD_BUTTON_PADDING + 60,
//                                        -refreshButton.size.height/2.0);
//   refreshButton.name = @"refresh";
//   [self addChild:refreshButton];
//
//   SKSpriteNode *startStopButton = [SKSpriteNode spriteNodeWithImageNamed:@"start"];
//   [startStopButton setScale:.25];
//   startStopButton.position = CGPointMake(HUD_POSITION_DEFAULT.x - _defaultSize.width +
//                                          HUD_BUTTON_EDGE_PADDING + HUD_BUTTON_PADDING + 125,
//                                          -startStopButton.size.height/2.0);
//   startStopButton.name = @"start_stop";
//   [self addChild:startStopButton];
//
//   SKSpriteNode *gearButton = [SKSpriteNode spriteNodeWithImageNamed:@"gear"];
//   [gearButton setScale:.25];
//   gearButton.position = CGPointMake(HUD_BUTTON_EDGE_PADDING - expandRightButton.size.width/2.0,
//                                     -gearButton.size.height/2.0);
//   gearButton.name = @"gear";
//   [self addChild:gearButton];
}

- (void)handleTouch:(UITouch *)touch moved:(BOOL)moved
{
}

@end
