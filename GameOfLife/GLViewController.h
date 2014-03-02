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

@interface GLViewController : UIViewController

- (void)acquireImageFromSource:(NSInteger)sourceType
           withCompletionBlock:(PhotoPickingCompletionBlock)completionBlock;

- (void)sendMessageWithImage:(UIImage *)image
          andCompletionBlock:(MessagingCompletionBlock)completionBlock;
@end
