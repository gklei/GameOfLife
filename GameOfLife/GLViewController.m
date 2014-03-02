//
//  GLViewController.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/1/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLViewController.h"
#import "GLGridScene.h"

#import <AssetsLibrary/AssetsLibrary.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface GLViewController()<UINavigationControllerDelegate,
                              UIImagePickerControllerDelegate,
                              MFMessageComposeViewControllerDelegate>
{
   GLGridScene * _gridScene;
}

@property (readwrite, copy) PhotoPickingCompletionBlock photoCompletionBlock;
@property (readwrite, copy) MessagingCompletionBlock  messageCompletionBlock;

@end

@implementation GLViewController

- (void)viewDidLoad
{
   [super viewDidLoad];

   if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
      [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)]; // iOS 7
   else
      [[UIApplication sharedApplication] setStatusBarHidden:YES
                                              withAnimation:UIStatusBarAnimationSlide]; // iOS 6

   // Configure the view.
   SKView * skView = (SKView *)self.view;
//    skView.showsFPS = YES;
//    skView.showsNodeCount = YES;

   // Create and configure the scene.
   _gridScene = [GLGridScene sceneWithViewController:self];
   _gridScene.scaleMode = SKSceneScaleModeAspectFill;
   // Present the scene.
   [skView presentScene:_gridScene];
}

- (BOOL)prefersStatusBarHidden
{
   return YES;
}

- (BOOL)canBecomeFirstResponder
{
   return YES;
}

-(void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];
   [self becomeFirstResponder];
   [_gridScene expandGeneralHUD];
}

- (void)viewWillDisappear:(BOOL)animated
{
   [self resignFirstResponder];
   [super viewWillDisappear:animated];
}

- (BOOL)shouldAutorotate
{
   return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
   if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
      return UIInterfaceOrientationMaskAllButUpsideDown;
   else
      return UIInterfaceOrientationMaskAll;
}

- (void)didReceiveMemoryWarning
{
   [super didReceiveMemoryWarning];
   // Release any cached data, images, etc that aren't in use.
}

#pragma mark - UIImagePickerController and delagate methods

- (void)callPhotoPickingCompletionBlock:(NSDictionary *) imageData
{
   if (_photoCompletionBlock) _photoCompletionBlock(imageData);
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   NSURL * url = [info objectForKey:UIImagePickerControllerReferenceURL];
   if (url)
   {
      ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
      [library assetForURL:url
               resultBlock:
                ^(ALAsset *asset)
                {
                   NSMutableDictionary * imageData = [[NSMutableDictionary alloc] init];
                   NSDictionary * metaData = [[asset defaultRepresentation] metadata];
                   if (metaData)
                   {
                      NSDictionary * exifData =
                        [metaData objectForKey:(NSString *)kCGImagePropertyExifDictionary];
                      
                      if (exifData)
                      {
                         NSString * comment =
                           [exifData objectForKey:(NSString*)kCGImagePropertyExifUserComment];
                         
                         if (comment)
                            [imageData setObject:comment forKey:@"GridRep"];
                      }
                   }
                   
                   UIImage * image =
                     [UIImage imageWithCGImage:[[asset defaultRepresentation] fullResolutionImage]];
                   
                   [imageData setObject:image forKey:@"UIImage"];
                   [self callPhotoPickingCompletionBlock:imageData];
                }
              failureBlock:
                ^(NSError *error)
                {
                   NSLog(@"error = %@", error);
                }];
      
      [self dismissViewControllerAnimated:YES completion:nil];
   }
   else
   {
      UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
      NSDictionary * imageData = [NSDictionary dictionaryWithObject:image forKey:@"UIImage"];
      [self dismissViewControllerAnimated:YES completion:nil];
      [self callPhotoPickingCompletionBlock:imageData];
   }
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
   [self dismissViewControllerAnimated:YES completion:nil];
   [self callPhotoPickingCompletionBlock:nil];
}

- (void)acquireImageFromSource:(NSInteger)sourceType
           withCompletionBlock:(PhotoPickingCompletionBlock)completionBlock
{  
   if (![UIImagePickerController isSourceTypeAvailable:sourceType]) return;

   self.photoCompletionBlock = completionBlock;
   
   UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
   imagePicker.delegate = self;
   imagePicker.sourceType = sourceType;
   imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
   imagePicker.allowsEditing = NO;
   [self presentViewController:imagePicker animated:YES completion:nil];
}

#pragma mark - MFMessageComposeViewController and delagate methods

- (void)callMessagingCompletionBlock:(MessageComposeResult)result
{
   if (_messageCompletionBlock) _messageCompletionBlock(result);
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)msgResult
{
   [self dismissViewControllerAnimated:YES completion:nil];
   [self callMessagingCompletionBlock:msgResult];
}

- (void)sendMessageWithImage:(UIImage *)image
          andCompletionBlock:(MessagingCompletionBlock)completionBlock;
{
   if (![MFMessageComposeViewController canSendText]) return;
   if (![MFMessageComposeViewController respondsToSelector:@selector(canSendAttachments)]) return;
   if (![MFMessageComposeViewController canSendAttachments]) return;
   
   self.messageCompletionBlock = completionBlock;
   
   MFMessageComposeViewController* composer = [[MFMessageComposeViewController alloc] init];
   composer.messageComposeDelegate = self;
   [composer setBody:@"Here's some LiFE for you...because you can never have too much LiFE!"];
   
   NSData* attachment = UIImageJPEGRepresentation(image, 0.5);
   NSString* uti = (NSString*)kUTTypeMessage;
   [composer addAttachmentData:attachment typeIdentifier:uti filename:@"LiFE.jpg"];
   
   [self presentViewController:composer animated:YES completion:nil];
}

@end
