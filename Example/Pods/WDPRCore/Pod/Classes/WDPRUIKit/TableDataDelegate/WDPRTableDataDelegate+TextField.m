//
//  WDPRTableDataDelegate+TextField.m
//  DLR
//
//  Created by german stabile on 3/9/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRTableDataDelegate+TextField.h"
#import "WDPRTableDataDelegate+Private.h"

#define WDPRAccessibilityFocusDelay 0.2
#define WDPRAccessibilityAnnouncementDelay 2.2

@implementation WDPRTableDataDelegate (TextField)

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if (self.focusedTextField == textField)
    {
        MAKE_WEAK(self);
        executeOnNextRunLoop
        (^{
            MAKE_STRONG(self);
            strongself.focusedIndexPath = nil;
        });
        
        return NO;
    }
    // Restore accessibility for textField, the cell will be reconfigured
    // so no need of setting it as acessible
    textField.isAccessibilityElement = NO;
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    NSIndexPath* indexPath = self.focusedIndexPath;
    NSDictionary* item = [self itemAtIndexPath:indexPath];
    
    if ([(item[WDPRCellStyle] ?: @(self.cellStyle))
         isEqual:@(WDPRTableCellStyleFloatLabelField)] || item[WDPRCellKeyboardType])
    {
        // Any keyboard type item should be able to enter here
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        cell[@"isEditing"] = @(YES); 
        // First set the textField as accessible, and prevent the cell from being it
        textField.isAccessibilityElement = YES;
        cell.isAccessibilityElement = NO;
        // Grab the clear button
        UIButton *clearButton = [textField valueForKey:@"_clearButton"];
        // Set the field and the button as accessibilityElements for the cell
        cell.accessibilityElements = clearButton ? @[textField, clearButton] : @[textField];
        // skip reading "*" in placeholder
        if (!textField.text.length)
        {
            textField.accessibilityValue = [textField.placeholder stringByReplacingOccurrencesOfString:@"*" withString:@""];
        }
        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, textField);
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if (!self.transitioningFocus &&
        (textField == self.focusedTextField))
    {
        self.focusedIndexPath = nil;
    }
    
    CGPoint pointInTableView =
    [self.tableView convertPoint:textField.center
                        fromView:textField.superview];
    
    NSIndexPath* indexPath =
    [self.tableView indexPathForRowAtPoint:pointInTableView];
    
    // hack: subItemIndex is stored in textField.tag
    indexPath = [indexPath indexPathWithSubItemIndex:textField.tag];
    
    id item = [self itemAtIndexPath:indexPath];
    id newValue = textField.text ?: textField.attributedText;
    
    if ([(item[WDPRCellStyle] ?: @(self.cellStyle))
         isEqual:@(WDPRTableCellStyleFloatLabelField)] || item[WDPRCellKeyboardType])
    {
        // Any keyboard type item should be able to enter here
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
        [self.tableView cellForRowAtIndexPath:indexPath][@"isEditing"] = @(NO);
        cell.isAccessibilityElement = YES;
    }
    
    [self changeDetailValueForItemAtIndexPath:indexPath to:newValue];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    WDPRTableViewItem *item = [self itemAtIndexPath:self.focusedIndexPath];
    
    if (([item[WDPRCellKeyboardReturnKey] intValue] == UIReturnKeyDone) ||
        ([item[WDPRCellKeyboardReturnKey] intValue] == UIReturnKeyGo))
    {
        self.focusedIndexPath = nil;

        WDPRCellKeyboardButtonTappedBlockType block = item[WDPRCellKeyboardButtonTapped];

        SAFE_CALLBACK(block)
    }
    else
    {
        executeOnNextRunLoop
        (^{
            [self selectNextCell:YES tableView:self.tableView forItem:item usingDelay:NO];
        });
    }
    
    return NO;
}

- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range
replacementString:(NSString *)replacement
{
    NSIndexPath* indexPath = self.focusedIndexPath;
    NSDictionary* item = [self itemAtIndexPath:indexPath];
    
    if ([(item[WDPRCellStyle] ?: @(self.cellStyle))
         isEqual:@(WDPRTableCellStyleFloatLabelField)])
    {
        UITableViewCell* cell = [self.tableView
                                 cellForRowAtIndexPath:indexPath];
        
        UILabel* textLabel = cell.textLabel;
        
        if ([cell isKindOfClass:WDPRTableViewCell.class])
        {
            NSUInteger subItemIndex = indexPath.subItemIndex;
            textLabel = ((WDPRTableViewCell *)cell).textLabels[subItemIndex];
            
            if (subItemIndex > 0 && range.location == 12)
            {
                return NO;
            }
            
            if ([item[WDPRCellValidateAvoidExtraTextInput] boolValue])
            {
                NSString *nextString = [NSString stringWithFormat:@"%@%@", textField.text, replacement];
                BOOL willBeValid = [self isItemValid:item forValue:nextString];
                if (!willBeValid)
                {
                    return NO;
                }
            }
        }
        [textLabel setHidden:
         [textField.text stringByReplacingCharactersInRange:range
                                                 withString:replacement].length == 0];
    }
    
    if (item[WDPRCellSuggestionsDelegate])
    {
        WDPRLog(@"Inserting suggestions as cells");
        
        id <WDPRSuggestAsYouTypeDelegate> delegate = item[WDPRCellSuggestionsDelegate];
        
        if ([delegate respondsToSelector:@selector(suggestionsForCell:fromText:andTextField:)])
        {
            [delegate suggestionsForCell:item[WDPRCellRowID] fromText:replacement andTextField:textField];
        }
    }
    
    // NOTE: Autocorrect can trigger a change in our text field without a
    //       focusedIndexPath. This method requires an indexPath argument,
    //       so we avoid the call altogether.
    if (indexPath)
    {
        [self changeDetailValueForItemAtIndexPath:indexPath
                                               to:[textField.text
                                                   stringByReplacingCharactersInRange:range
                                                   withString:replacement]];
    }
    
    enum { kDefaultTextFieldHeight = 22 };
    if (textField.text.length == 0 && textField.frame.size.height > kDefaultTextFieldHeight)
    {
        enum { kDefaultTextFieldYPosition = 38 };
        textField.frame = CGRectMake(textField.frame.origin.x, kDefaultTextFieldYPosition,
                                     textField.frame.size.width, kDefaultTextFieldHeight);
    }
    // jfr 12/10/14: dunno if this is still needed or not, may have been iOS6 only issue
    //    // Check if the added string contains lowercase characters.
    //    // If so, those characters are replaced by uppercase characters.
    //    // But this has the effect of losing the editing point
    //    // (only when trying to edit with lowercase characters),
    //    // because the text of the UITextField is modified.
    //    // That is why we only replace the text when this is really needed.
    //    if (textField.autocapitalizationType == UITextAutocapitalizationTypeAllCharacters)
    //    {
    //        NSRange lowercaseCharRange;
    //        lowercaseCharRange = [string rangeOfCharacterFromSet:[NSCharacterSet lowercaseLetterCharacterSet]];
    //
    //        if (lowercaseCharRange.location != NSNotFound)
    //        {
    //            textField.text = [textField.text stringByReplacingCharactersInRange:range
    //                                                                     withString:[string uppercaseString]];
    //            return NO;
    //        }
    //    }
    
    return YES;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    NSIndexPath* indexPath = self.focusedIndexPath;
    
    NSDictionary* item = [self itemAtIndexPath:indexPath];
    UITableViewCell* cell = [self.tableView cellForRowAtIndexPath:indexPath];
    
    if ([(item[WDPRCellStyle] ?: @(self.cellStyle))
         isEqual:@(WDPRTableCellStyleFloatLabelField)])
    {
        UILabel* textLabel = cell.textLabel;
        
        if ([cell isKindOfClass:WDPRTableViewCell.class])
        {
            NSUInteger subItemIndex = indexPath.subItemIndex;
            textLabel = ((WDPRTableViewCell *)cell).textLabels[subItemIndex];
            
            if (subItemIndex > 0)
            {
                [self changeDetailValueForItemAtIndexPath:indexPath
                                                       to:@""];
            }
        }
        
        textLabel.hidden = YES;
    }
    
    id <WDPRSuggestAsYouTypeDelegate> delegate = item[WDPRCellSuggestionsDelegate];
    
    if ([delegate respondsToSelector:@selector(suggestionsForCell:fromText:andTextField:)])
    {
        [delegate suggestionsForCell:item[WDPRCellRowID] fromText:@"" andTextField:textField];
    }
    
    // Accessibility
    // skip reading "*" in placeholder
    textField.accessibilityValue = [textField.placeholder stringByReplacingOccurrencesOfString:@"*" withString:@""];

    return YES;
}

