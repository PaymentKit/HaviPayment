//
//  NSString+WDPRUIKit.m
//  WDPR
//
//  Created by Rodden, James on 4/16/14.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "NSString+WDPRUIKit.h"

@implementation NSString (NSString_WDPRUIKit)

- (NSAttributedString *)htmlAttributedString
{
    return [[[NSAttributedString alloc] 
             initWithData:[self dataUsingEncoding:NSUTF8StringEncoding]
             options:@{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                       NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)}
             documentAttributes:nil error:nil] copy];
}

- (NSInteger)heightWithFont:(UIFont *)font andBoundingWidth:(NSInteger)width
{
    CGSize constrainedSize = CGSizeMake(width, CGFLOAT_MAX);
    
    CGRect requiredHeight = 
    [self boundingRectWithSize:constrainedSize
                       options:(NSStringDrawingUsesLineFragmentOrigin | 
                                NSStringDrawingUsesFontLeading)
                    attributes:@{ NSFontAttributeName:font }
                       context:nil];
    
    return ceilf(requiredHeight.size.height);
}

@end // @implementation NSString (NSString_WDPRUIKit)
