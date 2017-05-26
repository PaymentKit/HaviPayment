//
//  WDPRLog.h
//  WDPR
//
//  Created by Pierce, Owen on 10/23/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NSUInteger WDPRLogType;

extern const WDPRLogType kWDPRLogTypeError;
extern const WDPRLogType kWDPRLogTypeWarning;
extern const WDPRLogType kWDPRLogTypeInfo;
extern const WDPRLogType kWDPRLogTypeDebug;
extern const WDPRLogType kWDPRLogTypeVerbose;

@interface WDPRLog : NSObject

+ (void)configureLogging;

+ (void)logMessage:(NSString *)format, ...;
+ (void)logFailure:(NSString *)format, ...;
+ (void)logError:(NSString *)format, ...;
+ (void)logWarning:(NSString *)format, ...;
+ (void)logDebug:(NSString *)format, ...;


+ (void)logMessage:(NSString *)format withParameters:(va_list)valist;
+ (void)logFailure:(NSString *)format withParameters:(va_list)valist;
+ (void)logError:(NSString *)format withParameters:(va_list)valist;
+ (void)logWarning:(NSString *)format withParameters:(va_list)valist;
+ (void)logDebug:(NSString *)format withParameters:(va_list)valist;
@end

#define WDPRLog(fmt, ...) [WDPRLog logMessage:@"%s [Line %d] " fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__]

#define WDPRLogDebug(fmt, ...) [WDPRLog logDebug:@"%s [Line %d] " fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__]
#define WDPRLogError(fmt, ...) [WDPRLog logError:@"%s [Line %d] " fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__]
#define WDPRLogFailure(fmt, ...) [WDPRLog logFailure:@"%s [Line %d] " fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__]
#define WDPRLogWarning(fmt, ...) [WDPRLog logWarning:@"%s [Line %d] " fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__]

