//
//  NSDate+WDPR.m
//  WDPR
//
//  Created by Garvin, Cody X. -ND on 8/11/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRFoundation.h"
#import "WDPRLocalization.h"

static NSCalendarOptions const kDefaultOptions = 0;
#define en_US_POSIX [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];


@implementation NSDate (WDPR)

+ (NSDate *)todayWithoutTime
{
    return [self dateWithoutTimeFromDate:[NSDate date]];
}

+ (NSDate *)dateWithoutTimeFromUTCDate:(NSDate *)date
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    calendar.timeZone = [NSTimeZone timeZoneForSecondsFromGMT:0];
    NSDateComponents *components = [calendar components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                               fromDate:date];
    [components setHour:0];
    NSDate *dateWithoutTime = [calendar dateFromComponents:components];
    
    return dateWithoutTime;
}

+ (NSDate *)dateWithoutTimeFromDate:(NSDate *)date
{
    if (!date)
    {
        return nil;
    }
    else
    {
        NSCalendar *calendar = [NSCalendar autoupdatingCurrentCalendar];
        calendar.timeZone = [NSTimeZone localTimeZone];
        NSDateComponents *components = [calendar components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                   fromDate:date];
        [components setHour:0];
        NSDate *dateWithoutTime = [calendar dateFromComponents:components];
        
        return dateWithoutTime;
    }
}

+ (NSDate *)dateWithTimeFromDate:(NSDate *)date withHour:(NSInteger)hour andMinute:(NSInteger)minute
{
    if (!date)
    {
        return nil;
    }
    else
    {
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
        NSDateComponents *components = [calendar components:(NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                   fromDate:date];
        [components setHour:hour];
        [components setMinute:minute];
        NSDate *returnDate = [calendar dateFromComponents:components];
        
        return returnDate;
    }
}

+ (NSInteger)daysBetween:(NSDate *)date1 and:(NSDate *)date2
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitDay fromDate:date1 toDate:date2 options:0];
    return [components day];
}

+ (NSInteger)minutesBetween:(NSDate *)start and:(NSDate *)end
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *comps = [calendar components:NSCalendarUnitMinute
                                          fromDate:start
                                            toDate:end
                                           options:(NSCalendarOptions)0];
    
    return comps.minute;
}

+ (BOOL)date:(NSDate *)date isBetweenDate:(NSDate *)beginDate andDate:(NSDate *)endDate
{
    if ([date compare:beginDate] == NSOrderedAscending)
    	return NO;
    
    if ([date compare:endDate] == NSOrderedDescending)
    	return NO;
    
    return YES;
}

+ (NSString*)utcDateStringFromDayDate:(NSDate *)dayDate andTimeString:(NSString*)timeStr
{
    // Create a UTC date / time string, that is server friendly.
    
    // First, get the time string as an NSDate.
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.timeStyle = NSDateFormatterShortStyle;
    formatter.locale = en_US_POSIX;
    NSDate *time = [formatter dateFromString:timeStr];
    
    // Use the calendar for the current locale. I believe this to be the right approach
    // for when the app is localized.
    NSCalendar *calendar = [[NSLocale currentLocale] objectForKey:NSLocaleCalendar];
    unsigned unitFlags = (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay);
    
    // Get the selected date components.
    NSDateComponents *dateComps = [calendar components:unitFlags fromDate:dayDate];
    
    // Get the selected date, without the time components.
    NSDate *date = [calendar dateFromComponents:dateComps];
    
    unitFlags = NSCalendarUnitHour | NSCalendarUnitMinute;
    
    // Get the selected time slot components from time as an NSDate.
    NSDateComponents *timeComps = [calendar components:unitFlags fromDate:time];
    
    // Combine the original incoming date and time, as one NSDate.
    NSDate *combinedDate = [calendar dateByAddingComponents:timeComps toDate:date options:0];
    
    // Now produce a string, from the combined date, in the UTC timezone.
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    formatter.timeStyle = NSDateFormatterNoStyle;
    [formatter setTimeZone:timeZone];
    [formatter setDateFormat:[NSDate dateTimeFormat_UTC]];
    
    return [formatter stringFromDate:combinedDate];
}

