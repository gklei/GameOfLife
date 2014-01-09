//
//  GLColorPaletteManager.m
//  GameOfLife
//
//  Created by Gregory Klein on 1/1/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLColorPaletteManager.h"

//
// the one and only GLColorPaletteManager
//
GLColorPaletteManager * g_globalColorPaletteManager = nil;

@implementation GLColorPaletteManager

+ (GLColorPaletteManager *)sharedManager;
{
   if (g_globalColorPaletteManager == nil)
      g_globalColorPaletteManager = [[GLColorPaletteManager alloc] init];

   return g_globalColorPaletteManager;
}

- (BOOL)hasStoredPalette
{
   return [[NSUserDefaults standardUserDefaults] objectForKey:@"gl_stored_color_drops"] != nil;
}

- (void)setStoredColorPalette:(NSArray *)storedColorPalette
{
   [[NSUserDefaults standardUserDefaults] setObject:storedColorPalette forKey:@"gl_stored_color_drops"];
}

- (NSArray *)storedColorPalette
{
   NSArray *colorDataArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"gl_stored_color_drops"];
   return [NSArray arrayWithArray:colorDataArray];
}

@end
