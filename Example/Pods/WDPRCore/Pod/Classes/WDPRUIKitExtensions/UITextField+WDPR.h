//
//  UITextField+WDPR.h
//  WDPR
//
//  Created by Rodden, James on 8/9/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITextField (WDPR)

- (void)setTextOrAttributedText:(id)text;
- (void)setPlaceholderOrAttributedPlaceholder:(id)text;

@end
