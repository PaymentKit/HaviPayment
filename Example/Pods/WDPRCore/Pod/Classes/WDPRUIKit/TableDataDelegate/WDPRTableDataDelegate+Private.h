//
//  WDPRTableDataDelegate+Private.h
//  DLR
//
//  Created by german stabile on 3/6/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"

/**
 
 This header should only be imported by the relevants
 mTDD categories in the implementation file.
 
 It exposes private methods that only mTDD and its categories
 should know about
 
 **/


#pragma mark -

@interface WDPRTableDataDelegate () < UIWebViewDelegate >

@property (nonatomic) BOOL transitioningFocus;
@property (nonatomic) BOOL switchingEditFields;
@property (nonatomic) NSMutableSet* pendingReloads;

@property (nonatomic) CGFloat tableHeightDiff;

@property (nonatomic) UITextField* focusedTextField;

@property (nonatomic) UIView* pickerView;

@property (nonatomic) UIPopoverController* popoverController;

@end

@interface WDPRTableDataDelegate (Private)


#pragma mark mTDD+PickerView && mTDD+TextField methods

- (UIPickerView*)plainPicker;

- (UIDatePicker*)datePicker;

- (BOOL)isFirstEditableCell:(NSIndexPath*)path;

- (BOOL)isLastEditableCell:(NSIndexPath*)path;

//Selects next editable cell in the given direction
- (void)selectNextCell:(BOOL)forward tableView:(UITableView*)tableView;

- (BOOL)changeDetailValueForItemAtIndexPath:(NSIndexPath*)indexPath to:(id)newValue;


@end
