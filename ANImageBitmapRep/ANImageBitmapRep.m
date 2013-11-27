//
//  ANImageBitmapRep.m
//  ImageManip
//
//  Created by Alex Nichol on 7/12/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ANImageBitmapRep.h"

#import "EAPixel.h"

BMPixel BMPixelMake (CGFloat red, CGFloat green, CGFloat blue, CGFloat alpha) {
	BMPixel pixel;
	pixel.red = red;
	pixel.green = green;
	pixel.blue = blue;
	pixel.alpha = alpha;
	return pixel;
}

#if TARGET_OS_IPHONE
UIColor * UIColorFromBMPixel (BMPixel pixel) {
	return [UIColor colorWithRed:pixel.red green:pixel.green blue:pixel.blue alpha:pixel.alpha];
}
#elif TARGET_OS_MAC
NSColor * NSColorFromBMPixel (BMPixel pixel) {
	return [NSColor colorWithCalibratedRed:pixel.red green:pixel.green blue:pixel.blue alpha:pixel.alpha];
}
#endif

@interface ANImageBitmapRep (BaseClasses)

- (void)generateBaseClasses;

@end

@implementation ANImageBitmapRep
{
    CGSize imageSize;
    NSMutableArray *allPixels;
}

- (void)forwardInvocation:(NSInvocation *)anInvocation {
	if (!baseClasses) [self generateBaseClasses];
	for (int i = 0; i < [baseClasses count]; i++) {
		BitmapContextManipulator * manip = [baseClasses objectAtIndex:i];
		if ([manip respondsToSelector:[anInvocation selector]]) {
			[anInvocation invokeWithTarget:manip];
			return;
		}
	}
	[self doesNotRecognizeSelector:[anInvocation selector]];
}

#if __has_feature(objc_arc) == 1
+ (ANImageBitmapRep *)imageBitmapRepWithCGSize:(CGSize)avgSize {
	return [[ANImageBitmapRep alloc] initWithSize:BMPointMake(round(avgSize.width), round(avgSize.height))];
}

+ (ANImageBitmapRep *)imageBitmapRepWithImage:(ANImageObj *)anImage {
	return [[ANImageBitmapRep alloc] initWithImage:anImage];
}
#else
+ (ANImageBitmapRep *)imageBitmapRepWithCGSize:(CGSize)avgSize {
	return [[[ANImageBitmapRep alloc] initWithSize:BMPointMake(round(avgSize.width), round(avgSize.height))] autorelease];
}

+ (ANImageBitmapRep *)imageBitmapRepWithImage:(ANImageObj *)anImage {
	return [[[ANImageBitmapRep alloc] initWithImage:anImage] autorelease];
}
#endif

- (void)invertColors {
	UInt8 pixel[4];
	BMPoint size = [self bitmapSize];
	for (long y = 0; y < size.y; y++) {
		for (long x = 0; x < size.x; x++) {
			[self getRawPixel:pixel atPoint:BMPointMake(x, y)];
			pixel[0] = 255 - pixel[0];
			pixel[1] = 255 - pixel[1];
			pixel[2] = 255 - pixel[2];
			[self setRawPixel:pixel atPoint:BMPointMake(x, y)];
		}
	}
}

- (void)setQuality:(CGFloat)quality {
	NSAssert(quality >= 0 && quality <= 1, @"Quality must be between 0 and 1.");
	if (quality == 1.0) return;
	CGSize cSize = CGSizeMake((CGFloat)([self bitmapSize].x) * quality, (CGFloat)([self bitmapSize].y) * quality);
	BMPoint oldSize = [self bitmapSize];
	[self setSize:BMPointMake(round(cSize.width), round(cSize.height))];
	[self setSize:oldSize];
}

- (void)setBrightness:(CGFloat)brightness {
	NSAssert(brightness >= 0 && brightness <= 2, @"Brightness must be between 0 and 2.");
	BMPoint size = [self bitmapSize];
	for (long y = 0; y < size.y; y++) {
		for (long x = 0; x < size.x; x++) {
			BMPoint point = BMPointMake(x, y);
			BMPixel pixel = [self getPixelAtPoint:point];
			pixel.red *= brightness;
			pixel.green *= brightness;
			pixel.blue *= brightness;
			if (pixel.red > 1) pixel.red = 1;
			if (pixel.green > 1) pixel.green = 1;
			if (pixel.blue > 1) pixel.blue = 1;
			[self setPixel:pixel atPoint:point];
		}
	}
}

