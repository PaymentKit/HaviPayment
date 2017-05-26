//
//  UIView+WDPR.h
//  DLR
//
//  Created by Francisco Valbuena on 3/31/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN
@interface UIView (WDPR)

typedef NSArray<__kindof NSLayoutConstraint *> NSLayoutConstraintArray;

+ (instancetype)autolayoutView;

- (void)centerViewInSuperview;
- (UIViewController *)closestViewController;

- (void)addUpperBorder:(UIColor *)borderColor;

@property (nonatomic, readonly, nonnull) UIImage* imageOfSelf;
@property (nonatomic, strong, nullable) UIColor* tintOrBarTintColor;

+ (UIView*)viewWithEquallySpacedSubviews:(NSArray<__kindof UIView*>*)subviews;

+ (UIView*)viewWithEquallySpacedSubviews:(NSArray<__kindof UIView*>*)subviews
                  withVerticalSeparators:(BOOL)verticalSeparators;


- (NSLayoutConstraintArray *)addSubviews:(NSDictionary<NSString*, UIView*>*)views 
                   withVisualConstraints:(nullable NSArray<NSString*>*)formats;

- (NSLayoutConstraintArray *)addSubviews:(NSDictionary<NSString*, UIView*>*)views 
                   withVisualConstraints:(nullable NSArray<NSString*>*)formats 
                                 options:(NSLayoutFormatOptions)constraintOptions 
                                 metrics:(nullable NSDictionary<NSString*, id>*)metrics;

- (NSLayoutConstraintArray *)addConstraintsWithFormat:(NSString *)format
                                              metrics:(nullable NSDictionary<NSString*, id>*)metrics
                                                views:(nullable NSDictionary<NSString*, id>*)views;

- (NSLayoutConstraintArray *)addConstraintsWithFormat:(NSString *)format
                                              options:(NSLayoutFormatOptions)options
                                              metrics:(nullable NSDictionary<NSString*, id>*)metrics
                                                views:(nullable NSDictionary<NSString*, id>*)views;

/** Looks through all of the subviews of a UIView (including self) and all accessiblityElements to find the
 currently VoiceOver focused element.
 @note Parameter and return types are <code>id</code> to allow for UIAccessibilityElement instances.
 @returns The focused element or nil.*/
+ (nullable id)focusedElementForView:(nonnull id)view;

@end
NS_ASSUME_NONNULL_END
