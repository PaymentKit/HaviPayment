//
//  UIGradientView.h
//  WDPR
//
//  Created by Rodden, James on 7/17/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CAGradientLayer;

@interface UIGradientView : UIView

@property (nonatomic, readonly) CAGradientLayer* gradientLayer;

@end
