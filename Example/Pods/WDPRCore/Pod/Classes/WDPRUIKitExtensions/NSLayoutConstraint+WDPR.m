//
//  NSLayoutConstraint+WDPR.m
//  Mdx
//
//  Created by Sera, Josh on 3/3/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import "NSLayoutConstraint+WDPR.h"

@implementation NSLayoutConstraint (WDPR)

+ (NSLayoutConstraint*)pinTopOfView:(UIView*)view toBottomOfView:(UIView*)otherView
{
    return [NSLayoutConstraint pinTopOfView:view toBottomOfView:otherView withMargin:0.0f];
}

+ (NSLayoutConstraint*)pinTopOfView:(UIView*)view toBottomOfView:(UIView*)otherView withMargin:(CGFloat)margin
{
    return [NSLayoutConstraint
            constraintWithItem:view
            attribute:NSLayoutAttributeTop
            relatedBy:NSLayoutRelationEqual
            toItem:otherView
            attribute:NSLayoutAttributeBottom
            multiplier:1.0
            constant:margin
            ];
}

+ (NSLayoutConstraint*)pinLeftOfView:(UIView*)view toLeftOfView:(UIView*)otherView
{
    return [NSLayoutConstraint pinLeftOfView:view toLeftOfView:otherView withMargin:0.0f];
}

+ (NSLayoutConstraint*)pinLeftOfView:(UIView*)view toLeftOfView:(UIView*)otherView withMargin:(CGFloat)margin
{
    return [NSLayoutConstraint
            constraintWithItem:view
            attribute:NSLayoutAttributeLeft
            relatedBy:NSLayoutRelationEqual
            toItem:otherView
            attribute:NSLayoutAttributeLeft
            multiplier:1.0
            constant:margin
            ];
}

+ (NSLayoutConstraint*)pinRightOfView:(UIView*)view toRightOfView:(UIView*)otherView
{
    return [NSLayoutConstraint pinRightOfView:view toRightOfView:otherView withMargin:0.0f];
}

+ (NSLayoutConstraint*)pinRightOfView:(UIView*)view toRightOfView:(UIView*)otherView withMargin:(CGFloat)margin
{
    return [NSLayoutConstraint
            constraintWithItem:view
            attribute:NSLayoutAttributeRight
            relatedBy:NSLayoutRelationEqual
            toItem:otherView
            attribute:NSLayoutAttributeRight
            multiplier:1.0
            constant:margin
            ];
}

+ (NSLayoutConstraint*)centerViewHorizontally:(UIView*)view inContainingView:(UIView*)container
{
    return [NSLayoutConstraint
            constraintWithItem:view
            attribute:NSLayoutAttributeCenterX
            relatedBy:NSLayoutRelationEqual
            toItem:container
            attribute:NSLayoutAttributeCenterX
            multiplier:1.0
            constant:0.0
            ];
}

+ (NSLayoutConstraint*)centerViewVertically:(UIView*)view inContainingView:(UIView*)container
{
    return [NSLayoutConstraint
            constraintWithItem:view
            attribute:NSLayoutAttributeCenterY
            relatedBy:NSLayoutRelationEqual
            toItem:container
            attribute:NSLayoutAttributeCenterY
            multiplier:1.0
            constant:0.0
            ];
}

+ (NSLayoutConstraint*)pinBottomOfView:(UIView*)view toBottomOfView:(UIView*)otherView
{
    return [NSLayoutConstraint pinBottomOfView:view toBottomOfView:otherView withMargin:0.0f];
}

+ (NSLayoutConstraint*)pinBottomOfView:(UIView*)view toBottomOfView:(UIView*)otherView withMargin:(CGFloat)margin
{
    return [NSLayoutConstraint
            constraintWithItem:view
            attribute:NSLayoutAttributeBottom
            relatedBy:NSLayoutRelationEqual
            toItem:otherView
            attribute:NSLayoutAttributeBottom
            multiplier:1.0f
            constant:margin
            ];
}

+ (NSLayoutConstraint*)pinTopOfView:(UIView*)view toTopOfView:(UIView*)otherView
{
    return [NSLayoutConstraint pinTopOfView:view toTopOfView:otherView withMargin:0.0f];
}

+ (NSLayoutConstraint*)pinTopOfView:(UIView*)view toTopOfView:(UIView*)otherView withMargin:(CGFloat)margin
{
    return [NSLayoutConstraint
            constraintWithItem:view
            attribute:NSLayoutAttributeTop
            relatedBy:NSLayoutRelationEqual
            toItem:otherView
            attribute:NSLayoutAttributeTop
            multiplier:1.0f
            constant:margin
            ];
}

+ (NSLayoutConstraint*)setConstantConstraintFor:(UIView*)view attribute:(NSLayoutAttribute)attribute constant:(CGFloat)constant
{
    NSLayoutConstraint* constraint = [NSLayoutConstraint
                                      constraintWithItem:view
                                      attribute:attribute
                                      relatedBy:NSLayoutRelationEqual
                                      toItem:nil
                                      attribute:NSLayoutAttributeNotAnAttribute
                                      multiplier:1.0
                                      constant:constant
                                      ];
    [view addConstraint:constraint];
    return constraint;
}

+ (NSLayoutConstraint*)setWidthOfView:(UIView*)view toWidthOfView:(UIView*)otherView
{
    return [NSLayoutConstraint setWidthOfView:view toWidthOfView:otherView withMargin:0.0f];
}

+ (NSLayoutConstraint*)setWidthOfView:(UIView*)view toWidthOfView:(UIView*)otherView withMargin:(CGFloat)margin
{
    return [NSLayoutConstraint
            constraintWithItem:view
            attribute:NSLayoutAttributeWidth
            relatedBy:NSLayoutRelationEqual
            toItem:otherView
            attribute:NSLayoutAttributeWidth
            multiplier:1.0f
            constant:margin
            ];
}

+ (void) autolayoutForView:(UIView*)view constraints:(NSArray*)contraints views:(NSDictionary*)views metrics:(NSDictionary*)metrics
{
#ifdef DEBUG
    // For development check to make sure autoresizingMasks are turned off
    for (UIView *view in [views allValues])
    {
        NSAssert(view.translatesAutoresizingMaskIntoConstraints == NO, @"Please turn off autoresizingMask");
    }
#endif
    for (NSString* constraintsWithVisualFormat in contraints)
    {
        [view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:constraintsWithVisualFormat options:0 metrics:metrics views:views]];
    }
}

@end
