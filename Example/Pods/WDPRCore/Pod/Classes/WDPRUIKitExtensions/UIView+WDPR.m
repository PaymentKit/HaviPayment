//
//  UIView+WDPR.m
//  DLR
//
//  Created by Francisco Valbuena on 3/31/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "UIView+WDPR.h"
#import "UIColor+WDPR.h"

@implementation UIView (WDPR)

- (UIImage*)imageOfSelf
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);

    [self.layer renderInContext:UIGraphicsGetCurrentContext()];

    UIImage *imageOfSelf = UIGraphicsGetImageFromCurrentImageContext();

    UIGraphicsEndImageContext();

    return imageOfSelf;
}

- (UIColor*)tintOrBarTintColor
{
    if (![self respondsToSelector:
          @selector(barTintColor)])
    {
        return [self tintColor];
    }
    else return [(id)self barTintColor];
}

- (void)setTintOrBarTintColor:(UIColor*)color
{
    if (![self respondsToSelector:
          @selector(barTintColor)])
    {
        [self setTintColor:color];
    }
    else [(id)self setBarTintColor:color];
}

- (void)centerViewInSuperview
{
    self.frame = CGRectMake((self.superview.frame.size.width / 2.0) - (self.frame.size.width / 2.0),
                            self.frame.origin.y,
                            self.frame.size.width,
                            self.frame.size.height);
}

- (void)addUpperBorder:(UIColor *)borderColor
{
    CALayer *upperBorder = [CALayer layer];
    upperBorder.backgroundColor = [borderColor CGColor];

    upperBorder.frame = CGRectMake(0,
                                   0,
                                   self.frame.size.width,
                                   1.0);

    [self.layer addSublayer:upperBorder];
}

+ (instancetype)autolayoutView
{
    UIView *view = [self new];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    return view;
}

#pragma mark -

+ (UIView*)viewWithEquallySpacedSubviews:(NSArray*)subviews;
{
    return [self viewWithEquallySpacedSubviews:subviews
                        withVerticalSeparators:NO];
}

+ (UIView *)viewWithEquallySpacedSubviews:(NSArray *)subviews
                   withVerticalSeparators:(BOOL)verticalSeparators
{
    NSMutableArray *constraints = [NSMutableArray array];

    UIView *view =  // frame is temporary
            [[UIView alloc] initWithFrame:CGRectMake(0, 0, 200, 50)];

    view.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
            UIViewAutoresizingFlexibleHeight);

    if (verticalSeparators)
    {
        NSMutableArray *subviewsWithSeparators =
                [NSMutableArray arrayWithArray:subviews];
        
        UIView *lastSubview = subviews.lastObject;

        for (NSUInteger ii = subviews.count; ii > 1;)
        {
            UIView *separator = [[UIView alloc] initWithFrame:CGRectZero];
            separator.backgroundColor = [UIColor wdprMutedGrayColor];

            [subviewsWithSeparators insertObject:separator atIndex:--ii];

            [constraints addObject: // keep separator the same
                                 [NSLayoutConstraint constraintWithItem:separator // height as view
                                                              attribute:NSLayoutAttributeHeight
                                                              relatedBy:NSLayoutRelationEqual toItem:lastSubview
                                                              attribute:NSLayoutAttributeHeight
                                                             multiplier:1 constant:0]];

            [constraints addObject: // keep separator 1 point wide
                                 [NSLayoutConstraint constraintWithItem:separator
                                                              attribute:NSLayoutAttributeWidth
                                                              relatedBy:NSLayoutRelationEqual toItem:nil
                                                              attribute:NSLayoutAttributeNotAnAttribute
                                                             multiplier:1 constant:1]];
        }

        subviews = subviewsWithSeparators.copy;
    }

    for (NSUInteger ii = 0; ii < subviews.count; ii++)
    {
        UIView *subview = subviews[ii];

        [view addSubview:subview];
        subview.translatesAutoresizingMaskIntoConstraints = NO;

        CGFloat multiplier = ((2.0 * (1 + ii))/(subviews.count + 1));

        [constraints addObject:  // vertically align to top edge of view
                             [NSLayoutConstraint constraintWithItem:subview
                                                          attribute:NSLayoutAttributeTop
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:view
                                                          attribute:NSLayoutAttributeTop
                                                         multiplier:1 constant:0]];

        [constraints addObject:  // horizontally distribute each item
                             [NSLayoutConstraint constraintWithItem:subview
                                                          attribute:NSLayoutAttributeCenterX
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:view
                                                          attribute:NSLayoutAttributeCenterX
                                                         multiplier:multiplier constant:0]];
    }

    if ([NSLayoutConstraint respondsToSelector:@selector(activateConstraints:)])
    {
        [NSLayoutConstraint activateConstraints:constraints];
    }
    else // iOS7 version, remove this when we drop iOS7 support
    {
        [view addConstraints:constraints];
    }

    return view;
}

