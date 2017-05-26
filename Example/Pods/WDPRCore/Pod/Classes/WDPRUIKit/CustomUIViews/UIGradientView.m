//
//  UIGradientView.m
//  WDPR
//
//  Created by Rodden, James on 7/17/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "UIGradientView.h"

#import <QuartzCore/QuartzCore.h>

@implementation UIGradientView

// Returns the default CALayer to be used by the class. This helps implement default functionality of the base layer
+ (Class)layerClass
{
    return CAGradientLayer.class;
}

- (CAGradientLayer*)gradientLayer
{
    return (CAGradientLayer*)self.layer;
}

@end
