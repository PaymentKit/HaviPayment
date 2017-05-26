//
//  NSAttributedString+WDPR.m
//  WDPR
//
//  Created by Rodden, James on 10/28/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRFoundation.h"
#import <CoreText/CTStringAttributes.h>

enum
{
    kSubScriptValue = -1,
    kSuperScriptValue = 1
};

@implementation NSString (NSAttributedString_WDPR)

- (NSAttributedString*)attributedStringWithAttributes:(NSDictionary*)attributes
{
    return [[NSAttributedString alloc] initWithString:self attributes:attributes];
}

@end // @implementation NSString (NSAttributedString_WDPR)

#pragma mark -

@implementation NSAttributedString (NSAttributedString_WDPR)

+ (instancetype)string:(NSString *)str attributes:(NSDictionary *)attrs
{
    if (!str)
    {
        WDPRLogWarning(@"Attempt to create NSAttributedString with nil string. Stack trace: %@",
                       [NSThread callStackSymbols]);
    }
    
    str = str ?: @"";
    return [(NSAttributedString *) [self.class alloc] initWithString:str attributes:attrs];
}

- (instancetype)stringByAppending:(NSAttributedString*)str
{
    NSMutableAttributedString* this = self.mutableCopy;
    
    [this appendAttributedString:str];
    
    return this.copy;
}

@end // @implementation NSAttributedString (NSAttributedString_WDPR)

#pragma mark -

@implementation NSMutableAttributedString (NSMutableAttributedString_WDPR)

- (void)appendString:(NSString *)str
{
    [self appendAttributedString:[[NSAttributedString alloc] initWithString:str]];
}

- (void)addSuperScriptAttributes:(NSDictionary *)att forSubstring:(NSString *)text forAttribute:(NSString *)attributeName
{
    NSUInteger length = [self length];
    NSRange range = NSMakeRange(0, length);
    
    range = [self.string rangeOfString:text options:0 range:range];
    if (range.location != NSNotFound)
    {
        //1 enables superscripting and a value of -1 enables subscripting.
        [self addAttribute:attributeName value:@(kSuperScriptValue) range:range];
        [self addAttributes:att range:range];
    }
}

@end // @implementation NSMutableAttributedString (NSMutableAttributedString_WDPR)

