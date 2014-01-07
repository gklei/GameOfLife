//
//  GLPickerControl.m
//  GameOfLife
//
//  Created by Leif Alton on 1/6/14.
//  Copyright (c) 2014 Gregory Klein. All rights reserved.
//

#import "GLPickerControl.h"
#import "GLTileNode.h"

//#define DEFAULT_LENGTH 180
//
//// These are dependant on the knob image and track end image sizes
//#define FULLY_EXTENDED_TRACK_SCALE_FACTOR .5 //.503318573
//#define HALF_EXTENDED_TRACK_SCALE_FACTOR .225
//
//// These assure that the correct regions of the track end images are
//// stretched when adjusting the xScale property
//#define LEFT_TRACK_CENTER_RECT CGRectMake(.75, .25, .25, .5)
//#define RIGHT_TRACK_CENTER_RECT CGRectMake(0, .25, .25, .5)
//
//#define DEFAULT_KNOB_SCALE .6
//#define SELECTED_KNOB_SCALE .74

#define IMAGE_X_PADDING 18
#define IMAGE_Y_PADDING 18
#define IMAGES_PER_ROW  5
#define IMAGE_SIZE CGSizeMake(20, 20)

@interface GLPickerControl()
{
   NSArray * _imagePairs;
   
   BOOL _shouldPlaySound;
   SKAction *_pressReleaseSoundFX;
   NSInteger _controlHeight;
   
   NSString *_preferenceKey;
   HUDItemRange _range;
}
@end


@implementation GLPickerControl

- (void)observeSoundFxChanges
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"SoundFX"];
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
      [self setupImagePairs];
      
      [self setupSoundFX];
      [self observeSoundFxChanges];
   }
   
   return self;
}

- (void)setupImagePairs
{
   int imageCount = 0;
   while (imageCount * 2 < _imagePairs.count)
   {
      int xPos = ((imageCount % IMAGES_PER_ROW) + 1) * (IMAGE_SIZE.width + IMAGE_X_PADDING);
      int yPos = -(imageCount / IMAGES_PER_ROW) * (IMAGE_SIZE.height + IMAGE_Y_PADDING);
      
      int imageIndex = imageCount * 2;
      ++imageCount;
      
      SKTexture *deadTexture =
         [SKTexture textureWithImageNamed:[_imagePairs objectAtIndex:imageIndex + 1]];
      
      double liveRotation = [self rotationForImageIndex:imageIndex];
      GLTileNode *tile = [GLTileNode tileWithTexture:deadTexture
                                                rect:CGRectMake(xPos,
                                                                yPos,
                                                                IMAGE_SIZE.width,
                                                                IMAGE_SIZE.height)
                                         andRotation:liveRotation];
      tile.deadRotation = 0;
      tile.position = CGPointMake(xPos, yPos);
      
      NSString * liveName = [_imagePairs objectAtIndex:imageIndex];
      if (liveName.length > 0)
      {
         SKTexture *liveTexture = [SKTexture textureWithImageNamed:liveName];
         if (liveTexture)
            tile.liveTexture = liveTexture;
      }
      
      [self addChild:tile];
   }
}

- (void)updateControlHeight
{
   NSInteger numImages =  _imagePairs.count * 0.5;
   NSInteger numRows = numImages / IMAGES_PER_ROW;
   if ((numRows * IMAGES_PER_ROW) < numImages) ++numRows;
   
   _controlHeight = numRows * (IMAGE_SIZE.height + IMAGE_Y_PADDING);
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
}

- (CGRect)largestPossibleAccumulatedFrame
{
   CGRect frame = self.calculateAccumulatedFrame;
   frame.size.width += IMAGE_X_PADDING;
   frame.size.height += IMAGE_Y_PADDING;
   NSLog(@"Picker:largestPossibleAccumulatedFrame = %@", NSStringFromCGRect(frame));
   return frame;
}

- (NSUInteger)controlHeight
{
   return _controlHeight;
}

@end
