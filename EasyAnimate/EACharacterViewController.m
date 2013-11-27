//
//  EACharacterViewController.m
//  EasyAnimate
//
//  Created by Jon Como on 11/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "EACharacterViewController.h"

#import "EAPart.h"

#import "ANImageBitmapRep.h"
#import "MBProgressHUD.h"

@interface EACharacterViewController () <UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    __weak IBOutlet UIImageView *imageViewOutput;
    UIImage *imageSource;
}

@end

@implementation EACharacterViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
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

- (IBAction)sliderChanged:(UISlider *)sender
{
    imageViewOutput.image = nil;
    
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:NO];
    hud.mode = MBProgressHUDModeIndeterminate;
    hud.labelText = @"Cutting BG";
    
    ANImageBitmapRep *rep = [ANImageBitmapRep imageBitmapRepWithImage:imageSource];
    
    [rep cutPixelsBelowWhite:sender.value completion:^{
        [MBProgressHUD hideAllHUDsForView:self.view animated:YES];
        
        UIImage *cutout = [rep image];
        imageViewOutput.image = cutout;
    }];
}

- (IBAction)getPicture:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    [imagePicker setDelegate:self];
    [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
    imagePicker.allowsEditing = YES;
    
    [self presentViewController:imagePicker animated:YES completion:nil];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *largeEdited = info[UIImagePickerControllerEditedImage];
    
    ANImageBitmapRep *rep = [ANImageBitmapRep imageBitmapRepWithImage:largeEdited];
    [rep setSize:BMPointMake(140, 140)];
    
    imageSource = [rep image];
    
    imageViewOutput.image = imageSource;
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)done:(id)sender
{
    SKTexture *texture = [SKTexture textureWithImage:imageViewOutput.image];
    EAPart *part = [[EAPart alloc] initWithTexture:texture];
    
    if ([self.delegate respondsToSelector:@selector(characterViewController:createdPart:)])
        [self.delegate characterViewController:self createdPart:part];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}


@end
