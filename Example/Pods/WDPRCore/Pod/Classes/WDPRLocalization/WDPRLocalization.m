//
//  WDPRLocalization.m
//  DLR
//
//  created by Ignacio Zunino on 5/18/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRLocalization.h"
#import "NSBundle+WDPR.h"
#import "NSDateFormatter+WDPR.h"
#import "NSDictionary+WDPR.h"
#import "WDPRSharedConstants.h"
#import "WDPRMacros.h"
#import "WDPRLocaleInfo.h"
#import "WDPRFoundation.h"

@implementation WDPRLocalization

static NSString* const kWDPRCoreBundle = @"WDPRCore";
static NSString* const kDefaultTableName = @"Localizable";
static NSString* const kLocaleConfiguration = @"WDPRLocalization";
static NSString* const kSupportedLocalesKey = @"supportedLocales";
static NSString* const kLocalizationBundleExtension = @"lproj";
static NSString* const kDefaultLanguageCode = @"Base";
static NSString* const kDefaultLocaleKey = @"defaultLocale";
static NSString* const kDefaultRegionKey = @"defaultRegion";
static NSString* const kSupportedRegionsKey = @"supportedRegions";
static NSString* const kLanguageKey = @"language";
static NSString* const kLanguagePrefixKey = @"languagePrefix";
static NSString* const kRegionKey = @"region";
static NSString* const kLocaleIdentifierKey = @"localeIdentifier";
static NSString* const klocalizedSorterKey = @"localizedSorter";
static NSString* const klocalizedFonts = @"localizedFonts";
static NSString* const kPushNotificationList = @"pushNotificationList";


typedef BOOL (^MatchBlock)(NSString *s1, NSString *s2);

+(NSString *)languageIdentifierFromSupportedLanguages:(NSArray *)supportedLanguages
                                     defaultLanguage:(NSString *)defaultLanguage
{
    static NSString *languageIdentifier;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (supportedLanguages)
        {
            [[NSLocale preferredLanguages] enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
             {
                if ([supportedLanguages containsObject:obj])
                {
                    languageIdentifier = obj;
                    *stop = YES;
                }
            }];

            if (!languageIdentifier)
            {
                languageIdentifier = defaultLanguage;
            }
        }
        NSAssert(languageIdentifier, @"should not be nil--check to make sure destinations.plist contains 'supportedLanguages' and 'defaultLanguage'");
    });
    return languageIdentifier;
}


+(NSString *)currentCountryCode
{
    return [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
}

+(NSString *)currentRegionFromSupportedRegions:(NSArray *)supportedRegions
                                defaultRegion:(NSString *)defaultRegion
{
    static NSString *region;

    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        if (supportedRegions)
        {
            NSString *countryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];

            if ([supportedRegions containsObject:countryCode])
            {
                region = countryCode;
            }
            else
            {
                region = defaultRegion;
            }
        }
        NSAssert(region, @"should not be nil--check to make sure destinations.plist contains 'supportedRegions' and 'defaultRegion'");
    });
    return region;
}

+(NSString *)currentLocale
{
    return [[NSLocale currentLocale] objectForKey:NSLocaleIdentifier];
}

+ (BOOL)is24HourFormat
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterNoStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    formatter.locale = [NSLocale currentLocale];
    NSString *dateString = [formatter stringFromDate:[NSDate date]];
    NSRange amRange = [dateString rangeOfString:[formatter AMSymbol]];
    NSRange pmRange = [dateString rangeOfString:[formatter PMSymbol]];
    BOOL is24Hour = amRange.location == NSNotFound && pmRange.location == NSNotFound;
    return is24Hour;
}

