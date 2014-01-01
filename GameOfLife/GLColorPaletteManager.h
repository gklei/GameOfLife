//
//  GLColorPaletteManager.h
//  GameOfLife
//
//  Created by Gregory Klein on 1/1/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GLColorPaletteManager : NSObject

+ (GLColorPaletteManager *)sharedManager;

@property (nonatomic, readonly) BOOL hasStoredPalette;
@property (nonatomic, readwrite) NSArray *storedColorPalette;

@end
