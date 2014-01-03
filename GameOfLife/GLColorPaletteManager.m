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
   return [[NSUserDefaults standardUserDefaults] objectForKey:@"gl_color_palette_array"] != nil;
}

- (void)setStoredColorPalette:(NSArray *)storedColorPalette
{
   NSMutableArray *colorDataArray = [NSMutableArray arrayWithCapacity:storedColorPalette.count];
   for (UIColor *color in storedColorPalette)
   {
      NSData *colorEncodedObject = [NSKeyedArchiver archivedDataWithRootObject:color];
      [colorDataArray addObject:colorEncodedObject];
   }

   [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"gl_color_palette_array"];
   [[NSUserDefaults standardUserDefaults] setObject:colorDataArray forKey:@"gl_color_palette_array"];
}

- (NSArray *)storedColorPalette
{
   NSArray *colorDataArray = [[NSUserDefaults standardUserDefaults] objectForKey:@"gl_color_palette_array"];
   NSMutableArray *colorArray = [NSMutableArray arrayWithCapacity:colorDataArray.count];

   for (NSData *colorEncodedObject in colorDataArray)
   {
      UIColor *color = [NSKeyedUnarchiver unarchiveObjectWithData:colorEncodedObject];
      [colorArray addObject:color];
   }
   
   return [NSArray arrayWithArray:colorArray];
}

@end