- (NSDate *)dateWithYear:(BOOL)year month:(BOOL)month day:(BOOL)day hour:(BOOL)hour minute:(BOOL)minute second:(BOOL)second
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |
                                    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:self ];
    
    if (!year)
        components.year = 0;
    if (!month)
        components.month = 0;
    if (!day)
        components.day = 0;
    if (!hour)
        components.hour = 0;
    if (!minute)
        components.minute = 0;
    if (!second)
        components.second = 0;
    
    return [calendar dateFromComponents:components];
}

- (NSDate *)addDays:(NSInteger)days
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *addingComponents = [NSDateComponents new];
    addingComponents.day = days;
    NSDate *result = [calendar dateByAddingComponents:addingComponents
                                               toDate:self
                                              options:kDefaultOptions];
    return result;
}

- (NSDate *)addYears:(NSInteger)years
              months:(NSInteger)months
                days:(NSInteger)days
               hours:(NSInteger)hours
             minutes:(NSInteger)minutes
             seconds:(NSInteger)seconds
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay |
                                    NSCalendarUnitHour | NSCalendarUnitMinute | NSCalendarUnitSecond fromDate:self];

    components.year += years;
    components.month += months;
    components.day += days;
    components.hour += hours;
    components.minute += minutes;
    components.second += seconds;
    return [calendar dateFromComponents:components];
}

- (NSString *)utcString
{
    NSDateFormatter *formatter = [NSDateFormatter systemFormatterWithFormat:NSDate.dateTimeFormat_UTC];
    return [formatter stringFromDate:self];
}

- (NSDate *)utcDate
{
    return [NSDate adjustedDate:[self utcString] withTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
}

- (BOOL)isSameDateAs:(NSDate *)date
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    if ([calendar respondsToSelector:@selector(isDate:inSameDayAsDate:)]) {
        // iOS 8 introduced this handy method for us
        return [calendar isDate:date inSameDayAsDate:self];
    }
    else
    {
        // TODO: Remove this logic once minimum target version is iOS 8 or later.
        NSDate *d1 = [NSDate dateWithoutTimeFromDate:self];
        NSDate *d2 = [NSDate dateWithoutTimeFromDate:date];
        return [d1 isEqualToDate:d2];
    }
}

- (BOOL)isSameUTCDateAs:(NSDate *)date
{
    NSDate *d1= [NSDate dateWithoutTimeFromUTCDate:self];
    NSDate *d2= [NSDate dateWithoutTimeFromUTCDate:date];
    return [d1 isEqualToDate:d2];
}

- (BOOL)isSameOrLaterThan:(NSDate *)date
{
    NSDate *selfDate = [NSDate dateWithoutTimeFromDate:self];
    NSDate *compareDate = [NSDate dateWithoutTimeFromDate:date];
    BOOL bret = [compareDate compare:selfDate] != NSOrderedDescending;      // self is same or earlier than compare date
    return bret;
}

- (BOOL)isToday
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    if ([calendar respondsToSelector:@selector(isDateInToday:)])
    {
        return [calendar isDateInToday:self];
    }
    else
    {
        // TODO: Remove this logic once minimum target version is iOS 8 or later.
        return [self isSameDateAs:[NSDate date]];
    }
}

- (BOOL)isTomorrow
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    if ([calendar respondsToSelector:@selector(isDateInTomorrow:)])
    {
        return [calendar isDateInTomorrow:self];
    }
    else
    {
        // TODO: Remove this logic once minimum target version is iOS 8 or later.
        NSDateComponents *otherDay = [calendar components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
        NSDateComponents *today = [calendar components:NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:[NSDate date]];
        if ([today day] + 1 == [otherDay day] &&
            [today month] == [otherDay month] &&
            [today year] == [otherDay year] &&
            [today era] == [otherDay era])
        {
            return YES;
        }
        return NO;
    }
}

