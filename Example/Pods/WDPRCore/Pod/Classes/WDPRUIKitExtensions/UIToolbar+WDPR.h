//
//  UIToolbar+WDPR.h
//  WDPR
//
//  Created by Hutchinson, Jack X. -ND on 8/22/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 This category extends UIToolbar and is used to add a custom toolbar to the keyboard.
 
 Adds Previous and Next buttons for scrolling among input elements.
 Also include a Close button for hiding the input (keyboard, or other input).
 
 */
@class WDPRTableDataDelegate;

typedef NS_ENUM(NSUInteger, WDPRToolbarDirection)
{
    WDPRToolbarBack,
    WDPRToolbarNext,
    WDPRToolbarDone
    
};

typedef void (^WDPRModifyInputBlock)(WDPRToolbarDirection direction);

@interface UIToolbar (WDPR)

/// Backwards support for MDX styling (dark blue navBar)
+ (BOOL)assumeDarkColoredNavigationBar __deprecated;

/// Backwards support for MDX styling (dark blue navBar)
+ (void)setAssumeDarkColoredNavigationBar:(BOOL)assumeDark __deprecated;

+ (UIToolbar*) wdprToolbar;
+ (UIToolbar*) wdprToolbarWithFrame:(CGRect)frame;

+ (UIToolbar *) wdprKeyboardToolBar:(WDPRModifyInputBlock)modifyInputBlock;
+ (UIToolbar *) wdprKeyboardToolBar:(WDPRModifyInputBlock)modifyInputBlock
                            hasNext:(BOOL)hasNext hasPrevious:(BOOL)hasPrevious;
+ (UIToolbar *) wdprDoneButtonToolBar:(WDPRModifyInputBlock)modifyInputBlock;
+ (UIToolbar *) wdprDoneButtonRightToolBar:(WDPRModifyInputBlock)modifyInputBlock;

@end
