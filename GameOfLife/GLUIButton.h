//
//  GLUIButton.h
//  GameOfLife
//
//  Created by Gregory Klein on 12/13/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "GLTouchHandler.h"

@protocol GLUIControlValueChangedDelegate <NSObject>
   - (void)controlValueChangedForKey:(NSString *)key;
@end

@interface GLUIButton : SKSpriteNode <GLTouchHandler>

- (NSString *)stringValue;
- (NSString *)longestPossibleStringValue;
- (CGRect)largestPossibleAccumulatedFrame;
- (void)glow;
- (void)loseFocus;

@property (nonatomic, readwrite) SKSpriteNode *hitBox;
@property (nonatomic, readwrite) BOOL hasFocus;
@property (retain, readwrite) id<GLUIControlValueChangedDelegate> delegate;
@property (nonatomic, readwrite) BOOL glowEnabled;
@property (nonatomic, readwrite) BOOL persistGlow;
@property (nonatomic, assign) BOOL scalesOnTouch;

@property (nonatomic, retain) SKSpriteNode *sprite;

@end