+ (WDPRLocaleInfo *)findMatch:(NSDictionary *)supportedLocale deviceLocale:(NSString *)preferredLanguage compareBlock:(MatchBlock) match compareString:(NSString *)stringToCompare
{
    NSString *currentCountryCode = [[NSLocale currentLocale] objectForKey:NSLocaleCountryCode];
    NSString* language = supportedLocale[kLanguageKey];
    NSArray* supportedRegions = supportedLocale[kSupportedRegionsKey];
    NSString* localeIdentifier = supportedLocale[kLocaleIdentifierKey];
    NSString* localizedSorter = supportedLocale[klocalizedSorterKey];
    NSDictionary* localizedFonts = supportedLocale[klocalizedFonts];
    NSString *localizedNotificationList = supportedLocale[kPushNotificationList];
    if (match(preferredLanguage, stringToCompare))
    {
        for (NSString *region in supportedRegions)
        {
            if ([currentCountryCode isEqualToString:region])
            {
                return [[WDPRLocaleInfo alloc] initWithLanguage:language region:region localeIdentifier:localeIdentifier localizedSorter:localizedSorter localizedFonts:localizedFonts pushNotificationList:localizedNotificationList];
            }
        }
        NSString *defaultRegion = supportedLocale[kDefaultRegionKey];
        return [[WDPRLocaleInfo alloc] initWithLanguage:language region:defaultRegion localeIdentifier:localeIdentifier localizedSorter:localizedSorter localizedFonts:localizedFonts pushNotificationList:localizedNotificationList];
    }
    
    return nil;
}

+ (WDPRLocaleInfo *)localeInfoWithPreferredLanguages:(NSArray *)preferredLanguages
{
    WDPRLocaleInfo *localeInfo;
    
    static NSArray *supportedLocales;
    static WDPRLocaleInfo *defaultLocaleInfo;
    static dispatch_once_t onceToken;

    dispatch_once(&onceToken, ^{
        NSDictionary *localesConfig = [WDPRLocalization localesConfig];
        supportedLocales = localesConfig[kSupportedLocalesKey];
        NSDictionary *defaultLocale = localesConfig[kDefaultLocaleKey];
        defaultLocaleInfo = [[WDPRLocaleInfo alloc] initWithLanguage:defaultLocale[kLanguageKey] region:defaultLocale[kRegionKey] localeIdentifier:defaultLocale[kLocaleIdentifierKey] localizedSorter:defaultLocale[klocalizedSorterKey] localizedFonts:defaultLocale[klocalizedFonts] pushNotificationList:defaultLocale[kPushNotificationList]];
    });
    
    for (NSString *preferredLanguage in preferredLanguages)
    {
        //first try with an exact match of the preferred language:
        MatchBlock equalMatchBlock = ^(NSString * s1, NSString *s2)
        {
            return [s1 isEqualToString:s2];
        };
        
        for (NSDictionary *locale in supportedLocales)
        {
            NSString* language = locale[kLanguageKey];
            localeInfo = [self findMatch:locale deviceLocale:preferredLanguage compareBlock:equalMatchBlock compareString:language];
            
            if (localeInfo)
            {
                return localeInfo;
            }
        }
        
        //if no exact match, try with a prefix match of the preferred language:
        MatchBlock prefixMatchBlock = ^(NSString * s1, NSString *s2)
        {
            return (BOOL)([s1 rangeOfString:s2].location != NSNotFound);
        };
        
        for (NSDictionary *locale in supportedLocales)
        {
            NSString* prefix = locale[kLanguagePrefixKey];
            localeInfo = [self findMatch:locale deviceLocale:preferredLanguage compareBlock:prefixMatchBlock compareString:prefix];
            
            if (localeInfo)
            {
                return localeInfo;
            }
        }
    }
    
    return defaultLocaleInfo;
}

+ (WDPRLocaleInfo *)localeInfo
{
    static WDPRLocaleInfo *localeInfo;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        localeInfo = [self localeInfoWithPreferredLanguages:[NSLocale preferredLanguages]];
    });
    
    return localeInfo;
}

+ (NSString *)localizedStringForKey:(NSString *)key
{
    return [self localizedStringByBundlePriorityForKey:key fromTableName:nil inBundle:nil];
}

+ (NSString *)localizedStringForKey:(NSString *)key fromTableName:(NSString *)tableName inBundle:(NSString *)bundle
{
    return [self localizedStringForKey:key fromTableName:tableName inBundleNamed:bundle];
}

