//
//  WDPRFontSizing.m
//  Pods
//
//  Created by Marcos Garcia on 8/26/16.
//
//

#import "WDPRFontSizing.h"
#import "WDPRUIKit.h"

static NSString * const kWDPRFontSizing      = @"WDPRFontSizing";
static NSString * const kWDPRCTAButtons      = @"WDPRCTAButtons";
static NSString * const kWDPRHeaders         = @"WDPRHeaders";
static NSString * const kWDPRDashboardFooter = @"WDPRDashboardFooter";

@interface WDPRFontSizing ()

@property (nonatomic) WDPRFontSizingElement element;
@property (nonatomic) CGFloat defaultFontSize;

@end

@implementation WDPRFontSizing

#pragma mark - Initializer

- (nonnull instancetype)initWithDefaultFontSize:(CGFloat)defaultFontSize forElement:(WDPRFontSizingElement)element;
{
    if (self = [super init])
    {
        self.defaultFontSize = defaultFontSize;
        self.element = element;
    }
    
    return self;
}

- (NSNumber *)supportedSizeWithLanguage:(NSString *)language
{
    NSString *key;
    
    switch (self.element)
    {
        case WDPRCTAButtons:
            key = [NSString stringWithFormat:@"%@", kWDPRCTAButtons];
            break;
            
        case WDPRHeaders:
            key = [NSString stringWithFormat:@"%@", kWDPRHeaders];
            break;
            
        case WDPRDashboardFooter:
            key = [NSString stringWithFormat:@"%@", kWDPRDashboardFooter];
            break;
            
        default:
            return nil;
    }
    
    NSDictionary *fontSizing = [NSDictionary dictionaryFromPList:kWDPRFontSizing];
    
    return fontSizing[key][language];
}

#pragma mark - Font Sizing Methods
//TODO: "preferredFontSize" should probably reach into the user's accessibility settings for font size.
- (CGFloat)preferredFontSize
{
    WDPRLocaleInfo *localeInfo = [WDPRLocalization localeInfoWithPreferredLanguages:[NSLocale preferredLanguages]];
    NSNumber *supportedSize = [self supportedSizeWithLanguage:localeInfo.language];
    
    if (supportedSize)
    {
        return [supportedSize floatValue];
    }
    return self.defaultFontSize;
}

@end
