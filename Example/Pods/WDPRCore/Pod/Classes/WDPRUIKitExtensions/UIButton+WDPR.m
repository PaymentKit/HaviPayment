//
//  UIButton+WDPR.m
//  WDPR
//
//  Created by Wright, Byron on 6/17/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import <objc/runtime.h>
#import "WDPRUIKit.h"

#define Key "eventBlock"

@implementation UIButton (WDPR)

- (PlainBlock)block
{
    return (PlainBlock)objc_getAssociatedObject(self, Key);
}

- (void)setBlock:(PlainBlock)block
{
    block = block ?: ^{};
    
    [self addTarget:self.class
             action:@selector(callBlock:)
   forControlEvents:UIControlEventTouchUpInside];
    
    objc_setAssociatedObject(self, Key, block,
                             OBJC_ASSOCIATION_COPY_NONATOMIC);
}

+ (void)callBlock:(UIButton*)sender
{
    sender.userInteractionEnabled = NO;
    sender.block();

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(),
                   ^{
                       sender.userInteractionEnabled = YES;
                   });
}

+ (UIButton*)buttonWithType:(UIButtonType)buttonType 
                   andBlock:(PlainBlock)block;
{
    UIButton* button = [UIButton buttonWithType:buttonType];
    
    button.block = block;
    
    return button;
}

+ (UIButton*)squareCheckboxButton:(CheckboxButtonBlock)block
{
    return [self checkboxButton:block];
}

+ (UIButton*)buttonWithImageNamed:(NSString*)imageName 
                         andLabel:(NSString*)labelText 
                        withStyle:(WDPRTextStyle)labelStyle
{
    return [self buttonWithImage:
            [UIImage imageNamed:imageName]
                        andLabel:labelText 
                       withStyle:labelStyle];
}

+ (UIButton*)buttonWithImage:(UIImage*)image
                    andLabel:(NSString*)labelText 
                   withStyle:(WDPRTextStyle)labelStyle
{
    return [self buttonWithView:
            [[UIImageView alloc] initWithImage:image]
                       andLabel:labelText withStyle:labelStyle];
}

+ (UIButton*)buttonWithView:(UIView*)subview
                   andLabel:(NSString*)labelText
                  withStyle:(WDPRTextStyle)labelStyle
{
    return [self buttonWithView:subview
                       andLabel:labelText
                      withStyle:labelStyle
             constrainedToWidth:CGFLOAT_MAX];
}


+ (UIButton*)buttonWithView:(UIView*)subview
                   andLabel:(NSString*)labelText
                  withStyle:(WDPRTextStyle)labelStyle
         constrainedToWidth:(CGFloat)width
{
    enum { kButtonToLabelSpacing = 8 };
    return [self.class buttonWithView:subview
                             andLabel:labelText
                            withStyle:labelStyle
                   constrainedToWidth:width
                 buttonToLabelSpacing:kButtonToLabelSpacing];
}

+ (UIButton*)buttonWithView:(UIView*)subview
                   andLabel:(NSString*)labelText
                  withStyle:(WDPRTextStyle)labelStyle
         constrainedToWidth:(CGFloat)width
       buttonToLabelSpacing:(CGFloat)buttonToLabelSpacing
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.accessibilityLabel = labelText;
    
    [button addSubview:subview];
    button.frame = subview.frame = CGRectIntegral(subview.bounds);
    
    subview.autoresizingMask = (UIViewAutoresizingFlexibleLeftMargin | 
                                UIViewAutoresizingFlexibleRightMargin |
                                UIViewAutoresizingFlexibleBottomMargin);
    
    UILabel *label = [UILabel new];
    
    label.text = labelText;
    [button addSubview:label];
    [label applyStyle:labelStyle];
    
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    
    CGSize labelSize = [label sizeThatFits:CGSizeMake(width, CGFLOAT_MAX)];
    CGRect labelRect = label.frame;
    labelRect.size = labelSize;
    label.frame = labelRect;
    
    label.textAlignment = NSTextAlignmentCenter;
    label.autoresizingMask = (UIViewAutoresizingFlexibleTopMargin | 
                              UIViewAutoresizingFlexibleLeftMargin | 
                              UIViewAutoresizingFlexibleRightMargin);
    
    [button setFrame:CGRectGrow(button.frame, buttonToLabelSpacing +
                                CGRectGetHeight(label.frame), CGRectMaxYEdge)];
    
    if (CGRectGetWidth(label.frame) > CGRectGetWidth(button.frame))
    {
        [button setFrame:CGRectGrow(button.frame, CGRectGetWidth(label.frame) - 
                                    CGRectGetWidth(button.frame), CGRectMaxXEdge)];
    }
    
    button.frame = CGRectIntegral(button.frame);
    
    [label setFrame:
     CGRectOffset(label.bounds, 
                  (CGRectGetWidth(button.frame) - CGRectGetWidth(label.frame))/2,
                  CGRectGetHeight(button.frame) - CGRectGetHeight(label.frame))];
    
    label.frame = CGRectIntegral(label.frame);
    
    MAKE_WEAK(button);
    
    void (^ highlightButton)(BOOL) =
    ^void(BOOL touch)
    {
        executeOnNextRunLoop
        (^{
            MAKE_STRONG(button);
            for (UIView* subview in strongbutton.subviews)
            {
                if ([subview respondsToSelector:@selector(setHighlighted:)])
                {
                    [(id)subview setHighlighted:touch];
                }
            }
        });
    };
    [button inResponseToControlEvents:
     UIControlEventAllEvents
                         executeBlock:
     ^{
         highlightButton(NO);
     }];
    
    [button inResponseToControlEvents:
     UIControlEventTouchDown
                         executeBlock:
     ^{
         highlightButton(YES);
     }];

    [button addConstraint:
     [NSLayoutConstraint constraintWithItem:button 
                                  attribute:NSLayoutAttributeWidth 
                                  relatedBy:NSLayoutRelationEqual toItem:nil 
                                  attribute:NSLayoutAttributeNotAnAttribute 
                                 multiplier:1 constant:CGRectGetWidth(button.frame)]];
    [button addConstraint:
     [NSLayoutConstraint constraintWithItem:button 
                                  attribute:NSLayoutAttributeHeight 
                                  relatedBy:NSLayoutRelationEqual toItem:nil 
                                  attribute:NSLayoutAttributeNotAnAttribute 
                                 multiplier:1 constant:CGRectGetHeight(button.frame)]];
    return button;
}

#pragma mark - Common init
+ (UIButton*)checkboxButton:(CheckboxButtonBlock)block
{
    __block UIButton* button = 
    [self buttonWithType:UIButtonTypeCustom andBlock:
     ^{
         button.selected = !button.selected;
         
         if (block) 
         {
             block(button.selected);
         }
     }];
    
    enum { kDefaultButtonSize = 30 };
    button.frame = CGRectMake(0, 0, 
                              kDefaultButtonSize, 
                              kDefaultButtonSize);
    UIColor *greenColor = [UIColor wdprEnabledTransactionButtonColor];
    UIColor *borderColor = [UIColor wdprGrayColor];
    UIImage *emptyCheckbox = [WDPRIcon imageOfIcon:WDPRIconEmptyCheckbox
                                         withColor:borderColor andSize:button.frame.size];
    UIImage *selectedCheckbox = [WDPRIcon imageOfIcon:WDPRIconSelectedSolidCheckbox
                                            withColor:greenColor andSize:button.frame.size];
    
    [button setImage: selectedCheckbox
            forState:UIControlStateSelected];
    
    [button setImage: emptyCheckbox
            forState:UIControlStateNormal];
    
    return button;
}

@end
