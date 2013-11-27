//
//  EAAnimation.m
//  EasyAnimate
//
//  Created by Jon Como on 11/27/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "EAAnimation.h"

@import SpriteKit;

@implementation EAAnimation
{
    NSMutableArray *frames; //records locations of each child sprite in scene, and ids, in a dictionary
    
    NSTimer *timerPlay;
    int currentFrame;
}

-(void)recordFrame
{
    //take a snapshot of all positions
    
    if (!frames){
        frames = [NSMutableArray array];
    }
    
    NSMutableArray *nodeInfo = [NSMutableArray array];
    
    for (SKSpriteNode *node in self.scene.children){
        NSDictionary *info = @{@"name": node.name, @"x" : @(node.position.x), @"y" : @(node.position.y)};
        [nodeInfo addObject:info];
    }
    
    [frames addObject:nodeInfo]; //add info
    currentFrame = frames.count-1;
}

-(void)play
{
    currentFrame = 0;
    
    timerPlay = [NSTimer scheduledTimerWithTimeInterval:1.0f/30.0f target:self selector:@selector(layoutNextFrame) userInfo:nil repeats:YES];
}

-(void)pause
{
    [timerPlay invalidate];
    timerPlay = nil;
}

-(void)clear
{
    [frames removeAllObjects];
    currentFrame = 0;
}

-(void)layoutNextFrame
{
    currentFrame++;
    [self layoutFrameNumber:currentFrame];
}

-(void)layoutFrameNumber:(int)index
{
    if (index < 0) index = 0;
    if (index > frames.count-1)
    {
        [self pause];
        index = frames.count-1;
    }
    
    if (frames.count == 0){
        [self pause];
        return;
    }
    
    NSArray *nodeInfo = frames[index];
    
    for (SKNode *node in self.scene.children)
    {
        //hide those with no info yet
        node.position = CGPointMake(0, -600);
    }
    
    for (NSDictionary *info in nodeInfo)
    {
        //layout all the sprites in the scene
        
        SKNode *node = [self.scene childNodeWithName:info[@"name"]];
        node.position = CGPointMake([info[@"x"] floatValue], [info[@"y"] floatValue]);
    }
}

@end
