//
//  EAPictureViewController.m
//  EasyAnimate
//
//  Created by Jon Como on 11/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "EAPictureViewController.h"
#import "ANImageBitmapRep.h"
#import "EAScrollView.h"
#import "EADrawView.h"

#import "EAPart.h"

@interface EAPictureViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIScrollViewDelegate>

@end

@implementation EAPictureViewController
{
    __weak IBOutlet EAScrollView *scrollViewContent;
    UIImage *imageSource;
    __weak IBOutlet EADrawView *drawView;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    scrollViewContent.contentSize = CGSizeMake(320, 320);
    scrollViewContent.drawView = drawView;
    
    drawView.zoomScale = 1;
    
    for (UIGestureRecognizer *gestureRecognizer in scrollViewContent.gestureRecognizers) {
        if ([gestureRecognizer  isKindOfClass:[UIPanGestureRecognizer class]]) {
            UIPanGestureRecognizer *panGR = (UIPanGestureRecognizer *) gestureRecognizer;
            panGR.minimumNumberOfTouches = 2;
        }
    }
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

- (IBAction)done:(id)sender
{
    UIImage *output = [drawView getTransparentImage];
    SKTexture *texture = [SKTexture textureWithImage:output];
    
    EAPart *part = [[EAPart alloc] initWithTexture:texture];
    
    if ([self.delegate respondsToSelector:@selector(pictureViewController:createdPart:)])
        [self.delegate pictureViewController:self createdPart:part];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)newPicture:(id)sender
{
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
    imagePicker.allowsEditing = YES;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *largeEdited = info[UIImagePickerControllerEditedImage];
    
    ANImageBitmapRep *rep = [ANImageBitmapRep imageBitmapRepWithImage:largeEdited];
    [rep setSize:BMPointMake(100, 100)];
    
    imageSource = [rep image];
    
    drawView.image = imageSource;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return drawView;
}

-(void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    drawView.zoomScale = scrollView.zoomScale;
}

@end