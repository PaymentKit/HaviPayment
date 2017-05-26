//
//  WDPRLocaleInfo.h
//  Pods
//
//  Created by Ignacio Zunino on 8/13/15.
//
//

#import <Foundation/Foundation.h>

@interface WDPRLocaleInfo : NSObject

@property(nonatomic, copy) NSString *localeIdentifier;
@property(nonatomic, copy) NSString *language;
@property(nonatomic, copy) NSString *region;
@property(nonatomic, copy) NSString *localizedSorter;
@property(nonatomic, copy) NSDictionary *localizedFonts;
@property(nonatomic, copy) NSString *pushNotificationList;

///create a locale info with a default language, region, and localeIdentifier
- (instancetype)initWithLanguage:(NSString *)language
                          region:(NSString *)region
                localeIdentifier:(NSString *)localeIdentifier;


///create a locale info with a default language, region, localeIdentifier, and localizedSorter
- (instancetype)initWithLanguage:(NSString *)language
                          region:(NSString *)region
                localeIdentifier:(NSString *)localeIdentifier
                 localizedSorter:(NSString *)localizedSorter;

///create a locale info with a default language, region, localeIdentifier, localizedSorter and localizedFonts
- (instancetype)initWithLanguage:(NSString *)language
                          region:(NSString *)region
                localeIdentifier:(NSString *)localeIdentifier
                 localizedSorter:(NSString *)localizedSorter
                  localizedFonts:(NSDictionary *)localizedFonts;

///create a locale info with a default language, region, localeIdentifier, localizedSorter, localizedFonts and pushNotificationList
- (instancetype)initWithLanguage:(NSString *)language
                          region:(NSString *)region
                localeIdentifier:(NSString *)localeIdentifier
                 localizedSorter:(NSString *)localizedSorter
                  localizedFonts:(NSDictionary *)localizedFonts
          pushNotificationList:(NSString *)pushNotificationList;

@end
