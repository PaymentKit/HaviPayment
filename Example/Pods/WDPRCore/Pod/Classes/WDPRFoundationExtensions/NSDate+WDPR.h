//
//  NSDate+WDPR.h
//  WDPR
//
//  Created by Garvin, Cody X. -ND on 8/11/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

enum
{
    kNumberOfSecondsInMinute = 60,
    
    kNumberOfMinutesInHour = 60,
    kNumberOfSecondsInHour = (kNumberOfMinutesInHour *
                              kNumberOfSecondsInMinute),
    
    kNumberOfHoursInDay = 24,
    kNumberOfMinutesInDay = (kNumberOfHoursInDay * 
                             kNumberOfMinutesInHour),
    kNumberOfSecondsInDay = (kNumberOfMinutesInDay * 
                             kNumberOfSecondsInMinute),

    kNumberOfDaysInYear = 365,
    kNumberOfHoursInYear = (kNumberOfDaysInYear * 
                            kNumberOfHoursInDay),
    kNumberOfMinutesInYear = (kNumberOfHoursInYear *
                              kNumberOfMinutesInHour),
    kNumberOfSecondsInYear = (kNumberOfMinutesInYear * 
                              kNumberOfSecondsInMinute),
};

@interface NSDate (WDPR)

// Returns the date today without a timestamp
+ (NSDate *)todayWithoutTime;
// Returns a date offset from today without a timestamp// Returns a date offset from date passed in without a timestamp

+ (NSDate *)dateWithoutTimeFromUTCDate:(NSDate *)date;

+ (NSDate *)dateWithoutTimeFromDate:(NSDate *)date;
// Returns a date offset from date passed in with a timestamp passed in
+ (NSDate *)dateWithTimeFromDate:(NSDate *)date
                        withHour:(NSInteger)hour
                       andMinute:(NSInteger)minute;

// Returns the number of days between two dates
+ (NSInteger)daysBetween:(NSDate *)dt1 and:(NSDate *)dt2;

// Returns the number of minutes between two dates
+ (NSInteger)minutesBetween:(NSDate *)start and:(NSDate *)end;

/// Returns YES if date is between "beginDate" & "endDate".
+ (BOOL)date:(NSDate*)date isBetweenDate:(NSDate*)beginDate andDate:(NSDate*)endDate;

/// Returns a UTC date/time string that is the combination of an NSDate for the day, and
/// an NSString as a time.  ("3:00 PM", "4:40 PM", "11:20 AM")
/// Useful for when you have a view controller containing both a date picker for the day, and
/// and a string picker for the time slots.
+ (NSString*)utcDateStringFromDayDate:(NSDate*)dayDate andTimeString:(NSString*)timeStr;

/// receiver is later than specified date
- (BOOL)isLaterThan:(NSDate*)date;

/// receiver is earlier than specified date
- (BOOL)isEarlierThan:(NSDate*)date;

/// Add or subtract N days from given date.
- (NSDate*) addDays:(NSInteger)days;

/// Allows truncation of less significant parts of date
- (NSDate*) dateWithYear:(BOOL)year month:(BOOL)month day:(BOOL)day hour:(BOOL)hour minute:(BOOL)minute second:(BOOL)second;

/// Add or subtract time units from given date.
- (NSDate*) addYears:(NSInteger)years
             months:(NSInteger)months
               days:(NSInteger)days
              hours:(NSInteger)hours
            minutes:(NSInteger)minutes
            seconds:(NSInteger)seconds;

/// Return a datetime string formatted as UTC
- (NSString*) utcString;

/// Return a NSDate formatted as UTC
- (NSDate*) utcDate;

- (BOOL) isToday;
- (BOOL) isTomorrow;
- (BOOL) isYesterday;

/// Returns YES if date is same date as target date.
- (BOOL) isSameDateAs:(NSDate*)date;
- (BOOL) isSameUTCDateAs:(NSDate*)date;
- (BOOL) isSameOrLaterThan:(NSDate*)date;
- (BOOL) isSameOrLaterMonthAndYear:(NSDate *)date;

/**
 Returns Localized day of week.
 
 For US English locale this returns full name for day
 of the week such as "Monday", "Tuesday", etc.
 */
- (NSString *)weekDay;

/**
 Returns Localized short abbreviation for day of week.
 
 For US English locale this returns three character day
 of the week abbreviations such as "Mon", "Tue", etc.
 */
