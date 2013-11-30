//
//  GLViewController.m
//  GameOfLife
//
//  Created by Gregory Klein on 11/1/13.
//  Copyright (c) 2013 Gregory Klein. All rights reserved.
//

#import "GLViewController.h"
#import "GLGridScene.h"

@interface GLViewController()
{
   GLGridScene *_gridScene;
}
@end

@implementation GLViewController

- (void)viewDidLoad
{
   [super viewDidLoad];

   if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)])
      // iOS 7
      [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
   else
      // iOS 6
      [[UIApplication sharedApplication] setStatusBarHidden:YES
                                              withAnimation:UIStatusBarAnimationSlide];

   // Configure the view.
   SKView * skView = (SKView *)self.view;
//   skView.showsFPS = YES;
//    skView.showsNodeCount = YES;

   // Create and configure the scene.
   _gridScene = [GLGridScene sceneWithSize:skView.bounds.size];
   _gridScene.scaleMode = SKSceneScaleModeAspectFill;
   // Present the scene.
   [skView presentScene:_gridScene];
}

- (BOOL)prefersStatusBarHidden {
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

@end
