//
//  GLGridScene.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/7/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLGridScene.h"

#import "GLAlertLayer.h"
#import "GLColorHud.h"
#import "GLGeneralHud.h"
#import "GLGrid.h"
#import "GLUIButton.h"
#import "GLScannerAnimation.h"
#import "GLSettingsLayer.h"
#import "GLTileNode.h"
#import "GLViewController.h"
#import "UIColor+Crayola.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <OpenGLES/ES1/glext.h>


#define DEFAULT_GENERATION_DURATION 0.8
#define BONUS_FOR_CLEARING_GRID     50

typedef void (^PhotoWorkBlock)();

@class ScreenShotPerformer;

#pragma mark - GLGridScene private interface
@interface GLGridScene() <GLGeneralHudDelegate, GLColorHudDelegate>
{
   GLGrid *_grid;
   
   GLTileNode *_currentTileBeingTouched;
   BOOL _oneTileTouched;
   
   GLGeneralHud *_generalHudLayer;
   GLColorHud *_colorHudLayer;
   
   BOOL _generalHudIsAnimating;
   BOOL _colorHudIsAnimating;
   BOOL _autoShowHideHudForStartStop;
   BOOL _generalHudShouldExpand;
   BOOL _gameFinished;
   BOOL _shouldPlaySound;
   BOOL _dismissedAlert;
   BOOL _gameNeedsSaving;
   
   SKAction *_fingerDownSoundFX;
   SKAction *_fingerUpSoundFX;
   SKAction *_flashSound;
   
   CFTimeInterval _lastGenerationTime;
   CFTimeInterval _generationDuration;
   
   ALAuthorizationStatus _photoLibraryAuthorizationStatus;
   SKSpriteNode *_flashLayer;
   SKAction *_flashAnimation;
   
   GLUIButton *_focusedButton;
   
   CGPoint _locationOfFirstTouch;
   NSArray * _gridImagePairs;
   
   unsigned long long _highScore;
   
   ScreenShotPerformer * _screenShotPerformer;
}

@property (nonatomic, assign, setter = setRunning:) BOOL running;
@property (nonatomic, assign) GLViewController * viewController;

-(void)doScreenShot:(CGPoint)buttonPosition andSave:(BOOL)saveNotSend;

@end


#pragma mark - ScreenShotPerformer
#pragma mark - ScreenShotPerformer interface
@interface ScreenShotPerformer : NSObject
{
@private
   GLGridScene * _gridScene;
   CGPoint  _buttonPosition;
   BOOL     _saveScreenshot;
}

- (id)initWithGridScene:(GLGridScene *)scene;
- (void)performSaveScreenShot:(CGPoint)buttonPosition afterDelay:(NSTimeInterval)delay;
- (void)performSendScreenShot:(CGPoint)buttonPosition afterDelay:(NSTimeInterval)delay;

@end

#pragma mark - ScreenShotPerformer implementation
@implementation ScreenShotPerformer

- (id)initWithGridScene:(GLGridScene *)scene
{
   if (self = [super init])
      _gridScene = scene;
   
   return self;
}

- (void)performSaveScreenShot:(CGPoint)buttonPosition afterDelay:(NSTimeInterval)delay
{
   _saveScreenshot = YES;
   _buttonPosition = buttonPosition;
   [self performSelector:@selector(doScreenShot) withObject:nil afterDelay:delay];
}

- (void)performSendScreenShot:(CGPoint)buttonPosition afterDelay:(NSTimeInterval)delay
{
   _saveScreenshot = NO;
   _buttonPosition = buttonPosition;
   [self performSelector:@selector(doScreenShot) withObject:nil afterDelay:delay];
}

- (void)doScreenShot
{
   [_gridScene doScreenShot:_buttonPosition andSave:_saveScreenshot];
}
@end


#pragma mark - GLGridScene implementation
@implementation GLGridScene

+ (instancetype)sceneWithViewController:(GLViewController *)controller
{
   GLGridScene * result = [super sceneWithSize:controller.view.bounds.size];
   result.viewController = controller;
   return result;
}

#pragma mark - registration methods
- (void)registerGeneralDurationHUD
{
   HUDItemDescription * hudItem = [[HUDItemDescription alloc] init];
   hudItem.keyPath = @"GenerationDuration";
   hudItem.label = @"SPEED";
   hudItem.range = HUDItemRangeMake(1.0, -0.9);
   hudItem.type = HIT_SLIDER;
   hudItem.defaultvalue = [NSNumber numberWithFloat:DEFAULT_GENERATION_DURATION];
   hudItem.valueType = HVT_FLOAT;
   
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addHudItem:hudItem];
}

- (void)registerGridImagePickerHUD:(NSArray *)imagePairs
{
   assert(imagePairs.count > 0);
   assert((imagePairs.count % 2) == 0);
   
   HUDPickerItemDescription * hudItem = [[HUDPickerItemDescription alloc] init];
   hudItem.keyPath = @"GridImageIndex";
   hudItem.label = @"TILES";
   hudItem.type = HIT_PICKER;
   hudItem.valueType = HVT_ULONG;
   hudItem.imagePairs = imagePairs;
   hudItem.range = HUDItemRangeMake(0, imagePairs.count - 1);
   hudItem.defaultvalue = [NSNumber numberWithUnsignedInteger:0];
   
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addHudItem:hudItem];
}

