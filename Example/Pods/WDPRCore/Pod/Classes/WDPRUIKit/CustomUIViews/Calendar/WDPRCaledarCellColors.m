//
//  WDPRCaledarCellColors.m
//  DLR
//
//  Created by Olson, Jason on 4/26/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRCaledarCellColors.h"
#import "WDPRUIKit.h"

@implementation WDPRCaledarCellColors

- (instancetype)initWithType:(WDPRCaledarCellColorsType)type
{
    self = [super init];
    
    if (self)
    {
        switch (type)
        {
            case WDPRCaledarCellColorsTypeParkHours:
                [self setParkHourColors];
                break;
            
            case WDPRCaledarCellColorsTypeBlockOut:
                [self setBlockoutColors];
                break;
            
            case WDPRCaledarCellColorsTypeNone:
            default:
                // Set no colors.
                break;
        }
    }
    return self;
}

- (void)setParkHourColors
{
    _dayOfWeekTextColor     = [UIColor wdprParkHoursDayOfWeekTextColor];
    _enabledDayTextColor    = [UIColor wdprParkHoursDayColor];
    _selectedDayTextColor   = [UIColor wdprParkHoursSelectedTextColor];
    _selectedDayCircleColor = [UIColor wdprParkHoursSelectedCircleColor];
}

- (void)setBlockoutColors
{
    _dayOfWeekTextColor     = [UIColor wdprBlockOutDayOfWeekTextColor];
    _enabledDayTextColor    = [UIColor wdprBlockOutDayColor];
    _disabledDayTextColor   = [UIColor wdprBlockOutDayBlockedColor];
    _selectedDayTextColor   = [UIColor wdprBlockOutSelectedTextColor];
    _selectedDayCircleColor = [UIColor wdprBlockOutSelectedCircleColor];
    _selectedDayBlockedCircleColor = [UIColor wdprBlockOutSelectedBlockedCircleColor];
}

@end
