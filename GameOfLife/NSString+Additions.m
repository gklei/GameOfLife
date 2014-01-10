//
//  NSString+Additions.m
//  GameOfLife
//
//  Created by Gregory Klein on 1/10/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "NSString+Additions.h"

@implementation NSString (Additions)

+ (NSString *)futurizedString:(NSString *)string
{
   if (string == nil)
      return nil;

   NSMutableString *futurizedString = [NSMutableString string];

   for (int i = 0; i < string.length - 1; ++i)
      [futurizedString appendFormat:@"%c ", [string characterAtIndex:i]];

   int lastASCII = [string characterAtIndex:string.length - 1];
   [futurizedString appendFormat:@"%c", lastASCII];

   return futurizedString;
}

@end