- (BMPixel)getPixelAtPoint:(BMPoint)point {
	UInt8 rawPixel[4];
	[self getRawPixel:rawPixel atPoint:point];
	BMPixel pixel;
	pixel.alpha = (CGFloat)(rawPixel[3]) / 255.0;
	pixel.red = ((CGFloat)(rawPixel[0]) / 255.0) / pixel.alpha;
	pixel.green = ((CGFloat)(rawPixel[1]) / 255.0) / pixel.alpha;
	pixel.blue = ((CGFloat)(rawPixel[2]) / 255.0) / pixel.alpha;
	return pixel;
}

- (void)setPixel:(BMPixel)pixel atPoint:(BMPoint)point {
	NSAssert(pixel.red >= 0 && pixel.red <= 1, @"Pixel color must range from 0 to 1.");
	NSAssert(pixel.green >= 0 && pixel.green <= 1, @"Pixel color must range from 0 to 1.");
	NSAssert(pixel.blue >= 0 && pixel.blue <= 1, @"Pixel color must range from 0 to 1.");
	NSAssert(pixel.alpha >= 0 && pixel.alpha <= 1, @"Pixel color must range from 0 to 1.");
	UInt8 rawPixel[4];
	rawPixel[0] = round(pixel.red * 255.0 * pixel.alpha);
	rawPixel[1] = round(pixel.green * 255.0 * pixel.alpha);
	rawPixel[2] = round(pixel.blue * 255.0 * pixel.alpha);
	rawPixel[3] = round(pixel.alpha * 255.0);
    
	[self setRawPixel:rawPixel atPoint:point];
}

- (ANImageObj *)image {
	return ANImageFromCGImage([self CGImage]);
}

