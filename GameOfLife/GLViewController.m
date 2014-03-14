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
                              MFMessageComposeViewControllerDelegate,
                              MFMailComposeViewControllerDelegate>
{
   GLGridScene * _gridScene;
}

@property (readwrite, copy) PhotoPickingCompletionBlock photoCompletionBlock;
@property (readwrite, copy) MessagingCompletionBlock  messageCompletionBlock;
@property (readwrite, copy) MailCompletionBlock  mailCompletionBlock;

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

- (void)grabImageDataFromUrl:(NSURL *)url
{
   ALAssetsLibraryAssetForURLResultBlock successBlock =
      ^(ALAsset *asset)
      {
         // we grab the metadata but also save the image
         // in case scanning the metadata fails
         NSMutableDictionary * imageData = [[NSMutableDictionary alloc] init];
         
         NSDictionary * metaData = [[asset defaultRepresentation] metadata];
         NSDictionary * exif = [metaData objectForKey:(NSString *)kCGImagePropertyExifDictionary];
         NSString * comment = [exif objectForKey:(NSString*)kCGImagePropertyExifUserComment];
         if (comment) [imageData setObject:comment forKey:@"GridRep"];
         
         UIImage * image = [UIImage imageWithCGImage:[[asset defaultRepresentation]
                                                      fullResolutionImage]];
         [imageData setObject:image forKey:@"UIImage"];
         [self callPhotoPickingCompletionBlock:imageData];
      };

   ALAssetsLibraryAccessFailureBlock errorBlock =
      ^(NSError *error)
      {
         NSLog(@"error = %@", error);
      };
   
   ALAssetsLibrary * assetLib = [[ALAssetsLibrary alloc] init];
   [assetLib assetForURL:url resultBlock:successBlock failureBlock:errorBlock];
   
   [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
   NSURL * url = [info objectForKey:UIImagePickerControllerReferenceURL];
   if (url)
   {
      [self grabImageDataFromUrl:url];
   }
   else
   {
      // we can only grab the image
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

- (BOOL)acquireImageFromSource:(NSInteger)sourceType
           withCompletionBlock:(PhotoPickingCompletionBlock)completionBlock
{  
   if (![UIImagePickerController isSourceTypeAvailable:sourceType]) return NO;

   self.photoCompletionBlock = completionBlock;
   
   UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
   imagePicker.delegate = self;
   imagePicker.sourceType = sourceType;
   imagePicker.mediaTypes = @[(NSString *)kUTTypeImage];
   imagePicker.allowsEditing = NO;
   [self presentViewController:imagePicker animated:YES completion:nil];
   
   return YES;
}

#pragma mark - MFMailComposeViewController and delagate methods

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error
{
   [self dismissViewControllerAnimated:YES completion:nil];
   if (_mailCompletionBlock) _mailCompletionBlock(result);
}

- (BOOL)sendMailWithImageData:(NSData *)imageData
           andCompletionBlock:(MailCompletionBlock)completionBlock
{
   if (![MFMailComposeViewController canSendMail])
      return NO;
   
   self.mailCompletionBlock = completionBlock;
   
   NSString* uti = (NSString*)kUTTypeImage;
   MFMailComposeViewController * mailer = [[MFMailComposeViewController alloc] init];
   mailer.mailComposeDelegate = self;
   [mailer setSubject:@"Here's some LiFE for you..."];
   [mailer setMessageBody:@"..because you can never have too much LiFE!" isHTML:NO];
   [mailer addAttachmentData:imageData mimeType:uti fileName:@"LiFE.jpg"];
   [self presentViewController:mailer animated:YES completion:nil];
   
   return YES;
}

#pragma mark - MFMessageComposeViewController and delagate methods

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller
                 didFinishWithResult:(MessageComposeResult)result;
{
   [self dismissViewControllerAnimated:YES completion:nil];
   if (_messageCompletionBlock) _messageCompletionBlock(result);
}

- (BOOL)sendMessageWithImageData:(NSData *)imageData
              andCompletionBlock:(MessagingCompletionBlock)completionBlock;
{
   MFMessageComposeViewController * messageComposer = [[MFMessageComposeViewController alloc] init];
   if (messageComposer == nil) return NO;
   
   if (![MFMessageComposeViewController canSendText]) return NO;
   if (![MFMessageComposeViewController respondsToSelector:@selector(canSendAttachments)]) return NO;
   if (![MFMessageComposeViewController canSendAttachments]) return NO;
   
   NSString* uti = (NSString*)kUTTypeImage;
   if (![MFMessageComposeViewController isSupportedAttachmentUTI:uti]) return NO;
   
   self.messageCompletionBlock = completionBlock;
   
   messageComposer.messageComposeDelegate = self;
   [messageComposer setBody:@"Here's some LiFE for you...because you can never have too much LiFE!"];
   
   if (![messageComposer addAttachmentData:imageData
                             typeIdentifier:uti
                                   filename:@"LiFE.jpg"]) return NO;
   
   [self presentViewController:messageComposer animated:YES completion:nil];
   
   return YES;
}

@end
