//
//  WDPRActivityAnimationView.h
//  WDPR
//
//  Created by Thompson, Greg X. -ND on 5/6/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, WDPRActivityAnimationViewType)
{
    WDPRActivityAnimationViewTypeSpinning,
    WDPRActivityAnimationViewTypeSpinningXL,
};

@interface WDPRActivityAnimationView : UIImageView

+ (instancetype)smallActivityIndicator:(WDPRActivityAnimationViewType)type;
+ (instancetype)mediumActivityIndicator:(WDPRActivityAnimationViewType)type;
+ (instancetype)largeActivityIndicator:(WDPRActivityAnimationViewType)type;

@end
