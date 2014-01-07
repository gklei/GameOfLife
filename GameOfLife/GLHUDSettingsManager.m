//
//  GLHUDSettingsManager.m
//  GameOfLife
//
//  Created by Leif Alton on 12/18/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLHUDSettingsManager.h"


//
// the one and only GLHUDSettingsManager
//
GLHUDSettingsManager * g_globalHUDSettigsManager = nil;


//
// class HUDItemDescription
//
@implementation HUDItemDescription

@end

//
// class HUDPickerItemDescription
//
@implementation HUDPickerItemDescription

@end

//
// class GLHUDSettingsManager
//
@interface GLHUDSettingsManager()
{
   NSMutableDictionary * _hudItems;
   NSMutableDictionary * _lastValueForKey;
   NSMutableDictionary * _observersForKey;
}

@end

@implementation GLHUDSettingsManager

#pragma mark - internal helper functions
- (NSInteger)indexOfObserver:(id<HUDSettingsObserver>)observer inArray:(NSMutableArray *) observers
{
   __block NSInteger result = NSNotFound;
   
   [observers enumerateObjectsUsingBlock:
       ^(id obj, NSUInteger idx, BOOL *stop)
       {
          if (obj == observers)
          {
             result = idx;
             *stop = YES;
          }
       }];
   
   return result;
}

- (BOOL)item:(HUDItemDescription *)item valueHasChanged:(NSNumber *)value
{
   if (item == nil)
      return NO;
   
   NSNumber * lastValue = [_lastValueForKey objectForKey:item.keyPath];
   if (lastValue == nil)
      return YES;
   
   switch (item.valueType)
   {
      case HVT_BOOL:
         if (lastValue.boolValue != value.boolValue) return YES;
         break;
      case HVT_FLOAT:
         if (lastValue.floatValue != value.floatValue) return YES;
         break;
      case HVT_DOUBLE:
         if (lastValue.doubleValue != value.doubleValue) return YES;
         break;
      case HVT_CHAR:
         if (lastValue.charValue != value.charValue) return YES;
         break;
      case HVT_UCHAR:
         if (lastValue.unsignedCharValue != value.unsignedCharValue) return YES;
         break;
      case HVT_SHORT:
         if (lastValue.shortValue != value.shortValue) return YES;
         break;
      case HVT_USHORT:
         if (lastValue.unsignedShortValue != value.unsignedShortValue) return YES;
         break;
      case HVT_INT:
         if (lastValue.intValue != value.intValue) return YES;
         break;
      case HVT_UINT:
         if (lastValue.unsignedIntValue != value.unsignedIntValue) return YES;
         break;
      case HVT_LONG:
         if (lastValue.longValue != value.longValue) return YES;
         break;
      case HVT_ULONG:
         if (lastValue.unsignedLongValue != value.unsignedLongValue) return YES;
         break;
      case HVT_LONGLONG:
         if (lastValue.longLongValue != value.longLongValue) return YES;
         break;
      case HVT_ULONGLONG:
         if (lastValue.unsignedLongLongValue != value.unsignedLongLongValue) return YES;
         break;
   }
   
   return NO;
}

#pragma mark - initialization
+ (GLHUDSettingsManager *)sharedSettingsManager;
{
   if (g_globalHUDSettigsManager == nil)
      g_globalHUDSettigsManager = [[GLHUDSettingsManager alloc] init];
      
   return g_globalHUDSettigsManager;
}

- (id)init
{
   if ((self = [super init]))
   {
      NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
      [center addObserver:self
                 selector:@selector(settingsChanged:)
                     name:NSUserDefaultsDidChangeNotification
                   object:nil];
      
      _hudItems        = [[NSMutableDictionary alloc] init];
      _lastValueForKey = [[NSMutableDictionary alloc] init];
      _observersForKey = [[NSMutableDictionary alloc] init];
   }
   
   return self;
}

#pragma mark - notification handler
- (void)notifyObserversThatItem:(HUDItemDescription *)item valueChanged:(NSNumber *)value
                   alwaysNotify:(BOOL)alwaysNotify
{
   if (item == nil || value == nil)
      return;
   
   NSMutableDictionary * observers = [_observersForKey objectForKey:item.keyPath];
   if (alwaysNotify || [self item:item valueHasChanged:value])
   {
      // save the current value
      [_lastValueForKey setObject:value forKey:item.keyPath];
      
      // notify observers of the new value
      for (id<HUDSettingsObserver> observer in observers)
         [observer settingChanged:value ofType:item.valueType forKeyPath:item.keyPath];
   }
}

- (void)notifyInitialValue:(NSNumber *) value forItem:(HUDItemDescription *) item
{
   [self notifyObserversThatItem:item valueChanged:value alwaysNotify:true];
}

