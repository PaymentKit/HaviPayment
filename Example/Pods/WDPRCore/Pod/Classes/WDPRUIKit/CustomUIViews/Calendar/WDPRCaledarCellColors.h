//
//  WDPRCaledarCellColors.h
//  DLR
//
//  Created by Olson, Jason on 4/26/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

typedef NS_ENUM(NSUInteger, WDPRCaledarCellColorsType)
{
    WDPRCaledarCellColorsTypeParkHours,
    WDPRCaledarCellColorsTypeBlockOut,
    WDPRCaledarCellColorsTypeNone
};


@interface WDPRCaledarCellColors : NSObject

- (instancetype)initWithType:(WDPRCaledarCellColorsType)type;

@property (strong, nonatomic) UIColor *dayOfWeekTextColor;
@property (strong, nonatomic) UIColor *enabledDayTextColor;
@property (strong, nonatomic) UIColor *disabledDayTextColor;
@property (strong, nonatomic) UIColor *selectedDayTextColor;
@property (strong, nonatomic) UIColor *selectedDayCircleColor;
@property (strong, nonatomic) UIColor *selectedDayBlockedCircleColor;

@end
