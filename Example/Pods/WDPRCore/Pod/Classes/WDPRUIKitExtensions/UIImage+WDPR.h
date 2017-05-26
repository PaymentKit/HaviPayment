//
//  UIImage+WDPR.h
//  WDPR
//
//  Created by Wright, Byron on 6/17/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (WDPR)

// Return Image in the main thread using the block.
// This is useful for callbacks. It safe to pass nil for the handler parameter.
+ (void)image:(UIImage *)image callback:(void (^)(UIImage *image))callback __deprecated;

/// force image into a maximum size,
/// with UIViewContentModeScaleAspectFit
- (UIImage*)sizedTo:(CGSize)size;

// scale image to a particular size
/// with UIViewContentModeScaleToFill, it safe to be called on background threads.
- (UIImage *)scaleToFillSize:(CGSize)size;

/// add rounded corners to a given image.
- (UIImage *)roundCornersWithRadius:(CGFloat)cornerRadius;

/// same as sizedTo: but always
- (UIImage*)forciblySizedTo:(CGSize)size;

/// Look for images in images/ directory,
/// w/o, then with, currect destination suffix,
/// falls through to standard imageNamed:

- (UIImage *)resizedImage:(CGSize)newSize
     interpolationQuality:(CGInterpolationQuality)quality;

/// Change the color of an image transparent image:
- (UIImage *) colorWithColor:(UIColor*)color;

/// Returns a grayscale / B+W image
- (UIImage *)imageBlackAndWhite;

/// Returns a cropped portion of an image.
+ (UIImage *)imageWithImage:(UIImage *)image cropInRect:(CGRect)rect;

+ (UIImage *)imageWithColor:(UIColor *)color bounds:(CGRect)imageBounds;

+ (UIImage *)imageWithColor:(UIColor *)color;

@end
