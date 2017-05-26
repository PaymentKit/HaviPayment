//
//  NSDictionary+WDPR.h
//  WDPR
//
//  Created by Rodden, James on 8/6/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (WDPR)

/*
 This method will first check the Data.bundle for this plist first, if this exists will merge in
 the plist from the main bundle.
 @return A dictionary merged from two potential dictionaries or nil if no plist is found.
 */
+ (NSDictionary*)dictionaryFromPList:(NSString*)file;

/*
 This method will return a merge of an external plist and a plist contained within Data.bundle.
 This method will first make a copy of the plist that is contained within the specified bundle.
 The bundle is found by looking in the mainBundle.
 If the Data.bundle contains an existing key within the plist, the corresponding value will be
 overwritten.
 @return A dictionary merged from three potential dictionaries or nil if no plist is found.
 */
+ (NSDictionary*)dictionaryFromPList:(NSString *)file inBundleNamed:(NSString*)bundleName;

/*
 This method will return a merge of an external plist and a plist contained within Data.bundle.
 This method will first make a copy of the plist that is contained within the specified bundle.
 If the Data.bundle contains an existing key within the plist, the corresponding value will be
 overwritten.
 @return A dictionary merged from three potential dictionaries or nil if no plist is found.
 */
+ (NSDictionary*)dictionaryFromPList:(NSString *)file inBundle:(NSBundle *)bundle;

/*
 This method will return a merge of an external plist and a plist contained within Data.bundle.
 This method will first make a copy of the plist that is contained within the specified bundle.
 If the Data.bundle contains an existing key within the plist, the corresponding value will be
 overwritten.
 If allowsNewKeys is YES, new keys and values from the Data.bundle will be added.
 @return A dictionary merged from three potential dictionaries or nil if no plist is found.
 */
+ (NSDictionary*)dictionaryFromPList:(NSString *)file inBundle:(NSBundle *)bundle allowNewKeys:(BOOL)allowNewKeys;

/**
 *
 */
+ (NSDictionary*)transform:(NSDictionary*)dictionary withMappingPlist:(NSString*)file;

/**
 *
 */
+ (NSDictionary*)transform:(NSDictionary*)dictionary withMappingDictionary:(NSDictionary*)mapping;

/// Transforms a NSDictionary into a NSString in JSON format.
- (NSString*)jsonStringWithPrettyPrint:(BOOL)prettyPrint;

/**
 * Returns the resulting NSDictionary from reading the JSON file at @path
 * @return nil on failure
 */
+ (NSDictionary *)readDictionaryFromJSONFile:(NSString *)path;

/*
 Writes the NSDictionary content into a JSON file at @path
 */
- (void)writeDictionaryToJSONFile:(NSString *)path;

@end
