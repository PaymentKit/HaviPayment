//
//  CAShapeLayer+WDPR.h
//  DLR
//
//  Created by Wright, Byron on 1/21/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface CAShapeLayer (WDPR)

+ (CAShapeLayer *)circleWithFrame:(CGRect)frame withStrokeColor:(UIColor *)color andLineWidth:(NSUInteger)lineWidth;

@end
