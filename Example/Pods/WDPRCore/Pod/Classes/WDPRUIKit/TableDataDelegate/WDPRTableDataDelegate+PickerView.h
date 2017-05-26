//
//  WDPRTableDataDelegate+PickerView.h
//  DLR
//
//  Created by german stabile on 3/4/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRTableDataDelegate.h"

@interface WDPRTableDataDelegate (PickerView) <UIPickerViewDataSource, UIPickerViewDelegate>

@property (nonatomic, readonly) UIView* pickerView;
@property (nonatomic, readonly) UIDatePicker *datePicker;
@property (nonatomic, readonly) UIPickerView *plainPicker;

- (UITableViewCell *)tableView:(UITableView *)tableView cellWithPickerAtIndexPath:(NSIndexPath *)indexPath;

- (void)tableView:(UITableView *)tableView closePickerForRowAtIndexPath:(WDPRIndexPath *)indexPath;

- (void)tableView:(UITableView*)tableView openPickerForRowAtIndexPath:(NSIndexPath*)indexPath;

@end
