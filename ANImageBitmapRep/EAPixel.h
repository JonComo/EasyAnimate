//
//  EAPixel.h
//  EasyAnimate
//
//  Created by Jon Como on 11/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EAPixel : NSObject

@property BOOL c;
@property BOOL p;
@property BOOL t;
@property int x, y;

@property (nonatomic, weak) EAPixel *u;
@property (nonatomic, weak) EAPixel *d;
@property (nonatomic, weak) EAPixel *l;
@property (nonatomic, weak) EAPixel *r;

@end