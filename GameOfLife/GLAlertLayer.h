//
//  GLAlertLayer.h
//  GameOfLife
//
//  Created by Gregory Klein on 1/9/14. (made in Mexico)
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLMenuLayer.h"

typedef NS_ENUM(int, GL_ALERT_TEXT_ELEMENT)
{
   e_ALERT_TEXT_HEADER = 0,
   e_ALERT_TEXT_BODY
};

@interface GLAlertLayer : GLMenuLayer

@property (nonatomic, readonly) BOOL animating;
@property (nonatomic, assign) BOOL animatesInAndOut;

- (id)initWithHeader:(NSString *)header
                body:(NSString *)body;

- (void)addHeaderText:(NSString *)headerText;
- (void)addBodyText:(NSString *)bodyText;

- (void)showWithParent:(SKNode *)parent;
- (void)hide;

@end