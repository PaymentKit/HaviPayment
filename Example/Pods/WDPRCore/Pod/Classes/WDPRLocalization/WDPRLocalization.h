//
//  WDPRLocalization.h
//  DLR
//
//  created by Ignacio Zunino on 5/18/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDPRLocaleInfo.h"

@interface WDPRLocalization : NSObject

/*
 *it looks if the key is present in the main bundle localizable files.
  if it doesn’t find a match then returns the received string.
*/
#define WDPRLocalizedString(key, comment) \
[WDPRLocalization localizedStringForKey:(key)]

/*
 *it looks for the key in the specified bundle. The default table name to use is "Localizable"
 if there isn’t a match, returns the received string.
 */
#define WDPRLocalizedStringInBundle(key, bundle, comment) \
[WDPRLocalization localizedStringForKey:(key) fromTableName:nil inBundleNamed:(bundle)]

/*
 *it looks for the key and tries to find it by looking up the specified bundle by name and table.
  if there isn’t a match, returns the received string.
 */
#define WDPRLocalizedStringFromTableInBundle(key, table, bundle, comment) \
[WDPRLocalization localizedStringForKey:(key) fromTableName:(table) inBundleNamed:(bundle)]

/*
 *it looks for the key in the specified bundle and table.
  if there isn’t a match, returns the received string.
 */
#define WDPRLocalizedStringFromTableInLocalizationBundle(key, table, bundle, comment) \
[WDPRLocalization localizedStringForKey:(key) fromTableName:(table) inLocalizationBundle:(bundle)]

/**
language used by the use. i.e en, gb
 
@deprecated This method has been deprecated. Use +localeInfoWithPreferredLanguages: instead.
*/
+(NSString*)languageIdentifierFromSupportedLanguages:(NSArray *)supportedLanguages
                                     defaultLanguage:(NSString *)defaultLanguage DEPRECATED_ATTRIBUTE;

///default country code. i.e: us, es
+(NSString*)currentCountryCode;

/**
current region, or default region if not available
 
@deprecated This method has been deprecated. Use +localeInfoWithPreferredLanguages: instead.
 */
+(NSString*)currentRegionFromSupportedRegions:(NSArray *)supportedRegions
                                defaultRegion:(NSString *)defaultRegion DEPRECATED_ATTRIBUTE;

///current locale
+(NSString*)currentLocale;

//returns YES if the current time format in the device is 24hours
+ (BOOL)is24HourFormat;

///returns the language and region associated to the current device and using the supported values
+ (WDPRLocaleInfo *)localeInfoWithPreferredLanguages:(NSArray *)preferredLanguages;

+ (WDPRLocaleInfo *)localeInfo;

//Localization methods

/*! it looks if the key is present in the main bundle localizable files, If it doesn’t find a match then returns the received string.
 * \param key The key to search
 * \returns The localized string
 */
+ (NSString *)localizedStringForKey:(NSString *)key;

/*! it looks for the key and tries to find it by looking up the specified bundle by name and table, after that if there isn’t a match, returns the received string.
 * \param key The key to search
 * \param bundle Bundle and framework's name where it is going to search
 * \param tableName The name of the string file
 * \returns The localized string
 */
+ (NSString *)localizedStringForKey:(NSString *)key fromTableName:(NSString *)tableName inBundle:(NSString *)bundle;

/*! it looks for the key and tries to find it by looking up the specified bundle by name and table, after that if there isn’t a match, returns the received string.
 * \param key The key to search
 * \param bundleName Name of the Bundle and framework's name where it is going to search
 * \param tableName The name of the string file
 * \returns The localized string
 */
+ (NSString *)localizedStringForKey:(NSString *)key fromTableName:(NSString *)tableName inBundleNamed:(NSString *)bundleName;

/*! it looks for the key in the specified bundle and table, after that if there isn’t a match, returns the received string.
 * \param key The key to search
 * \param localizationBundle Bundle and framework's name where it is going to search
 * \param tableName The name of the string file
 * \returns The localized string
 */
+ (NSString *)localizedStringForKey:(NSString *)key fromTableName:(NSString *)tableName inLocalizationBundle:(NSBundle *)localizationBundle;

/**
 Return all languages supported by this app.
 @return an NSArray containing NSStrings listing the supported language ids (eg: @[ @"en-GB", @"fr" ] )
 */
+ (NSArray *)supportedLanguageIds;

@end
