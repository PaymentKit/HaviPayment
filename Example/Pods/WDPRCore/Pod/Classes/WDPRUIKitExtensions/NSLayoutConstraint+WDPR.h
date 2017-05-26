//
//  NSLayoutConstraint+WDPR.h
//  Mdx
//
//  Created by Sera, Josh on 3/3/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSLayoutConstraint (WDPR)

+ (NSLayoutConstraint*)pinTopOfView:(UIView*)view toBottomOfView:(UIView*)otherView;
+ (NSLayoutConstraint*)pinTopOfView:(UIView*)view toBottomOfView:(UIView*)otherView withMargin:(CGFloat)margin;

+ (NSLayoutConstraint*)pinTopOfView:(UIView*)view toTopOfView:(UIView*)otherView;
+ (NSLayoutConstraint*)pinTopOfView:(UIView*)view toTopOfView:(UIView*)otherView withMargin:(CGFloat)margin;

+ (NSLayoutConstraint*)pinBottomOfView:(UIView*)view toBottomOfView:(UIView*)otherView;
+ (NSLayoutConstraint*)pinBottomOfView:(UIView*)view toBottomOfView:(UIView*)otherView withMargin:(CGFloat)margin;

+ (NSLayoutConstraint*)pinLeftOfView:(UIView*)view toLeftOfView:(UIView*)otherView;
+ (NSLayoutConstraint*)pinLeftOfView:(UIView*)view toLeftOfView:(UIView*)otherView withMargin:(CGFloat)margin;

+ (NSLayoutConstraint*)pinRightOfView:(UIView*)view toRightOfView:(UIView*)otherView;
+ (NSLayoutConstraint*)pinRightOfView:(UIView*)view toRightOfView:(UIView*)otherView withMargin:(CGFloat)margin;

+ (NSLayoutConstraint*)centerViewHorizontally:(UIView*)view inContainingView:(UIView*)container;
+ (NSLayoutConstraint*)centerViewVertically:(UIView*)view inContainingView:(UIView*)container;
+ (NSLayoutConstraint*)setConstantConstraintFor:(UIView*)view attribute:(NSLayoutAttribute)attribute constant:(CGFloat)constant;

+ (NSLayoutConstraint*)setWidthOfView:(UIView*)view toWidthOfView:(UIView*)otherView;
+ (NSLayoutConstraint*)setWidthOfView:(UIView*)view toWidthOfView:(UIView*)otherView withMargin:(CGFloat)margin;

+ (void) autolayoutForView:(UIView*)view constraints:(NSArray*)contraints views:(NSDictionary*)views metrics:(NSDictionary*)metrics;

@end
