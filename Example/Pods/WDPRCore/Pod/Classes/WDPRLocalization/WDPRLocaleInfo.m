//
//  WDPRLocaleInfo.m
//  Pods
//
//  Created by Ignacio Zunino on 8/13/15.
//
//

#import "WDPRLocaleInfo.h"

@implementation WDPRLocaleInfo

- (instancetype)initWithLanguage:(NSString *)language region:(NSString *)region localeIdentifier:(NSString *)localeIdentifier
{
    return [self initWithLanguage:language region:region localeIdentifier:localeIdentifier localizedSorter:nil];
}

- (instancetype)initWithLanguage:(NSString *)language region:(NSString *)region localeIdentifier:(NSString *)localeIdentifier localizedSorter:(NSString *)localizedSorter
{
    return [self initWithLanguage:language region:region localeIdentifier:localeIdentifier localizedSorter:localeIdentifier localizedFonts:nil];
}

- (instancetype)initWithLanguage:(NSString *)language
                          region:(NSString *)region
                localeIdentifier:(NSString *)localeIdentifier
                 localizedSorter:(NSString *)localizedSorter
                  localizedFonts:(NSDictionary *)localizedFonts
{
    return [self initWithLanguage:language region:region localeIdentifier:localeIdentifier localizedSorter:localeIdentifier localizedFonts:localizedFonts pushNotificationList:nil];
}

- (instancetype)initWithLanguage:(NSString *)language
                          region:(NSString *)region
                localeIdentifier:(NSString *)localeIdentifier
                 localizedSorter:(NSString *)localizedSorter
                  localizedFonts:(NSDictionary *)localizedFonts
          pushNotificationList:(NSString *)pushNotificationList
{
    self = [super init];
    
    if (self)
    {
        _language = language;
        _region = region;
        _localeIdentifier = localeIdentifier;
        _localizedSorter = localizedSorter;
        _localizedFonts = localizedFonts;
        _pushNotificationList = pushNotificationList;
    }
    
    return self;
}

@end
