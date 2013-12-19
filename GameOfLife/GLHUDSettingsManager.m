//
//  GLHUDSettingsManager.m
//  GameOfLife
//
//  Created by Leif Alton on 12/18/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLHUDSettingsManager.h"

@implementation HUDItemDescription

@end

@interface GLHUDSettingsManager()
{
   NSMutableDictionary * _hudItems;
   NSMutableDictionary * _observersForKey;
}

@end

// TODO:LEA: store last known value and only notifiy observers if the value
//           differs from the last known value
@implementation GLHUDSettingsManager

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

- (id)init
{
   if ((self = [super init]))
   {
      NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
      [center addObserver:self
                 selector:@selector(defaultsChanged:)
                     name:NSUserDefaultsDidChangeNotification
                   object:nil];
   }
   
   return self;
}

- (BOOL)addHudItem:(HUDItemDescription *)item
{
   if ([_hudItems objectForKey:item.keyPath])
      return NO;
   
   [_hudItems setObject:item forKey:item.keyPath];
   return YES;
}

- (void)defaultsChanged:(NSNotification *)notification
{
   NSUserDefaults *defaults = (NSUserDefaults *)[notification object];
   NSArray * keys = [[defaults dictionaryRepresentation] allKeys];
   for (NSString * keyPath in keys)
   {
      HUDItemDescription * item = [_hudItems objectForKey:keyPath];
      if (item)
      {
         NSMutableDictionary * observers = [_observersForKey objectForKey:keyPath];
         NSNumber * value = (NSNumber *)[defaults valueForKey:keyPath];
         for (id<HUDSettingsObserver> observer in observers)
            [observer settingChanged:value ofType:item.valueType forKeyPath:keyPath];
      }
   }
}

- (BOOL)addObserver:(id<HUDSettingsObserver>)observer forKeyPath:(NSString *)keyPath
{
   HUDItemDescription * item = [_hudItems objectForKey:keyPath];
   if (item == nil)
      return NO;  // no item with this keyPath to observe
   
   // get the list of observers for this key
   NSMutableArray * observers = [_observersForKey objectForKey:keyPath];
   if (observers == nil)
   {
      // create an observer array and add the observer - one does not exist
      observers = [NSMutableArray arrayWithObject:observer];
      [_observersForKey setObject:observers forKey:keyPath];
      return YES;
   }
   
   // if the observer isn't in the list, add it
   if (NSNotFound == [self indexOfObserver:observer inArray:observers])
      [observers addObject:observer];
   
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

- (BOOL)addObserver:(id<HUDSettingsObserver>)observer
{
   BOOL result = NO;
   
   // observe all keys
   NSArray * keys = [_hudItems allKeys];
   for (NSString * key in keys)
      if ([self addObserver:observer forKeyPath:key])
         result = YES;
   
   return result;
}

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
