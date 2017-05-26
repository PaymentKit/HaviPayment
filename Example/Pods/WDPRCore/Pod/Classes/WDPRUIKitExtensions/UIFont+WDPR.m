//
//  UIFont+WDPR.m
//  
//
//  Created by Pierce, Owen on 12/5/14.
//
//

#import "UIFont+WDPR.h"
#import "WDPRLocalization.h"
#import <WDPRCore/WDPRLog.h>

NS_ASSUME_NONNULL_BEGIN

@implementation UIFont (WDPR)

+ (BOOL)dynamicText
{
    return [NSUserDefaults.
            standardUserDefaults
            boolForKey:@"dynamicText"];
}

#pragma mark -

+ (NSString *)localizedFontNameFor:(NSString *)fontName
{
    WDPRLocaleInfo *localeInfo = [WDPRLocalization localeInfo];
    
    NSDictionary *localizedFonts = localeInfo.localizedFonts;
    NSString *mappedFontName;
    if(localizedFonts)
    {
        mappedFontName = [localizedFonts objectForKey:fontName];
        NSAssert(mappedFontName.length > 0, @"Unrecognized fontname");
    }
    
    if (mappedFontName.length == 0)
    {
        //Check standard fonts
        UIFont *loadedFont = [UIFont fontWithName:fontName size:12.0];
        NSAssert(loadedFont != nil, @"Unrecognized fontname");
        mappedFontName = loadedFont ? loadedFont.fontName : [UIFont systemFontOfSize:12.0].fontName;
    }
    return mappedFontName ? mappedFontName : fontName;
}

+ (UIFont *)fontForSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:[UIFont localizedFontNameFor:@"Avenir-Roman"] size:fontSize] ? : [UIFont systemFontOfSize:fontSize];
}

+ (UIFont *)emphasisFontForSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:[UIFont localizedFontNameFor:@"Avenir-Heavy"] size:fontSize] ? : [UIFont systemFontOfSize:fontSize];
}

+ (UIFont *)boldEmphasisFontForSize:(CGFloat)fontSize
{
    return [UIFont fontWithName:[UIFont localizedFontNameFor:@"Avenir-Black"] size:fontSize] ? : [UIFont systemFontOfSize:fontSize];
}

#pragma mark -

+ (UIFont *)fontForTextStyle:(NSString *)style
{
    return [self fontForSize:
            [self preferredFontForTextStyle:style].pointSize - 3];
}

+ (UIFont *)emphasisFontForTextStyle:(NSString *)style
{
    return [self emphasisFontForSize:
            [self preferredFontForTextStyle:style].pointSize - 3];
}

+ (UIFont *)boldEmphasisFontForTextStyle:(NSString *)style
{
    return [self boldEmphasisFontForSize:
            [self preferredFontForTextStyle:style].pointSize - 3];
}

#pragma mark -

+ (UIFont *)wdprFontStyleC1
{
    return (!UIFont.dynamicText ? [UIFont emphasisFontForSize:12.0f] :
            [UIFont emphasisFontForTextStyle:UIFontTextStyleCaption1]);
}

+ (UIFont *)wdprFontStyleC2
{
    return (!UIFont.dynamicText ? [UIFont fontForSize:12.0f] :
            [UIFont fontForTextStyle:UIFontTextStyleCaption1]);
}

+ (UIFont *)wdprFontStyleC3
{
    return (!UIFont.dynamicText ? [UIFont fontForSize:10.0f] :
            [UIFont fontForTextStyle:UIFontTextStyleCaption1]);
}

+ (UIFont *)wdprFontStyleB1
{
    return (!UIFont.dynamicText ? [UIFont emphasisFontForSize:16.0f] :
            [UIFont emphasisFontForTextStyle:UIFontTextStyleBody]);
}

+ (UIFont *)wdprFontStyleB2
{
    return (!UIFont.dynamicText ? [UIFont fontForSize:16.0f] :
            [UIFont fontForTextStyle:UIFontTextStyleBody]);
}

+ (UIFont *)wdprFontStyleH1
{
    return [UIFont boldEmphasisFontForSize:24.0f];
}

+ (UIFont *)wdprFontStyleH1H
{
    return [UIFont emphasisFontForSize:24.0f];
}

+ (UIFont *)wdprFontStyleH1R
{
    return [UIFont fontForSize:24.0f];
}

+ (UIFont *)wdprFontStyleH2
{
    return [UIFont boldEmphasisFontForSize:20.0f];
}

+ (UIFont *)wdprFontStyleH3
{
    return [UIFont emphasisFontForSize:20.0f];
}

+ (UIFont *)wdprFontStyleH4
{
    return [UIFont fontForSize:20.0f];
}

+ (UIFont *)wdprFontStyleH1RDL
{
    return [UIFont fontForSize:32.0f];
}

+ (UIFont *)wdprFontStyleS1
{
    return [UIFont boldEmphasisFontForSize:20.0f];
}

+ (UIFont *)wdprFontStyleS2
{
    return [UIFont emphasisFontForSize:20.0f];
}

+ (UIFont *)wdprFontStyleS3
{
    return [UIFont fontForSize:20.0f];
}

+ (UIFont *)wdprStandardButtonFont
{
    return [UIFont wdprFontStyleB1];
}

+ (UIFont *)wdprStandardButtonFontWithCustomSize:(CGFloat)fontSize {
    return [UIFont emphasisFontForSize:fontSize];
}

- (CGFloat)capAscender
{
    return fabs(self.capHeight - self.ascender);
}

NS_ASSUME_NONNULL_END

@end