-(void)cutPixelsBelowWhite:(float)whiteLevel completion:(void (^)(void))block
{
    imageSize = self.image.size;
    
    if (!allPixels)
        allPixels = [NSMutableArray array];
    
    [allPixels removeAllObjects];
    
    for (int x = 0; x<self.image.size.width; x++)
    {
        NSMutableArray *rowPixels = [NSMutableArray array];
        
        [allPixels addObject:rowPixels];
        
        for (int y = 0; y<self.image.size.height; y++)
        {
            BMPixel pixel = [self getPixelAtPoint:BMPointMake(x, y)];
            
            BOOL isTransparent = NO;
            
            if (pixel.red > whiteLevel && pixel.blue > whiteLevel && pixel.green > whiteLevel){
                isTransparent = YES;
            }
            
            EAPixel *pixelModel = [EAPixel new];
            
            pixelModel.p = NO;
            pixelModel.c = NO;
            pixelModel.t = isTransparent;
            
            pixelModel.x = x;
            pixelModel.y = y;
            
            [rowPixels addObject:pixelModel];
        }
    }
    
    //Associate pixels
    for (NSMutableArray *row in allPixels)
    {
        for (EAPixel *pixelModel in row)
        {
            pixelModel.u = [self pixelAtPoint:BMPointMake(pixelModel.x, pixelModel.y-1)];
            pixelModel.d = [self pixelAtPoint:BMPointMake(pixelModel.x, pixelModel.y+1)];
            pixelModel.l = [self pixelAtPoint:BMPointMake(pixelModel.x-1, pixelModel.y)];
            pixelModel.r = [self pixelAtPoint:BMPointMake(pixelModel.x+1, pixelModel.y)];
        }
    }
    
    //Start off with a transparent left corner
    EAPixel *pixelModel = allPixels[0][0];
    pixelModel.c = YES;
    [self setPixel:BMPixelMake(1, 1, 1, 0) atPoint:BMPointMake(0, 0)];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        BOOL pixelChanged = YES;
        
        while (pixelChanged)
        {
            for (NSMutableArray *row in allPixels)
            {
                for (EAPixel *pixelModel in row)
                {
                    if (!pixelModel.p && pixelModel.c)
                    {
                        //check all neighbors
                        pixelModel.p = YES;
                        
                        BOOL a = [self changePixel:pixelModel];
                        
                        BOOL b = [self changePixel:pixelModel.u];
                        BOOL c = [self changePixel:pixelModel.d];
                        BOOL d = [self changePixel:pixelModel.l];
                        BOOL e = [self changePixel:pixelModel.r];
                        
                        if (a || b || c || d || e){
                            //pixel was changed, also this one is connected
                            pixelModel.c = YES;
                        }else{
                            
                            BOOL unprocessedConnectedPixel = NO;
                            
                            for (NSMutableArray *row in allPixels)
                            {
                                for (EAPixel *pixelModelTest in row)
                                {
                                    if (!pixelModelTest.p && pixelModelTest.c){
                                        unprocessedConnectedPixel = YES;
                                    }
                                }
                            }
                            
                            pixelChanged = unprocessedConnectedPixel;
                        }
                    }
                }
            }
        }
        
        //Done fixing all pixels, find min rect
        int minX = imageSize.width;
        int minY = imageSize.height;
        
        int maxX = 0;
        int maxY = 0;
        
        for (NSMutableArray *row in allPixels)
        {
            for (EAPixel *pixelModel in row)
            {
                //stop at processed unconnected pixels
                if (!pixelModel.t)
                {
                    if (pixelModel.x > maxX) maxX = pixelModel.x;
                    if (pixelModel.x < minX) minX = pixelModel.x;
                    
                    if (pixelModel.y > maxY) maxY = pixelModel.y;
                    if (pixelModel.y < minY) minY = pixelModel.y;
                }
            }
        }
        
        NSLog(@"Rect %i %i, %i %i", minX, minY, maxX, maxY);
        
        [self setNeedsUpdate:YES];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [self setNeedsUpdate:YES];
            if (block) block();
        });
    });
}

-(EAPixel *)pixelAtPoint:(BMPoint)point
{
    if (point.x < 0 || point.y < 0 || point.x > imageSize.width-1 || point.y > imageSize.height-1)
    {
        return nil;
    }else{
        return allPixels[point.x][point.y];
    }
}

-(BOOL)changePixel:(EAPixel *)pixel
{
    if (!pixel){
        return NO;
    }else{
        if (pixel.p) return NO;
        
        if (pixel.t){
            [self setPixel:BMPixelMake(1, 1, 1, 0) atPoint:BMPointMake(pixel.x, pixel.y)];
            pixel.c = YES;
            
            return YES;
        }
    }
    
    return NO;
}

#if __has_feature(objc_arc) != 1
- (void)dealloc {
	[baseClasses release];
	[super dealloc];
}
#endif

#pragma mark Base Classes

- (void)generateBaseClasses {
	BitmapCropManipulator * croppable = [[BitmapCropManipulator alloc] initWithContext:self];
	BitmapScaleManipulator * scalable = [[BitmapScaleManipulator alloc] initWithContext:self];
	BitmapRotationManipulator * rotatable = [[BitmapRotationManipulator alloc] initWithContext:self];
    BitmapDrawManipulator * drawable = [[BitmapDrawManipulator alloc] initWithContext:self];
	baseClasses = [[NSArray alloc] initWithObjects:croppable, scalable, rotatable, drawable, nil];
#if __has_feature(objc_arc) != 1
	[rotatable release];
	[scalable release];
	[croppable release];
    [drawable release];
#endif
}

#pragma mark NSCopying

- (id)copyWithZone:(NSZone *)zone {
	BMPoint size = [self bitmapSize];
	ANImageBitmapRep * rep = [[ANImageBitmapRep allocWithZone:zone] initWithSize:size];
	CGContextRef newContext = [rep context];
	CGContextDrawImage(newContext, CGRectMake(0, 0, size.x, size.y), [self CGImage]);
	[rep setNeedsUpdate:YES];
	return rep;
}

@end
