//
//  WDPRTableDataDelegate+PickerView.m
//  DLR
//
//  Created by german stabile on 3/4/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRTableDataDelegate+PickerView.h"
#import "WDPRTableDataDelegate+Private.h"

#import "WDPRUIKit.h"

#define PickerCell @"pickerCell"
#define WDPRPickerViewOptionLabelFontSize 23

@implementation WDPRTableDataDelegate (PickerView)

- (UIDatePicker*)datePicker
{
    // we only support one pickerView, date or otherwise
    // at a time, so just use the same property to store it
    if (![self.pickerView isKindOfClass:UIDatePicker.class])
    {
        CGRect frame = CGRectZero;
        frame.size.height = 180; // arbitrary, non-zero
        self.pickerView = [[UIDatePicker alloc] initWithFrame:frame];
        
        [self sizePickerWidthToFitTableView];
        
        self.pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.pickerView.backgroundColor = [UIColor whiteColor];
        self.pickerView.opaque = YES;
        
        MAKE_WEAK(self);
        [(UIDatePicker*)self.pickerView 
         inResponseToControlEvents:UIControlEventValueChanged executeBlock:
         ^{
             MAKE_STRONG(self);
             
            if ([strongself.pickerView isKindOfClass:[UIDatePicker class]])
            {
                [strongself changeDetailValueForItemAtIndexPath:strongself.focusedIndexPath
                                                             to:strongself.datePicker.date];
            }
            else
            {
                strongself.focusedIndexPath = nil;
            }
             
         }];
    }
    
    return (UIDatePicker*)self.pickerView;
}

- (UIPickerView*)plainPicker
{
    // we only support one pickerView, date or otherwise
    // at a time, so just use the same property to store it
    if (![self.pickerView isKindOfClass:UIPickerView.class])
    {
        CGRect frame = CGRectZero;
        frame.size.height = 180; // arbitrary, non-zero
        self.pickerView = [[UIPickerView alloc] initWithFrame:frame];
        
        [self sizePickerWidthToFitTableView];
        
        ((UIPickerView*)self.pickerView).delegate = self;
        ((UIPickerView*)self.pickerView).dataSource = self;
        ((UIPickerView*)self.pickerView).showsSelectionIndicator = YES;
        self.pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        self.pickerView.backgroundColor = [UIColor whiteColor];
        self.pickerView.opaque = YES;
    }
    
    return (UIPickerView*)self.pickerView;
}

- (void)configurePicker:(NSDictionary*)item
{
    NSDictionary* options = item[WDPRCellOptions];
    
    if ([options isKindOfClass:NSArray.class])
    {
        NSAssert([self.pickerView
                  isKindOfClass:
                  UIPickerView.class], @"");
        
        [self.plainPicker reloadAllComponents];
    }
    else if ([options isKindOfClass:NSDictionary.class])
    {   // otherwise, it's a datePicker, configure it
        
        if (WDPRDatePickerModeMonthYear ==
            [options[WDPRDatePickerMode] intValue])
        {
            // special-case, not really a datePicker
            NSAssert([self.pickerView
                      isKindOfClass:
                      UIPickerView.class], @"");
            
            [self.plainPicker reloadAllComponents];
            
            if (options[WDPRCellMinimumDate])
            {
                NSDateComponents* dateComponents =
                [NSCalendar.currentCalendar
                 components:(NSCalendarUnitYear |
                             NSCalendarUnitMonth) fromDate:options[WDPRCellMinimumDate]];
                
                [self.plainPicker selectRow:dateComponents.month-1 inComponent:0 animated:NO];
                [self.plainPicker selectRow:0 inComponent:1 animated:NO];
            }
        }
        else
        {
            NSAssert([self.pickerView
                      isKindOfClass:UIDatePicker.class], @"");
            
            if ([item[WDPRCellDetail] isKindOfClass:NSDate.class])
            {
                self.datePicker.date = item[WDPRCellDetail];
            }
            
            self.datePicker.minimumDate = options[WDPRCellMinimumDate];
            self.datePicker.maximumDate = options[WDPRCellMaximumDate];
            
            WDPRDatePickerModeType mode = [options[WDPRDatePickerMode] intValue];
            self.datePicker.datePickerMode = ((mode ==
                                               WDPRDatePickerModeMonthYear) ?
                                              WDPRDatePickerModeDate : mode);
            
            if (options[WDPRCellMinuteInterval])
            {
                self.datePicker.minuteInterval= [options[WDPRCellMinuteInterval] integerValue];
            }
        }
    }
}

- (void)sizePickerWidthToFitTableView
{
    [self.pickerView sizeToFit];
    CGRect pickerFrame = self.pickerView.frame;
    pickerFrame.size.width = CGRectGetWidth(self.tableView.frame);
    self.pickerView.frame = pickerFrame;
}