- (BOOL)isYesterday
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    if ([calendar respondsToSelector:@selector(isDateInYesterday:)])
    {
        return [calendar isDateInYesterday:self];
    }
    else
    {
        // TODO: Remove this logic once minimum target version is iOS 8 or later.
        NSDateComponents *yesterdayComponents = [[NSDateComponents alloc] init];
        [yesterdayComponents setDay:-1];
        NSDate *yesterday = [calendar dateByAddingComponents:yesterdayComponents
                                                      toDate:[NSDate date]
                                                     options:kDefaultOptions];
        return [self isSameDateAs:yesterday];
    }
}

- (BOOL)isLaterThan:(NSDate *)date
{
    // TODO: Update to using [self compare:date] == NSOrderedDescending
    return (date && ![self isEqualToDate:date] && [self isEqualToDate:[self laterDate:date]]);
}

- (BOOL)isEarlierThan:(NSDate *)date
{
    // TODO: Update to using [self compare:date] == NSOrderedAscending
    return (date && ! [self isEqualToDate:date] && [self isEqualToDate:[self earlierDate:date]]);
}

- (BOOL)isSameOrLaterMonthAndYear:(NSDate *)date
{
    NSDateComponents *dateOfSelf = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth
                                                                   fromDate:self];
    
    NSDateComponents *comparedDate = [[NSCalendar currentCalendar] components:NSCalendarUnitYear | NSCalendarUnitMonth
                                                                    fromDate:date];

    return (dateOfSelf.year > comparedDate.year) || (dateOfSelf.year == comparedDate.year && dateOfSelf.month >= comparedDate.month);
}

- (NSUInteger)age
{
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                          components:NSCalendarUnitYear
                                            fromDate:self
                                              toDate:[NSDate date]
                                             options:0];
    
    return [ageComponents year];
}

- (NSString *)description
{
    return [NSDateFormatter localizedStringFromDate:self
                                          dateStyle:NSDateFormatterShortStyle
                                          timeStyle:NSDateFormatterLongStyle];
}

/** 
 Returns Localized day of week.
 
 For US English locale this returns full name for day
 of the week such as "Monday", "Tuesday", etc.
 */
- (NSString *)weekDay
{
    NSDateFormatter *dateFormatter = [NSDateFormatter userFormatterWithFormat:@"yyyy-MM-dd"];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:self];
    
    NSInteger weekday = [components weekday];
    return [dateFormatter weekdaySymbols][weekday - 1];
}

/**
 Returns Localized short abbreviation for day of week.
 
 For US English locale this returns three character day
 of the week abbreviations such as "Mon", "Tue", etc.
 */
- (NSString *)shortWeekDay
{
    NSDateFormatter *dateFormatter = [NSDateFormatter userFormatterWithFormat:
                                      WDPRLocalizedStringInBundle(@"com.wdprcore.dateformatter.weekdayformat", WDPRCoreResourceBundleName, nil)];

    return [dateFormatter stringFromDate:self];
}

/**
 Returns Localized single character (or shortest possible)
 abbreviation for day of week.
 
 For US English locale this returns one character day
 of the week abbreivations such as "M", "T", etc. 
 NOTE: Saturday and Sunday would both return as "S".
 */
- (NSString *)veryShortWeekDay
{
    NSDateFormatter *dateFormatter = [NSDateFormatter userFormatterWithFormat:@"yyyy-MM-dd"];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSCalendarUnitWeekday fromDate:self];
    
    NSInteger weekday = [components weekday];
    return [dateFormatter veryShortWeekdaySymbols][weekday - 1];
}

- (NSString *)monthAndDay
{
    // TODO: This does not result in localized date format.  (Other locales put day before month.)
    // Since this method does not appear to be used anywhere it is not worth the effort to correct with true localized date formatter.
    NSDateFormatter *dateFormatter = [NSDateFormatter userFormatterWithFormat:@"yyyy-MM-dd"];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
    
    return [NSString stringWithFormat:@"%@ %ld", [dateFormatter standaloneMonthSymbols][[components month]-1], (long)[components day]];
}

