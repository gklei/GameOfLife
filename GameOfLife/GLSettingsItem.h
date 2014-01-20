//
//  GLSettingsItem.h
//  GameOfLife
//
//  Created by Gregory Klein on 12/15/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class GLUIButton;
@interface GLSettingsItem : SKSpriteNode

- (id)initWithTitle:(NSString *)title
            control:(GLUIButton *)control;
@end