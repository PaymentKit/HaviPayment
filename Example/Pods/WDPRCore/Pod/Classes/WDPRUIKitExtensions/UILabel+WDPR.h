//
//  UILabel+WDPR.h
//  WDPR
//
//  Created by Rodden, James on 8/9/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (WDPR)

- (void)setTextOrAttributedText:(id)text;

/**
 Sizes this label based on it's textual content, and given maximum size dimensions.
 If the maximum dimensions are reached during resizing, text will be truncated.
 
 Note: Set the text and font, before calling this method.
 
 @param maxSize -  Maximum size this label can be.
 */
- (void)sizeWithMaxSize:(CGSize)maxSize;

/**
 Calculates the current number of lines based on the label's bounds and the font's line height.
 
 @return The current number of line the label has
 */
- (NSInteger)currentNumberOfLines;

@end
