//
//  UIImageView+WDPR.h
//  WDPR
//
//  Created by Brigance, Yuri on 10/7/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kCrossDissolveImageAnimationDuration 0.25f
#define kCrossDissolveImageAnimationDurationLong 1.75f

@interface UIImageView (WDPR)

- (void)setImage:(UIImage *)image animated:(BOOL)animated;
- (void)setImage:(UIImage *)image animated:(BOOL)animated duration:(CGFloat)duration;

@end
