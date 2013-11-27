//
//  EACharacterViewController.h
//  EasyAnimate
//
//  Created by Jon Como on 11/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <UIKit/UIKit.h>

@class EAPart;
@class EACharacterViewController;

@protocol EACharacterViewControllerDelegate <NSObject>

-(void)characterViewController:(EACharacterViewController *)characterVC createdPart:(EAPart *)part;

@end

@interface EACharacterViewController : UIViewController

@property (nonatomic, weak) id<EACharacterViewControllerDelegate> delegate;

@end