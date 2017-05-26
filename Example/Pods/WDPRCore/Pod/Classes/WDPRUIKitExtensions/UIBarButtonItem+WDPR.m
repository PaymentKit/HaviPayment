//
//  UIBarButtonItem+WDPR.m
//  WDPR
//
//  Created by Rodden, James on 7/17/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <objc/runtime.h>
#import "WDPRUIKit.h"
#import "WDPRLocalization.h"

#define kButtonBlockKey "WDPRBarButtonBlock"

static CGFloat const kButtonWDPRIconDimension = 24.0;
static CGFloat const kBarButtonItemHeight = 42.0;
static CGFloat const kBarButtonItemWidth = 42.0;
static CGFloat const kToolBarButtonWidth = 32.0;

@interface WDPRBarButtonItem : UIBarButtonItem
@end

@implementation WDPRBarButtonItem

- (void)setTitle:(NSString *)title
{
    if (![self.customView
          isKindOfClass:UIButton.class])
    {
        [super setTitle:title];
    }
    else
    {
        [(UIButton*)self.customView
         setTitle:title forState:UIControlStateNormal];
        
        [(UIButton*)self.customView sizeToFit];
    }
}

- (void)setEnabled:(BOOL)enabled
{
    if (![self.customView
          isKindOfClass:UIButton.class])
    {
        [super setEnabled:enabled];
    }
    else
    {
        ((UIButton*)self.customView).enabled = enabled;
    }
}

- (void)setTitleTextAttributes:(NSDictionary *)attributes
                      forState:(UIControlState)state
{
    if (![self.customView
          isKindOfClass:UIButton.class])
    {
        [super setTitleTextAttributes:attributes forState:state];
    }
    else
    {
        onExitFromScope
        (^{
            //[(UIButton*)self.customView sizeToFit];
        });
        
        typedef void (^AttributeSetter)(id key, UIControlState state);
        
        [@{
           NSFontAttributeName : ^(UIFont *font, UIControlState state)
           { [((UIButton*)self.customView).titleLabel setFont:font]; },
           
           NSStrokeColorAttributeName : ^(UIColor* color, UIControlState state)
           { [(UIButton*)self.customView setTitleColor:color forState:state]; },
           
           NSShadowAttributeName : ^(UIColor* color, UIControlState state)
           { [(UIButton*)self.customView setTitleShadowColor:color forState:state]; },
           }
         enumerateKeysAndObjectsUsingBlock:^(NSString* key, AttributeSetter block, BOOL *stop)
         {
             id value = attributes[key];
             
             if (value)
             {
                 block(value, state);
             }
         }];
    }
}

@end // @implementation WDPRBarButtonItem

#pragma mark -

@implementation UIBarButtonItem (WDPR)

- (PlainBlock)block
{
    return ((PlainBlock)
            objc_getAssociatedObject(self, kButtonBlockKey));
}

