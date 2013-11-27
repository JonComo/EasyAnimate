//
//  EAPart.m
//  EasyAnimate
//
//  Created by Jon Como on 11/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "EAPart.h"

@implementation EAPart

-(id)initWithColor:(UIColor *)color size:(CGSize)size
{
    if (self = [super initWithColor:color size:size]) {
        //init
        self.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:size];
        self.physicsBody.linearDamping = 0.8;
        self.physicsBody.angularDamping = 0.8;
    }
    
    return self;
}

-(id)initWithTexture:(SKTexture *)texture
{
    if (self = [super initWithTexture:texture]) {
        //init
        self.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:(texture.size.width/2 + texture.size.height/2)/2];
        self.physicsBody.linearDamping = 0.8;
        self.physicsBody.angularDamping = 0.8;
    }
    
    return self;
}

@end
