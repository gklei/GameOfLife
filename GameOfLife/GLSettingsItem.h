//
//  GLSettingsItem.h
//  GameOfLife
//
//  Created by Gregory Klein on 12/15/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@protocol GLSettingsItemValueChangedDelegate <NSObject>
- (void)settingsValueChangedForKey:(NSString *)key;
@end

@class GLUIButton;

@interface GLSettingsItem : SKSpriteNode

- (id)initWithTitle:(NSString *)title
            control:(GLUIButton *)control;

@property (retain, readwrite) id<GLSettingsItemValueChangedDelegate> delegate;

@end