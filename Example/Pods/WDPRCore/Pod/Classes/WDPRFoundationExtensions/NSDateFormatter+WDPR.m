//
//  NSDateFormatter+WDPR.m
//  WDPR
//
//  Created by Carlos Matias Tripode on 7/2/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import "WDPRFoundation.h"
#import "WDPRLocalization.h"

@implementation NSDateFormatter (WDPR)

#define WDPRFormatterDictionaryKey @"WDPRFormatterDictionaryKey"

#pragma mark - Caching

+ (void)setupLowMemoryObserverForName:(NSString *)lowMemoryNotificationName
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:lowMemoryNotificationName
                                                  object:nil];
    [[NSNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(lowMemory:)
                   name:lowMemoryNotificationName
                 object:nil]; //UIApplicationDidReceiveMemoryWarningNotification
}

+ (void)lowMemory:(NSNotification*)notification
{
    @synchronized(self)
    {
        NSMutableDictionary *cachedFormatters =
        [self currentThreadFormatterDictionary];

        if (cachedFormatters)
        {
            [cachedFormatters removeAllObjects];
        }
    }
}

+ (NSDateFormatter*)systemFormatterWithFormat:(NSString *)format
{
    NSTimeZone *timeZone = [NSTimeZone GMTTimeZone];
    return [self systemFormatterWithFormat:format timeZone:timeZone];
}

+ (NSDateFormatter*)systemFormatterWithFormat:(NSString*)format timeZone:(NSTimeZone*)timeZone
{
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    return [self sharedFormatterWithFormat:format locale:locale timezone:timeZone];
}

+ (NSDateFormatter*)userFormatterWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle
{
    NSTimeZone *timeZone = [NSTimeZone localTimeZone];
    return [self userFormatterWithDateStyle:dateStyle timeStyle:timeStyle timeZone:timeZone];
}

+ (NSDateFormatter*)userFormatterWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle timeZone:(NSTimeZone*)timeZone
{
    WDPRLocaleInfo *localeInfo = [WDPRLocalization localeInfoWithPreferredLanguages:[NSLocale preferredLanguages]];
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:localeInfo.language];
    return [self sharedFormatterWithDateStyle:dateStyle timeStyle:timeStyle locale:locale timezone:timeZone];
}

+ (NSDateFormatter*)userFormatterWithDateStyle:(NSDateFormatterStyle)dateStyle timeZone:(NSTimeZone*)timeZone
{
    return [self userFormatterWithDateStyle:dateStyle timeStyle:NSDateFormatterNoStyle timeZone:timeZone];
}

+ (NSDateFormatter*)userFormatterWithDateStyle:(NSDateFormatterStyle)dateStyle
{
    return [self userFormatterWithDateStyle:dateStyle timeZone:[NSTimeZone GMTTimeZone]];
}

+ (NSDateFormatter*)userFormatterWithTimeStyle:(NSDateFormatterStyle)timeStyle timeZone:(NSTimeZone*)timeZone
{
    return [self userFormatterWithDateStyle:NSDateFormatterNoStyle timeStyle:timeStyle timeZone:timeZone];
}

+ (NSDateFormatter*)userFormatterWithTimeStyle:(NSDateFormatterStyle)timeStyle
{
    return [self userFormatterWithTimeStyle:timeStyle timeZone:[NSTimeZone GMTTimeZone]];
}

+ (NSDateFormatter*)userFormatterWithFormat:(NSString*)format
{
    WDPRLocaleInfo *localeInfo = [WDPRLocalization localeInfoWithPreferredLanguages:[NSLocale preferredLanguages]];
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:localeInfo.language];
    
    NSTimeZone *timezone = [NSTimeZone localTimeZone];
    return [self sharedFormatterWithFormat:format locale:locale timezone:timezone];
}

+ (NSDateFormatter*)sharedFormatterWithFormat:(NSString*)format locale:(NSLocale*)locale timezone:(NSTimeZone*)timezone
{
    NSDateFormatter *dateFormatter = nil;

    @synchronized(self)
    {
        // get cached formatter
        NSString *key = [self keyForFormatterWithFormat:format];
        dateFormatter = [self cachedFormatterWithKey:key];

        // setup properly
        dateFormatter.dateFormat = format;
        dateFormatter.locale = locale;
        dateFormatter.timeZone = timezone;
    }

    return dateFormatter;
}

