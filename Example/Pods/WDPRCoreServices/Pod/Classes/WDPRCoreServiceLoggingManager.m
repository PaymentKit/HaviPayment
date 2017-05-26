//
// Created by Clark, Daniel on 6/25/15.
//

#import "WDPRCoreServiceLoggingManager.h"

WDPRLogType _libraryLoggingLevel;

@implementation WDPRCoreServiceLoggingManager

+ (void) initialize
{
    // Default is all logs
    _libraryLoggingLevel = kWDPRLogTypeInfo;
}

+ (WDPRLogType) libraryLoggingLevel
{
    return _libraryLoggingLevel;
}

+ (void) setLibraryLoggingLevel:(WDPRLogType)newLevel
{
    _libraryLoggingLevel = newLevel;
}

+ (void) logMessage:(NSString *)format, ...
{
    if(_libraryLoggingLevel >= kWDPRLogTypeInfo)
    {
        va_list argumentList;
        va_start(argumentList, format);
        [WDPRLog logMessage:format withParameters:argumentList];
        va_end(argumentList);
    }
}

+ (void) logFailure:(NSString *)format, ...
{
    if(_libraryLoggingLevel >= kWDPRLogTypeError)
    {
        va_list argumentList;
        va_start(argumentList, format);
        [WDPRLog logMessage:format withParameters:argumentList];
        va_end(argumentList);
    }
}

+ (void) logError:(NSString *)format, ...
{
    if(_libraryLoggingLevel >= kWDPRLogTypeError)
    {
        va_list argumentList;
        va_start(argumentList, format);
        [WDPRLog logMessage:format withParameters:argumentList];
        va_end(argumentList);
    }
}

+ (void) logWarning:(NSString *)format, ...
{
    if(_libraryLoggingLevel >= kWDPRLogTypeWarning)
    {
        va_list argumentList;
        va_start(argumentList, format);
        [WDPRLog logMessage:format withParameters:argumentList];
        va_end(argumentList);
    }
}

+ (void) logDebug:(NSString *)format, ...
{
    if(_libraryLoggingLevel >= kWDPRLogTypeDebug)
    {
        va_list argumentList;
        va_start(argumentList, format);
        [WDPRLog logMessage:format withParameters:argumentList];
        va_end(argumentList);
    }
}

@end