- (void)settingsChanged:(NSNotification *)notification
{
   NSUserDefaults * defaults = (NSUserDefaults *)[notification object];
   NSArray * keys = [[defaults dictionaryRepresentation] allKeys];
   for (NSString * keyPath in keys)
   {
      HUDItemDescription * item = [_hudItems objectForKey:keyPath];
      if (item)
      {
         NSNumber * value = (NSNumber *)[defaults valueForKey:item.keyPath];
         [self notifyObserversThatItem:item valueChanged:value alwaysNotify:false];
      }
   }
}

#pragma mark - public functions
#pragma mark -

- (BOOL)addHudItem:(HUDItemDescription *)item
{
   if (item.keyPath == nil)
      return NO;
   
   if ([_hudItems objectForKey:item.keyPath])
      return NO;  // key already exists
   
   if (item.defaultvalue == nil)
      return NO;
   
   NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
   if (userDefaults)
   {
      // register the default value for the key
      NSDictionary * tmpDict =
         [NSDictionary dictionaryWithObject:item.defaultvalue forKey:item.keyPath];
      
      [userDefaults registerDefaults:tmpDict];
      
      // query the last saved value
      NSNumber * value = (NSNumber *)[userDefaults objectForKey:item.keyPath];
      if ([value isKindOfClass:[NSNumber class]])
      {
         [_hudItems setObject:item forKey:item.keyPath];
         [_lastValueForKey setObject:value forKey:item.keyPath];
         
         [self notifyInitialValue:value forItem:item];
         return YES;
      }
   }
   else
   {
      [_hudItems setObject:item forKey:item.keyPath];
      [_lastValueForKey setObject:item.defaultvalue forKey:item.keyPath];
      return YES;
   }
   
   return NO;
}

- (NSDictionary *)getHudItems
{
   return _hudItems;
}

- (HUDItemDescription *)getHudItemforKeyPath:(NSString *)keyPath
{
   return [_hudItems objectForKey:keyPath];
}

- (NSDictionary *)getHudItemsforKeyPaths:(NSArray *)keyPaths
{
   NSMutableDictionary * result = [[NSMutableDictionary alloc] init];
   for (NSString * key in keyPaths)
   {
      HUDItemDescription * item = [self getHudItemforKeyPath:key];
      if (item)
         [result setObject:item forKey:key];
   }
   
   return result;
}

#pragma mark adding observers
- (void)updateObserver:(id<HUDSettingsObserver>)observer forKeyPath:(NSString *)keyPath
{
   if (observer == nil || keyPath == nil)
      return;
   
   HUDItemDescription * item = [self getHudItemforKeyPath:keyPath];
   if (item)
   {
      NSNumber * lastValue = [_lastValueForKey objectForKey:item.keyPath];
      if (lastValue)
         [observer settingChanged:lastValue ofType:item.valueType forKeyPath:item.keyPath];
   }
}

- (BOOL)addObserver:(id<HUDSettingsObserver>)observer forKeyPath:(NSString *)keyPath
{
   // get the list of observers for this key
   NSMutableArray * observers = [_observersForKey objectForKey:keyPath];
   if (observers == nil)
   {
      // add an observer array for the key
      observers = [[NSMutableArray alloc] init];
      [_observersForKey setObject:observers forKey:keyPath];
   }
   
   // if the observer isn't in the list, add it
   if (NSNotFound == [self indexOfObserver:observer inArray:observers])
   {
      [observers addObject:observer];
      [self updateObserver:observer forKeyPath:keyPath];
   }
   
   return YES;
}

- (BOOL)addObserver:(id<HUDSettingsObserver>)observer forKeyPaths:(NSArray *)keyPaths
{
   BOOL result = NO;
   
   for (NSString * keyPath in keyPaths)
      if ([self addObserver:observer forKeyPath:keyPath])
         result = YES;
   
   return result;
}

#pragma mark removing observers
- (void)removeObserver:(id<HUDSettingsObserver>)observer forKeyPath:(NSString *)keyPath
{
   HUDItemDescription * item = [_hudItems objectForKey:keyPath];
   if (item == nil)
      return;  // no item with this keyPath to remove ourselves from
   
   // get the list of observers for this key
   NSMutableArray * observers = [_observersForKey objectForKey:keyPath];
   if (observers == nil)
      return;

   [observers removeObject:observer];
}

- (void)removeObserver:(id<HUDSettingsObserver>)observer forKeyPaths:(NSArray *)keyPaths
{
   for (NSString * keyPath in keyPaths)
      [self removeObserver:observer forKeyPath:keyPath];
}

- (void)removeObserver:(id<HUDSettingsObserver>)observer
{
   // relinquish observation of all keys
   NSArray * keys = [_hudItems allKeys];
   for (NSString * key in keys)
      [self removeObserver:observer forKeyPath:key];
}

@end
