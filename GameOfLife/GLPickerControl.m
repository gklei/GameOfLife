//
//  GLPickerControl.m
//  GameOfLife
//
//  Created by Leif Alton on 1/6/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLPickerControl.h"
#import "GLTileNode.h"

#define IMAGE_X_PADDING 18
#define IMAGE_Y_PADDING 10
#define IMAGES_PER_ROW  5
#define IMAGE_SIZE CGSizeMake(20, 20)


//
// GLPickerItem
//
@interface GLPickerItem : GLUIButton<GLTouchHandler>

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
   item.hitBox.size = tileNode.size;
   item.hitBox.position = tileNode.position;
   item.sprite = tileNode;
   item.preferenceKey = preferenceKey;
   [item addChild:tileNode];
   [item addChild:item.hitBox];

   return item;
}

- (void)handleTouchBegan:(UITouch *)touch
{
}

- (void)handleTouchMoved:(UITouch *)touch
{
}

- (void)handleTouchEnded:(UITouch *)touch
{
   NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
   [defaults setObject:[NSNumber numberWithUnsignedLong:_imageIndex] forKey:_preferenceKey];
}

- (void)setIsLiving:(BOOL)living
{
   GLTileNode * node = (GLTileNode *)[self sprite];
   [node updateLivingAndColor:living];
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

- (id)initWithHUDPickerItemDescription:(HUDPickerItemDescription *)itemDesc
{
   if (self = [super init])
   {
      assert((itemDesc.imagePairs.count % 2) == 0);
      _imagePairs = itemDesc.imagePairs;
      _preferenceKey = itemDesc.keyPath;
      _range = itemDesc.range;
      
      [self updateControlHeight];
      
      NSNumber * value = [[NSUserDefaults standardUserDefaults] objectForKey:@"GridImageIndex"];
      [self setupImagePairs:[value unsignedIntegerValue]];
      
      [self setupSoundFX];
      [self observeSoundFxChanges];
      [self observeGridImageIndexChanges];
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
      int xPos = ((imageCount % IMAGES_PER_ROW) + 1) * (IMAGE_SIZE.width + IMAGE_X_PADDING);
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
      tile.tileColorDelegate = self;
      
      NSString * liveName = [_imagePairs objectAtIndex:imageIndex];
      if (liveName.length > 0)
      {
         SKTexture *liveTexture = [SKTexture textureWithImageNamed:liveName];
         if (liveTexture)
            tile.liveTexture = liveTexture;
      }
      
      [tile updateLivingAndColor:(imageCount == selectedIndex)];
      
      GLPickerItem * item = [GLPickerItem itemWithTileNode:tile
                                                imageIndex:imageIndex
                                          forPreferenceKey:@"GridImageIndex"];
      [self addChild:item];
      [pickerItems addObject:item];
      ++imageCount;
   }
   
   self.items = [NSArray arrayWithArray:pickerItems];
}

- (void)updateControlHeight
{
   NSInteger numImages =  _imagePairs.count * 0.5;
   NSInteger numRows = numImages / IMAGES_PER_ROW;
   if ((numRows * IMAGES_PER_ROW) < numImages) ++numRows;
   
   _controlHeight = numRows * (IMAGE_SIZE.height + IMAGE_Y_PADDING) + IMAGE_Y_PADDING;
}

- (double)rotationForImageIndex:(NSInteger)imageIndex
{
   double result = 0;
   
   switch (imageIndex)
   {
      case 0:
         result = -M_PI_2;
         break;
      case 4:
      case 6:
      case 8:
      case 10:
         result = -M_PI;
         break;
      default:
         result = 0;
   }
   
   return result;
}

- (SKColor *)currentTileColor
{
   return [SKColor blueColor];
}

- (void)setupSoundFX
{
   _pressReleaseSoundFX = [SKAction playSoundFileNamed:@"toggle.1.wav" waitForCompletion:NO];
}

- (void)handleTouchBegan:(UITouch *)touch
{
   if (_shouldPlaySound) [self runAction:_pressReleaseSoundFX];
   [super handleTouchBegan:touch];
}

- (void)handleTouchMoved:(UITouch *)touch
{
// Currently this does not need to be called
//   [super handleTouchMoved:touch];
}

- (void)handleTouchEnded:(UITouch *)touch
{
   if (_shouldPlaySound) [self runAction:_pressReleaseSoundFX];
   [super handleTouchEnded:touch];
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
      for (GLPickerItem *item in self.items)
         [item setIsLiving:(item.imageIndex == imageIndex)];
   }
}

- (NSUInteger)controlHeight
{
   return _controlHeight;
}

@end
