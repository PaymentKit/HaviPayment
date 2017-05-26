//
//  UIImage+WDPR.m
//  WDPR
//
//  Created by Wright, Byron on 6/17/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "WDPRUIKit.h"

@implementation UIImage (WDPR)

+ (void)image:(UIImage *)image callback:(void (^)(UIImage *image))callback
{
    if (callback)
    {
        dispatch_async(dispatch_get_main_queue(),
        ^{
            callback(image);
        });
    }
}

- (UIImage*)sizedTo:(CGSize)size
{
    UIImage* image = self;
    
    if (!CGSizeEqualToSize(size, self.size))
    {
        image = [self forciblySizedTo:size];
    }
    
    return image;
}

- (UIImage*)forciblySizedTo:(CGSize)size
{
    UIImage* image = self;
    
    UIGraphicsBeginImageContextWithOptions
    (size, NO, [UIScreen mainScreen].scale);
    
    // calculate UIViewContentModeScaleAspectFit
    float hfactor = self.size.width / size.width;
    float vfactor = self.size.height / size.height;
    
    float factor = fmax(hfactor, vfactor);
    
    // Divide the size by the greater of the
    // vertical or horizontal shrinkage factor
    float newWidth = self.size.width / factor;
    float newHeight = self.size.height / factor;
    
    // Then figure out if you need to offset
    // it to center vertically or horizontally
    float leftOffset = (size.width - newWidth) / 2;
    float topOffset = (size.height - newHeight) / 2;
    
    [image drawInRect:CGRectMake(leftOffset, topOffset,
                                 newWidth, newHeight)];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIImage *)scaleToFillSize:(CGSize)size
{
    // thanks http://nshipster.com/image-resizing/ for this awesome function
    CGRect adjustedRect = AVMakeRectWithAspectRatioInsideRect(self.size, CGRectMake(0.0f, 0.0f, size.width, size.height));
    
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    [self drawInRect:adjustedRect];
    
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

- (UIImage *)roundCornersWithRadius:(CGFloat)cornerRadius
{
    CGRect imageRect = CGRectMake(0, 0, self.size.width, self.size.height);

    UIGraphicsBeginImageContextWithOptions(imageRect.size, NO, 0.0);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect:imageRect cornerRadius:cornerRadius];
    [path addClip];
    [self drawInRect:imageRect];
    UIImage *maskedImage = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();
    
    return maskedImage;
}

// Returns a rescaled copy of the image, taking into account its orientation
// The image will be scaled disproportionately if necessary to fit the bounds specified by the parameter
- (UIImage *)resizedImage:(CGSize)newSize interpolationQuality:(CGInterpolationQuality)quality
{
    BOOL drawTransposed;
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            drawTransposed = YES;
            break;
            
        default:
            drawTransposed = NO;
    }
    
    return [self resizedImage:newSize
                    transform:[self transformForOrientation:newSize]
               drawTransposed:drawTransposed
         interpolationQuality:quality];
}

