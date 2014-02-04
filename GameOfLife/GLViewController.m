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
#import <MessageUI/MessageUI.h>
#import <MobileCoreServices/MobileCoreServices.h>

@interface GLViewController()<UINavigationControllerDelegate,
                              UIImagePickerControllerDelegate,
                              MFMessageComposeViewControllerDelegate>
{
   GLGridScene * _gridScene;
}

@property (readwrite, copy) PhotoPickingCompletionBlock photoCompletionBlock;

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

- (void)callPhotoPickingCompletionBlock:(UIImage *)image
{
   if (_photoCompletionBlock)
      _photoCompletionBlock(image);
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   UIImage *image = info[UIImagePickerControllerOriginalImage];
   [self dismissViewControllerAnimated:YES completion:nil];
   [self callPhotoPickingCompletionBlock:image];
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
   [self dismissViewControllerAnimated:YES completion:nil];
   [self callPhotoPickingCompletionBlock:nil];
}

- (void)acquireImageFromSource:(NSInteger)sourceType
           withCompletionBlock:(PhotoPickingCompletionBlock)completionBlock
{  
   if ([UIImagePickerController isSourceTypeAvailable:sourceType])
   {
      self.photoCompletionBlock = completionBlock;
      
      UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
      imagePicker.delegate = self;
      imagePicker.sourceType = sourceType;
      imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
      imagePicker.allowsEditing = NO;
      [self presentViewController:imagePicker animated:YES completion:nil];
   }
}

#pragma mark - UIImagePickerController and delagate methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result
{
   switch (result)
   {
      case MessageComposeResultCancelled:
         break;
      case MessageComposeResultFailed:
      {
//         UIAlertView *warningAlert =
//            [[UIAlertView alloc] initWithTitle:@"Error"
//                                       message:@"Failed to send SMS!"
//                                      delegate:nil
//                             cancelButtonTitle:@"OK"
//                             otherButtonTitles:nil];
//         [warningAlert show];
         break;
      }
      case MessageComposeResultSent:
//         GLAlertLayer * alert = [GLAlertLayer alertWithHeader:@""
//                                                         body:@""
//                                                     position:0
//                                                    andParent:nil;
         break;
      default:
         break;
   }
   
   [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)sendMessageWithImage:(UIImage *)image
//          andCompletionBlock:(PhotoPickingCompletionBlock)completionBlock
{
   if (![MFMessageComposeViewController canSendText])
      return;
   
   if (![MFMessageComposeViewController respondsToSelector:@selector(canSendAttachments)])
       return;
   
   if (![MFMessageComposeViewController canSendAttachments])
      return;
   
   MFMessageComposeViewController* composer = [[MFMessageComposeViewController alloc] init];
   composer.messageComposeDelegate = self;
   [composer setBody:@"My high flying LiFE!!"];
   
   NSData* attachment = UIImageJPEGRepresentation(image, 0.5);
   NSString* uti = (NSString*)kUTTypeMessage;
   [composer addAttachmentData:attachment typeIdentifier:uti filename:@"LiFE.jpg"];
   
   [self presentViewController:composer animated:YES completion:nil];
}

@end