#pragma mark - TextField

- (void)tableView:(UITableView *)tableView addTextFieldToRowAtIndexPath:(NSIndexPath*)indexPath
{
    self.tableView = tableView;
    
    WDPRTableViewItem* item = [self itemAtIndexPath:// ignore subItemIndex
                          [NSIndexPath indexPathForRow:indexPath.row
                                             inSection:indexPath.section]];
    NSAssert(item.isMultiValueTableItem, @"precondition violation");
    
    WDPRTableViewCell * cell = ((WDPRTableViewCell *)
                                [tableView cellForRowAtIndexPath:indexPath]);
    UITextField* textField = (UITextField*)cell.contentView.subviews.lastObject;
    
    UILabel* detailLabel = cell.detailTextLabel;
    
    if ((textField.tag != indexPath.subItemIndex) ||
        ![textField isKindOfClass:UITextField.class])
    {
        [cell.contentView addSubview:textField =
         [[UITextField alloc] initWithFrame:CGRectZero]];
        
        // size the text field to use available space:
        CGRect frame = detailLabel.frame;
        
        enum { kInset = 10 };
        // ensure frame always stretches to right edge
        // of the contentView (minus an inset)
        frame.size.width = (cell.contentView.
                            frame.size.width -
                            frame.origin.x - kInset);
        
        if ([cell isA:WDPRTableViewCell.class] &&
            [item isA:WDPRTableMultipleItems.class] &&
            (cell.detailTextLabels.count >= indexPath.subItemIndex))
        {
            // hack: stash subItemIndex in textField.tag
            // (needed during textFieldDidEndEditing:)
            NSUInteger subItemIndex = (textField.tag =
                                       indexPath.subItemIndex);
            
            detailLabel = cell.detailTextLabels[subItemIndex];
            item = ((WDPRTableMultipleItems *)item)[subItemIndex];
            
            frame = detailLabel.frame;
            
            if (subItemIndex == 0) // ensure 0th width
            {
                frame.size.width = (cell.contentView.
                                    frame.size.width -
                                    frame.origin.x - kInset);
                
                frame.size.width /= cell.detailTextLabels.count;
            }
        }
        
        frame.origin.y = frame.origin.y + 1;
        
        textField.frame = frame;
        textField.delegate = self;
        
        // formatting
        textField.secureTextEntry = YES;
        textField.adjustsFontSizeToFitWidth = YES;
        
        textField.font = detailLabel.font;
        textField.textColor = UIColor.wdprDarkBlueColor;
        textField.textAlignment = detailLabel.textAlignment;
        
        // behavior
        textField.returnKeyType = [item[WDPRCellKeyboardReturnKey] intValue] ?: UIReturnKeyNext;
        textField.enablesReturnKeyAutomatically = NO;
        
        textField.autocorrectionType = UITextAutocorrectionTypeNo;
        textField.spellCheckingType = UITextSpellCheckingTypeNo;
        
        textField.clearButtonMode = UITextFieldViewModeWhileEditing;
        
        // Add toolbar to keyboard for data entry/edit with Previous and Next buttons:
        BOOL formAssistantHasNext = self.wrapEnabled || ![self isLastEditableCell:indexPath];
        BOOL formAssistantHasPrevious = self.wrapEnabled || ![self isFirstEditableCell:indexPath];
        
        MAKE_WEAK(self);
        if (formAssistantHasNext || formAssistantHasPrevious)
        {
            textField.inputAccessoryView =
            [UIToolbar
             wdprKeyboardToolBar:^(WDPRToolbarDirection direction)
             {
                 MAKE_STRONG(self);
                 if (direction == WDPRToolbarDone)
                 {
                     strongself.focusedIndexPath = nil;
                     [strongself focusVoiceOverOnCellAtIndexPath:indexPath];
                 }
                 else
                 {
                     BOOL forward = (direction == WDPRToolbarNext);
                     [strongself selectNextCell:forward tableView:tableView forItem:item usingDelay:YES];
                 }
             }
             hasNext:formAssistantHasNext
             hasPrevious:formAssistantHasPrevious];
        }
        else
        {
            textField.inputAccessoryView =
            [UIToolbar wdprDoneButtonRightToolBar:^(WDPRToolbarDirection direction)
             {
                 MAKE_STRONG(self);
                 if (direction == WDPRToolbarDone)
                 {
                     strongself.focusedIndexPath = nil;
                     [strongself focusVoiceOverOnCellAtIndexPath:indexPath];
                 }
             }];
        }
    }
    
    // per-item customizable behavior
    textField.textOrAttributedText = item[WDPRCellDetail];
    textField.keyboardType = [item[WDPRCellKeyboardType] intValue];
    
    textField.secureTextEntry = (//textField.clearsOnBeginEditing =
                                 [item[WDPRCellObscureText] boolValue]);
    
    textField.placeholderOrAttributedPlaceholder = item[WDPRCellPlaceholder];
    
    if (item[WDPRCellSpellChecking])
    {
        textField.spellCheckingType =  [item[WDPRCellSpellChecking] intValue];
    }
    
    if (item[WDPRCellAutocorrection])
    {
        textField.autocorrectionType = [item[WDPRCellAutocorrection] intValue];
    }
    
    if (item[WDPRCellAutocapitalization])
    {
        textField.autocapitalizationType = [item[WDPRCellAutocapitalization] intValue];
    }
    
    detailLabel.hidden = YES; // the textField's placeholder text "replaces" this
    self.focusedTextField = textField; // this must happen AFTER customization above
    
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, textField);
}

