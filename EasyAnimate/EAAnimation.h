//
//  EAAnimation.h
//  EasyAnimate
//
//  Created by Jon Como on 11/27/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SKSpriteNode;

@interface EAAnimation : NSObject

@property (nonatomic, weak) SKSpriteNode *scene;

-(void)recordFrame;
-(void)play;

-(void)clear;

@end
