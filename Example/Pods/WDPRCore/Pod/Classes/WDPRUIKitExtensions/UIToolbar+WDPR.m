//
//  UIToolbar+WDPR.m
//  WDPR
//
//  Created by Hutchinson, Jack X. -ND on 8/22/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <objc/runtime.h>
#import "WDPRUIKit.h"

#define Key_Block "WDPRBlock"

enum
{
    translucentNavBars = NO,
    kMarginForBarButtons = 10,
};

@implementation UIToolbar (WDPR)

+ (UIToolbar*) wdprToolbar
{
    UIToolbar *toolbar = [UIToolbar new];
    
    if (!translucentNavBars)
    {
        toolbar.tintColor = UIColor.whiteColor;
    }
    
    [toolbar setBarTintColor:
     [UIColor colorWithHexValue:0xf0f1f2]];
    
    toolbar.translucent = translucentNavBars;
    
    [toolbar sizeToFit];

    return toolbar;
}

+ (UIToolbar*) wdprToolbarWithFrame:(CGRect)frame
{
    UIToolbar* toolbar = [self wdprToolbar];
    toolbar.frame = frame;
    return toolbar;
}

+ (UIToolbar *) wdprKeyboardToolBar:(WDPRModifyInputBlock)modifyInputBlock
{
    return [UIToolbar wdprKeyboardToolBar:modifyInputBlock
                                  hasNext:YES
                              hasPrevious:YES];
}

+ (UIToolbar *) wdprKeyboardToolBar:(WDPRModifyInputBlock)modifyInputBlock hasNext:(BOOL)hasNext hasPrevious:(BOOL)hasPrevious
{
    UIToolbar *toolbar = [UIToolbar wdprToolbar];
    
    MAKE_WEAK(toolbar);
    
    // save block for change event:
    [toolbar setWDPRBlock:modifyInputBlock];

    UIBarButtonItem *previousBtn = 
    [UIBarButtonItem backButtonItemForKeyboard:
     ^{
         MAKE_STRONG(toolbar);
         strongtoolbar.wdprBlock(WDPRToolbarBack);
     }];
    
    UIBarButtonItem *forwardBtn = 
    [UIBarButtonItem forwardButtonItemForKeyboard:
     ^{
         MAKE_STRONG(toolbar);
         strongtoolbar.wdprBlock(WDPRToolbarNext);
     }];
    
    forwardBtn.enabled = hasNext;
    previousBtn.enabled = hasPrevious;
    
    UIBarButtonItem* closeButton = 
    [UIBarButtonItem doneButtonItem:
     ^{
         MAKE_STRONG(toolbar);
         strongtoolbar.accessibilityElementsHidden = YES;
         UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, nil);
         strongtoolbar.wdprBlock(WDPRToolbarDone);
    }];
    
    // Fixed Space spacer is only used on iOS 7
    UIBarButtonItem *fixedSpace = UIBarButtonItem.fixedSpaceItem;
    fixedSpace.width = 20;
    
    if (IS_VERSION_8_OR_LATER)
    {
        // On iOS 8 and later, we're seeing a negative margin from default insets which requires an additional inset to layout the bar button items correctly.
        UIView *invisibleMargin = [[UIView alloc] initWithFrame:CGRectMake(0,
                                                                           0,
                                                                           kMarginForBarButtons,
                                                                           kMarginForBarButtons)];
        UIBarButtonItem *insetFromEdges = [[UIBarButtonItem alloc] initWithCustomView:invisibleMargin];
        
        toolbar.items = @[insetFromEdges, previousBtn, forwardBtn,
                          UIBarButtonItem.flexibleSpaceItem, closeButton, insetFromEdges];
    }
    else
    {
        toolbar.items = @[previousBtn, fixedSpace, forwardBtn,
                          UIBarButtonItem.flexibleSpaceItem, closeButton];
    }
    return toolbar;
}

+ (UIToolbar *) wdprDoneButtonToolBar:(WDPRModifyInputBlock)modifyInputBlock
{
    UIToolbar *toolbar = [UIToolbar wdprToolbar];
    
    MAKE_WEAK(toolbar);
    
    // save block for change event:
    [toolbar setWDPRBlock:modifyInputBlock];
    
    [toolbar setItems:
     @[[UIBarButtonItem doneButtonItem:
        ^{ 
            MAKE_STRONG(toolbar);
            strongtoolbar.wdprBlock(WDPRToolbarDone);
        }]]];
    
    return toolbar;
}

+ (UIToolbar *) wdprDoneButtonRightToolBar:(WDPRModifyInputBlock)modifyInputBlock
{
    UIToolbar *toolbar = [UIToolbar wdprToolbar];
    
    // save block for change event:
    [toolbar setWDPRBlock:modifyInputBlock];
    
    UIBarButtonItem *doneButton = [UIBarButtonItem doneButtonItem:^{ modifyInputBlock(WDPRToolbarDone); }];
    
    toolbar.items = @[[UIBarButtonItem flexibleSpaceItem], doneButton];
    
    return toolbar;
}

#pragma mark - associated methods

- (WDPRModifyInputBlock) wdprBlock
{
    return ((WDPRModifyInputBlock) objc_getAssociatedObject(self, Key_Block));
}

- (void) setWDPRBlock:(WDPRModifyInputBlock)block
{
    objc_setAssociatedObject(self, Key_Block, block, OBJC_ASSOCIATION_RETAIN);
}

#pragma mark -

+ (BOOL)assumeDarkColoredNavigationBar
{
    return NO;
}

+ (void)setAssumeDarkColoredNavigationBar:(BOOL)assumeDark
{
    NSAssert(NO, @"setAssumeDarkColoredNavigationBar: is deprecated");
}


@end
