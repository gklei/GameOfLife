//
//  GLPickerControl.m
//  GameOfLife
//
//  Created by Leif Alton on 1/6/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLPickerControl.h"
#import "GLTileNode.h"
#import "GLUIActionButton.h"
#import "UIColor+Crayola.h"


#define IMAGE_X_PADDING 40
#define IMAGE_Y_PADDING 15
#define IMAGES_PER_ROW  4
#define IMAGE_SIZE CGSizeMake(20, 20)


//
// GLPickerItem
//
@interface GLPickerItem : GLUIActionButton

@property (nonatomic, assign) NSUInteger imageIndex;
@property (nonatomic, strong) NSString * preferenceKey;

@end


@implementation GLPickerItem

+ (GLPickerItem *)itemWithTileNode:(GLTileNode *)tileNode
                        imageIndex:(NSUInteger)index
                  forPreferenceKey:(NSString *)preferenceKey
{
   GLPickerItem * item = [[GLPickerItem alloc] init];

   item.imageIndex = index;
   item.preferenceKey = preferenceKey;
   item.sprite = tileNode;

   CGSize size = tileNode.size;
   size.width += IMAGE_X_PADDING;
   size.height += IMAGE_Y_PADDING;
   item.hitBox.size = size;
   
   item.hitBox.position = tileNode.position;

   ActionBlock itemActionBlock = ^
   {
      NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
      [defaults setObject:[NSNumber numberWithUnsignedLong:item.imageIndex]
                   forKey:item.preferenceKey];
   };
   item.actionBlock = itemActionBlock;
   
   [item addChild:tileNode];
   [item addChild:item.hitBox];

   return item;
}

- (void)setIsLiving:(BOOL)living
{
   GLTileNode * node = (GLTileNode *)[self sprite];
   node.isLiving = living;
   [node clearActionsAndRestore];
}

- (void)setLiveColor:(SKColor *)color
{
   GLTileNode * node = (GLTileNode *)[self sprite];
   [node setLiveColor:color];
   [node clearActionsAndRestore];
}

@end

//
// GLPickerControl
//
@interface GLPickerControl() <GLTileColorDelegate>
{
   NSArray * _imagePairs;
   
   BOOL _shouldPlaySound;
   SKAction *_pressReleaseSoundFX;
   NSInteger _controlHeight;
   
   NSString *_preferenceKey;
   HUDItemRange _range;
   
   CrayolaColorName _colorName;
}

@property (nonatomic, strong) NSArray *items;

@end


@implementation GLPickerControl

- (void)observeSoundFxChanges
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"SoundFX"];
}

- (void)observeGridImageIndexChanges
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"GridImageIndex"];
}

- (void)observeGridLiveColorNameChanges
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"GridLiveColorName"];
}

- (id)initWithHUDPickerItemDescription:(HUDPickerItemDescription *)itemDesc
{
   if (self = [super init])
   {
      assert((itemDesc.imagePairs.count % 2) == 0);
      _imagePairs = itemDesc.imagePairs;
      _preferenceKey = itemDesc.keyPath;
      _range = itemDesc.range;
      
      [self updateControlHeight];
      
      [self setupSoundFX];
      [self observeSoundFxChanges];
      [self observeGridImageIndexChanges];
      
      NSNumber * value = [[NSUserDefaults standardUserDefaults] objectForKey:@"GridImageIndex"];
      [self setupImagePairs:[value unsignedIntegerValue]];
      
      [self observeGridLiveColorNameChanges];
   }
   
   return self;
}