- (void)registerToggleItemWithLabel:(NSString *)label andKeyPath:(NSString *)keyPath
{
   HUDItemDescription * hudItem = [[HUDItemDescription alloc] init];
   hudItem.keyPath = keyPath;
   hudItem.label = label;
   hudItem.range = HUDItemRangeMake(0, 1);
   hudItem.type = HIT_TOGGLER;
   hudItem.defaultvalue = [NSNumber numberWithBool:YES];
   hudItem.valueType = HVT_BOOL;
   
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addHudItem:hudItem];
}

- (void)registerSoundFXToggleItemWithLabel:(NSString *)label andKeyPath:(NSString *)keyPath
{
   HUDItemDescription * hudItem = [[HUDItemDescription alloc] init];
   hudItem.keyPath = keyPath;
   hudItem.label = label;
   hudItem.range = HUDItemRangeMake(0, 1);
   hudItem.type = HIT_SOUND_FX_TOGGLER;
   hudItem.defaultvalue = [NSNumber numberWithBool:YES];
   hudItem.valueType = HVT_BOOL;

   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addHudItem:hudItem];
}

- (void)registerSoundFxHUD
{
   [self registerSoundFXToggleItemWithLabel:@"SOUND FX" andKeyPath:@"SoundFX"];
}

- (void)registerSmartMenuHUD
{
   [self registerToggleItemWithLabel:@"SMART MENU" andKeyPath:@"SmartMenu"];
}

- (void)registerLoopDetectionHUD
{
   [self registerToggleItemWithLabel:@"LOOP DETECTION" andKeyPath:@"LoopDetection"];
}

- (void)registerLockedColorMode
{
   [self registerToggleItemWithLabel:@"COLOR LOCKED" andKeyPath:@"LockedColorMode"];
}

- (void)registerLiveColorNameChanges
{
   HUDItemDescription * hudItem = [[HUDItemDescription alloc] init];
   hudItem.keyPath = @"GridLiveColorName";
   hudItem.label = @"Live Color Name";
   hudItem.range = HUDItemRangeMake(0, CCN_crayolaBrickRedColor);
   hudItem.type = HIT_NO_UI;
   hudItem.defaultvalue = [NSNumber numberWithUnsignedInt:CCN_crayolaCeruleanColor];
   hudItem.valueType = HVT_UINT;
   
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addHudItem:hudItem];
}
   
- (void)registerGenerationTracking
{
   [self registerToggleItemWithLabel:@"COLOR FOR GENERATION"
                          andKeyPath:@"TileGenerationTracking"];
}

- (void)registerHighScoreHUD
{
   HUDPickerItemDescription * hudItem = [[HUDPickerItemDescription alloc] init];
   hudItem.keyPath = @"HighScore";
   hudItem.label = @"HIGH SCORE";
   hudItem.range = HUDItemRangeMake(0, 100000);
   hudItem.type = HIT_LABEL;
   hudItem.valueType = HVT_ULONGLONG;
   hudItem.defaultvalue = [NSNumber numberWithUnsignedLongLong:0];
   
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addHudItem:hudItem];
}

- (void)registerHudParameters
{
   [self registerSoundFxHUD];
   [self registerSmartMenuHUD];
   [self registerGeneralDurationHUD];
   [self registerLoopDetectionHUD];
   [self registerLockedColorMode];
   [self registerGridImagePickerHUD:_gridImagePairs];
   [self registerLiveColorNameChanges];
   [self registerGenerationTracking];
   [self registerHighScoreHUD];
}

#pragma mark - observation methods
- (void)observeSoundFxChanges
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"SoundFX"];
}

- (void)observeSmartMenuChanges
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"SmartMenu"];
}

- (void)observeLoopDetectionChanges
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"LoopDetection"];
}

- (void)observeGeneralDurationChanges
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"GenerationDuration"];
}

- (void)observeGridImageIndexChanges
{
   GLHUDSettingsManager * hudManager = [GLHUDSettingsManager sharedSettingsManager];
   [hudManager addObserver:self forKeyPath:@"GridImageIndex"];
}

- (void)observeHudParameterChanges
{
   [self observeSoundFxChanges];
   [self observeSmartMenuChanges];
   [self observeLoopDetectionChanges];
   [self observeGeneralDurationChanges];
   [self observeGridImageIndexChanges];
}

#pragma mark - high score
- (unsigned long long)getHighScore
{
   unsigned long long result = 0;
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   NSNumber * highScore = (NSNumber *)[defaults objectForKey:@"HighScore"];
   if (highScore)
      result = [highScore unsignedLongLongValue];
   
   return result;
}

