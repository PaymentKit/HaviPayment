//
//  UIButton+WDPR.h
//  WDPR
//
//  Created by Wright, Byron on 6/17/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIControl+WDPR.h"
#import "WDPRTheme.h"

typedef void(^CheckboxButtonBlock)(BOOL checked);

@interface UIButton (WDPR)

@property (nonatomic, copy) PlainBlock block;

/** Wraps SDK's buttonWithType by adding a block handler */
+ (UIButton *)buttonWithType:(UIButtonType)buttonType
                    andBlock:(PlainBlock)block;


/**
 Creates a standard green checkbox button 
 @param block a block of code that will be called when the checkbox is selected/unselected
 @return a UIButton for the checkbox button
 */
+ (UIButton *)squareCheckboxButton:(CheckboxButtonBlock)block;

/**
 Creates a button with specified view and label
 positioned below (as a subview, with labelStyle)
 @param subview the subview to place inside the button
 @param labelText a string for the button label
 @param labelStyle the style to use for the text
 @return a UIButton configured with the given view, label string and text style
 */
+ (UIButton *)buttonWithView:(UIView *)subview
                    andLabel:(NSString *)labelText
                   withStyle:(WDPRTextStyle)labelStyle;

/**
 Creates a button with specified image and label
 positioned below (as a subview, with labelStyle)
 @param image the image to place inside the button
 @param labelText a string for the button label
 @param labelStyle the style to use for the text
 @return a UIButton configured with the given image, label string and text style
 */
+ (UIButton *)buttonWithImage:(UIImage *)image
                     andLabel:(NSString *)labelText
                    withStyle:(WDPRTextStyle)labelStyle;

/**
 Creates a button with specified image and label
 positioned below (as a subview, with labelStyle)
 @param imageName the name of the image to place inside the button
 @param labelText a string for the button label
 @param labelStyle the style to use for the text
 @return a UIButton configured with the named image, label string and text style
 */
+ (UIButton *)buttonWithImageNamed:(NSString *)imageName
                          andLabel:(NSString *)labelText
                         withStyle:(WDPRTextStyle)labelStyle;

/**
 Creates a button with specified image and label
 positioned below (as a subview, with labelStyle) and constrained to a specified width
 @param subview the subView to place inside the button
 @param labelText a string for the button label
 @param labelStyle the style to use for the text
 @param width the max width for the button
 @return a UIButton configured with the named image, label string and text style
 */
+ (UIButton *)buttonWithView:(UIView *)subview
                    andLabel:(NSString *)labelText
                   withStyle:(WDPRTextStyle)labelStyle
          constrainedToWidth:(CGFloat)width;

/**
 Creates a button with specified image and label
 positioned below (as a subview, with labelStyle) and constrained to a specified width
 @param subview the subView to place inside the button
 @param labelText a string for the button label
 @param labelStyle the style to use for the text
 @param width the max width for the button
 @param buttonToLabelSpacing space between button and label
 @return a UIButton configured with the named image, label string and text style
 */
+ (UIButton*)buttonWithView:(UIView*)subview
                   andLabel:(NSString*)labelText
                  withStyle:(WDPRTextStyle)labelStyle
         constrainedToWidth:(CGFloat)width
       buttonToLabelSpacing:(CGFloat)buttonToLabelSpacing;

@end
