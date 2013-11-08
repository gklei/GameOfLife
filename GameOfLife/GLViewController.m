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

   // Configure the view.
   SKView * skView = (SKView *)self.view;
   //    skView.showsFPS = YES;
   //    skView.showsNodeCount = YES;

   // Create and configure the scene.
   _gridScene = [GLGridScene sceneWithSize:skView.bounds.size];
   _gridScene.scaleMode = SKSceneScaleModeAspectFill;
   // Present the scene.
   [skView presentScene:_gridScene];
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

- (void)motionEnded:(UIEventSubtype)motion
          withEvent:(UIEvent *)event
{
   if (motion == UIEventSubtypeMotionShake)
      [_gridScene toggleRunning];
}

- (BOOL)shouldAutorotate
{
   return YES;
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
