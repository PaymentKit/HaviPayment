//
// Created by Clark, Daniel on 6/25/15.
//

#import <Foundation/Foundation.h>

#import <WDPRCore/WDPRLog.h>

@interface WDPRCoreServiceLoggingManager : NSObject

+ (WDPRLogType) libraryLoggingLevel;
+ (void) setLibraryLoggingLevel:(WDPRLogType)newLevel;

+ (void)logMessage:(NSString *)format, ...;
+ (void)logFailure:(NSString *)format, ...;
+ (void)logError:(NSString *)format, ...;
+ (void)logWarning:(NSString *)format, ...;
+ (void)logDebug:(NSString *)format, ...;

#define WDPRCoreServicesLog(fmt, ...) [WDPRCoreServiceLoggingManager logMessage:@"%s [Line %d] " fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__]

#define WDPRCoreServicesLogDebug(fmt, ...) [WDPRCoreServiceLoggingManager logDebug:@"%s [Line %d] " fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__]
#define WDPRCoreServicesLogError(fmt, ...) [WDPRCoreServiceLoggingManager logError:@"%s [Line %d] " fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__]
#define WDPRCoreServicesLogFailure(fmt, ...) [WDPRCoreServiceLoggingManager logFailure:@"%s [Line %d] " fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__]
#define WDPRCoreServicesLogWarning(fmt, ...) [WDPRCoreServiceLoggingManager logWarning:@"%s [Line %d] " fmt, __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__]

@end