- (NSString *)shortWeekDay;

/**
 Returns Localized single character (or shortest possible)
 abbreviation for day of week.

 For US English locale this returns one character day
 of the week abbreivations such as "M", "T", etc.
 NOTE: Saturday and Sunday would both return as "S".
 */
- (NSString *)veryShortWeekDay;

- (NSString *)monthAndDay;
- (NSString *)year;
- (NSString *)month;
- (NSString *)monthAndYear;

/// return the age of the date (useful for date of birth NSDates)
- (NSUInteger)age;

- (NSString*)daysFromNow;

/// Combine the date part of one datetime and the time part of another datetime.
+ (NSDate*) combineDate:(NSDate*)date andTime:(NSDate*)time;

/// Return a local dateTime from UTC formatted string.
/// (useful for displaying the time for park events.)
+ (NSDate*) dateTime_fromParkHours:(NSString*)dateTimeString_withUTCOffset;

/// Return self as UTC-Offset formatted string for park (ie, user selects 3:00PM will be 3:00PM park time)
- (NSString*) parkDateTime_withUTCOffset;

/// Return self as UTC formatted string for park
- (NSString*) parkDateTime_withUTC;

/**
 Class method to return a full style date string from a UTC date string. The returned
 date string is adjusted for the park's local time zone.
 @param dateString is a UTC date string
 */
+ (NSString*)fullStyleDateStringFromUTCString:(NSString*)dateString;

/**
 Class method to return a long style date string from a UTC date string. The returned
 date string is adjusted for the park's local time zone.
 @param dateString is a UTC date string
 */
+ (NSString*)longStyleDateStringFromUTCString:(NSString*)dateString;

/**
 Class method to return a full style date string from a date object. The returned
 date string is adjusted for the park's local time zone.
 @param date is a date object
 */
+ (NSString*)fullStyleDateStringFromDate:(NSDate*)date;
+ (NSString*)longStyleDateStringFromDate:(NSDate*)date;
+ (NSString*)mediumStyleDateStringFromDate:(NSDate*)date;

/**
 Class method to return a "EEE, MMM d, yyyy" style date string from a date object.
 @param date is an NSDate instance that will be interpreted with the current
 calendar and timezone of the device.
 */
+ (NSString *)abbrevFullStyleDateStringFromDate:(NSDate *)date;

/**
 Class method to return a short style date only string from a date object.
 The returned format will be "yyyy-mm-dd"
 @param date is an NSDate instance that will be interpreted with the current
             calendar and timezone of the device.
 */
+ (NSString*)shortStyleDateOnlyStringForDate:(NSDate *)date;

/**
 Class method to return a medium style date string from a UTC date string. The returned
 date string is adjusted for the park's local time zone.
 @param dateString is a UTC date string
 */
+ (NSString*)mediumStyleDateStringFromUTCString:(NSString*)dateString;

/**
 Class method to return a short style time string from a UTC date string. The returned
 time string is adjusted for the park's local time zone. This differs from
 longStyleDateStringFromUTCString in that this exepcts a timezone in the format
 of -04:00.
 @param dateString is a UTC date string
 */
+ (NSString*)shortStyleTimeStringFromUTCString:(NSString*)dateString;

/**
 Class method to return a long style date string from a UTC date string. The returned
 date string is adjusted for the park's local time zone. This differes from 
 longStyleDateStringFromUTCString in that this exepcts a timezone in the format 
 of -04:00.
 @param dateString is a UTC date string
 */
+ (NSString*)longStyleWithDifferenceDateStringFromUTCString:(NSString*)dateString;

/**
 Class method to return a medium style date string from a UTC date string. The returned
 date string is adjusted for the park's local time zone. This differes from
 longStyleDateStringFromUTCString in that this exepcts a timezone in the format
 of -04:00.
 @param dateString is a UTC date string
 */
+ (NSString*)mediumStyleWithDifferenceDateStringFromUTCString:(NSString*)dateString;

/**
 Class method to return a short style time string from a UTC date string. The returned
 time string is adjusted for the park's local time zone. This differs from
 longStyleDateStringFromUTCString in that this exepcts a timezone in the format
 of -04:00.
 @param dateString is a UTC date string
 */
+ (NSString*)shortStyleTimeWithDifferenceDateStringFromUTCString:(NSString*)dateString;