+ (NSString *)localizedStringForKey:(NSString *)key fromTableName:(NSString *)tableName inBundleNamed:(NSString *)bundleName
{
    NSBundle *bundle = [NSBundle bundleFromMainBundleOrFramework:bundleName bundleName:bundleName];
    if (!bundle)
    {
        bundle = [NSBundle mainBundleOrFrameworkBundle:bundleName];
    }
    return [self localizedStringByBundlePriorityForKey:key fromTableName:tableName inBundle:bundle];
}

+ (NSString *)localizedStringForKey:(NSString *)key fromTableName:(NSString *)tableName inLocalizationBundle:(NSBundle *)localizationBundle
{
    return [self localizedStringByBundlePriorityForKey:key fromTableName:tableName inBundle:localizationBundle];
}

+ (NSString *)localizedStringByBundlePriorityForKey:(NSString *)key fromTableName:(NSString *)tableName inBundle:(NSBundle *)bundle
{
    NSString *result = @"";
    
    //First check Main Bundle for override
    result = [self localizedStringByLocaleBundleResourcesforKey:key fromTableName:kDefaultTableName inBundle:[NSBundle mainBundle]];

    //No override, checking passed in bundle.
    if (!result || [key isEqualToString:result])
    {
        //Check if bundle is not nil and that the bundle is not the Main Bundle either
        // then try to fetch value from the bundle and table
        if (bundle && ![bundle isEqual:[NSBundle mainBundle]])
        {
            if (tableName && ![@"" isEqualToString:tableName])
            {
                result = [self localizedStringByLocaleBundleResourcesforKey:key fromTableName:tableName inBundle:bundle];
            }
            else //if (!tableName || [@"" isEqualToString:tableName]) // (inverse of above per DeMorgan's Law)
            {
                result = [self localizedStringByLocaleBundleResourcesforKey:key fromTableName:kDefaultTableName inBundle:bundle];
            }
        }
    }
    
    return result;
}

+ (NSString *)localizedStringByLocaleBundleResourcesforKey:(NSString *)key fromTableName:(NSString *)tableName inBundle:(NSBundle *)bundle
{
    NSBundle *languageBundle = nil;
    NSString *localizedString = key;

    WDPRLocaleInfo *localInfo =  [WDPRLocalization localeInfo];

    // Look for the localization bundle in the passed in bundle
    if (localInfo && localInfo.localeIdentifier)
    {
        NSString *path = [bundle pathForResource: localInfo.localeIdentifier ofType:kLocalizationBundleExtension];
        languageBundle = [NSBundle bundleWithPath:path];
        localizedString = NSLocalizedStringFromTableInBundle(key, tableName, languageBundle, nil);
    }

    // Look in the mainBundle for the Base language bundle
    if (!localizedString || [@"" isEqualToString:localizedString] || [key isEqualToString:localizedString])
    {
        languageBundle = [NSBundle bundleWithPath:[bundle pathForResource:kDefaultLanguageCode ofType:kLocalizationBundleExtension]];
        localizedString = NSLocalizedStringFromTableInBundle(key, tableName, languageBundle, nil);
    }

    // Finally look in the passed in bundle itself -- This would be unusual, but possible see WDPRMemoryMaker 1.0.4
    if (!localizedString || [@"" isEqualToString:localizedString] || [key isEqualToString:localizedString])
    {
        localizedString = NSLocalizedStringFromTableInBundle(key, tableName, bundle, nil);
    }

    //Add extra validation to avoid returning nil. In some cases NSLocalizedString returns nil value
    if (!localizedString)
    {
        localizedString = key;
    }

    return localizedString;
}

+ (NSArray *)supportedLanguageIds
{
    NSDictionary *localesConfig = [WDPRLocalization localesConfig];
    NSArray *languageIds = [localesConfig valueForKeyPath:[NSString stringWithFormat:@"%@.%@", kSupportedLocalesKey, kLanguageKey]];
    NSParameterAssert([languageIds isKindOfClass:[NSArray class]]);
    return languageIds;
}

#pragma mark - private methods

+ (NSDictionary *)localesConfig
{
    return [NSDictionary dictionaryFromPList:kLocaleConfiguration inBundle:[WDPRFoundation wdprCoreResourceBundle]];
}

@end
