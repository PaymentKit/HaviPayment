//
//  UIBarButtonItem+WDPRO.h
//  WDPR
//
//  Created by Rodden, James on 7/17/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDPRFoundation.h"

@interface UIBarButtonItem (WDPR)

/// Backwards support for MDX styling (dark blue navBar)
+ (BOOL)assumeDarkColoredNavigationBar __deprecated;

/// Backwards support for MDX styling (dark blue navBar)
+ (void)setAssumeDarkColoredNavigationBar:(BOOL)assumeDark __deprecated;

/// An either/or alternative to the target/action
/// pair for specifying behavior when tapped.
/// Note: only target/action *OR* block can be 
/// used to specify behavior. Setting the block 
/// internally changes the target/action to glue
/// code which implements block support.
@property (nonatomic, copy) PlainBlock block;

+ (UIBarButtonItem*)fixedSpaceItem;
+ (UIBarButtonItem*)flexibleSpaceItem;
+ (UIBarButtonItem*)itemWithTitle:(NSString*)title;

+ (UIBarButtonItem*)backButtonItem:(PlainBlock)block;
+ (UIBarButtonItem*)backButtonItemForKeyboard:(PlainBlock)block;
+ (UIBarButtonItem*)forwardButtonItem:(PlainBlock)block;
+ (UIBarButtonItem*)forwardButtonItemForKeyboard:(PlainBlock)block;
+ (UIBarButtonItem*)refreshButtonItem:(PlainBlock)block;

+ (UIBarButtonItem*)doneButtonItem:(PlainBlock)block;
+ (UIBarButtonItem*)doneButtonItem:(id)target action:(SEL)action;

+ (UIBarButtonItem*)cancelButtonItem:(PlainBlock)block;
+ (UIBarButtonItem*)cancelButtonItem:(id)target action:(SEL)action;

+ (UIBarButtonItem*)buttonWithTitle:(NSString*)title block:(PlainBlock)block;
+ (UIBarButtonItem*)buttonWithTitle:(NSString *)title target:(id)target action:(SEL)action;

+ (UIBarButtonItem*)buttonWithImage:(UIImage*)image block:(PlainBlock)block;
+ (UIBarButtonItem*)buttonWithImage:(UIImage*)image target:(id)target action:(SEL)action;
+ (UIBarButtonItem*)buttonWithImage:(UIImage*)image style:(UIBarButtonItemStyle)style block:(PlainBlock)block;

#pragma mark - Accessibility

/*! Set accessibility label string to left button in navigation item.
 \param label Custom accessibility string for the button.
 */
- (void)setAccessibilityLeftBarButtonItemLabel:(NSString *)label;

/*
 Sets isAccessibilityELement and accessibilityElementsHidden properties of navigation bar items and view.
 */
- (void)makeViewElementsAccessibile:(BOOL)isAccessible;

@end