#pragma mark -

- (NSArray *)addSubviews:(NSDictionary<NSString*, UIView*>*)views 
   withVisualConstraints:(NSArray<NSString*>*)formattedConstraints
{
    return [self addSubviews:views withVisualConstraints:
            formattedConstraints options:0 metrics:nil];
}

- (NSArray *)addSubviews:(NSDictionary<NSString*, UIView*>*)views 
   withVisualConstraints:(NSArray<NSString*>*)formattedConstraints 
                 options:(NSLayoutFormatOptions)constraintOptions 
                 metrics:(nullable NSDictionary<NSString *,id> *)metrics
{
    for (UIView* subview in views.allValues)
    {
        [self addSubview:subview];
        [subview setTranslatesAutoresizingMaskIntoConstraints:NO];
    }
    
    NSMutableArray* result = [NSMutableArray new];
    for (NSString* constraints in formattedConstraints)
    {
        [result addObjectsFromArray:
         [self addConstraintsWithFormat:constraints 
                                options:constraintOptions 
                                metrics:metrics views:views]];
    }
    
    return result.copy;
}

- (NSArray *)addConstraintsWithFormat:(NSString *)format
                              metrics:(NSDictionary *)metrics
                                views:(NSDictionary *)views
{
    return [self addConstraintsWithFormat:format
                                  options:0
                                  metrics:metrics
                                    views:views];
}

- (NSArray *)addConstraintsWithFormat:(NSString *)format
                              options:(NSLayoutFormatOptions)options
                              metrics:(NSDictionary *)metrics
                                views:(NSDictionary *)views
{
    NSArray *constraints = [NSLayoutConstraint constraintsWithVisualFormat:format
                                                                   options:options
                                                                   metrics:metrics
                                                                     views:views];
    [self addConstraints:constraints];
    
    return constraints;
}

#pragma mark -

- (UIViewController *)closestViewController
{
    UIResponder *nextResponder = self;
    
    while (nextResponder && ![nextResponder isKindOfClass:[UIViewController class]])
    {
        nextResponder = [nextResponder nextResponder];
    }
    
    return (UIViewController *)nextResponder;
}

#pragma mark -

+ (nullable id)focusedElementForView:(nonnull id <NSObject>)element
{
    if (!UIAccessibilityIsVoiceOverRunning())
    {
        return nil;
    }
    
    // base case, element is focused
    if ([(id)element accessibilityElementIsFocused])
    {
        return element;
    }
    
    // recurse over subviews (if any)
    if ([element isKindOfClass:[UIView class]])
    {
        for (UIView *subview in [(UIView *)element subviews])
        {
            id result = [UIView focusedElementForView:subview];
            if (result)
            {
                return result;
            }
        }
    }
    
    // recurse over accessibilityElements (for potential instances of UIAccessibilityElement)
    for (id accessibilityElement in [(id)element accessibilityElements])
    {
        id result = [UIView focusedElementForView:accessibilityElement];
        if (result)
        {
            return result;
        }
    }
    
    // Focused element not found within subviews
    return nil;
}

@end