- (NSString *)year
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear fromDate:self];
    
    return [[NSNumber numberWithInteger:components.year] stringValue];
}

- (NSString *)month
{
    NSDateFormatter *dateFormatter = [NSDateFormatter userFormatterWithFormat:@"yyyy-MM-dd"];
    WDPRLocaleInfo *localeInfo = [WDPRLocalization localeInfoWithPreferredLanguages:[NSLocale preferredLanguages]];
    NSLocale *locale = [NSLocale localeWithLocaleIdentifier:localeInfo.language];
    [dateFormatter setLocale:locale];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay fromDate:self];
    
    return [dateFormatter standaloneMonthSymbols][[components month] - 1];
}

- (NSString *)monthAndYear
{
    NSDateFormatter *dateFormatter = [NSDateFormatter userFormatterWithFormat:
                                      WDPRLocalizedStringInBundle(@"com.wdprcore.dateformatter.yearmonthformat", WDPRCoreResourceBundleName, nil)];
    
    return [dateFormatter stringFromDate:self];
}

+ (NSString *)fullStyleDateStringFromUTCString:(NSString *)dateString
{
    return [self parkDateStringFromUTCDate:[self dateFromUTCDateString:dateString]
                    withDateFormatterStyle:NSDateFormatterFullStyle
                     andTimeFormatterStyle:NSDateFormatterNoStyle];
}

+ (NSString *)fullStyleDateStringFromDate:(NSDate *)date
{
    return [self parkDateStringFromUTCDate:date
                                withDateFormatterStyle:NSDateFormatterFullStyle
                                 andTimeFormatterStyle:NSDateFormatterNoStyle];
}

+ (NSString *)longStyleDateStringFromDate:(NSDate *)date
{
    return [self parkDateStringFromUTCDate:date
                    withDateFormatterStyle:NSDateFormatterLongStyle
                     andTimeFormatterStyle:NSDateFormatterNoStyle];
}

+ (NSString *)mediumStyleDateStringFromDate:(NSDate *)date
{
    return [self parkDateStringFromUTCDate:date
                    withDateFormatterStyle:NSDateFormatterMediumStyle
                     andTimeFormatterStyle:NSDateFormatterNoStyle];
}

+ (NSString *)abbrevFullStyleDateStringFromDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [NSDateFormatter userFormatterWithFormat:@"EEE, MMM d, yyyy"];
	
    NSTimeZone *previousTimeZone = dateFormatter.timeZone;
    
    onExitFromScope
    (^{ // restore timeZone to what it was
        dateFormatter.timeZone = previousTimeZone;
    });
    
    dateFormatter.timeZone = NSTimeZone.localTimeZone;
    return [dateFormatter stringFromDate:date];
}

+ (NSDate *)combineDate:(NSDate *)date andTime:(NSDate *)time
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitDay |NSCalendarUnitMonth | NSCalendarUnitYear fromDate:date];
    NSDateComponents *timeComponents = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:time];
    
    NSDateComponents *newComponents = [[NSDateComponents alloc]init];
    newComponents.timeZone = [NSTimeZone systemTimeZone];
    [newComponents setDay:[dateComponents day]];
    [newComponents setMonth:[dateComponents month]];
    [newComponents setYear:[dateComponents year]];
    [newComponents setHour:[timeComponents hour]];
    [newComponents setMinute:[timeComponents minute]];
    
    return [calendar dateFromComponents:newComponents];
}


#pragma mark - Park Hours Formatting and Parsing

// UTC
+ (NSDate *)dateTime_fromParkHours:(NSString *)dateTimeString_withUTC
{
    NSDate *dateTime;

    // First Try "standard" UTC format
    @try
    {
        NSDateFormatter *inputFormatter = [NSDateFormatter systemFormatterWithFormat:self.dateTimeFormat_UTC];
        dateTime = [inputFormatter dateFromString:dateTimeString_withUTC];
    }
    @catch (NSException *exception){}
    
    if ( ! dateTime)
	{
        @try
        {
            NSDateFormatter *inputFormatter = [NSDateFormatter systemFormatterWithFormat:self.dateTimeFormat_UTCwithOffset];
            dateTime = [inputFormatter dateFromString:dateTimeString_withUTC];
        }
        @catch (NSException *exception){}
    }
    
    return dateTime;
}

