//
//  GLAppDelegate.h
//  GameOfLife
//
//  Created by Gregory Klein on 11/1/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GLSettingsItem.h"

@interface GLAppDelegate : UIResponder <UIApplicationDelegate, GLSettingsItemValueChangedDelegate>

@property (strong, nonatomic) UIWindow *window;

@end
