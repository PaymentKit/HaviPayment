//
//  NSString+WDPRUIKit.h
//  WDPR
//
//  Created by Rodden, James on 4/16/14.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

@interface NSString (NSString_WDPRUIKit)

// Generate html attributed string for label or text views.
- (NSAttributedString *)htmlAttributedString;

- (NSInteger)heightWithFont:(UIFont *)font andBoundingWidth:(NSInteger)width;

@end

