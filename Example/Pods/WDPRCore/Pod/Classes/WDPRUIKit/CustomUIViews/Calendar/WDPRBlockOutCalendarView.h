//
//  WDPRBlockOutCalendarView.h
//  DLR
//
//  Created by Olson, Jason on 4/24/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDPRCaledarCellColors.h"

typedef void (^cellButtonClickedBlock)(void);

@interface WDPRBlockOutCalendarView : UIView

@property (assign, nonatomic) NSInteger numberOfDaysToShow;
@property (strong, nonatomic) NSArray *blockoutDates;
@property (readonly, nonatomic) NSDate *selectedDate;
@property (assign, nonatomic) BOOL allowsSelection;
@property (strong, nonatomic) WDPRCaledarCellColors *controlColors;

/**
 Basic usage:
 
 WDPRBlockOutCalendarView *calendarView = [WDPRBlockOutCalendarView ...;
 
 
 - (void)updateSchedules
 {
 NSDate *newDate = calendarView.selectedDate;
 ...
 }
 
 
 WDPRBlockOutCalendarView *calendarView = [WDPRBlockOutCalendarView ...;
 
 __weak typeof(self) weakSelf = self;
 [calendarView setNewDateSelectedBlock:^
 {
 __strong typeof(self) strongSelf = weakSelf;
 [strongSelf updateSchedules];
 }];
 
 */
@property (strong, nonatomic) cellButtonClickedBlock newDateSelectedBlock;

+ (CGFloat)defaultViewHeight;

/// For inital display of items in ViewControllers:viewWillAppear
- (void)loadItems;

/// If you need to update dates
- (void)generateDates;

@end