- (NSString *)parkDateTime_withUTCOffset
{
    // show local time but with park time zone
    return [NSDate parkDateTime:self format:[NSDate dateTimeFormat_UTCwithOffset]];
}

- (NSString *)parkDateTime_withUTC
{
    // return string with std UTC format
    NSTimeZone *parkTimeZone = NSTimeZone.localTimeZone;
    NSTimeInterval secondsParkToGMT = [parkTimeZone secondsFromGMT];
    
    NSDate *dateTime = [self dateByAddingTimeInterval: - secondsParkToGMT];
    
    NSString *ret= [NSDate parkDateTime:dateTime format:[NSDate dateTimeFormat_UTC]];
    
    return ret;
}

+ (NSString *)parkDateTime:(NSDate *)dateTime format:(NSString *)format
{
    // return string with std UTC format
    NSTimeZone *parkTimeZone = NSTimeZone.localTimeZone;
    NSTimeZone *localTimeZone = NSTimeZone.systemTimeZone;
    
    // adjust datetime so its seems to come from park
    NSTimeInterval secondsLocalToGMT = [localTimeZone secondsFromGMT];
    NSTimeInterval secondsParkToGMT = [parkTimeZone secondsFromGMT];
    dateTime = [dateTime dateByAddingTimeInterval:secondsLocalToGMT - secondsParkToGMT];
    
    NSDateFormatter *outputFormatter = [NSDateFormatter systemFormatterWithFormat:format];
    outputFormatter.timeZone = parkTimeZone;
    NSString *ret = [outputFormatter stringFromDate:dateTime];
    
    return ret;
    
}
#pragma mark -

+ (NSString *)createDateStringFromDate:(NSString *)date andHour:(NSString *)hour
{
    return [NSString stringWithFormat:@"%@T%@", date, hour];
}

+ (NSString *)shortStyleDateOnlyStringForDate:(NSDate *)date
{
    NSDateFormatter *shortDateFormatter = [NSDateFormatter userFormatterWithFormat:@"yyyy-MM-dd"];
    shortDateFormatter.locale = en_US_POSIX;
    return [shortDateFormatter stringFromDate:date];
}

+ (NSString *)longStyleDateStringFromUTCString:(NSString *)dateString
{
    return [self parkDateStringFromUTCDate:[self dateFromUTCDateString:dateString]
                    withDateFormatterStyle:NSDateFormatterLongStyle
                     andTimeFormatterStyle:NSDateFormatterNoStyle];
}

+ (NSString *)mediumStyleDateStringFromUTCString:(NSString *)dateString
{
    return [self parkDateStringFromUTCDate:[self dateFromUTCDateString:dateString]
                    withDateFormatterStyle:NSDateFormatterMediumStyle
                     andTimeFormatterStyle:NSDateFormatterNoStyle];
}

+ (NSString *)shortStyleTimeStringFromUTCString:(NSString *)dateString
{
    return [self parkDateStringFromUTCDate:[self dateFromUTCDateString:dateString]
                    withDateFormatterStyle:NSDateFormatterNoStyle
                     andTimeFormatterStyle:NSDateFormatterShortStyle];
}

+ (NSString *)parkDateStringFromUTCDate:(NSDate *)date
                 withDateFormatterStyle:(NSDateFormatterStyle)dateStyle
                  andTimeFormatterStyle:(NSDateFormatterStyle)timeStyle
{
    // returns a long style date string based on park's time zone:
    NSDateFormatter *outputFormatter= [NSDateFormatter new];
    outputFormatter.dateStyle= dateStyle;
    outputFormatter.timeStyle= timeStyle;
    [outputFormatter setTimeZone:NSTimeZone.localTimeZone];
    return [outputFormatter stringFromDate:date];
}