- (void)storeHighScore:(unsigned long long)highScore
{
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   [defaults setObject:[NSNumber numberWithUnsignedLongLong:highScore] forKey:@"HighScore"];
   [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Initializer Method
- (id)initWithSize:(CGSize)size
{
   if (self = [super initWithSize:size])
   {
      //                  live image,            dead image
      _gridImagePairs = @[@"",                   @"tile.square.png",
                          @"",                   @"tile.ring.png",
                          @"",                   @"tile.circle.png",
                          @"",                   @"tile.heart.png",
                          @"",                   @"tile.blam.png",
                          @"",                   @"tile.diamonds.png",
                          @"",                   @"tile.stripes.png",
                          @"",                   @"tile.amoeba.png"];
      
      _highScore = [self getHighScore];

      [self registerHudParameters];

      [self checkPhotoLibraryAuthorizationStatus];
      [self setupGridWithSize:size];
      [self setupGeneralHud];
      [self setupColorHud];
      [self setupSoundFX];
      [self setupFlashLayerAndAnimation];

      [self observeHudParameterChanges];

      // set background color for the scene
      self.backgroundColor = [SKColor crayolaPeriwinkleColor];
      self.userInteractionEnabled = YES;

      if ([self firstTimeRunning])
         [self loadLife];
      else
         [self loadLastGrid];
      
      _screenShotPerformer = [[ScreenShotPerformer alloc] initWithGridScene:self];
   }
   return self;
}

#pragma mark - Setup Methods
- (void)setupGridWithSize:(CGSize)size
{
   _grid = [[GLGrid alloc] initWithSize:size];
   [self addChild:_grid];
}

- (void)setupGeneralHud
{
   _generalHudLayer = [GLGeneralHud new];
   _generalHudLayer.delegate = self;
   _generalHudLayer.position = CGPointMake(-self.size.width + 60, 0);
   _generalHudLayer.userInteractionEnabled = YES;
   [self addChild:_generalHudLayer];
}

- (void)setupColorHud
{
   _colorHudLayer = [GLColorHud new];
   _colorHudLayer.delegate = self;
   _colorHudLayer.position = CGPointMake(self.size.width - 60, 0);
   [self addChild:_colorHudLayer];
}

- (void)setupSoundFX
{
   _fingerUpSoundFX = [SKAction playSoundFileNamed:@"up.finger.off.tile.wav" waitForCompletion:NO];
   _fingerDownSoundFX = [SKAction playSoundFileNamed:@"down.finger.on.tile.wav" waitForCompletion:NO];
   _flashSound = [SKAction playSoundFileNamed:@"flash.wav" waitForCompletion:NO];
}

- (void)setupFlashLayerAndAnimation
{
   _flashLayer = [SKSpriteNode spriteNodeWithColor:[UIColor whiteColor] size:self.size];
   _flashLayer.name = @"flashLayer";
   _flashLayer.colorBlendFactor = 1.0;
   _flashLayer.alpha = 0;
   _flashLayer.anchorPoint = CGPointZero;
   _flashLayer.position = CGPointZero;

   SKAction * flashIn = [SKAction fadeAlphaTo:1 duration:0.125];
   SKAction * flashOut = [SKAction fadeAlphaTo:0 duration:0.625];
   _flashAnimation = [SKAction sequence:@[flashIn, flashOut]];

   [self addChild:_flashLayer];
}

- (void)checkPhotoLibraryAuthorizationStatus
{
   // NOTE: when the user changes the apps access to the photo library in
   // privacy settings, the app will automatically (and unavoidably) be
   // killed by the OS and restarted.  Because of this, we do not need to
   // register for a notification when the authorization status changes, but
   // instead, simply check to see what it is every time the app starts.
   _photoLibraryAuthorizationStatus = [ALAssetsLibrary authorizationStatus];

   if (_photoLibraryAuthorizationStatus == ALAuthorizationStatusAuthorized ||
       _photoLibraryAuthorizationStatus == ALAuthorizationStatusNotDetermined)
   {
      // connect to the photo library!
      UIImageWriteToSavedPhotosAlbum(nil, nil, nil, nil);
   }
}

- (void)setRunning:(BOOL)running
{
   _running = running;
   
   if (_running)
   {
      _gameFinished = NO;
      [self removeAllAlertsForcefully:NO];
   }
   else
   {
      [self showGenerationCountAlert];
      _gameFinished = NO;
   }
}

- (void)expandGeneralHUD
{
   [_generalHudLayer expand];
}

- (void)loadLife
{
   [_grid loadLifeTileStates];
   [self restoreButtonPressed:0 buttonPosition:CGPointZero];
   [_grid storeGridState];
   [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)loadLastGrid
{
   [_grid loadStoredTileStates];
   [self restoreButtonPressed:0 buttonPosition:CGPointZero];
}

- (BOOL)firstTimeRunning
{
   BOOL retVal = NO;
   NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
   if (![defaults objectForKey:@"firstRun"])
   {
      retVal = YES;
      [defaults setObject:[NSDate date] forKey:@"firstRun"];
   }

   [[NSUserDefaults standardUserDefaults] synchronize];
   return retVal;
}

- (void)setDefaultGridAttributes
{
   [_grid clearGrid];
}

-(void)removeAllAlertsForcefully:(BOOL)force
{
   for (id child in self.children)
   {
      if ([child isKindOfClass:[GLAlertLayer class]])
      {
         if (force)
            [child removeFromParent];
         else
            [child hide];
      }
   }
}

- (void)showGenerationCountAlert
{
   unsigned long long genCount = [_grid generationCount];
   if (genCount)
   {
      GLAlertLayer *alert = [GLAlertLayer new];

      BOOL bonus = [_grid isCleared];
      BOOL checkHighScore = ![_grid startedWithLife];
      
      [self removeAllAlertsForcefully:NO];
      
      unsigned long long totalScore = genCount;
      
      if (bonus)
         totalScore += BONUS_FOR_CLEARING_GRID;
      
      if (checkHighScore && totalScore > _highScore)
      {
         _highScore = totalScore;
         [self storeHighScore:_highScore];

         [alert addHeaderText:@"High Score!"];\
      }
      else if (_gameFinished)
         [alert addHeaderText:@"Game Finished"];
      else
         [alert addHeaderText:@"Game Stopped"];
      
      [alert addBodyText:[NSString stringWithFormat:@"Game score: %llu", genCount]];
         
      if (bonus)
      {
         [alert addBodyText:
          [NSString stringWithFormat:@"Cleared board bonus: %u", BONUS_FOR_CLEARING_GRID]];
         [alert addBodyText:[NSString stringWithFormat:@"Total score: %llu", totalScore]];
      }

      alert.position = CGPointMake(0, CGRectGetHeight([UIScreen mainScreen].bounds) - 20);
      alert.animatesIn = YES;

      if (_generalHudLayer.settingsAreExpanded)
         [_generalHudLayer toggleSettingsWithCompletion:^{[alert showWithParent:self];}];
      else
         [alert showWithParent:self];
   }
}

- (void)storeGridIfDirtyAndClearFlag
{
   if (_gameNeedsSaving)
   {
      [_grid storeGridState];
      _gameNeedsSaving = NO;
   }
}

#pragma mark - GLGeneralHud Delegate Methods
- (void)clearButtonPressed
{
   if (_running)
   {
      [self updateGenerationDuration:_generationDuration];

      [_grid toggleRunning:!_running];
      self.running = !_running;
      
      [_generalHudLayer updateStartStopButtonForState:(_running)? GL_RUNNING : GL_STOPPED
                                            withSound:NO];
   }
   else
      [self removeAllAlertsForcefully:NO];
   
   [self storeGridIfDirtyAndClearFlag];
   [_grid clearGrid];
}

- (void)restoreButtonPressed:(NSTimeInterval)holdTime buttonPosition:(CGPoint)position;
{
   if (_running)
   {
      [self updateGenerationDuration:_generationDuration];

      [_grid toggleRunning:!_running];
      self.running = !_running;
      
      [_generalHudLayer updateStartStopButtonForState:(_running)? GL_RUNNING : GL_STOPPED
                                            withSound:NO];
   }
   else
      [self removeAllAlertsForcefully:NO];
   
   [_grid restoreGrid];
   
   if (holdTime > 2)
   {
      [self beginMessagingAtPosition:position];
      return;
   }
}

- (void)updateGenerationDuration:(float)duration
{
   float bdDuration = (_running)? 0.1875 * duration : 0.4375 * duration;
   [_grid setTilesBirthingDuration:bdDuration
                     dyingDuration:bdDuration];
   
   _generationDuration = duration;
}

- (void)toggleRunningButtonPressed:(NSTimeInterval)holdTime buttonPosition:(CGPoint)position;
{
   if (holdTime > 2)
   {
      [self beginCameraImportAtPosition:position];
      return;
   }
   
   if (![_grid currentStateIsRunnable] && !_running)
      return;
   
   [self storeGridIfDirtyAndClearFlag];
   
   [self updateGenerationDuration:_generationDuration];
   
   [_grid toggleRunning:!_running];
   self.running = !_running;
   
   [_generalHudLayer updateStartStopButtonForState:(_running)? GL_RUNNING : GL_STOPPED
                                         withSound:!_autoShowHideHudForStartStop];
   if (_autoShowHideHudForStartStop)
   {
      if (_running)
         [_generalHudLayer collapse];
      else if (!_generalHudIsAnimating)
         [_generalHudLayer expand];
      else
         _generalHudShouldExpand = YES;
   }
}

#pragma mark - sceenshot related functions
- (void)addNodeBehindFlashNode:(SKSpriteNode *)node
{
   // add the node
   [self addChild:node];
   
   // remove the flash layer
   NSArray * toRemove = @[_flashLayer];
   [self removeChildrenInArray:toRemove];
   
   //  and add it back on top
   [self addChild:_flashLayer];
}

- (SKSpriteNode *)addNodeForScreenShot:(UIImage *)viewImage
{
   // create a node from the screenshot
   SKSpriteNode * node =
      [SKSpriteNode spriteNodeWithTexture:[SKTexture textureWithImage:viewImage]];

   // scale the node to fit the current view
   if (node.size.width > [self size].width)
      node.scale = [self size].width / node.size.width;

   // postion the node
   node.position = CGPointZero;
   node.anchorPoint = CGPointZero;
   
   [self addNodeBehindFlashNode:node];
   return node;
}

- (void)animateNode:(SKSpriteNode *)node
         toPosition:(CGPoint)position
withCompletionBlock:(void (^)())completionBlock
{
   // set the animation end position
   CGPoint point = position;
   point.y *= -1;
   SKAction * move = [SKAction moveTo:point duration:0.75];
   
   // scale the node
   SKAction * scaleX = [SKAction scaleXBy:0.01 y:1.0 duration:0.75];
   SKAction * pause = [SKAction waitForDuration:0.25];
   SKAction * scaleY = [SKAction scaleXBy:1.0 y:0.01 duration:0.5];
   
   move.timingMode = SKActionTimingEaseInEaseOut;
   scaleX.timingMode = SKActionTimingEaseInEaseOut;
   scaleY.timingMode = SKActionTimingEaseInEaseOut;
   
   SKAction * pauseThenScaleY = [SKAction sequence:@[pause, scaleY]];
   SKAction * group = [SKAction group:@[move, scaleX, pauseThenScaleY]];
   
   [node runAction:group completion:^
    {
       // remove the node now that we're done with it
       NSArray * toRemove = @[node];
       [self removeChildrenInArray:toRemove];
       
       if (completionBlock)
          completionBlock();
    }];
}

- (void)runScannerAnimation
{
   GLScannerAnimation *scannerAnimation = [[GLScannerAnimation alloc] initWithScannerDelegate:_grid];
   scannerAnimation.updateIncrement = 20;
   scannerAnimation.duration = 1.0;
   [scannerAnimation runAnimationOnParent:self
                      withCompletionBlock:^
    {
       [_grid scanAnimationFinished];
    }
    ];
}

- (void)doScreenShot:(CGPoint)buttonPosition andSave:(BOOL)save
{
   if (_shouldPlaySound) [self runAction:_flashSound];

   CGFloat scale = self.view.contentScaleFactor;
   UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, YES, scale);
   [self.view drawViewHierarchyInRect:self.view.bounds afterScreenUpdates:NO];
   
   UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
   UIGraphicsEndImageContext();
   
   // make certain the HUDs are restored
   [_generalHudLayer setHidden:NO];
   [_colorHudLayer setHidden:NO];
   
   if (viewImage)
   {
      if (save)
      {
         // save the screenshot
         UIImageWriteToSavedPhotosAlbum(viewImage, nil, nil, nil);
         
         // create and animate the screenshot
         SKSpriteNode * node = [self addNodeForScreenShot:viewImage];
         if (node)
            [self animateNode:node toPosition:buttonPosition withCompletionBlock:nil];
      }
      else
      {
         // send the screenshot
         if (_viewController)
         {
            // create and animate the screenshot, and send the image
            SKSpriteNode * node = [self addNodeForScreenShot:viewImage];
            if (node)
            {
               MessagingCompletionBlock msgBlock = ^(MessageComposeResult msgResult)
               {
                  CGPoint position = CGPointMake(0, self.size.height - 20);
                  switch (msgResult)
                  {
                     case MessageComposeResultCancelled:
                        // you know you cancelled, don't show anything
                        break;
                     case MessageComposeResultFailed:
                     {
                        // report error case
                        [GLAlertLayer alertWithHeader:@"SMS Failed"
                                                 body:@"Failed to send message :("
                                             position:position
                                            andParent:self];
                        break;
                     }
                     case MessageComposeResultSent:
                     {
                        // just for fun, let them know they sent LiFE!!
                        [GLAlertLayer alertWithHeader:@"Success"
                                                 body:@"Sent your friends LiFE!"
                                             position:position
                                            andParent:self];
                        break;
                     }
                     default:
                        // WTF???
                        break;
                  }
               };
               
               [self animateNode:node toPosition:buttonPosition withCompletionBlock:^
                {
                   [_viewController sendMessageWithImage:viewImage
                                      andCompletionBlock:msgBlock];
                }];
            }
         }
      }
   }
   [_flashLayer runAction:_flashAnimation];
}

- (void)doPhotoAccessWithBlock:(PhotoWorkBlock)doWork
{
   [self removeAllAlertsForcefully:YES];
   
   /*
    ALAuthorizationStatusNotDetermined = 0, // User has not yet made a choice with regards to this application
    ALAuthorizationStatusRestricted,        // This application is not authorized to access photo data.
    // The user cannot change this application’s status, possibly due to active restrictions
    //  such as parental controls being in place.
    ALAuthorizationStatusDenied,            // User has explicitly denied this application access to photos data.
    ALAuthorizationStatusAuthorized
    */
   NSString *header = nil;
   NSString *bodyLine1 = nil;
   NSString *bodyLine2 = nil;
   switch (_photoLibraryAuthorizationStatus)
   {
      case ALAuthorizationStatusRestricted:
      case ALAuthorizationStatusDenied:
         header = @"Photo access denied!";
         bodyLine1 = @"Give this app permission to save photos to your Photo Library by changing the settings in:";
         bodyLine2 = @"Settings > Privacy > Photos";
         break;
      case ALAuthorizationStatusNotDetermined:
      case ALAuthorizationStatusAuthorized:
         doWork();  // do the work (read from/write to the photo library)
         return;
      default:
         NSLog(@"Authorization Status %ld unrecognized", (long)_photoLibraryAuthorizationStatus);
         return;
   }
   
   GLAlertLayer *alert = [GLAlertLayer new];
   [alert addHeaderText:header];
   [alert addBodyText:bodyLine1];
   [alert addBodyText:bodyLine2];
   
   alert.position = CGPointMake(0, self.size.height - 20);
   alert.animatesIn = YES;
   [alert showWithParent:self];
}

- (void)beginScreenShotAtPosition:(CGPoint)buttonPosition
{
   // hack to get the HUD hidden when taking a screenshot
   // we hide the HUD, set up a delayed callback and exit
   // When the delay expires, the screen shot is taken and the HUD restored (see doScreenShot:)
   PhotoWorkBlock work = ^()
   {
      [_generalHudLayer setHidden:YES];
      [_colorHudLayer setHidden:YES];
      [_screenShotPerformer performSaveScreenShot:buttonPosition afterDelay:0.02];
   };
   
   [self doPhotoAccessWithBlock:work];
}

- (void)scanImageForGameBoard:(UIImage *)image
{
   if (_grid && image)
   {
      [_grid scanImageForGameBoard:image];

      // for some reason, when we return back to our app from the image
      // picker, there is a slight delay before the UI updates... this
      // hack will make it look a little more smooth
      
      [_grid clearGrid];
      [_grid storeGridState];
      [self runAction:[SKAction waitForDuration:.45]
           completion:^
      {
         if (_generalHudLayer.settingsAreExpanded)
            [_generalHudLayer toggleSettingsWithCompletion:^{[self runScannerAnimation];}];
         else
            [self runScannerAnimation];
      }];
   }
}

- (void)beginCameraImportAtPosition:(CGPoint)position
{
   PhotoWorkBlock work = ^()
   {
      if (_viewController)
      {
         PhotoPickingCompletionBlock completionBlock =
         ^(UIImage * image) { [self scanImageForGameBoard:image]; };
         
        [_viewController acquireImageFromSource:UIImagePickerControllerSourceTypeCamera
                            withCompletionBlock:completionBlock];
      }
   };
   
   [self doPhotoAccessWithBlock:work];
}

- (void)beginPhotoImportAtPosition:(CGPoint)position
{  
   PhotoWorkBlock work = ^()
   {
      if (_viewController)
      {
         PhotoPickingCompletionBlock completionBlock =
            ^(UIImage * image) { [self scanImageForGameBoard:image]; };
      
         [_viewController acquireImageFromSource:UIImagePickerControllerSourceTypePhotoLibrary
                             withCompletionBlock:completionBlock];
      }
   };
   
   [self doPhotoAccessWithBlock:work];
}

- (void)screenShotButtonPressed:(NSTimeInterval)holdTime buttonPosition:(CGPoint)position
{
   if (holdTime > 1.0)
      [self beginPhotoImportAtPosition:position];
   else
      [self beginScreenShotAtPosition:position];
}

#pragma mark - messaging related functions
- (void)beginMessagingAtPosition:(CGPoint)position
{
   // hack to get the HUD hidden when taking a screenshot
   // we hide the HUD, set up a delayed callback and exit
   // When the delay expires, the screen shot is taken and the HUD restored (see doScreenShot:)
   [_generalHudLayer setHidden:YES];
   [_colorHudLayer setHidden:YES];
   [_screenShotPerformer performSendScreenShot:position afterDelay:0.02];
}

#pragma mark -
- (void)settingsWillExpandWithRepositioningAction:(SKAction *)action
{
   [self removeAllAlertsForcefully:YES];
   [_colorHudLayer runAction:action];
}

- (void)settingsDidExpand
{
}

- (void)settingsWillCollapseWithRepositioningAction:(SKAction *)action
{
   [_colorHudLayer runAction:action];
}

- (void)settingsDidCollapse
{
}

#pragma mark GLColorHud Delegate Method
- (void)colorGridWillExpandWithRepositioningAction:(SKAction *)action
{
   [self removeAllAlertsForcefully:YES];
   [_generalHudLayer runAction:action];
}

- (void)colorGridDidExpand
{
}

- (void)colorGridWillCollapseWithRepositioningAction:(SKAction *)action
{
   [_generalHudLayer runAction:action];
}

- (void)colorGridDidCollapse
{
}

#pragma mark Touch Methods
- (void)handleTouch:(UITouch *)touch
{
   if (![_generalHudLayer containsPoint:[touch locationInNode:self]] &&
       ![_colorHudLayer containsPoint:[touch locationInNode:self]])
   {
      _oneTileTouched = YES;
      [self toggleLivingForTileAtTouch:touch withSoundFX:_fingerDownSoundFX];
   }
}

- (void)touchesBegan:(NSSet *)touches
           withEvent:(UIEvent *)event
{
   UITouch *touch = touches.allObjects.firstObject;
   _locationOfFirstTouch = [touch locationInNode:self];

   if (_focusedButton)
   {
      [_focusedButton loseFocus];
      _focusedButton = nil;
   }

   for (SKNode *node in [self nodesAtPoint:_locationOfFirstTouch])
   {
      if ([node.name isEqualToString:@"ui_button_hit_box"] && !node.parent.parent.hidden)
      {
         _focusedButton = (GLUIButton *)node.parent.parent;
         [_focusedButton handleTouchBegan:touch];
         return;
      }
      else if ([node isKindOfClass:[GLAlertLayer class]])
      {
         [node removeFromParent];
         _dismissedAlert = YES;
         return;
      }
   }

   if (!_running)
   {
      [self handleTouch:touches.allObjects.lastObject];
   }
}

- (void)touchesMoved:(NSSet *)touches
           withEvent:(UIEvent *)event
{
   UITouch *touch = touches.allObjects.lastObject;
   if (_focusedButton)
      [_focusedButton handleTouchMoved:touch];

   if (!_running &&
       ![_generalHudLayer containsPoint:_locationOfFirstTouch] &&
       ![_colorHudLayer containsPoint:_locationOfFirstTouch])
   {
      if (_dismissedAlert == NO)
         [self toggleLivingForTileAtTouch:touch withSoundFX:_fingerUpSoundFX];
   }
}

- (void)touchesEnded:(NSSet *)touches
           withEvent:(UIEvent *)event
{
   UITouch *touch = touches.allObjects.lastObject;
   if (_focusedButton)
   {
      [_focusedButton handleTouchEnded:touch];
      _focusedButton = nil;
   }

   if (_oneTileTouched)
   {
      if (_shouldPlaySound) [self runAction:_fingerUpSoundFX];
      _oneTileTouched = NO;
   }

   [_currentTileBeingTouched handleTouchEnded:touch];
   _currentTileBeingTouched = nil;
   _dismissedAlert = NO;
}

#pragma mark GLHud Delegate Methods
- (void)hud:(GLHud *)hud willExpandAfterPeriod:(CFTimeInterval *)waitPeriod
{
   if (hud == _colorHudLayer)
      [self colorHudWillExpandWithWaitPeriod:waitPeriod];
   else if (hud == _generalHudLayer)
      [self generalHudWillExpandWithWaitPeriod:waitPeriod];
}

- (BOOL)hudCanExpand:(GLHud *)hud
{
   if (hud == _colorHudLayer)
      return !_generalHudLayer.animating;
   else if (hud == _generalHudLayer)
      return !_colorHudLayer.animating;

   return NO;
}

- (void)hudDidExpand:(GLHud *)hud
{
   if (hud == _colorHudLayer)
      [self colorHudDidExpand];
   else if (hud == _generalHudLayer)
      [self generalHudDidExpand];
}

- (void)hudWillCollapse:(GLHud *)hud
{
   if (hud == _colorHudLayer)
      [self colorHudWillCollapse];
   else if (hud == _generalHudLayer)
      [self generalHudWillCollapse];
}

- (void)hudDidCollapse:(GLHud *)hud
{
   if (hud == _colorHudLayer)
      [self colorHudDidCollapse];
   else if (hud == _generalHudLayer)
      [self generalHudDidCollapse];
}

#pragma mark Helper HUD Methods
- (void)colorHudWillExpandWithWaitPeriod:(CFTimeInterval *)waitPeriod
{
   if (_generalHudLayer.isExpanded)
   {
      *waitPeriod = (_generalHudLayer.settingsAreExpanded)? 0.5 : 0.25;
      [_generalHudLayer collapse];
   }
   else
   {
      SKAction *reposition = [SKAction moveByX:0 y:60 duration:.25];
      reposition.timingMode = SKActionTimingEaseInEaseOut;

      [_generalHudLayer setCoreFunctionButtonsHidden:YES];
      _generalHudLayer.animating = YES;
      [_generalHudLayer runAction:reposition completion:^{_generalHudLayer.animating = NO;}];
   }
   _colorHudIsAnimating = YES;
}

- (void)generalHudWillExpandWithWaitPeriod:(CFTimeInterval *)waitPeriod
{
   if (_colorHudLayer.isExpanded)
   {
      *waitPeriod = (_colorHudLayer.colorGridIsExpanded)? 0.5 : 0.25;
      [_colorHudLayer collapse];
   }
   else
   {
      SKAction *reposition = [SKAction moveByX:0 y:60 duration:.25];
      reposition.timingMode = SKActionTimingEaseInEaseOut;

      [_colorHudLayer setColorDropsHidden:YES];
      _colorHudLayer.animating = YES;
      [_colorHudLayer runAction:reposition completion:^{_colorHudLayer.animating = NO;}];
   }
   _generalHudIsAnimating = YES;
}

- (void)colorHudDidExpand
{
   _colorHudIsAnimating = NO;
}

- (void)generalHudDidExpand
{
   _generalHudIsAnimating = NO;
}

- (void)colorHudWillCollapse
{
   _colorHudIsAnimating = YES;

   SKAction *wait = [SKAction waitForDuration:.15];
   SKAction *reposition = [SKAction moveByX:0 y:-60 duration:.25];
   reposition.timingMode = SKActionTimingEaseInEaseOut;

   [_generalHudLayer runAction:[SKAction sequence:@[wait, reposition]]
                    completion:^
   {
      [_generalHudLayer setCoreFunctionButtonsHidden:NO];
   }];
}

- (void)generalHudWillCollapse
{
   _generalHudIsAnimating = YES;

   SKAction *wait = [SKAction waitForDuration:.15];
   SKAction *reposition = [SKAction moveByX:0 y:-60 duration:.25];
   reposition.timingMode = SKActionTimingEaseInEaseOut;

   [_colorHudLayer runAction:[SKAction sequence:@[wait, reposition]]
                  completion:^
   {
      [_colorHudLayer setColorDropsHidden:YES];
   }];
}

- (void)colorHudDidCollapse
{
   _colorHudIsAnimating = NO;
   if (_generalHudIsAnimating)
   {
      SKAction *reposition = [SKAction moveByX:0 y:60 duration:.15];
      reposition.timingMode = SKActionTimingEaseInEaseOut;
      [_colorHudLayer setColorDropsHidden:YES];
      [_colorHudLayer runAction:reposition];
   }
}

- (void)generalHudDidCollapse
{
   _generalHudIsAnimating = NO;
   if (_colorHudIsAnimating)
   {
      SKAction *reposition = [SKAction moveByX:0 y:60 duration:.15];
      reposition.timingMode = SKActionTimingEaseInEaseOut;
      [_generalHudLayer setCoreFunctionButtonsHidden:YES];
      [_generalHudLayer runAction:reposition
                       completion:
       ^{
          if (_generalHudShouldExpand)
          {
             _generalHudShouldExpand = NO;
             [_generalHudLayer expand];
          }
       }];
   }
   else if (_generalHudShouldExpand)
   {
      _generalHudShouldExpand = NO;
      [_generalHudLayer expand];
   }
}

#pragma mark Helper Methods
- (void)toggleLivingForTileAtTouch:(UITouch *)touch withSoundFX:(SKAction *)soundFX
{
   [self removeAllAlertsForcefully:NO];
   
   GLTileNode *tile = [_grid tileAtTouch:touch];
   if (_currentTileBeingTouched != tile)
   {
      _oneTileTouched = (_currentTileBeingTouched == nil);

      [_currentTileBeingTouched handleTouchEnded:touch];
      [tile handleTouchBegan:touch];
      
      _currentTileBeingTouched = tile;
      if (_shouldPlaySound) [self runAction:soundFX];
      [_grid toggleTileLiving:tile];
      _gameNeedsSaving = YES;
   }
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

#pragma mark - SKScene Overridden Method
-(void)update:(CFTimeInterval)currentTime
{
   if (_running && currentTime - _lastGenerationTime > _generationDuration)
   {
      _lastGenerationTime = currentTime;
      
      if (!_grid.isInContinuousLoop)
         [_grid updateNextGeneration];
      else
      {
         _gameFinished = YES;
         [self toggleRunningButtonPressed:0 buttonPosition:CGPointZero];
      }
   }
}

#pragma mark - HUDSettingsObserver protocol
- (void)settingChanged:(NSNumber *)value ofType:(HUDValueType)type forKeyPath:(NSString *)keyPath
{
   if ([keyPath compare:@"GenerationDuration"] == NSOrderedSame)
   {
      assert(type == HVT_FLOAT);
      [self updateGenerationDuration:[value floatValue]];
   }
   else if ([keyPath compare:@"SmartMenu"] == NSOrderedSame)
   {
      assert(type == HVT_BOOL);
      _autoShowHideHudForStartStop = [value boolValue];
   }
   else if ([keyPath compare:@"SoundFX"] == NSOrderedSame)
   {
      assert(type == HVT_BOOL);
      _shouldPlaySound = [value boolValue];
   }
   else if ([keyPath compare:@"LoopDetection"] == NSOrderedSame)
   {
      assert(type == HVT_BOOL);
      _grid.inContinuousLoop = NO;
      _grid.considerDeeperLoops = [value boolValue];
   }
   else if ([keyPath compare:@"GridImageIndex"] == NSOrderedSame)
   {
      assert(type == HVT_ULONG);
      NSUInteger imageIndex = [value unsignedLongValue];
      if (imageIndex + 1 >= _gridImagePairs.count)
         return;
      
      [_grid setDeadImage:[_gridImagePairs objectAtIndex:imageIndex + 1]];
      [_grid setDeadRotation:0];
      
      [_grid setLiveImage:[_gridImagePairs objectAtIndex:imageIndex]];
      [_grid setLiveRotation:[self rotationForImageIndex:imageIndex]];
   }
}

@end
