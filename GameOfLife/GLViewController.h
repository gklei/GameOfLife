//
//  GLViewController.h
//  GameOfLife
//

//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SpriteKit/SpriteKit.h>

typedef void (^PhotoPickingCompletionBlock)(UIImage * image);

@interface GLViewController : UIViewController

- (void)acquireImageFromSource:(NSInteger)sourceType
           withCompletionBlock:(PhotoPickingCompletionBlock)completionBlock;

- (void)sendMessageWithImage:(UIImage *)image
//          andCompletionBlock:(PhotoPickingCompletionBlock)completionBlock
                                                                           ;
@end