+ (NSString *)parkHourStringFromUTCDate:(NSDate *)date
{
    return [NSDate parkHourStringFromUTCDate:date withFormat:@"hh:mm a"];
}

+ (NSString*) parkHourShortStringFromUTCDate:(NSDate*)date
{
    return [NSDate parkHourStringFromUTCDate:date withFormat:@"h:mm a"];
}

+ (NSString *)fullParkHourStringFromUTCDate:(NSDate *)date
{
    return [NSDate parkHourStringFromUTCDate:date withFormat:@"HH:mm:ss"];
}

+ (NSString*) parkHourStringFromUTCDate:(NSDate *)date withFormat:(NSString *)format
{
    NSDateFormatter *outputFormatter = [NSDateFormatter userFormatterWithFormat:format];
    [outputFormatter setTimeZone:NSTimeZone.localTimeZone];
    
    return [outputFormatter stringFromDate:date];
}

+ (NSDate *)dateFromUTCDateString:(NSString *)dateString
{
    NSDateFormatter *inputFormatter = [NSDateFormatter systemFormatterWithFormat:[self dateTimeFormat_UTC]];
    [inputFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    return [inputFormatter dateFromString:dateString];
}

+ (NSDate *)hourFromUTCDateString:(NSString *)dateString
{
    NSDateFormatter *inputFormatter = [NSDateFormatter systemFormatterWithFormat:@"hh:mm a"];
    [inputFormatter setTimeZone:NSTimeZone.localTimeZone];
    return [inputFormatter dateFromString:dateString];
}

+ (NSDate *)hourPlusSecondsFromUTCDateString:(NSString *)dateString
{
    NSDateFormatter *inputFormatter = [NSDateFormatter systemFormatterWithFormat:@"HH:mm:ss"];
    [inputFormatter setTimeZone:NSTimeZone.localTimeZone];
    return [inputFormatter dateFromString:dateString];
}

+ (NSString *)longStyleWithDifferenceDateStringFromUTCString:(NSString *)dateString
{
    return [self parkDateStringFromUTCDateWithDifference:[self dateFromUTCWithDifferenceDateString:dateString] withDateFormatterStyle:NSDateFormatterLongStyle andTimeFormatterStyle:NSDateFormatterNoStyle];
}

+ (NSString *)mediumStyleWithDifferenceDateStringFromUTCString:(NSString *)dateString
{
    return [self parkDateStringFromUTCDateWithDifference:[self dateFromUTCWithDifferenceDateString:dateString] withDateFormatterStyle:NSDateFormatterMediumStyle andTimeFormatterStyle:NSDateFormatterNoStyle];
}

+ (NSString *)shortStyleTimeWithDifferenceDateStringFromUTCString:(NSString *)dateString
{
    return [self parkDateStringFromUTCDateWithDifference:[self dateFromUTCWithDifferenceDateString:dateString] withDateFormatterStyle:NSDateFormatterNoStyle andTimeFormatterStyle:NSDateFormatterShortStyle];
}

+ (NSString *)parkDateStringFromUTCDateWithDifference:(NSDate *)date withDateFormatterStyle:(NSDateFormatterStyle)dateStyle andTimeFormatterStyle:(NSDateFormatterStyle)timeStyle
{
    // returns a long style date string based on park's time zone:
    NSDateFormatter *outputFormatter= [NSDateFormatter new];
    outputFormatter.dateStyle= dateStyle;
    outputFormatter.timeStyle= timeStyle;
    [outputFormatter setTimeZone:NSTimeZone.localTimeZone];
    return [outputFormatter stringFromDate:date];
}

+ (NSDate *)dateFromUTCWithDifferenceDateString:(NSString *)dateString
{
    NSDateFormatter *inputFormatter = [NSDateFormatter systemFormatterWithFormat:[self dateTimeFormat_UTCwithOffset]];
    return [inputFormatter dateFromString:dateString];
}

+ (NSDate *)adjustedDate:(NSString *)dateString withTimeZone:(NSTimeZone *)timeZone
{
    NSDateFormatter *inputFormatter = [NSDateFormatter systemFormatterWithFormat:[self dateTimeFormat_UTCwithOffset]];
    
    NSTimeZone *parkTimeZone= NSTimeZone.localTimeZone;
    NSTimeInterval secondsToGMT= [timeZone secondsFromGMT];
    NSTimeInterval secondsParkToGMT= [parkTimeZone secondsFromGMT];
    
    NSDate *d = [[inputFormatter dateFromString:dateString] dateByAddingTimeInterval:secondsParkToGMT - secondsToGMT];
    
    // SLING-3678: Homescreen - Incorrect Date for Resort Reservation
    // this case was not working:
    //      "2014-04-07T04:00:00Z" was returning 2014-04-06 16:00:00 PDT
    // Need to adjust time if today is a Daylight Savings Time date, and the given date is not, or vica verso.
    NSTimeInterval secondsParkToGmtForDate= [parkTimeZone secondsFromGMTForDate:d];
    if (secondsParkToGMT != secondsParkToGmtForDate)
    {
        d = [d dateByAddingTimeInterval:secondsParkToGmtForDate - secondsParkToGMT];
    }
    
    return d;
}

+ (NSDate *)adjustedDate:(NSString *)dateString
{
    return [self adjustedDate:dateString withTimeZone:[NSTimeZone systemTimeZone]];
}

+ (NSString *)localizedDiningStringFromDate:(NSDate *)date
{
    if ( ! date)
    {
        date = [NSDate date];
    }
    
    NSString *diningString = nil;
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSCalendarUnitHour | NSCalendarUnitMinute) fromDate:date];
    NSInteger hour = [components hour];
    NSInteger minute = [components minute];
