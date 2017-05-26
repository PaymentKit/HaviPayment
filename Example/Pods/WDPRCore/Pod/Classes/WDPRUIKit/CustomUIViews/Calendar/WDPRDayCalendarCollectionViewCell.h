//
//  WDPRDayCalendarCollectionViewCell.h
//  DLR
//
//  Created by Olson, Jason on 4/24/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDPRCaledarCellColors.h"

@interface WDPRDayCalendarCollectionViewCell : UICollectionViewCell

@property (strong, nonatomic) UILabel *dayOfWeekLabel;
@property (strong, nonatomic) UILabel *dayLabel;
@property (strong, nonatomic) UIView *dayLabelSelected;
@property (strong, nonatomic) NSDate *displayDate;
@property (assign, nonatomic) BOOL blockOutDate;

/// Set when initalizing the cell, colors will be cached.
@property (strong, nonatomic) WDPRCaledarCellColors *controlColors;

+ (CGSize)cellSize;
+ (CGFloat)minimumInteritemSpacing;
+ (CGFloat)minimumLineSpacing;

/// Show circle
- (void)showSelectedStateAnimated:(BOOL)animated;

/// Hide circle
- (void)showDeselectedStateAnimated:(BOOL)animated;

@end
