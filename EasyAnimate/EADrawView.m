//
//  EADrawView.m
//  EasyAnimate
//
//  Created by Jon Como on 11/26/13.
//  Copyright (c) 2013 Jon Como. All rights reserved.
//

#import "EADrawView.h"
#import "EALineDisplayView.h"

@implementation EADrawView
{
    UIBezierPath *currentPath;
    
    UIImage *imageSource;
    
    UIImageView *imageView;
    EALineDisplayView *viewPaths;
    
    int lineResolution;
    
    float minX, maxX, minY, maxY;
}

-(void)setImage:(UIImage *)image
{
    imageSource = image;
    
    if (!imageView)
    {
        imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        [self addSubview:imageView];
        
        viewPaths = [[EALineDisplayView alloc] initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        viewPaths.backgroundColor = [UIColor clearColor];
        [self addSubview:viewPaths];
        
        viewPaths.alpha = 0.5;
        lineResolution = 0;
        
        minX = 320;
        minY = 320;
        maxX = 0;
        maxY = 0;
    }
    
    imageView.image = imageSource;
}

-(UIImage *)getTransparentImage
{
    CGRect drawnSize = CGRectMake(minX, minY, maxX-minX, maxY-minY);
    
    NSLog(@"Drawn rect: %@", NSStringFromCGRect(drawnSize));
    
    //Make mask
    UIGraphicsBeginImageContextWithOptions(drawnSize.size, NO, 1);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    float alpha = viewPaths.alpha;
    viewPaths.alpha = 1;
    [viewPaths drawViewHierarchyInRect:CGRectMake(-drawnSize.origin.x, -drawnSize.origin.y, 320, 320) afterScreenUpdates:YES];
    viewPaths.alpha = alpha;
    
    UIImage *mask = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    
    UIGraphicsBeginImageContextWithOptions(drawnSize.size, NO, 1);
    
    context = UIGraphicsGetCurrentContext();
    
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -drawnSize.size.height);
    
    CGContextClipToMask(context, CGRectMake(0, 0, drawnSize.size.width, drawnSize.size.height), mask.CGImage);
    
    CGContextTranslateCTM(context, 0, drawnSize.size.height);
    CGContextTranslateCTM(context, 0, -320);
    
    CGContextDrawImage(context, CGRectMake(-drawnSize.origin.x, drawnSize.origin.y, 320, 320), imageSource.CGImage);
    
    UIImage *outputImage = UIGraphicsGetImageFromCurrentImageContext();
    
    return outputImage;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    
    if (!viewPaths.paths)
        viewPaths.paths = [NSMutableArray array];
    
    currentPath = [[UIBezierPath alloc] init];
    
    currentPath.lineWidth = 6 / self.zoomScale;
    currentPath.lineCapStyle = kCGLineCapRound;
    
    [currentPath moveToPoint:location];
    
    [viewPaths.paths addObject:currentPath];
    
    [viewPaths setNeedsDisplay];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint location = [[touches anyObject] locationInView:self];
    
    lineResolution ++;
    
    if (lineResolution > 4)
    {
        lineResolution = 0;
        
        NSLog(@"Moving: %f %f", location.x, location.y);
        
        [currentPath addLineToPoint:location];
        
        if (location.x > maxX) maxX = location.x;
        if (location.x < minX) minX = location.x;
        if (location.y > maxY) maxY = location.y;
        if (location.y < minY) minY = location.y;
        
        [viewPaths setNeedsDisplay];
    }
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [viewPaths setNeedsDisplay];
    [viewPaths rasterize];
    
    currentPath = nil;
}

@end