#ifdef DEBUG
    WDPRLog(@"Hour: %d - Minute: %d", hour, minute);
#endif
    
    // Build the string
    if (hour < 11)
    {
        diningString = WDPRLocalizedStringInBundle(@"com.wdprcore.dining.breakfast", WDPRCoreResourceBundleName, nil );
    }
    else if (hour >= 11 && (hour < 15 || (hour==15 && minute <= 25)))
    {
        diningString = WDPRLocalizedStringInBundle(@"com.wdprcore.dining.lunch", WDPRCoreResourceBundleName, nil);
    }
    else
    {
        diningString = WDPRLocalizedStringInBundle(@"com.wdprcore.dining.dinner", WDPRCoreResourceBundleName, nil);
    }
    
    return diningString;
}

#pragma mark - Specific DateTime Formats

+ (NSString *) dateTimeFormat_UTC
{
    return @"yyyy'-'MM'-'dd'T'HH':'mm':'ss'Z'";
}

+ (NSString *) dateTimeFormat_UTCwithOffset
{
    return @"yyyy-MM-dd'T'HH:mm:ssZZZZZ";
}

+ (NSString *)relativeFullDateStringForDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [NSDateFormatter userFormatterWithFormat:@"EEEE, MMMM dd, yyyy"];
    return [self dateStringForDate:date andDateFormatter:dateFormatter];
}

+ (NSString *)relativeDateStringForDate:(NSDate *)date
{
    NSDateFormatter *dateFormatter = [NSDateFormatter userFormatterWithFormat:@"EEE, MMM dd, yyyy"];
    return [self dateStringForDate:date andDateFormatter:dateFormatter];
}

+ (NSString *)relativeFullDateWithoutYearStringForDate:(NSDate *)date
{
    //Using NSDateFormatter+WDPR method which provides caching for formatters:
    NSDateFormatter *dateFormatter = [NSDateFormatter userFormatterWithFormat:@"EEEE, MMMM dd"];
    return [self dateStringForDate:date andDateFormatter:dateFormatter];
}

