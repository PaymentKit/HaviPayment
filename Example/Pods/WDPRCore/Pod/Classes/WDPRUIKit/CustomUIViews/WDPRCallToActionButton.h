//
//  WDPRCallToActionButton.h
//  
//
//  Created by Pierce, Owen on 12/5/14.
//
//

#import "WDPRUIKit.h"

IB_DESIGNABLE
@interface WDPRCallToActionButton : UIButton

@property (nonatomic, strong) UIColor *defaultColor;
@property (nonatomic, strong) UIColor *highlightedColor;
@property (nonatomic, strong) UIColor *disabledColor;

@property (nonatomic, strong) UIColor *defaultTextColor;
@property (nonatomic, strong) UIColor *highlightedTextColor;
@property (nonatomic, strong) UIColor *disabledTextColor;

@property (nonatomic, assign) CGColorRef defaultBorderColor;
@property (nonatomic, assign) CGColorRef highlightedBorderColor;
@property (nonatomic, assign) CGColorRef disabledBorderColor;

/// Produces a standard solid color button
+ (instancetype)buttonWithTitle:(NSString *)title;

/// Produces a standard solid color button with attached block
+ (instancetype)buttonWithTitle:(NSString *)title block:(PlainBlock)block;

/// Produces a standard secondary button
+ (instancetype)secondaryButtonWithTitle:(NSString *)title;

/// Produces a standard secondary button with attached block
+ (instancetype)secondaryButtonWithTitle:(NSString *)title block:(PlainBlock)block;

/// Produces a standard tertiary button
+ (instancetype)tertiaryButtonWithTitle:(NSString *)title;

/// Produces a standard tertiary button with attached block
+ (instancetype)tertiaryButtonWithTitle:(NSString *)title block:(PlainBlock)block;


@end
