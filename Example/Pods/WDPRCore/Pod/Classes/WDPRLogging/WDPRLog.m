//
//  WDPRLog.m
//  WDPR
//
//  Created by Pierce, Owen on 10/23/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import <CocoaLumberjack/CocoaLumberjack.h>
#import "WDPRLog.h"

const WDPRLogType kWDPRLogTypeError = DDLogLevelError;
const WDPRLogType kWDPRLogTypeWarning = DDLogLevelWarning;
const WDPRLogType kWDPRLogTypeInfo = DDLogLevelInfo;
const WDPRLogType kWDPRLogTypeDebug = DDLogLevelDebug;
const WDPRLogType kWDPRLogTypeVerbose = DDLogLevelAll;

#ifdef DEBUG
NSUInteger const ddLogLevel = kWDPRLogTypeVerbose;
#else
NSUInteger const ddLogLevel = kWDPRLogTypeWarning;
#endif

@implementation WDPRLog

+ (void)configureLogging
{
    [DDLog addLogger:[DDASLLogger sharedInstance]];
    [DDLog addLogger:[DDTTYLogger sharedInstance]];

    [WDPRLog enableFileLogging];
}

+ (void)enableFileLogging
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *baseDir = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;

    NSString *documentsPath = baseDir;

    DDFileLogger *fileLogger = [[DDFileLogger alloc] initWithLogFileManager:[[DDLogFileManagerDefault alloc] initWithLogsDirectory:documentsPath]];
    fileLogger.rollingFrequency = 60 * 60 * 24; // 24 hour rolling
    fileLogger.logFileManager.maximumNumberOfLogFiles = 7;

    [DDLog addLogger:fileLogger];
}

+ (void)logMessage:(NSString *)format, ...
{
    va_list argumentList;
    va_start(argumentList, format);
    [self logMessage:format withParameters:argumentList];
    va_end(argumentList);
}

+ (void) logMessage:(NSString *)format withParameters:(va_list)valist
{
    NSString *message = [[NSString alloc] initWithFormat:format arguments:valist];
    DDLogInfo(@"%@",message);
}

+ (void)logFailure:(NSString *)format, ...
{
    va_list argumentList;
    va_start(argumentList, format);
    [self logFailure:format withParameters:argumentList];
    va_end(argumentList);
}

+ (void) logFailure:(NSString *)format withParameters:(va_list)valist
{
    NSString *message = [[NSString alloc] initWithFormat:format arguments:valist];
    DDLogError(@"%@",message);

    assert(false);
}

+ (void)logError:(NSString *)format, ...
{
    va_list argumentList;
    va_start(argumentList, format);
    [self logError:format withParameters:argumentList];
    va_end(argumentList);
}

+ (void) logError:(NSString *)format withParameters:(va_list)valist
{
    NSString *message = [[NSString alloc] initWithFormat:format arguments:valist];
    DDLogError(@"%@",message);
}

+ (void)logWarning:(NSString *)format, ...
{
    va_list argumentList;
    va_start(argumentList, format);
    [self logWarning:format withParameters:argumentList];
    va_end(argumentList);
}

+ (void) logWarning:(NSString *)format withParameters:(va_list)valist
{
    NSString *message = [[NSString alloc] initWithFormat:format arguments:valist];
    DDLogWarn(@"%@",message);
}

+ (void)logDebug:(NSString *)format, ...
{
    va_list argumentList;
    va_start(argumentList, format);
    [self logDebug:format withParameters:argumentList];
    va_end(argumentList);
}

+ (void) logDebug:(NSString *)format withParameters:(va_list)valist
{
    NSString *message = [[NSString alloc] initWithFormat:format arguments:valist];
    DDLogDebug(@"%@",message);
}

@end