#pragma mark - Public Methods

- (UITableViewCell *)tableView:(UITableView *)tableView
     cellWithPickerAtIndexPath:(NSIndexPath *)indexPath
{
    NSAssert(self.showPickersInline, @"");
    
    NSDictionary* item = [self itemAtIndexPath:indexPath];
    NSAssert([self.focusedIndexPath isEqual:
              [NSIndexPath indexPathForRow:indexPath.row-1
                                 inSection:indexPath.section]], @"");
    
    UITableViewCell* cell = ([tableView dequeueReusableCellWithIdentifier:PickerCell] ?:
                             [[UITableViewCell alloc] initWithStyle:
                              UITableViewCellStyleDefault reuseIdentifier:PickerCell]);
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (!cell.contentView.subviews.count)
    {
        NSDictionary* options = item[WDPRCellOptions];
        [cell.contentView addSubview:([options isA:NSArray.class] ?
                                      self.plainPicker : self.datePicker)];
        
        [self configurePicker:item];
        self.pickerView.frame = cell.contentView.bounds;
        self.pickerView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView closePickerForRowAtIndexPath:(WDPRIndexPath *)indexPath
{
    if (self.pickerView)
    {
        
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell[@"isEditing"] = @(NO);
        
        if (self.showPickersInline)
        {
            [tableView deleteRowsAtIndexPaths:
             @[[NSIndexPath indexPathForRow:indexPath.row+1
                                  inSection:indexPath.section]]
                                  withRowAnimation:UITableViewRowAnimationTop];
        }
        else
        {
            UIView* wrapperView = self.pickerView.superview;
            CGRect finalFrame = CGRectOffset(wrapperView.frame, 0,
                                             wrapperView.frame.size.height);
            
            // post a keyboardWillHide notification to act like a keyboard
            NSNotification* keyboardNotification =
            [NSNotification notificationWithName:UIKeyboardWillHideNotification
                                          object:nil userInfo:@
             {
                 UIKeyboardFrameEndUserInfoKey : [NSValue valueWithCGRect:finalFrame],
                 UIKeyboardFrameBeginUserInfoKey : [NSValue valueWithCGRect:wrapperView.frame],
             }];
            
            if (!self.switchingEditFields)
            {
                [NSNotificationCenter.defaultCenter postNotification:keyboardNotification];
            }
            
            // finally, animate the wrapperView offscreen and dispose of it (& toolbar w/it)
            [UIView animateWithDuration:0.2 animations:^{ wrapperView.frame = finalFrame; }
                             completion:^(BOOL finished){ [wrapperView removeFromSuperview]; }];
            
            if ([tableView.delegate respondsToSelector:@selector(tableView:didDismissPickerAtIndexPath:)])
            {
                executeOnNextRunLoop
                (^{
                    id<WDPRTableViewDelegate> delegate =
                    (id<WDPRTableViewDelegate>)tableView.delegate;
                    
                    [delegate tableView:tableView didDismissPickerAtIndexPath:indexPath];
                });
            }
        }
        
        self.pickerView = nil;
    }
}

- (void)tableView:(UITableView*)tableView openPickerForRowAtIndexPath:(NSIndexPath*)indexPath
{
    id item = [self itemAtIndexPath:indexPath];
    const BOOL wasAlreadyOpen = (self.pickerView != nil);
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
    cell[@"isEditing"] = @(YES);
    
    id options = item[WDPRCellOptions];
    if ([options count]) // skip if empty options
    {
        if ([options isKindOfClass:NSArray.class])
        {
            self.pickerView = self.plainPicker;
        }
        else if ([options isKindOfClass:NSDictionary.class])
        {
            if (WDPRDatePickerModeMonthYear ==
                [options[WDPRDatePickerMode] intValue])
            {
                // special-case plainPicker
                self.pickerView = self.plainPicker;
            }
            else
            {
                self.pickerView = self.datePicker;
            }
        }
        
        NSAssert(self.pickerView, @"this assertion should never fire");
        
        [self configurePicker:item]; // pickerIndexPath must be set first
        
        if (self.showPickersInline)
        {
            [tableView insertRowsAtIndexPaths:
             @[[NSIndexPath indexPathForRow:indexPath.row+1
                                  inSection:indexPath.section]]
                             withRowAnimation:UITableViewRowAnimationTop];
        }
        else if (IS_IPAD)
        {
            executeOnNextRunLoop
            (^{ // When the keyboard hides, this makes sure that the popover uses the new cell position
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                UIViewController* popoverContent = [[UIViewController alloc] init];
                popoverContent.view = self.pickerView;
                self.popoverController = [[UIPopoverController alloc] initWithContentViewController:popoverContent];
                self.popoverController.delegate = self;
                [self.popoverController setPopoverContentSize:popoverContent.view.bounds.size animated:YES];
                [self.popoverController presentPopoverFromRect:cell.bounds inView:cell.contentView
                                      permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
            });
        }
        else if (!wasAlreadyOpen)
        {
            MAKE_WEAK(self);
            BOOL formAssistantHasNext = self.wrapEnabled || ![self isLastEditableCell:indexPath];
            BOOL formAssistantHasPrevious = self.wrapEnabled || ![self isFirstEditableCell:indexPath];
            UIToolbar* toolbar =
                    [UIToolbar wdprKeyboardToolBar:^(WDPRToolbarDirection direction)
                     {
                         MAKE_STRONG(self);
                         if (direction == WDPRToolbarDone)
                         {
                             strongself.focusedIndexPath = nil;
                         }
                         else
                         {
                             BOOL forward = (direction == WDPRToolbarNext);
                             [strongself selectNextCell:forward
                                              tableView:tableView];
                         }
                     }
                                           hasNext:formAssistantHasNext
                                       hasPrevious:formAssistantHasPrevious];
            
            CGRect frame = UIScreen.mainScreen.bounds;
            frame.origin.y = frame.size.height;
            frame.size.height = (toolbar.bounds.size.height +
                                 self.pickerView.bounds.size.height);
            UIView* wrapperView = [[UIView alloc] initWithFrame:frame];
            
            [wrapperView addSubview:toolbar];
            [wrapperView addSubview:self.pickerView];
            [tableView.window addSubview:wrapperView];
            
            // get relative frame of wrapperView to superview
            CGRect finalFrame = CGRectOffset(wrapperView.frame, 0,
                                             -wrapperView.frame.size.height
                                             -[tableView.superview convertRect:tableView.superview.bounds toView:nil].origin.y);
            [tableView.superview addSubview:wrapperView];
            
            // position pickerView below toolbar (w/in wrapperView)
            self.pickerView.frame = CGRectOffset(self.pickerView.bounds,
                                                 0, toolbar.frame.size.height);
            
            // post a keyboardWillShow notification to act like a keyboard
            [NSNotificationCenter.defaultCenter postNotification:
             [NSNotification notificationWithName:
              UIKeyboardWillShowNotification object:nil userInfo:
              @{
                UIKeyboardFrameEndUserInfoKey : [NSValue valueWithCGRect:finalFrame],
                UIKeyboardFrameBeginUserInfoKey : [NSValue valueWithCGRect:wrapperView.frame],
                }]];
            
            // finally, animate the wrapperView into view
            [UIView animateWithDuration:0.2 animations:^{ wrapperView.frame = finalFrame; }];
            UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, self.pickerView);
        }
        
        if ([options isKindOfClass:NSArray.class] &&
            [self.pickerView isKindOfClass:UIPickerView.class])
        {
            MAKE_WEAK(self);
            executeOnNextRunLoop
            (^{  // set initial picker view index here at end of RunLoop
                MAKE_STRONG(self);
                
                NSUInteger rowToSelect =
                [options indexOfObject:item[WDPRCellDetail]];
                
                if (rowToSelect == NSNotFound) rowToSelect = 0;
                
                if (strongself.plainPicker.numberOfComponents > 0 &&
                    ([strongself.plainPicker numberOfRowsInComponent:0] > rowToSelect))
                {
                    [strongself.plainPicker selectRow:rowToSelect inComponent:0 animated:NO];
                }
                
                if (![[item[WDPRCellDetail] formattedDescription] length])
                {
                    [strongself changeDetailValueForItemAtIndexPath:indexPath
                                                                 to:options[rowToSelect]];
                }
            });
        }
    }
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    NSDictionary* item = 
    [self itemAtIndexPath:self.focusedIndexPath];
    
    if (!item) 
    {
        return 0;
    }
    
    id options = item[WDPRCellOptions];
    
    if (![options isA:NSDictionary.class])
    {
        Require(options, NSArray);
        return ([options[0] isA:NSArray.class] ? [options count] : 1);
    }
    else
    {
        NSAssert(WDPRDatePickerModeMonthYear ==
                 [options[WDPRDatePickerMode] intValue], @"");
        
        return 2; // special-case month/year "date" picker
    }
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    NSDictionary* item = 
    [self itemAtIndexPath:self.focusedIndexPath];
    
    id options = item[WDPRCellOptions];
    
    if ([options isKindOfClass:NSArray.class])
    {
        return ([options[0] isA:NSArray.class] ?
                [options[component] count] : [options count]);
    }
    else if ([options isKindOfClass:NSDictionary.class])
    {
        NSAssert(WDPRDatePickerModeMonthYear ==
                 [options[WDPRDatePickerMode] intValue], @"");
        
        switch (component)
        {
            default:
            {   return 0;
            }   break;
                
            case 0:
            {   return 12; // months
            }   break;
                
            case 1:
            {   return 100; // two digit years
            }   break;
        }
    }
    
    return 0;
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView
             titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    id options = [self itemAtIndexPath:self.focusedIndexPath][WDPRCellOptions];
    
    if ([options isKindOfClass:NSDictionary.class])
    {
        NSAssert(WDPRDatePickerModeMonthYear ==
                 [options[WDPRDatePickerMode] intValue], @"");
        
        if (component == 0) // months
        {
            row++;
        }
        else if (component == 1) // year
        {
            row = ([NSDate baseYear] % 100) + row;
        }
        
        return [NSString stringWithFormat:@"%0.2ld", (long)row];
    }
    else if ([options isKindOfClass:NSArray.class])
    {
        if ((component >= [options count]) ||
            ![options[component] isKindOfClass:NSArray.class])
        {
            // one-dimensional options (ignore component)
            return ([options[row] formattedDescription] ?: @"");
        }
        else
        {   // two-dimensional options ([component][row])
            NSArray* nestedArray = options[component];
            
            return ([nestedArray[row] formattedDescription] ?: @"");
        }
    }
    
    return @"";
}

- (void)pickerView:(UIPickerView *)pickerView
      didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    id newValue;
    id item = [self itemAtIndexPath:self.focusedIndexPath];
    
    id options = item[WDPRCellOptions];
    if (![options isKindOfClass:NSDictionary.class])
    {
        // TODO: flush out multi-column support
        if ( [options isKindOfClass:[NSArray class]])
        {
            // if we are using model objects as options, we want the actual object to be returned. otherwise this will be NSString
            newValue = options[row];
        }
    }
    else
    {
        NSAssert(WDPRDatePickerModeMonthYear ==
                 [options[WDPRDatePickerMode] intValue], @"");
        
        NSDateComponents* dateComponents = [NSDateComponents new];
        
        if (pickerView.numberOfComponents > 0)
        {
            dateComponents.month = ([pickerView selectedRowInComponent:0] + 1);
        }
        
        if (pickerView.numberOfComponents > 1)
        {
            dateComponents.year = ([NSDate baseYear] + [pickerView selectedRowInComponent:1]);
        }
        
        NSDate *selectedDate = [NSCalendar.currentCalendar dateFromComponents:dateComponents];
        
        unsigned unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth;
        NSDateComponents* minDateComponents = [NSCalendar.currentCalendar components:unitFlags
                                                                            fromDate:options[WDPRCellMinimumDate]];
        
        if (options[WDPRCellMinimumDate] &&
            ((dateComponents.year < minDateComponents.year) ||
             ((dateComponents.month < minDateComponents.month) &&
              (dateComponents.year <= minDateComponents.year))))
        {
            minDateComponents.month = dateComponents.month;
            minDateComponents.year = minDateComponents.year + 1;
            
            //Let's select the minimum expiration date
            newValue = [NSCalendar.currentCalendar dateFromComponents:minDateComponents];
            
            //Select this month in next year
            [pickerView selectRow:minDateComponents.month - 1 inComponent:0 animated:YES];
            [pickerView selectRow:1  inComponent:1 animated:YES];
        }
        else
        {
            newValue = selectedDate;
        }
    }
    
    //Some placeholder items don't have this value set, no need to update
    if (item[WDPRCellDetail])
    {
        [self changeDetailValueForItemAtIndexPath:self.focusedIndexPath to:newValue];
    }
}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row
          forComponent:(NSInteger)component reusingView:(UILabel *)label
{
    label = label ?: [[UILabel alloc] initWithFrame:CGRectZero];
    
    label.font = [label.font fontWithSize:WDPRPickerViewOptionLabelFontSize];
    label.textAlignment = NSTextAlignmentCenter;
    
    label.text = [self pickerView:pickerView
                      titleForRow:row forComponent:component];
    //label.text = [label.text stringByAppendingString:@"      "];
    
    id optionLabels = [self itemAtIndexPath:self.focusedIndexPath][WDPRCellOptionAccessibilityLabels];
    NSString *accessibilityLabel = nil;
    if ([optionLabels isKindOfClass:NSArray.class])
    {
        if ((component >= [optionLabels count]) ||
            ![optionLabels[component] isKindOfClass:NSArray.class])
        {
            // one-dimensional options (ignore component)
            accessibilityLabel = ([optionLabels[row] formattedDescription] ?: @"");
        }
        else
        {   // two-dimensional options ([component][row])
            NSArray* nestedArray = optionLabels[component];
            
            accessibilityLabel = ([nestedArray[row] formattedDescription] ?: @"");
        }
    }
    if (accessibilityLabel)
    {
        label.accessibilityLabel = accessibilityLabel;
    }
    
    return label;
}



@end
