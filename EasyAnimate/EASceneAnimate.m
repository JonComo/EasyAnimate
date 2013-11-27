//
//  EASceneAnimate
//  EasyAnimate
//
//  Created by Jon Como on 11/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "EASceneAnimate.h"

#import "EAAnimation.h"
#import "EAPart.h"

@implementation EASceneAnimate
{
    SKNode *nodeDragging;
    
    SKPhysicsJointSpring *springJoint;
    SKNode *touchNode;
    
    int uniqueCounter;
    BOOL isDraggingNewPart;
}

-(id)initWithSize:(CGSize)size
{
    if (self = [super initWithSize:size]) {
        //init
        
        uniqueCounter = 0;
        
        self.physicsWorld.gravity = CGVectorMake(0, 0);
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(0, 0, size.width, size.height)];
        
        touchNode = [SKNode new];
        touchNode.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:2];
        touchNode.physicsBody.dynamic = NO;
        touchNode.name = @"touch";
        
        SKSpriteNode *debugRect = [[SKSpriteNode alloc] initWithColor:[UIColor redColor] size:CGSizeMake(4, 4)];
        [touchNode addChild:debugRect];
        
        _parts = [[SKSpriteNode alloc] initWithColor:[SKColor purpleColor] size:CGSizeMake(size.width, size.height-320)];
        _parts.position = CGPointMake(_parts.size.width/2, _parts.size.height/2);
        _parts.name = @"parts";
        [self addChild:_parts];
        
        _parts.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:CGRectMake(-_parts.size.width/2, -_parts.size.height/2, _parts.size.width, _parts.size.height)];
        
        _sceneSprite = [[SKSpriteNode alloc] initWithColor:[SKColor yellowColor] size:CGSizeMake(320, 320)];
        _sceneSprite.position = CGPointMake(_sceneSprite.size.width/2, size.height - _sceneSprite.size.height/2);
        _sceneSprite.name = @"scene";
        [self addChild:_sceneSprite];
        
        _animation = [EAAnimation new];
        _animation.scene = _sceneSprite;
        
        EAPart *testPart = [[EAPart alloc] initWithColor:[UIColor blueColor] size:CGSizeMake(60, 80)];
        testPart.name = @"test";
        [_parts addChild:testPart];
    }
    
    return self;
}

-(void)didSimulatePhysics
{
    if (nodeDragging.physicsBody){
        nodeDragging.physicsBody.velocity = CGVectorMake(0, 0);
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //dragging sprites
    NSArray *nodes = [self nodesAtPoint:[[touches anyObject] locationInNode:self]];
    
    BOOL touchedScene = NO;
    
    for (SKNode *node in nodes){
        if ([node.name isEqualToString:@"scene"]){
            touchedScene = YES;
        }
    }
    
    if (touchedScene)
    {
        //in scene
        NSLog(@"Touched scene");
        
        isDraggingNewPart = NO;
        
        CGPoint location = [[touches anyObject] locationInNode:self.sceneSprite];
        SKNode *touchedNode = [self.sceneSprite nodeAtPoint:location];
        
        if ([touchedNode isKindOfClass:[EAPart class]]){
            
            //nodeDragging = touchedNode;
        }
    }else{
        //in parts
        NSLog(@"Touched parts");
        
        isDraggingNewPart = YES;
        
        CGPoint location = [[touches anyObject] locationInNode:self.parts];
        CGPoint sceneLocation = [[touches anyObject] locationInNode:self.sceneSprite];
        SKNode *touchedNode = [self.parts nodeAtPoint:location];
        
        if ([touchedNode isKindOfClass:[EAPart class]]){
            //duplicate and drag it!
            
            SKSpriteNode *copy = [touchedNode copy];
            
            copy.name = [NSString stringWithFormat:@"%i", uniqueCounter];
            uniqueCounter ++;
            
            [self.sceneSprite addChild:copy];
            copy.position = sceneLocation;
            
            [self addChild:touchNode];
            touchNode.position = sceneLocation;
            
            springJoint = [SKPhysicsJointSpring jointWithBodyA:touchNode.physicsBody bodyB:copy.physicsBody anchorA:CGPointZero  anchorB:sceneLocation];
            [self.physicsWorld addJoint:springJoint];
            
            //nodeDragging = copy;
        }
    }
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint locationScene = [[touches anyObject] locationInNode:self.sceneSprite];
    CGPoint locationGlobal = [[touches anyObject] locationInNode:self];

    touchNode.position = locationGlobal;
    
    /*
    if (nodeDragging){
        nodeDragging.position = location;
        
        if (!isDraggingNewPart)
            [self.animation recordFrame];
    } */
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInNode:self.sceneSprite];
    
    [touchNode removeFromParent];
    [self.physicsWorld removeJoint:springJoint];
    springJoint = nil;
    
    if (nodeDragging && location.y < -self.sceneSprite.size.height/2){
        //remove that node as you dragged it back into the parts
        [nodeDragging removeFromParent];
    }
    
    nodeDragging = nil;
}

@end