/**
 Class method to return a string date from a separately date and hour.
 The returned format will be "yyyy-mm-ddThh:mm:ss"
 @param date is a date string with format "yyyy-mm-dd"
 @param hour is a date string with format "hh:mm:ss"
 */
+ (NSString*) createDateStringFromDate:(NSString*)date andHour:(NSString*)hour;

/**
 Class method to return a long style date string when given a UTC date.
 @param date is a UTC date.
 */
+ (NSString*)parkDateStringFromUTCDate:(NSDate*)date
                withDateFormatterStyle:(NSDateFormatterStyle)dateStyle
                 andTimeFormatterStyle:(NSDateFormatterStyle)timeStyle;

/**
 Class method to return an hour string when given a UTC date (with AM/PM).
 @param date is a UTC date.
 */
+ (NSString*) parkHourStringFromUTCDate:(NSDate*)date;

/**
 Class method to return an hour string when given a UTC date (with AM/PM).
 Unlike parkHourStringFromUTCDate, 0s on the left are trimmed.
 @param date is a UTC date.
 */
+ (NSString*) parkHourShortStringFromUTCDate:(NSDate*)date;

/**
 Class method to return a full hour string when given a UTC date.
 @param date is a UTC date.
 */
+ (NSString*)fullParkHourStringFromUTCDate:(NSDate*)date;

/**
 Class method to return a UTC date from a UTC formatted date string.
 */
+ (NSDate*)dateFromUTCDateString:(NSString*)dateString;

/**
 Class method to return a UTC hour from a UTC formatted date string.
 */
+ (NSDate*)hourFromUTCDateString:(NSString*)dateString;

/**
 Class method to return a UTC hour from a UTC formatted date string.
 */
+ (NSDate*)hourPlusSecondsFromUTCDateString:(NSString*)dateString;

/**
 Class method to return a UTC date from a UTC with a timezone difference 
 formatted date string.
 */
+ (NSDate*)dateFromUTCWithDifferenceDateString:(NSString*)dateString;

/**
 Class method to return dining time (breakfast, lunch, dinner). This method is 
 set to return a localized string. 
 @param date is an NSDate
 */
+ (NSString *)localizedDiningStringFromDate:(NSDate *)date;

/**
 Class method to return a UTC date from a UTC with a timezone difference
 formatted date string.
 */
+ (NSDate*)adjustedDate:(NSString *)dateString withTimeZone:(NSTimeZone*)timeZone;

/**
 Class method to return a UTC date from a UTC with a timezone(systemTimeZone) difference
 formatted date string.
 */
+ (NSDate*)adjustedDate:(NSString *)dateString;

+ (NSString*) dateTimeFormat_UTC;
+ (NSString*) dateTimeFormat_UTCwithOffset;

/**
  Returns a relative date string in medium format without the time.
  For example, if the date is equal to today or tomorrow a string will be returned, "Today" or "Tomorrow"
  All other dates are returned in medium format.
*/
+ (NSString *)relativeDateStringForDate:(NSDate *)date;

/**
 Returns a relative date string in full format without the time.
 For example, if the date is equal to today or tomorrow a string will be returned, "Today" or "Tomorrow"
 All other dates are returned in full format  <full day>, <full month> <DD>, <YYYY>..
 */
+ (NSString *)relativeFullDateStringForDate:(NSDate *)date;

/**
 Returns a relative date string in full format without the time and year.
 For example, if the date is equal to today or tomorrow a string will be returned, "Today" or "Tomorrow"
 All other dates are returned in full format  <full day>, <full month> <DD>.
 */
+ (NSString *)relativeFullDateWithoutYearStringForDate:(NSDate *)date;

/**
 Returns AM PM format for a time from a 24 hrs format
 */
+ (NSString *) hoursFromFullHourFormat:(NSString *)inputHour;

/**
 Returns the current year as an integer
 */
+ (NSInteger)baseYear;

+ (NSString *)humanInterval:(NSDate *)fromDate toDate:(NSDate *)toDate;

/**
 * Method to get a NSString based on 12h or 24h formatter strings.
 * In order to personalize those formatters you need to override the following strings in your app:
 * "com.wdprcore.briefTimeFormat24" and "com.wdprcore.briefTimeFormat12"
 *
 * @return NSString from 24h or 12h string formatter.
 */
+ (NSString *)briefFormattedTimeFromDate:(NSDate *)date;

@end
