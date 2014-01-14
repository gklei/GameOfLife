//
//  GLHUDSettingsManager.h
//  GameOfLife
//
//  Created by Leif Alton on 12/18/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum
{
   HIT_NO_UI   = 0,
   HIT_LABEL   = 1,
   HIT_TOGGLER = 2,
   HIT_SLIDER  = 3,
   HIT_PICKER  = 4,
   HIT_SPACING = 5,
} HUDItemType;

typedef enum
{
   HVT_BOOL       = 0,
   HVT_FLOAT      = 1,
   HVT_DOUBLE     = 2,
   HVT_CHAR       = 3,
   HVT_UCHAR      = 4,
   HVT_SHORT      = 5,
   HVT_USHORT     = 6,
   HVT_INT        = 7,
   HVT_UINT       = 8,
   HVT_LONG       = 9,
   HVT_ULONG      = 10,
   HVT_LONGLONG   = 11,
   HVT_ULONGLONG  = 12,
} HUDValueType;

@protocol HUDSettingsObserver <NSObject>

- (void)settingChanged:(NSNumber *)value ofType:(HUDValueType)type forKeyPath:(NSString *)keyPath;

@end

typedef struct HUDItemRange
{
   double minValue;
   double maxValue;
} HUDItemRange;

NS_INLINE HUDItemRange HUDItemRangeMake(double minValue, double maxValue)
{
   HUDItemRange result;
   result.minValue = minValue;
   result.maxValue = maxValue;
   return result;
}

@interface HUDItemDescription : NSObject

@property (nonatomic, strong) NSString *   keyPath;
@property (nonatomic, strong) NSString *   label;
@property (nonatomic, assign) HUDItemRange range;
@property (nonatomic, assign) HUDItemType  type;
@property (nonatomic, strong) NSNumber *   defaultvalue;
@property (nonatomic, assign) HUDValueType valueType;

@end

@interface HUDPickerItemDescription : HUDItemDescription
   @property (nonatomic, strong) NSArray * imagePairs;
@end

@interface GLHUDSettingsManager : NSObject

+ (GLHUDSettingsManager *)sharedSettingsManager;

- (BOOL)addHudItem:(HUDItemDescription *)item;
- (NSDictionary *)getHudItems;
- (HUDItemDescription *)getHudItemforKeyPath:(NSString *)keyPath;
- (NSDictionary *)getHudItemsforKeyPaths:(NSArray *)keyPaths;

- (BOOL)addObserver:(id<HUDSettingsObserver>)observer forKeyPath:(NSString *)keyPath;
- (BOOL)addObserver:(id<HUDSettingsObserver>)observer forKeyPaths:(NSArray *)keyPaths;

- (void)removeObserver:(id<HUDSettingsObserver>)observer forKeyPath:(NSString *)keyPath;
- (void)removeObserver:(id<HUDSettingsObserver>)observer forKeyPaths:(NSArray *)keyPaths;
- (void)removeObserver:(id<HUDSettingsObserver>)observer;

@end
