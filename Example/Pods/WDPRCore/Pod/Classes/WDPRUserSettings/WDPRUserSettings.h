//
//  WDPRUserSettings.h
//  WDPRFinderCore
//
//  Created by Hart, Nick on 6/23/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol WDPRUserSettingsProtocol;

@interface WDPRUserSettings : NSObject

/**
 Class method to access the shared instance for accessing user settings.
 @return an instance of WDPRUserSettings for accessing user settings.
 */
+ (id<WDPRUserSettingsProtocol>)userSettings;

/**
 Class method to configure the shared instance for accessing user settings.
 This method can only be called once.  The system is not designed to change between user settings at runtime. 
 @param userSettings the instance of WDPRUserSettings to use for accessing user settings.
 */
+ (void)configureUserSettings:(id<WDPRUserSettingsProtocol>)userSettings;

@end

/**
 A protocol which contains the NSUserDefaults methods that we support.
 */
@protocol WDPRUserSettingsProtocol <NSObject>

- (id)objectForKey:(NSString *)key;
- (void)setObject:(id)value forKey:(NSString *)key;
- (void)removeObjectForKey:(NSString *)key;
- (NSString *)stringForKey:(NSString *)key;
- (NSArray *)arrayForKey:(NSString *)key;
- (NSDictionary *)dictionaryForKey:(NSString *)key;
- (NSData *)dataForKey:(NSString *)key;
- (NSArray *)stringArrayForKey:(NSString *)key;
- (NSInteger)integerForKey:(NSString *)key;
- (float)floatForKey:(NSString *)key;
- (double)doubleForKey:(NSString *)key;
- (BOOL)boolForKey:(NSString *)key;
- (void)setInteger:(NSInteger)value forKey:(NSString *)key;
- (void)setFloat:(float)value forKey:(NSString *)key;
- (void)setDouble:(double)value forKey:(NSString *)key;
- (void)setBool:(BOOL)value forKey:(NSString *)key;
- (void)registerDefaults:(NSDictionary *)registrationDictionary;
- (BOOL)synchronize;

@end