- (void)setupImagePairs:(NSUInteger)selectedIndex;
{
   int imageCount = 0;
   NSMutableArray * pickerItems = [[NSMutableArray alloc] init];
   while (imageCount * 2 < _imagePairs.count)
   {
      // don't know why I have to shift xPos by one IMAGE_SIZE.width + IMAGE_X_PADDING
      int xPos = ((imageCount % IMAGES_PER_ROW) + 1) * (IMAGE_SIZE.width + IMAGE_X_PADDING) - 10;
      int yPos = -(imageCount / IMAGES_PER_ROW) * (IMAGE_SIZE.height + IMAGE_Y_PADDING);
      
      int imageIndex = imageCount * 2;
      SKTexture *deadTexture =
         [SKTexture textureWithImageNamed:[_imagePairs objectAtIndex:imageIndex + 1]];
      
      double rotation = [self rotationForImageIndex:imageIndex];
      GLTileNode *tile = [GLTileNode tileWithTexture:deadTexture
                                                rect:CGRectMake(xPos,
                                                                yPos,
                                                                IMAGE_SIZE.width,
                                                                IMAGE_SIZE.height)
                                         andRotation:rotation];
      tile.deadRotation = 0;
      tile.position = CGPointMake(xPos, yPos);
      
      NSString * liveName = [_imagePairs objectAtIndex:imageIndex];
      if (liveName.length > 0)
      {
         SKTexture *liveTexture = [SKTexture textureWithImageNamed:liveName];
         if (liveTexture)
            tile.liveTexture = liveTexture;
      }
      
      GLPickerItem * item = [GLPickerItem itemWithTileNode:tile
                                                imageIndex:imageIndex
                                          forPreferenceKey:@"GridImageIndex"];
      [self addChild:item];
      [pickerItems addObject:item];
      ++imageCount;
   }
   
   self.items = [NSArray arrayWithArray:pickerItems];
   
   [self updateImageIndex:[[[NSUserDefaults standardUserDefaults]
                              objectForKey:@"GridImageIndex"]
                                 unsignedLongValue]];
}

- (void)updateControlHeight
{
   NSInteger numImages =  _imagePairs.count * 0.5;
   NSInteger numRows = numImages / IMAGES_PER_ROW;
   if ((numRows * IMAGES_PER_ROW) < numImages) ++numRows;
   
   _controlHeight = numRows * (IMAGE_SIZE.height + IMAGE_Y_PADDING) + IMAGE_Y_PADDING * 0.5;
}

- (double)rotationForImageIndex:(NSInteger)imageIndex
{
   double result = 0;
   
   switch (imageIndex)
   {
      case 0:
         result = -M_PI_2;
         break;
      case 8:
      case 10:
      case 12:
      case 14:
         result = -M_PI;
         break;
      default:
         result = 0;
   }
   
   return result;
}

- (SKColor *)currentTileColor
{
   return [UIColor colorForCrayolaColorName:_colorName];
}

- (void)setupSoundFX
{
   _pressReleaseSoundFX = [SKAction playSoundFileNamed:@"toggle.1.wav" waitForCompletion:NO];
}

- (void)handleTouchBegan:(UITouch *)touch
{
}

- (void)handleTouchMoved:(UITouch *)touch
{
}

- (void)handleTouchEnded:(UITouch *)touch
{
}

- (void)updateImageIndex:(NSUInteger)index
{
   for (GLPickerItem *item in self.items)
      [item setIsLiving:(item.imageIndex == index)];
}

- (void)updateImageColorName:(CrayolaColorName)colorName
{
   SKColor * color = [UIColor colorForCrayolaColorName:colorName];
   if (color)
   {
      _colorName = colorName;
      for (GLPickerItem *item in self.items)
         [item setLiveColor:color];
   }
}

- (void)settingChanged:(NSNumber *)value ofType:(HUDValueType)type forKeyPath:(NSString *)keyPath
{
   if ([keyPath compare:@"SoundFX"] == NSOrderedSame)
   {
      assert(type == HVT_BOOL);
      _shouldPlaySound = [value boolValue];
   }
   else if ([keyPath compare:@"GridImageIndex"] == NSOrderedSame)
   {
      assert(type == HVT_ULONG);
      
      NSUInteger imageIndex = [value unsignedLongValue];
      [self updateImageIndex:imageIndex];
      if (_shouldPlaySound && self.items) [self runAction:_pressReleaseSoundFX];
   }
   else if ([keyPath compare:@"GridLiveColorName"] == NSOrderedSame)
   {
      assert(type == HVT_UINT);
      [self updateImageColorName:[value unsignedIntValue]];
   }
}

- (NSUInteger)controlHeight
{
   return _controlHeight;
}

- (void)setHidden:(BOOL)hidden
{
   super.hidden = hidden;
   for (GLPickerItem *item in self.items)
      item.hidden = hidden;
}

@end
