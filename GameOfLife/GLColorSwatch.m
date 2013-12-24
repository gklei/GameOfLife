//
//  GLColorSwatch.m
//  GameOfLife
//
//  Created by Gregory Klein on 12/24/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLColorSwatch.h"

@interface GLColorSwatch()
{
   SKSpriteNode *_outerRing;
   SKSpriteNode *_innerFill;
}
@end

@implementation GLColorSwatch

- (id)init
{
   if (self = [super init])
   {
      [self setupSwatchImages];
      [self setupHitBox];
   }
   return self;
}

- (void)setupSwatchImages
{
   _outerRing = [SKSpriteNode spriteNodeWithImageNamed:@"color-swatch-ring-outer.png"];
   _outerRing.colorBlendFactor = 1.0;
   _outerRing.color = [SKColor whiteColor];
   [_outerRing setScale:.75];

   [self addChild:_outerRing];
}

- (void)setupHitBox
{
   self.hitBox.size = _outerRing.size;
   self.hitBox.position = _outerRing.position;
   [self addChild:self.hitBox];
}

@end