- (void)setBlock:(PlainBlock)block
{
    // Implementation Detail:
    // Set target and action to glue code that enables 
    // block execution in response to user interation.
    // This is an implied part of the API contract: 
    // not only set the block, but also make it work.
    
    self.target = self.class;
    self.action = @selector(callBlock:);
    
    objc_setAssociatedObject(self, kButtonBlockKey, block,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (void)callBlock:(UIBarButtonItem*)sender
{
    (sender.block ?: ^{})();
}

#pragma mark -

+ (UIBarButtonItem*)itemWithTitle:(NSString*)title
{
    UIBarButtonItem* buttonItem;
    
    UILabel* label = [[UILabel alloc] 
                      initWithFrame:CGRectZero];
    
    label.text = title;
    [label applyStyle:WDPRTextStyleB1B];
    label.backgroundColor = UIColor.clearColor;
    
    [label sizeToFit];
    
    buttonItem = [[WDPRBarButtonItem alloc] 
                  initWithCustomView:label];
    
    return buttonItem;
}

+ (UIBarButtonItem*)fixedSpaceItem
{
    return [[self alloc] initWithBarButtonSystemItem:
            UIBarButtonSystemItemFixedSpace target:nil action:nil];
}

+ (UIBarButtonItem*)flexibleSpaceItem
{
    return [[self alloc] initWithBarButtonSystemItem:
            UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
}

#pragma mark -

+ (UIBarButtonItem*)backButtonItem:(PlainBlock)block
{
    UIBarButtonItem* buttonItem =
    [self backButtonItem:nil action:nil];
    
    buttonItem.block = block;
    
    return buttonItem;
}

+ (UIBarButtonItem *)backButtonItemForKeyboard:(PlainBlock)block
{
    UIBarButtonItem *buttonItem = [self backButtonItem:block];
    buttonItem.width = kToolBarButtonWidth;
    return buttonItem;
}

+ (UIBarButtonItem*)doneButtonItem:(PlainBlock)block
{
    UIBarButtonItem* buttonItem =
    [self doneButtonItem:nil action:nil];
    
    buttonItem.block = block;
   
    return buttonItem;
}

+ (UIBarButtonItem*)cancelButtonItem:(PlainBlock)block
{
    UIBarButtonItem* buttonItem =
    [self cancelButtonItem:nil action:nil];
    
    buttonItem.block = block;
    
    return buttonItem;
}

+ (UIBarButtonItem *)forwardButtonItemForKeyboard:(PlainBlock)block
{
    UIBarButtonItem *buttonItem = [self forwardButtonItem:block];
    buttonItem.width = kToolBarButtonWidth;
    return buttonItem;
}

+ (UIBarButtonItem*)forwardButtonItem:(PlainBlock)block
{
    UIBarButtonItem* buttonItem = 
    [self buttonWithTitle:nil target:nil action:nil];
    
    buttonItem.block = block;
    buttonItem.accessibilityLabel = WDPRLocalizedStringInBundle(@"com.wdprcore.buttonitem.accessibilitylabel.next.label", WDPRCoreResourceBundleName, nil);
    
    UIImage *image = 
    [[WDPRIcon imageOfIcon:WDPRIconRightCaret 
                 withColor:UIColor.wdprBlueColor
                   andSize:CGSizeMake(kButtonWDPRIconDimension, 
                                      kButtonWDPRIconDimension)]
     imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [(UIButton*)buttonItem.customView 
     setImage:image forState:UIControlStateNormal];
    
    [(UIButton*)buttonItem.customView 
     setImage:image forState:UIControlStateHighlighted];
    
    [(UIButton*)buttonItem.customView
     setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 2, 7)];
    
    [(UIButton*)buttonItem.customView sizeToFit];
    
    CGRect frame = buttonItem.customView.frame;
    buttonItem.customView.frame = CGRectMake(frame.origin.x,
                                             frame.origin.y,
                                             kBarButtonItemWidth,
                                             kBarButtonItemHeight);
    [buttonItem.customView setContentMode:UIViewContentModeCenter];
    
    return buttonItem;
}

#pragma mark -

+ (UIBarButtonItem*)backButtonItem:(id)target
                             action:(SEL)action
{
    UIBarButtonItem* buttonItem =
    [self buttonWithTitle:nil target:target action:action];
    
    buttonItem.accessibilityLabel = WDPRLocalizedStringInBundle(@"com.wdprcore.buttonitem.accessibilitylabel.back.label", WDPRCoreResourceBundleName, nil);
    
    UIImage *image =
    [[WDPRIcon imageOfIcon:WDPRIconLeftCaret
                 withColor:UIColor.wdprBlueColor
                   andSize:CGSizeMake(kButtonWDPRIconDimension, 
                                      kButtonWDPRIconDimension)]
     imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [(UIButton*)buttonItem.customView 
     setImage:image forState:UIControlStateNormal];
    
    [(UIButton*)buttonItem.customView 
     setImage:image forState:UIControlStateHighlighted];
    
    [(UIButton*)buttonItem.customView 
     setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 2, 7)];
    
    [(UIButton*)buttonItem.customView sizeToFit];
    
    CGRect frame = buttonItem.customView.frame;
    buttonItem.customView.frame = CGRectMake(frame.origin.x,
                                             frame.origin.y,
                                             kBarButtonItemWidth,
                                             kBarButtonItemHeight);
    [buttonItem.customView setContentMode:UIViewContentModeCenter];

    return buttonItem;
}

+ (UIBarButtonItem*)refreshButtonItem:(PlainBlock)block
{
    UIBarButtonItem* buttonItem =
    [self buttonWithTitle:nil target:nil action:nil];
    
    buttonItem.block = block;
    buttonItem.accessibilityLabel = WDPRLocalizedStringInBundle(@"com.wdprcore.buttonitem.accessibilitylabel.refresh.label", WDPRCoreResourceBundleName, nil);
    
    UIImage *image =
    [[WDPRIcon imageOfIcon:WDPRIconRefresh 
                 withColor:UIColor.wdprBlueColor
                   andSize:CGSizeMake(kButtonWDPRIconDimension,
                                      kButtonWDPRIconDimension)]
     imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    [(UIButton*)buttonItem.customView
     setImage:image forState:UIControlStateNormal];
    
    [(UIButton*)buttonItem.customView
     setImage:image forState:UIControlStateHighlighted];
    
    [(UIButton*)buttonItem.customView
     setImageEdgeInsets:UIEdgeInsetsMake(0, 0, 2, 7)];
    
    [(UIButton*)buttonItem.customView sizeToFit];
    
    CGRect frame = buttonItem.customView.frame;
    buttonItem.customView.frame = CGRectMake(frame.origin.x,
                                             frame.origin.y,
                                             kBarButtonItemWidth,
                                             kBarButtonItemHeight);
    [buttonItem.customView setContentMode:UIViewContentModeCenter];
    
    return buttonItem;
}


+ (UIBarButtonItem*)doneButtonItem:(id)target
                             action:(SEL)action
{
    UIBarButtonItem* buttonItem = 
    [self buttonWithTitle:nil 
                    style:UIBarButtonItemStyleDone 
                   target:target action:action];

    buttonItem.title = WDPRLocalizedStringInBundle(@"com.wdprcore.buttonitem.done.title", WDPRCoreResourceBundleName, nil);
    buttonItem.accessibilityLabel = buttonItem.title;
    
    return buttonItem;
}

+ (UIBarButtonItem*)cancelButtonItem:(id)target
                               action:(SEL)action
{
    UIBarButtonItem* buttonItem;
    
    buttonItem = [self buttonWithTitle:nil 
                                 style:UIBarButtonItemStyleDone 
                                target:target action:action];
    
    buttonItem.title = WDPRLocalizedStringInBundle(@"com.wdprcore.buttonitem.cancel.title", WDPRCoreResourceBundleName, nil);
    buttonItem.accessibilityLabel = buttonItem.title;
    
    return buttonItem;
}

#pragma mark -

+ (UIBarButtonItem*)buttonWithTitle:(NSString *)title
                               block:(PlainBlock)block
{
    UIBarButtonItemStyle style = UIBarButtonItemStylePlain;
    UIBarButtonItem* buttonItem = [self buttonWithTitle:title 
                                                  style:style 
                                                 target:nil 
                                                 action:nil];
    
    buttonItem.block = block;
    
    return buttonItem;
}

+ (UIBarButtonItem*)buttonWithTitle:(NSString *)title
                              target:(id)target action:(SEL)action
{
    UIBarButtonItemStyle style = UIBarButtonItemStylePlain;
    return [self buttonWithTitle:title style:style 
                          target:target action:action];
}

+ (UIBarButtonItem*)buttonWithTitle:(NSString *)title
                               style:(UIBarButtonItemStyle)style
                              target:(id)target action:(SEL)action
{
    NSAssert(!target || !action ||
             [target respondsToSelector:action], @"");
    
#if DEBUG
    if ([title.lowercaseString 
         isEqualToString:NSLocalizedString(@"back", )])
    {
        WDPRLog(@"Why are you using buttonWithTitle when there is a "
               "perfectly good, even better, backButtonItem available?");
    }
    else if ([title.lowercaseString 
              isEqualToString:NSLocalizedString(@"next", )])
    {
        WDPRLog(@"Why are you using buttonWithTitle when there is a "
               "perfectly good, even better, forwardButtonItem available?");
    }
    else if ([title.lowercaseString 
              isEqualToString:NSLocalizedString(@"done", )])
    {
        WDPRLog(@"Why are you using buttonWithTitle when there is a "
               "perfectly good, even better, doneButtonItem available?");
    }
    else if ([title.lowercaseString 
              isEqualToString:NSLocalizedString(@"cancel", )])
    {
        WDPRLog(@"Why are you using buttonWithTitle when there is a "
               "perfectly good, even better, cancelButtonItem available?");
    }
#endif
    
    UIButton* button = [UIButton
                        buttonWithType:
                        UIButtonTypeCustom];

    [button setTitle:title
            forState:UIControlStateNormal];
    
    button.backgroundColor = UIColor.clearColor;
    [button.titleLabel applyStyle:WDPRTextStyleB1D];

    [button setTitleColor:UIColor.wdprBlueColor
                 forState:UIControlStateNormal];
    
    [button setTitleColor:UIColor.grayColor 
                 forState:UIControlStateHighlighted];
    
    [button setTitleColor:UIColor.grayColor
                 forState:UIControlStateDisabled];
    
    [button sizeToFit];

    UIBarButtonItem* buttonItem =
    [[WDPRBarButtonItem alloc] initWithEmbededButton:button 
                                              target:target 
                                              action:action];
    
    buttonItem.accessibilityLabel = title;
    
    return buttonItem;
}

#pragma mark -

+ (UIBarButtonItem*)buttonWithImage:(UIImage*)image
                               block:(PlainBlock)block
{
    UIBarButtonItem* buttonItem =
    [self buttonWithImage:image target:nil action:nil];
    
    buttonItem.block = block;
    
    return buttonItem;
}

+ (UIBarButtonItem*)buttonWithImage:(UIImage*)image 
                              style:(UIBarButtonItemStyle)style 
                              block:(PlainBlock)block
{
    UIBarButtonItem *buttonItem =
    [[WDPRBarButtonItem alloc] initWithImage:image style:style 
                                      target:nil action:nil];
    
    buttonItem.block = block;
    
    return buttonItem;
}

+ (UIBarButtonItem*)buttonWithImage:(UIImage*)image
                              target:(id)target action:(SEL)action
{
    UIButton* button =
    [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.frame = CGRectMake(0, 0, 25, 25);
    
    [button setImage:image forState:UIControlStateNormal];
    button.contentMode = UIViewContentModeScaleAspectFit;
    
    return [[WDPRBarButtonItem alloc] initWithEmbededButton:button 
                                                     target:target 
                                                     action:action];
}

- (instancetype)initWithEmbededButton:(UIButton*)button 
                               target:(id)target action:(SEL)action
{
    UIBarButtonItem* buttonItem = 
    [self initWithCustomView:button];
    
    MAKE_WEAK(buttonItem);
    button.block = ^{ weakbuttonItem.block(); };
    
    buttonItem.block = 
    ^{ 
        UIBarButtonItem* buttonItem = weakbuttonItem;
        if ([buttonItem.target respondsToSelector:buttonItem.action])
        {
            #pragma clang diagnostic push
            #pragma clang diagnostic ignored "-Warc-performSelector-leaks"
            [buttonItem.target performSelector:buttonItem.action withObject:buttonItem]; 
            #pragma clang diagnostic pop
        }
        else WDPRLogError(@"%@ does not respond to %@", buttonItem.target, buttonItem.action);
    };
    
    // set these after block
    buttonItem.target = target;
    buttonItem.action = action;

    return buttonItem;
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

#pragma mark - Accessibility

- (void)setAccessibilityLeftBarButtonItemLabel:(NSString *)label {
    
    self.isAccessibilityElement = YES;
    self.accessibilityTraits = UIAccessibilityTraitButton;
    self.accessibilityLabel = label;
}

- (void)makeViewElementsAccessibile:(BOOL)isAccessible
{
    self.isAccessibilityElement = isAccessible;
    self.accessibilityElementsHidden = !isAccessible;
}

@end























