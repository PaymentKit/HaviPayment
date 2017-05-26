//
//  NSAttributedString+WDPRUIKit.m
//  WDPR
//
//  Created by Rodden, James on 4/1/14.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "NSAttributedString+WDPRUIKit.h"

#import <UIKit/UIKit.h>

@implementation NSAttributedString (NSAttributedString_WDPRUIKit)

- (NSInteger)heightWithBoundingWidth:(CGFloat)width
{
    CGSize constrainedSize = CGSizeMake(width, CGFLOAT_MAX);
    
    CGRect requiredHeight = [self boundingRectWithSize:constrainedSize
                                               options:(NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading)
                                               context:nil];
    
    return ceilf(requiredHeight.size.height);
}

@end // @implementation NSAttributedString (NSAttributedString_WDPRUIKit)
