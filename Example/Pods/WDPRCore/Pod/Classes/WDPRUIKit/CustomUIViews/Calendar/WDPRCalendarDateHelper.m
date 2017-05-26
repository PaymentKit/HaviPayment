//
//  WDPRCalendarDateHelper.m
//  DLR
//
//  Created by Olson, Jason on 4/27/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRCalendarDateHelper.h"
#import "NSDate+WDPR.h"

static NSCalendarUnit calendarUnits;

@interface WDPRCalendarDateHelper ()

@property (strong, nonatomic) NSString *dayOfWeekText;
@property (strong, nonatomic) NSString *dayNumberAsText;

@end

#pragma mark -

@implementation WDPRCalendarDateHelper

+ (void)initialize
{
    if (self == [WDPRCalendarDateHelper class])
    {
        calendarUnits = NSCalendarUnitDay | NSCalendarUnitMonth | NSCalendarUnitYear;
    }
}

+ (WDPRCalendarDateHelper *)dateCellInfoForDate:(NSDate *)date
{
    NSDateComponents *components = [[NSCalendar currentCalendar] components:calendarUnits fromDate:date];
    
    WDPRCalendarDateHelper *calDateHelper = [WDPRCalendarDateHelper new];
    
    calDateHelper.dayNumberAsText = [[NSNumber numberWithInteger:components.day] stringValue];
    calDateHelper.dayOfWeekText = [date shortWeekDay];
    
    return calDateHelper;
}

@end