+ (NSDateFormatter*)sharedFormatterWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle locale:(NSLocale*)locale timezone:(NSTimeZone*)timezone
{
    NSDateFormatter *dateFormatter = nil;

    @synchronized(self)
    {
        // get cached formatter
        NSString *key = [self keyForFormatterWithDateStyle:dateStyle timeStyle:timeStyle];
        dateFormatter = [self cachedFormatterWithKey:key];

        // setup properly
        dateFormatter.dateStyle = dateStyle;
        dateFormatter.timeStyle = timeStyle;
        dateFormatter.locale = locale;
        dateFormatter.timeZone = timezone;
    }

    return dateFormatter;
}

#pragma mark - Helper methods

+ (NSString*)keyForFormatterWithFormat:(NSString*)format
{
    return [NSString stringWithFormat:@"format:%@", format];
}

+ (NSString*)keyForFormatterWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle
{
    NSString *dateStyleString = [self stringFromFormatterStyle:dateStyle];
    NSString *timeStyleString = [self stringFromFormatterStyle:timeStyle];
    return [NSString stringWithFormat:@"dateStyle:%@ timeStyle:%@", dateStyleString, timeStyleString];
}

+ (NSString*)stringFromFormatterStyle:(NSDateFormatterStyle)style
{
    switch (style)
    {
        case NSDateFormatterNoStyle:
            return @"NSDateFormatterNoStyle";
            break;
        case NSDateFormatterShortStyle:
            return @"NSDateFormatterShortStyle";
            break;
        case NSDateFormatterMediumStyle:
            return @"NSDateFormatterMediumStyle";
            break;
        case NSDateFormatterLongStyle:
            return @"NSDateFormatterLongStyle";
            break;
        case NSDateFormatterFullStyle:
            return @"NSDateFormatterFullStyle";
            break;
        default:
            break;
    }
}

+ (NSDateFormatter*)cachedFormatterWithKey:(NSString*)key
{
    NSDateFormatter *dateFormatter = nil;

    @synchronized(self)
    {
        NSMutableDictionary *cachedFormatters = [self currentThreadFormatterDictionary];

        if (!cachedFormatters)
        {
            cachedFormatters = [NSMutableDictionary dictionary];
            [self saveFormatterDictionary:cachedFormatters];
        }

        dateFormatter = cachedFormatters[key];

        if (!dateFormatter)
        {
            dateFormatter = [[NSDateFormatter alloc] init];
            cachedFormatters[key] = dateFormatter;
        }
    }

    return dateFormatter;
}

+ (NSDateFormatter *)briefTimeFormat
{
    NSString *timeFormat = [WDPRLocalization is24HourFormat] ?
    WDPRLocalizedStringInBundle(@"com.wdprcore.briefTimeFormat24", WDPRCoreResourceBundleName, nil) :
    WDPRLocalizedStringInBundle(@"com.wdprcore.briefTimeFormat12", WDPRCoreResourceBundleName, nil);

    return [self userFormatterWithFormat:timeFormat];
}

/** @note This class only handles date formatters caching, NSDate+WDPR has some higher level date formatting methods. Use systemFormatterWithFormat: instead if working with system dates, or userFormatterWithDateStyle:timeStyle: if working with user facing dates. If more control is needed sharedFormatterWithFormat:locale:timezone: is available.
 **/
+ (NSString *)stringWithRelativeDateAndTimeForDate:(NSDate *)date;
{
    __block NSTimeZone *previousTimeZone;
    __block NSDateFormatter *timeFormatter;
    
    onExitFromScope
    (^{
        timeFormatter.timeZone = previousTimeZone;
    });
    
    timeFormatter = [NSDateFormatter briefTimeFormat];
    
    // Show this according to the device's time zone,
    // localTimeZone will be that of the park
    previousTimeZone = timeFormatter.timeZone;
    timeFormatter.timeZone = NSTimeZone.systemTimeZone;
    
    NSString* relativeDate = [NSDate relativeDateStringForDate:date];
    NSArray* dateComponents = [relativeDate componentsSeparatedByString:@","];
    
    // relativeDate will return "Today", "Yesterday", "Tomorrow", or "EEE, MMM d, yyyy"
    // (e.g. "Fri, Nov 7, 2014").  We want "Today", "Yesterday", "Tomorrow" or "MMM d"
    relativeDate = (dateComponents.count == 1) ? dateComponents[0] : dateComponents[1];
    
    return [NSString stringWithFormat:
            WDPRLocalizedStringInBundle(@"com.wdprcore.dateformatter.relativedate", WDPRCoreResourceBundleName, @"rdate at time"),
            relativeDate, [timeFormatter stringFromDate:date]];
}

#pragma mark - Deprecated methods

