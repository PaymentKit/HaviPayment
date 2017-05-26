//
//  UIImageView+WDPR.m
//  WDPR
//
//  Created by Brigance, Yuri on 10/7/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"

@implementation UIImageView (WDPR)

- (void)setImage:(UIImage *)image animated:(BOOL)animated
{
    if (animated) {
        [self setImage:image animated:animated duration:kCrossDissolveImageAnimationDuration];
    } else {
        [self setImage:image];
    }
}

- (void)setImage:(UIImage *)image animated:(BOOL)animated duration:(CGFloat)duration
{
    if (animated) {
        [UIView transitionWithView:self
                          duration:duration
                           options:UIViewAnimationOptionTransitionCrossDissolve
                        animations:^{
                            [self setImage:image];
                        }
                        completion:^(BOOL finished) {
                        }];
    } else {
        [self setImage:image];
    }
}

@end
