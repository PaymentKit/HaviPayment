//
//  WDPRActivityAnimationView.m
//  WDPR
//
//  Created by Thompson, Greg X. -ND on 5/6/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"

@implementation WDPRActivityAnimationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

+ (instancetype)smallActivityIndicator:(WDPRActivityAnimationViewType)type;
{
    WDPRActivityAnimationView *activityIndicator = [self largeActivityIndicator:type];
    activityIndicator.frame = CGRectMake(0, 0, 20, 20);
    return activityIndicator;
}

+ (instancetype)mediumActivityIndicator:(WDPRActivityAnimationViewType)type;
{
    WDPRActivityAnimationView *activityIndicator = [self largeActivityIndicator:type];
    activityIndicator.frame = CGRectMake(0, 0, 30, 30);
    return activityIndicator;
}

+ (instancetype)largeActivityIndicator:(WDPRActivityAnimationViewType)type;
{
    NSUInteger numFrames;

    UIImage *framesImg = nil;
    switch (type)
    {
        case WDPRActivityAnimationViewTypeSpinningXL:
        {
            numFrames = 18;
            framesImg = [UIImage imageNamed:WDPRCoreActivitySpinnerXLImageName
                                   inBundle:[WDPRFoundation wdprCoreResourceBundle]
                                 compatibleWithTraitCollection:nil];
        }
            break;
        case WDPRActivityAnimationViewTypeSpinning:
        default:
        {
            numFrames = 18;
            framesImg = [UIImage imageNamed:WDPRCoreActivitySpinnerImageName
                                   inBundle:[WDPRFoundation wdprCoreResourceBundle]
                                 compatibleWithTraitCollection:nil];
        }
            break;
    }
    
    if ((framesImg.scale != UIScreen.mainScreen.scale) &&
        ((CGImageGetWidth(framesImg.CGImage) != framesImg.size.width) ||
         (CGImageGetHeight(framesImg.CGImage) != framesImg.size.height)))
    {
        // special-case for SLING-3686....CGImageRef's don't auto-scale
        framesImg = [framesImg forciblySizedTo:
                     CGSizeMake(framesImg.size.width, framesImg.size.height)];
    }
    
    CGImageRef framesImgRef = framesImg.CGImage;
    NSMutableArray *frames = [NSMutableArray arrayWithCapacity:numFrames];
    
    CGRect imgFrame = CGRectMake(0, 0,
                                 CGImageGetWidth(framesImgRef)/numFrames,
                                 CGImageGetHeight(framesImgRef));
    
    for (unsigned ii = 0; ii < numFrames; ii++)
    {
        CGImageRef imageRef =
        CGImageCreateWithImageInRect(framesImgRef, imgFrame);
        
        [frames addObject:[UIImage imageWithCGImage:imageRef]];
        
        CGImageRelease(imageRef);
        
        imgFrame = CGRectOffset(imgFrame, imgFrame.size.width, 0);
    }
    
    // we need to reduce the image size on scaled
    // (aka retina) screened devices, but no others
    const CGFloat scale = UIScreen.mainScreen.scale;
    
    WDPRActivityAnimationView *activityIndicator = [[WDPRActivityAnimationView alloc] initWithFrame:
                                      CGRectMake(0, 0,
                                                 imgFrame.size.width/scale,
                                                 imgFrame.size.height/scale)];
    
    activityIndicator.animationImages = frames;
    activityIndicator.contentMode = UIViewContentModeScaleAspectFill;
    
    return activityIndicator;
}

@end