+ (NSDateFormatter*)formatterWithFormat:(NSString*)format
{
    WDPRLocaleInfo *localeInfo = [WDPRLocalization localeInfo];

    return [self formatterWithFormat:format locale:[NSLocale localeWithLocaleIdentifier:localeInfo.localeIdentifier]];
}

+ (NSString*)formattedTimeFromDate:(NSDate*)date
{
    return [self.briefTimeFormat stringFromDate:date];
}

+ (NSDateFormatter*)formatterWithFormat:(NSString*)format locale:(NSLocale*)locale
{
    return [self formatterWithFormat:format locale:locale timezone:[NSTimeZone defaultTimeZone]];
}

+ (NSDateFormatter*)formatterWithFormat:(NSString*)format locale:(NSLocale*)locale timezone:(NSTimeZone*)timezone
{
    NSDateFormatter *dateFormat;

    @synchronized(self)
    {
        NSMutableDictionary *cachedFormatters =
        [self currentThreadFormatterDictionary];

        if (!cachedFormatters)
        {
            cachedFormatters = [NSMutableDictionary dictionaryWithCapacity:1];
            [self saveFormatterDictionary:cachedFormatters];
        }

        dateFormat = cachedFormatters[format];

        if (!dateFormat)
        {
            dateFormat = [[NSDateFormatter alloc] init];
            [dateFormat setDateFormat: format];
            cachedFormatters[format] = dateFormat;
        }

        dateFormat.locale = locale;
        dateFormat.timeZone = timezone;
    }

    return dateFormat;
}

+ (NSDateFormatter*)shortDateFormatter
{
    return [self formatterWithFormat:@"yyyy-MM-dd"];
}

+ (NSDateFormatter *)briefDateOnlyFormat
{
    return [self formatterWithFormat:@"MMM d, yyyy"];
}

#pragma mark - Helpers

+ (NSMutableDictionary*)currentThreadFormatterDictionary
{
    return [[[NSThread currentThread] threadDictionary] objectForKey:WDPRFormatterDictionaryKey];
}

+ (void)saveFormatterDictionary:(NSMutableDictionary*)dictionary
{
    NSMutableDictionary* threadDictionary = [[NSThread currentThread] threadDictionary];
    threadDictionary[WDPRFormatterDictionaryKey] = dictionary;
}

+ (NSDate*)dateFromTimeString:(NSString*)timeString
{
    NSDateComponents* dateComponents = [NSCalendar.currentCalendar
                                        components:(NSCalendarUnitYear |
                                                    NSCalendarUnitMonth |
                                                    NSCalendarUnitDay )
                                        fromDate:[NSDate date]];

    NSArray* timeComponents = [timeString
                               componentsSeparatedByString:@":"];

    dateComponents.hour = [timeComponents[0] intValue];
    dateComponents.minute = [timeComponents[1] intValue];
    dateComponents.second = [timeComponents[2] intValue];

    NSDate* date = [NSCalendar.currentCalendar
                    dateFromComponents:dateComponents];

    return date;
}

+ (NSString *)durationBriefFormat:(NSString *)durationString
{
    NSArray *arrayDuration = [durationString componentsSeparatedByString:@":"];
    NSString *briefDurationString;
    NSString *localizableString;
    int hours = [SAFE_CAST(arrayDuration[0], NSString) intValue];
    int minutes = [SAFE_CAST(arrayDuration[1], NSString) intValue];
    
    if (hours != 0)
    {
        NSString *minutesAproach = [NSString stringWithFormat:@"%.1f", minutes / 60.0];
        NSRange range = [minutesAproach rangeOfString:@"."];
        
        minutesAproach = (minutes > 0) ? [minutesAproach substringFromIndex:range.location] : @"";
        localizableString = (hours == 1 && minutes == 0) ? @"com.wdprcore.dateformatter.hour" : @"com.wdprcore.dateformatter.hours";
        briefDurationString = [NSString stringWithFormat:WDPRLocalizedStringInBundle(localizableString, WDPRCoreResourceBundleName, nil),[NSString stringWithFormat:@"%d%@", hours, minutesAproach]];
    }
    else if (minutes != 0)
    {
        localizableString = (minutes == 1) ? @"com.wdprcore.dateformatter.minute" : @"com.wdprcore.dateformatter.minutes";
        briefDurationString = [NSString stringWithFormat:WDPRLocalizedStringInBundle(localizableString, WDPRCoreResourceBundleName, nil),[NSString stringWithFormat:@"%d", minutes]];
    }
    
    return briefDurationString;
}

@end
