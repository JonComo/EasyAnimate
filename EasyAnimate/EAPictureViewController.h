//
//  EAPictureViewController.h
//  EasyAnimate
//
//  Created by Jon Como on 11/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAPictureViewController;
@class EAPart;

@protocol EAPictureViewControllerDelegate <NSObject>

-(void)pictureViewController:(EAPictureViewController *)pictureVC createdPart:(EAPart *)part;

@end

@interface EAPictureViewController : UIViewController

@property (nonatomic, weak) id<EAPictureViewControllerDelegate> delegate;

@end