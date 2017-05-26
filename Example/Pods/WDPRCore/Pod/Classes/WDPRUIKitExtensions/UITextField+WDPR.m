//
//  UITextField+WDPR.m
//  WDPR
//
//  Created by Rodden, James on 8/9/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"

@implementation UITextField (WDPR)

- (void)setTextOrAttributedText:(id)text
{
    if (!text ||
        [text isKindOfClass:NSString.class])
    {
        self.text = text;
    }
    else if ([text isKindOfClass:
              NSAttributedString.class])
    {
        self.attributedText = text;
    }
}
- (void)setPlaceholderOrAttributedPlaceholder:(id)text
{
    if (!text ||
        [text isKindOfClass:NSString.class])
    {
        self.placeholder = text;
    }
    else if ([text isKindOfClass:
              NSAttributedString.class])
    {
        self.attributedPlaceholder = text;
    }
}

@end
