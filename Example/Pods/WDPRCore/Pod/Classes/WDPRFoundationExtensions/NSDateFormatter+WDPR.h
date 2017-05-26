//
//  NSDateFormatter+WDPR.h
//  WDPR
//
//  Created by Carlos Matias Tripode on 7/2/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 * NSDateFormatter category to support caching date formatters with common attributes.
 * A distinction between user-facing and system-facing date formatters is exposed clearly,
 * because these dates need to be treated very differently.
 * The `userFormatterWithDateStyle:timeStyle:` method is preferred for formatting user-facing dates,
 * and the `systemFormatterWithFormat:` method is preferred for formatting system facing dates.
 */
@interface NSDateFormatter (WDPR)

#pragma mark - Caching

/**
 * Return a cached system-friendly date formatter with the given format for the current thread.
 * The date formatter is setup using the en_US_POSIX locale and the UTC timezone.
 * This formatter is suitable for parsing/formatting system-facing dates (e.g: dates coming from web services),
 * but not user-facing dates (e.g: dates rendered on the screen).
 * To parse/format user-facing dates use userFormatterWithDateStyle:timeStyle: instead.
 */
+ (NSDateFormatter*)systemFormatterWithFormat:(NSString*)format;

/**
 * Return a cached system-friendly date formatter with the given format for the current thread.
 * The date formatter is setup using the en_US_POSIX locale and the given timezone.
 * This formatter is suitable for parsing/formatting system-facing dates (e.g: dates coming from web services),
 * but not user-facing dates (e.g: dates rendered on the screen).
 * To parse/format user-facing dates use userFormatterWithDateStyle:timeStyle: instead.
 */
+ (NSDateFormatter*)systemFormatterWithFormat:(NSString*)format timeZone:(NSTimeZone*)timeZone;

/**
 * Return a cached user-friendly date formatter with the given date and time styles, for the current thread.
 * The date formatter is set up using the current locale and time zone.
 * This formatter is suitable for parsing/formatting user-facing dates.
 * This is the preferred way of formatting user-facing dates in order to be consistent with user settings,
 * according to the NSDateFormatter class reference:
 * https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSDateFormatter_Class/
 * To parse/format system-facing dates use systemFormatterWithFormat: instead.
 * If more control on the date format is needed userFormatterWithFormat: can be used.
 */
+ (NSDateFormatter*)userFormatterWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle;

/**
 * Return a cached user-friendly date formatter with the given date and time styles, for the current thread.
 * The date formatter is set up using the current locale and the given time zone.
 * This formatter is suitable for parsing/formatting user-facing dates.
 * This is the preferred way of formatting user-facing dates in order to be consistent with user settings,
 * according to the NSDateFormatter class reference:
 * https://developer.apple.com/library/mac/documentation/Cocoa/Reference/Foundation/Classes/NSDateFormatter_Class/
 * To parse/format system-facing dates use systemFormatterWithFormat: instead.
 * If more control on the date format is needed userFormatterWithFormat: can be used.
 */
+ (NSDateFormatter*)userFormatterWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle timeZone:(NSTimeZone*)timeZone;

/**
 * Shortcut method for `userFormatterWithDateStyle:timeStyle:timeZone:`.
 * Uses NSDateFormatterNoStyle for the time style.
 */
+ (NSDateFormatter*)userFormatterWithDateStyle:(NSDateFormatterStyle)dateStyle timeZone:(NSTimeZone*)timeZone;

/**
 * Shortcut method for `userFormatterWithDateStyle:timeZone:`, using GMT timezone.
 */
+ (NSDateFormatter*)userFormatterWithDateStyle:(NSDateFormatterStyle)dateStyle;

/**
 * Shortcut method for `userFormatterWithDateStyle:timeStyle:timeZone:`.
 * Uses NSDateFormatterNoStyle for the date style.
 */
+ (NSDateFormatter*)userFormatterWithTimeStyle:(NSDateFormatterStyle)timeStyle timeZone:(NSTimeZone*)timeZone;

/**
 * Shortcut method for `userFormatterWithTimeStyle:timeZone:`, using GMT timezone.
 */
+ (NSDateFormatter*)userFormatterWithTimeStyle:(NSDateFormatterStyle)timeStyle;

/**
 * Return a cached user-friendly formatter for the current thread with the current locale and default timezone.
 * This is formatter should be used for parsing and formatting user-friendly dates only.
 * For system-friendly dates use systemFormatterWithFormat: instead.
 * Notice that userFormatterWithDateStyle:timeStyle: is preferred for formatting user friendly dates.
 */
+ (NSDateFormatter*)userFormatterWithFormat:(NSString*)format;


