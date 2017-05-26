//
//  NSAttributedString+WDPR.h
//  WDPR
//
//  Created by Rodden, James on 10/28/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSAttributedString (NSAttributedString_WDPR)

- (instancetype)stringByAppending:(NSAttributedString*)str;
+ (instancetype)string:(NSString *)str attributes:(NSDictionary *)attrs;

@end

#pragma mark -

@interface NSString (NSAttributedString_WDPR)

- (NSAttributedString*)attributedStringWithAttributes:(NSDictionary*)attributes;

@end

#pragma mark -

@interface NSMutableAttributedString (NSMutableAttributedString_WDPR)

- (void)appendString:(NSString *)str;
- (void)addSuperScriptAttributes:(NSDictionary *)att forSubstring:(NSString *)text forAttribute:(NSString *)attributeName;

@end
