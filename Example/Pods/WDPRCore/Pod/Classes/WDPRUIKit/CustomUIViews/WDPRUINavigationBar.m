//
//  WDPRUINavigationBar.m
//  DLR
//
//  Created by Delafuente, Rob on 6/1/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRUINavigationBar.h"
#import "WDPRUIKit.h"

static CGFloat const kDefaultHeight = 56.0;

@interface WDPRUINavigationBar()

@property (nonatomic, assign) CGFloat navigationBarHeight;

@end

@implementation WDPRUINavigationBar

- (instancetype)init
{
    self = [super init];
    if (self)
    {
        _navigationBarHeight = kDefaultHeight;
        [self setup];
    }
    return self;
}

- (void)setup
{
    CGFloat standardHeight = [super sizeThatFits:CGSizeZero].height;
    [self setTitleVerticalPositionAdjustment:(standardHeight-kDefaultHeight)/2
                               forBarMetrics:UIBarMetricsDefault];
    
}

- (CGSize)sizeThatFits:(CGSize)size
{
    [super sizeThatFits:size];
    
    return CGSizeMake(SCREEN_WIDTH, _navigationBarHeight);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    NSArray *classNamesToReposition = @[@"UINavigationItemView", @"UINavigationButton", @"UIButton"];
    
    for (UIView *view in self.subviews)
    {
        if ([classNamesToReposition containsObject:NSStringFromClass([view class])])
        {
            view.center = CGPointMake(view.center.x, CGRectGetMidY(self.bounds));
        }
    }
}

@end
