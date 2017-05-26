//
//  UIFont+WDPR.h
//  
//
//  Created by Pierce, Owen on 12/5/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIFont (WDPR)

/// Checks to see if we support the Dynamic Text setting
+ (BOOL)dynamicText;

/// Dynamically sized Avenir-Heavy for caption text (default size 12)
+ (UIFont *)wdprFontStyleC1;

/// Dynamically sized Avenir-Roman for caption text (default size 12)
+ (UIFont *)wdprFontStyleC2;

/// Dynamically sized Avenir-Roman for caption text (default size 10)
+ (UIFont *)wdprFontStyleC3;

/// Dynamically sized Avenir-Heavy for body text (default size 16)
+ (UIFont *)wdprFontStyleB1;

/// Dynamically sized Avenir-Roman for body text (default size 16)
+ (UIFont *)wdprFontStyleB2;

/// Avenir-Black for headlines size 24
+ (UIFont *)wdprFontStyleH1;

/// Avenir-Black for headlines size 20
+ (UIFont *)wdprFontStyleH2;

/// Avenir-Heavy for headlines size 24
+ (UIFont *)wdprFontStyleH1H;

/// Avenir-Heavy for headline text size 20
+ (UIFont *)wdprFontStyleH3;

/// Avenir-Heavy for buttons size 20
+ (UIFont *)wdprStandardButtonFont;

/// Avenir-Heavy for buttons using a custom size
+ (UIFont *)wdprStandardButtonFontWithCustomSize:(CGFloat)fontSize;

/// Avenir-Roman for headlines size 24
+ (UIFont *)wdprFontStyleH1R;

/// Avenir-Book for headline text size 20
+ (UIFont *)wdprFontStyleH4;

/// Avenir-Book for headline text size 32
+ (UIFont *)wdprFontStyleH1RDL;

/// Avenir-Black for headlines size 20
+ (UIFont *)wdprFontStyleS1;

/// Avenir-Heavy for headline text size 20
+ (UIFont *)wdprFontStyleS2;

/// Avenir-Roman for body text size 20
+ (UIFont *)wdprFontStyleS3;

/**
 *  Returns difference between capHeight and ascender
 *  https://www.cocoanetics.com/2010/02/understanding-uifont/
 *
 *  @return (capHeight - ascender)
 */
- (CGFloat)capAscender;

NS_ASSUME_NONNULL_END

@end
