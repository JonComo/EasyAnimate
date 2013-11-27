//
//  EAAnimateViewController.m
//  EasyAnimate
//
//  Created by Jon Como on 11/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

@import SpriteKit;

#import "EAAnimateViewController.h"
#import "EAPictureViewController.h"

#import "EASceneAnimate.h"
#import "EAAnimation.h"

#import "EAPart.h"

@interface EAAnimateViewController () < EAPictureViewControllerDelegate>
{
    __weak IBOutlet SKView *viewScene;
    EASceneAnimate *scene;
}

@end

@implementation EAAnimateViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    scene = [EASceneAnimate sceneWithSize:viewScene.bounds.size];
    
    scene.scaleMode = SKSceneScaleModeAspectFit;
    
    viewScene.showsFPS = YES;
    
    [viewScene presentScene:scene];
    
//    NSTimer *capture;
//    capture = [NSTimer scheduledTimerWithTimeInterval:1.0f/24.0f target:self selector:@selector(captureScene) userInfo:nil repeats:YES];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    viewScene.paused = NO;
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    viewScene.paused = YES;
}

-(void)captureScene
{
    NSLog(@"Captured");
    
    UIGraphicsBeginImageContextWithOptions(viewScene.bounds.size, NO, 1);
    [viewScene drawViewHierarchyInRect:viewScene.bounds afterScreenUpdates:YES];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
//    
//    UIImageView *ss = [[UIImageView alloc] initWithFrame:CGRectMake(0, 100, 320, 320)];
//    [self.view addSubview:ss];
//    ss.image = viewImage;
}

- (IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)newPicture:(id)sender
{
    EAPictureViewController *pictureVC = [self.storyboard instantiateViewControllerWithIdentifier:@"pictureVC"];
    pictureVC.delegate = self;
    
    [self presentViewController:pictureVC animated:YES completion:nil];
}

- (IBAction)play:(id)sender {
    [scene.animation play];
}

- (IBAction)clear:(id)sender {
    [scene.animation clear];
}

-(void)pictureViewController:(EAPictureViewController *)pictureVC createdPart:(EAPart *)part
{
    part.position = CGPointMake(0, 0);
    [scene.parts addChild:part];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