// Returns an affine transform that takes into account the image orientation when drawing a scaled image
- (CGAffineTransform)transformForOrientation:(CGSize)newSize
{
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationDown:           // EXIF = 3
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, newSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:           // EXIF = 6
        case UIImageOrientationLeftMirrored:   // EXIF = 5
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:          // EXIF = 8
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, 0, newSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationUpMirrored:
            break;
    }
    
    switch (self.imageOrientation)
    {
        case UIImageOrientationUpMirrored:     // EXIF = 2
        case UIImageOrientationDownMirrored:   // EXIF = 4
            transform = CGAffineTransformTranslate(transform, newSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:   // EXIF = 5
        case UIImageOrientationRightMirrored:  // EXIF = 7
            transform = CGAffineTransformTranslate(transform, newSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        case UIImageOrientationUp:
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
        case UIImageOrientationDown:
            break;
    }
    
    return transform;
}

// Returns a copy of the image that has been transformed using the given affine transform and scaled to the new size
// The new image's orientation will be UIImageOrientationUp, regardless of the current image's orientation
// If the new size is not integral, it will be rounded up
- (UIImage *)resizedImage:(CGSize)newSize
                transform:(CGAffineTransform)transform
           drawTransposed:(BOOL)transpose
     interpolationQuality:(CGInterpolationQuality)quality
{
    CGRect newRect = CGRectIntegral(CGRectMake(0, 0, newSize.width, newSize.height));
    CGRect transposedRect = CGRectMake(0, 0, newRect.size.height, newRect.size.width);
    CGImageRef imageRef = self.CGImage;
    
    // Build a context that's the same dimensions as the new size
    CGContextRef bitmap = CGBitmapContextCreate(NULL,
                                                newRect.size.width,
                                                newRect.size.height,
                                                CGImageGetBitsPerComponent(imageRef),
                                                0,
                                                CGImageGetColorSpace(imageRef),
                                                CGImageGetBitmapInfo(imageRef));
    
    // Rotate and/or flip the image if required by its orientation
    CGContextConcatCTM(bitmap, transform);
    
    // Set the quality level to use when rescaling
    CGContextSetInterpolationQuality(bitmap, quality);
    
    // Draw into the context; this scales the image
    CGContextDrawImage(bitmap, transpose ? transposedRect : newRect, imageRef);
    
    // Get the resized image from the context and a UIImage
    CGImageRef newImageRef = CGBitmapContextCreateImage(bitmap);
    UIImage *newImage = [UIImage imageWithCGImage:newImageRef];
    
    // Clean up
    CGContextRelease(bitmap);
    CGImageRelease(newImageRef);
    
    return newImage;
}

// Color image with given color while maintaining its transparency.
- (UIImage *) colorWithColor:(UIColor*)color
{
    // Set an image's color while maintaining its transparency.
    
    UIGraphicsBeginImageContext(self.size);
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeCopy);
    CGRect imageRect = CGRectMake(0, 0, self.size.width, self.size.height);
    [self drawInRect:imageRect];
    
    CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeNormal);
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(UIGraphicsGetCurrentContext(), 0, self.size.height);
    CGContextScaleCTM(UIGraphicsGetCurrentContext(), 1.0, -1.0);
    //mask the image
    CGContextClipToMask(UIGraphicsGetCurrentContext(), imageRect, self.CGImage);
    CGContextSetFillColorWithColor(UIGraphicsGetCurrentContext(), color.CGColor);
    CGContextFillRect(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, self.size.width, self.size.height));
    UIImage *returnImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return returnImage;
}

- (UIImage *)imageBlackAndWhite
{
    CIImage *beginImage = [CIImage imageWithCGImage:self.CGImage];
    
    CIImage *output = [CIFilter filterWithName:@"CIColorMonochrome" keysAndValues:kCIInputImageKey, beginImage, @"inputIntensity", [NSNumber numberWithFloat:0.6f], @"inputColor", [[CIColor alloc] initWithColor:[UIColor whiteColor]], nil].outputImage;
    
    CIContext *context = [CIContext contextWithOptions:nil];
    CGImageRef cgiimage = [context createCGImage:output fromRect:output.extent];
    UIImage *newImage = [UIImage imageWithCGImage:cgiimage];
    
    CGImageRelease(cgiimage);
    
    return newImage;
    
    return self;
}

+ (UIImage *)imageWithImage:(UIImage *)image cropInRect:(CGRect)rect 
{
    
    if (CGPointEqualToPoint(CGPointZero, rect.origin) && CGSizeEqualToSize(rect.size, image.size))
    {
        return image;
    }
    UIGraphicsBeginImageContextWithOptions(rect.size, NO, 0);
    [image drawAtPoint:(CGPoint){-rect.origin.x, -rect.origin.y}];
    UIImage *croppedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return croppedImage;
}

+ (UIImage *)imageWithColor:(UIColor *)color bounds:(CGRect)imageBounds
{
    UIGraphicsBeginImageContextWithOptions(imageBounds.size, NO, 0);
    [color setFill];
    UIRectFill(imageBounds);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();

    return image;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    return [UIImage imageWithColor:color bounds:rect];
}

@end
