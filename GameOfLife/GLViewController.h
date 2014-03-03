//
//  GLViewController.h
//  GameOfLife
//

//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import <SpriteKit/SpriteKit.h>

typedef void (^PhotoPickingCompletionBlock)(NSDictionary * data);
typedef void (^MessagingCompletionBlock)(MessageComposeResult msgResult);
typedef void (^MailCompletionBlock)(MFMailComposeResult mailResult);

@interface GLViewController : UIViewController

- (BOOL)acquireImageFromSource:(NSInteger)sourceType
           withCompletionBlock:(PhotoPickingCompletionBlock)completionBlock;

- (BOOL)sendMessageWithImageData:(NSData *)imageData
              andCompletionBlock:(MessagingCompletionBlock)completionBlock;

- (BOOL)sendMailWithImageData:(NSData *)imageData
           andCompletionBlock:(MailCompletionBlock)completionBlock;
@end
