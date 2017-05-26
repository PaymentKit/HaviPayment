//
//  UILabel+WDPR.m
//  WDPR
//
//  Created by Rodden, James on 8/9/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"

@implementation UILabel (WDPR)

- (void)setTextOrAttributedText:(id)text
{
    self.text = nil;
    
    if ([text isKindOfClass:NSString.class])
    {
        self.text = text;
    }
    else if ([text isKindOfClass:
              NSAttributedString.class])
    {
        self.attributedText = text;
    }
}

- (void)sizeWithMaxSize:(CGSize)maxSize 
{
    CGRect rectWithMaxSize = [self.text boundingRectWithSize:maxSize
                                                     options:NSStringDrawingUsesLineFragmentOrigin
                                                  attributes:@{ NSFontAttributeName:self.font } context:nil];
    //The previous implementation was setting the origin coordinates to (0,0) because the method returns the origin of the first glyph but not the view itself, causing SLING-19643.
    [self setFrame: CGRectMake(self.frame.origin.x, self.frame.origin.y, rectWithMaxSize.size.width, rectWithMaxSize.size.height)];
}

- (NSInteger)currentNumberOfLines
{
    return round(self.bounds.size.height / self.font.lineHeight);
}

@end
