//
//  CAShapeLayer+WDPR.m
//  DLR
//
//  Created by Wright, Byron on 1/21/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "CAShapeLayer+WDPR.h"
#import <UIKit/UIKit.h>

@implementation CAShapeLayer (WDPR)

+ (CAShapeLayer *)circleWithFrame:(CGRect)frame withStrokeColor:(UIColor *)color andLineWidth:(NSUInteger)lineWidth
{
    CAShapeLayer *layer = (id)self.layer;
    layer.lineWidth = lineWidth;
    layer.fillColor = NULL;
    layer.path = [UIBezierPath bezierPathWithOvalInRect:frame].CGPath;
    layer.strokeColor = color.CGColor;
    layer.contentsScale = [UIScreen mainScreen].scale * 4.0;
    layer.shouldRasterize = NO;
    
    return layer;
}
@end