- (void)selectNextCell:(BOOL)forward tableView:(UITableView *)tableView forItem:(WDPRTableViewItem *)item
            usingDelay:(BOOL)useDelay
{
    if (!item[WDPRCellDetail] || ([item[WDPRCellDetail] isEqualToString:@""] &&
                                  !item[WDPRCellErrorState]))
    {
        item[WDPRCellErrorState] = @(![self isItemValid:item
                                               forValue:item[WDPRCellDetail]]);
    }
    if([item[WDPRCellErrorState] boolValue] && UIAccessibilityIsVoiceOverRunning())
    {
        NSString *format = WDPRLocalizedStringInBundle(@"com.wdprcore.tabledatadelegate.error.alerterror",
                                                       WDPRCoreResourceBundleName, nil);
        NSString *alert = [NSString stringWithFormat:format, [item errorMessage]];
        [self announceAlert:alert withDelay:useDelay ? WDPRAccessibilityAnnouncementDelay : 0
              andCompletion:^{
                  [self selectNextCell:forward
                             tableView:tableView];
              }];
    }
    else
    {
        [self selectNextCell:forward
                   tableView:tableView];
    }
}

- (void)focusVoiceOverOnCellAtIndexPath:(NSIndexPath *)indexPath
{
    MAKE_WEAK(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(WDPRAccessibilityFocusDelay * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
                       MAKE_STRONG(self);
                       WDPRTableViewCell * cell = ((WDPRTableViewCell *)
                                                   [strongself.tableView cellForRowAtIndexPath:indexPath]);
                       UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification,
                                                       cell);
                   });
}


@end
