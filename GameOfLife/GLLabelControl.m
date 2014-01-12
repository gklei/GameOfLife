//
//  GLLabelControl.m
//  GameOfLife
//
//  Created by Leif Alton on 1/11/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLLabelControl.h"


#pragma mark - private interface
@interface GLLabelControl()
{
   NSString *_preferenceKey;
   NSNumber * _hudValue;
   HUDValueType _hudValueType;
   NSString * _longestPossigleString;
}

@end


#pragma mark - private implementation
@implementation GLLabelControl

- (void)observeChangesForKey:(NSString *)key
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:key];
}

- (NSString *)calculateLongestPossibleString:(HUDItemRange)range
{
   NSString * minValue = nil;
   NSString * maxValue = nil;
   
   switch (_hudValueType)
   {
      case HVT_BOOL:
         return @"YES";
      case HVT_FLOAT:   // fall through
      case HVT_DOUBLE:
         minValue = [NSString stringWithFormat:@"%0.2f", range.minValue];
         maxValue = [NSString stringWithFormat:@"%0.2f", range.maxValue];
         break;
      case HVT_CHAR:    // fall through
      case HVT_UCHAR:
         return @"W";
      case HVT_SHORT:
      case HVT_USHORT:
         return @"256";
      case HVT_INT:
         minValue = [NSString stringWithFormat:@"%d", (int)range.minValue];
         maxValue = [NSString stringWithFormat:@"%d", (int)range.maxValue];
         break;
      case HVT_UINT:
         minValue = [NSString stringWithFormat:@"%u", (unsigned)range.minValue];
         maxValue = [NSString stringWithFormat:@"%u", (unsigned)range.maxValue];
         break;
      case HVT_LONG:
         minValue = [NSString stringWithFormat:@"%ld", (long)range.minValue];
         maxValue = [NSString stringWithFormat:@"%ld", (long)range.maxValue];
         break;
      case HVT_ULONG:
         minValue = [NSString stringWithFormat:@"%lu", (unsigned long)range.minValue];
         maxValue = [NSString stringWithFormat:@"%lu", (unsigned long)range.maxValue];
         break;
      case HVT_LONGLONG:
         minValue = [NSString stringWithFormat:@"%lld", (long long)range.minValue];
         maxValue = [NSString stringWithFormat:@"%lld", (long long)range.maxValue];
         break;
      case HVT_ULONGLONG:
         minValue = [NSString stringWithFormat:@"%llu", (unsigned long long)range.minValue];
         maxValue = [NSString stringWithFormat:@"%llu", (unsigned long long)range.maxValue];
         break;
      default:
         return @"";
   }
   
   if (minValue.length > maxValue.length) return minValue;
   if (maxValue) return maxValue;
   return @"";
}

- (id)initWithHUDItemDescription:(HUDItemDescription *)item
{
   if ([self init])
   {
      _hudValueType = item.valueType;
      _preferenceKey = item.keyPath;
      _longestPossigleString = [self calculateLongestPossibleString:item.range];
      
      [self observeChangesForKey:_preferenceKey];
   }
   
   return self;
}

- (NSString *)stringValue
{
   switch (_hudValueType)
   {
      case HVT_BOOL:
         return [_hudValue boolValue]? @"YES" : @"NO";
      case HVT_FLOAT:
         return [NSString stringWithFormat:@"%0.2f", [_hudValue floatValue]];
      case HVT_DOUBLE:
         return [NSString stringWithFormat:@"%0.4f", [_hudValue doubleValue]];
      case HVT_CHAR:
         return [NSString stringWithFormat:@"%c", [_hudValue charValue]];
      case HVT_UCHAR:
         return [NSString stringWithFormat:@"%c", [_hudValue unsignedCharValue]];
      case HVT_SHORT:
         return [NSString stringWithFormat:@"%d", [_hudValue shortValue]];
      case HVT_USHORT:
         return [NSString stringWithFormat:@"%u", [_hudValue unsignedShortValue]];
      case HVT_INT:
         return [NSString stringWithFormat:@"%d", [_hudValue intValue]];
      case HVT_UINT:
         return [NSString stringWithFormat:@"%d", [_hudValue unsignedIntValue]];
      case HVT_LONG:
         return [NSString stringWithFormat:@"%ld", [_hudValue longValue]];
      case HVT_ULONG:
         return [NSString stringWithFormat:@"%lu", [_hudValue unsignedLongValue]];
      case HVT_LONGLONG:
         return [NSString stringWithFormat:@"%lld", [_hudValue longLongValue]];
      case HVT_ULONGLONG:
         return [NSString stringWithFormat:@"%llu", [_hudValue unsignedLongLongValue]];
      default:
         return @"";
   }
   
   return @"";
}

- (NSString *)longestPossibleStringValue
{
   return _longestPossigleString;
}

- (void)handleTouchBegan:(UITouch *)touch
{
   [super handleTouchBegan:touch];
}

- (void)handleTouchMoved:(UITouch *)touch
{
}

- (void)handleTouchEnded:(UITouch *)touch
{
   [super handleTouchEnded:touch];
}

- (void)settingChanged:(NSNumber *)value ofType:(HUDValueType)type forKeyPath:(NSString *)keyPath
{
   if ([keyPath compare:_preferenceKey] == NSOrderedSame)
   {
      assert(type == _hudValueType);
      _hudValue = value;
      [self.delegate controlValueChangedForKey:_preferenceKey];
   }
}

- (NSUInteger)controlHeight
{
   return 40;
}

@end
