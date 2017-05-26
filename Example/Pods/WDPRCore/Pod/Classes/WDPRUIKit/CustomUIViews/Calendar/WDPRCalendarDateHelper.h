//
//  WDPRCalendarDateHelper.h
//  DLR
//
//  Created by Olson, Jason on 4/27/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WDPRCalendarDateHelper : NSObject

@property (readonly, nonatomic) NSString *dayOfWeekText;
@property (readonly, nonatomic) NSString *dayNumberAsText;

+ (WDPRCalendarDateHelper *)dateCellInfoForDate:(NSDate *)date;

@end
