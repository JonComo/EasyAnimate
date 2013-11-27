//
//  EASceneAnimate
//  EasyAnimate
//
//  Created by Jon Como on 11/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>

@class EAAnimation;

@interface EASceneAnimate : SKScene

@property (nonatomic, strong) EAAnimation *animation;
@property (nonatomic, strong) SKSpriteNode *sceneSprite;
@property (nonatomic, strong) SKSpriteNode *parts;


@end
