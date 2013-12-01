//
//  GLSettingsLayer.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/1/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLSettingsLayer.h"

@interface GLSettingsLayer()
{
   SKSpriteNode *_backgroundLayer;
}
@end

@implementation GLSettingsLayer

- (id)initWithSize:(CGSize)size
{
   if (self = [super init])
   {
      SKLabelNode *settingsLabel = [SKLabelNode labelNodeWithFontNamed:@"AvenirNext-UltraLight"];

      settingsLabel.text = @"Settings";
      settingsLabel.colorBlendFactor = 1.0;
      settingsLabel.color = [SKColor whiteColor];
      settingsLabel.fontSize = 30;
      settingsLabel.position = CGPointMake(CGRectGetMidX(self.frame),
                                     CGRectGetMidY(self.frame));
      [self addChild:settingsLabel];
   }
   return self;
}

@end