+ (NSString *)dateStringForDate:(NSDate *)date andDateFormatter:(NSDateFormatter*)dateFormatter
{
    if (date.isToday) 
    {
        return WDPRLocalizedStringInBundle(@"com.wdprcore.datewdpr.today", WDPRCoreResourceBundleName, nil);
    }
    else if (date.isTomorrow) 
    {
        return WDPRLocalizedStringInBundle(@"com.wdprcore.datewdpr.tomorrow", WDPRCoreResourceBundleName, nil);
    }
    else if (date.isYesterday)
    {
        return WDPRLocalizedStringInBundle(@"com.wdprcore.datewdpr.yesterday", WDPRCoreResourceBundleName, nil);
    }
    else 
    {
        return [dateFormatter stringFromDate:date];
    }

}

+ (NSString *)hoursFromFullHourFormat:(NSString *)inputHour
{
    NSDateFormatter *outputFormatter = [NSDateFormatter userFormatterWithFormat:@"h:mm a"];
    NSDateFormatter *inputFormatter = [NSDateFormatter systemFormatterWithFormat:@"HH:mm:ss"];
    NSDate *inputDate = [inputFormatter dateFromString:inputHour];
    NSString *outputDate = [outputFormatter stringFromDate:inputDate];
    
    return outputDate;
}

+ (NSInteger)baseYear
{
    NSDateComponents* dateComponentsYear = [NSCalendar.currentCalendar components:(NSCalendarUnitYear) fromDate:NSDate.date];
    
    return dateComponentsYear.year;
}

- (NSString *)daysFromNow
{
    NSCalendar *gregorianCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    
    NSDateComponents *components = [gregorianCalendar components:NSCalendarUnitDay
                                                        fromDate:[NSDate dateWithoutTimeFromDate:[NSDate date]]
                                                          toDate:self
                                                         options:0];
    return [NSString stringWithFormat:@"%ld",(long)components.day];
}

+ (NSString *)humanInterval:(NSDate *)fromDate toDate:(NSDate *)toDate
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour |NSCalendarUnitMinute | NSCalendarUnitSecond;
    NSString *humanRedableString = nil;
    
    NSDateComponents *dateComponents = [calendar components:unitFlags
                                                   fromDate:fromDate
                                                     toDate:toDate
                                                    options:0];
    
    NSInteger years    = [dateComponents year];
    NSInteger days     = [dateComponents day];
    NSInteger months   = [dateComponents month];
    NSInteger hours    = [dateComponents hour];
    NSInteger minutes  = [dateComponents minute];
    NSInteger seconds  = [dateComponents second];
    
    if (months > 1 && years == 0)
    {
       humanRedableString = [NSString stringWithFormat:@"%ld Months ago", (long)months];
    }
    else if (months >= 1 && years == 0)
    {
       humanRedableString = [NSString stringWithFormat:@"%ld Month ago", (long)months];
    }
    else if (days > 1 && months == 0)
    {
       humanRedableString = [NSString stringWithFormat:@"%ld Days ago", (long)days];
    }
    else if (days == 1 && months == 0)
    {
       humanRedableString = [NSString stringWithFormat:@"%ld Day ago", (long)days];
    }
    else if (hours > 1 && days == 0)
    {
       humanRedableString = [NSString stringWithFormat:@"%ld Hours ago", (long)hours];
    }
    else if (hours == 1 && days == 0)
    {
       humanRedableString = [NSString stringWithFormat:@"%ld Hour ago", (long)hours];
    }
    else if (minutes > 1 && hours == 0)
    {
       humanRedableString = [NSString stringWithFormat:@"%ld Minutes ago", (long)minutes];
    }
    else if (minutes == 1 && hours == 0)
    {
       humanRedableString = [NSString stringWithFormat:@"%ld Minute ago", (long)minutes];
    }
    else if (seconds > 1 && minutes == 0)
    {
       humanRedableString = [NSString stringWithFormat:@"%ld Seconds ago", (long)seconds];
    }
    else if (seconds == 1 && minutes == 0)
    {
       humanRedableString = [NSString stringWithFormat:@"%ld Second ago", (long)seconds];
    }
    
    return humanRedableString;
}

+ (NSString *)briefFormattedTimeFromDate:(NSDate *)date
{
    return [[NSDateFormatter briefTimeFormat] stringFromDate:date];
}

@end