/**
 * Return a cached formatter for the current thread with the given format, locale and timezone.
 * Locale and timezone need to be properly set according to the use of the date formatter.
 * For example for system-facing dates locale always has to be set to en_US_POSIX,
 * this is a known caveat, for more information check https://developer.apple.com/library/ios/qa/qa1480/_index.html
 * Using systemFormatterWithFormat: is preferred.
 */
+ (NSDateFormatter*)sharedFormatterWithFormat:(NSString*)format locale:(NSLocale*)locale timezone:(NSTimeZone*)timezone;

/**
 * Return a cached formatter for the current thread with the given date and time styles, locale and timezone.
 * Using userFormatterWithDateStyle:timeStyle: is preferred.
 */
+ (NSDateFormatter*)sharedFormatterWithDateStyle:(NSDateFormatterStyle)dateStyle timeStyle:(NSDateFormatterStyle)timeStyle locale:(NSLocale*)locale timezone:(NSTimeZone*)timezone;

// Setup the Low Memory observer to clear cache of NSDateFormatters
+ (void) setupLowMemoryObserverForName:(NSString *)lowMemoryNotificationName;

#pragma mark - Deprecated methods

#if AVOID_NSDATE_DEPRECATIONS
// Set this symbol in the host app build to (temporarily) avoid the deprecation
// warnings while you clean them up.
#define DEPRECATED(message)
#else
#define DEPRECATED(message)     __attribute((deprecated(message)))
#endif

/// Returns a date formatter with 'yyyy-MM-dd' format
+ (NSDateFormatter*)shortDateFormatter
             DEPRECATED("Use systemFormatterWithFormat:@\"yyyy-MM-dd\" instead if working with system facing dates.");

// Return a cached formatter for the current thread with the current locale and default timezone
+ (NSDateFormatter*)formatterWithFormat:(NSString*)format
             DEPRECATED("Use systemFormatterWithFormat: instead if working with system dates, or userFormatterWithDateStyle:timeStyle: if working with user facing dates. If more control is needed sharedFormatterWithFormat:locale:timezone: is available.");

// Return a cached formatter for the current thread with the given locale and default timezone
+ (NSDateFormatter*)formatterWithFormat:(NSString*)format locale:(NSLocale*)locale
             DEPRECATED("Use systemFormatterWithFormat: instead if working with system dates, or userFormatterWithDateStyle:timeStyle: if working with user facing dates. If more control is needed sharedFormatterWithFormat:locale:timezone: is available.");

// Return a cached formatter for the current thread with the given locale and timezone
+ (NSDateFormatter*)formatterWithFormat:(NSString*)format locale:(NSLocale*)locale timezone:(NSTimeZone*)timezone
             DEPRECATED("Use systemFormatterWithFormat: instead if working with system dates, or userFormatterWithDateStyle:timeStyle: if working with user facing dates. If more control is needed sharedFormatterWithFormat:locale:timezone: is available.");

/// Return a string with 'h:mm a' format
+ (NSString*)formattedTimeFromDate:(NSDate*)date
             DEPRECATED("This class only handles date formatters caching, NSDate+WDPR has some higher level date formatting methods. Use systemFormatterWithFormat: instead if working with system dates, or userFormatterWithDateStyle:timeStyle: if working with user facing dates. If more control is needed sharedFormatterWithFormat:locale:timezone: is available.");

/// Returns a date formatter with 'Jan 1, 2015' format
+ (NSDateFormatter *)briefDateOnlyFormat
             DEPRECATED("Use userFormatterWithDateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterNoStyle instead if working with user facing dates. ");

// Today with time from the string 'HH:mm:ss'
+ (NSDate*)dateFromTimeString:(NSString*)timeString
             DEPRECATED("This class only handles date formatters caching, NSDate+WDPR has some higher level date formatting methods. Use systemFormatterWithFormat: instead if working with system dates, or userFormatterWithDateStyle:timeStyle: if working with user facing dates. If more control is needed sharedFormatterWithFormat:locale:timezone: is available.");

/**
 * Method to get NSDateFormatter based on 12h or 24h formatter strings.
 * In order to personalize those formatters you need to override the following strings in your app:
 * "com.wdprcore.briefTimeFormat24" and "com.wdprcore.briefTimeFormat12"
 *
 * @return NSDateFormatter from 24h or 12h string formatter.
 */
+ (NSDateFormatter *)briefTimeFormat;

/// "Today/Tomorrow/Yesterday/'MMM dd' at h:mm a" in device timezone
+ (NSString *)stringWithRelativeDateAndTimeForDate:(NSDate *)date;

// Returns duration string in a brief format:"01:30:00:0" -> "1.5 Hours"
+ (NSString*)durationBriefFormat:(NSString*)durationString;

@end
