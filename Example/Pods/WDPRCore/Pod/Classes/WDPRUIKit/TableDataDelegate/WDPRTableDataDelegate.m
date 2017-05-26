//
//  WDPRTableDataDelegate.m
//  WDPR
//
//  Created by Rodden, James on 6/28/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"

#import "WDPRTableDataDelegate+Private.h"
#import "WDPRTableDataDelegate+TextField.h"

// frameworks
#import <objc/runtime.h>

#define WebViewBlock    @"resizeBlock"

#define kDefaultFloatLabelFieldHeight 60

NSString* htmlify(NSString* string, BOOL includeRequiredFieldText)
{
    NSString* reqdFieldText = @"";
    
    if (includeRequiredFieldText)
    {
        reqdFieldText =
        [NSString stringWithFormat:
         @"<p><div class=\"calltextleft\">%@</div>",
         WDPRLocalizedStringInBundle(@"com.wdprcore.tabledatadelegate.requiredtext", WDPRCoreResourceBundleName, nil)];
    }
    
    return [NSString stringWithFormat:
            @"<html>%@%@</html>", string, reqdFieldText];
}

@interface WDPRTableDataDelegate()

@property (nonatomic) NSUInteger sectionToBeInsertedOrRemoved;
@property (nonatomic) PlainBlock announcementCompletionBlock;

@end

#pragma mark -

@implementation WDPRTableDataDelegate

- (void)dealloc
{
    [self removeAllObservers];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIAccessibilityAnnouncementDidFinishNotification
                                                  object:nil];
    self.focusedTextField = nil;
    
    [self.pickerView.superview removeFromSuperview];
}

- (id)initWithArray:(NSArray *)array
     sectionHeaders:(NSArray *)headers
     sectionFooters:(NSArray *)footers
{
    self = [super initWithArray:array
                 sectionHeaders:headers
                 sectionFooters:footers];
    
    if (self)
    {
        _selectionBlock = nil;
        
        [self observeRelevantChanges];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(announcementDidFinish)
                                                     name:UIAccessibilityAnnouncementDidFinishNotification object:nil];
        [self updateCurrentValidationStatus];
        
        // TODO: suggestionsResults needs revisitation
        self.suggestionsResults = [NSMutableArray new];
    }
    
    return self;
}

#pragma mark - Getters

- (BOOL)allItemsAreValid
{
    return (self.invalidItems.count == 0);
}

- (id)itemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!indexPath)
    {
        return nil;
    }
    
    if (self.focusedIndexPath &&
        self.showPickersInline &&
        (self.focusedIndexPath.row < indexPath.row) &&
        (self.focusedIndexPath.section == indexPath.section))
    {
        indexPath = [NSIndexPath indexPathForRow:indexPath.row - 1
                                       inSection:indexPath.section];
    }
    
    return [super itemAtIndexPath:indexPath];
}

- (BOOL)isFirstEditableCell:(NSIndexPath*)path
{
    BOOL result = YES;
    NSInteger startRow = path.row;
    for (NSInteger section = path.section; section >= 0; section--)
    {
        for (NSInteger row = startRow; row >= 0; row--)
        {
            if (!(section == path.section && row == path.row))
            {
                if ([self isCellEditableAtIndexPath:
                     [NSIndexPath indexPathForRow:row
                                        inSection:section]])
                {
                    return NO;
                }
            }
        }
        if (section > 0) {
            startRow = [self.tableView numberOfRowsInSection:section-1]-1;
        }
    }
    return result;
}

- (BOOL)isLastEditableCell:(NSIndexPath*)path
{
    BOOL result = YES;
    NSInteger startRow = path.row;
    for (NSInteger section = path.section;
         section < [self.tableView numberOfSections]; section++)
    {
        for (NSInteger row = startRow;
             row < [self.tableView numberOfRowsInSection:section]; row++)
        {
            if (!(section == path.section && row == path.row))
            {
                if ([self isCellEditableAtIndexPath:
                     [NSIndexPath indexPathForRow:row
                                        inSection:section]])
                {
                    return NO;
                }
            }
        }
        startRow = 0;
    }
    return result;
}

- (CGFloat)idealContentHeight:(UITableView *)tableView
{
    return tableView.idealContentHeight;
}

- (BOOL)isCellEditableAtIndexPath:(NSIndexPath*)path
{
    NSDictionary* item = [self itemAtIndexPath:path];
    BOOL hasRowHeight = ((!item[WDPRCellRowHeight]) ||
                         ([item[WDPRCellRowHeight] integerValue] != 0));
    
    return (item[WDPRCellPlaceholder] || item[WDPRCellOptions]) && hasRowHeight;
}

#pragma mark - Setters

- (void)setItems:(NSArray *)items
{
    // this is called by initializer, so be careful!!
    
    // first stop edit session, 
    if (self.focusedIndexPath && // only if there is one &
        ![self.items isEqual:items]) // items are changing
    {
        // and if the focused index section is greater or
        // equal than the section to be inserted or removed
        if (self.focusedIndexPath.section >= 
            self.sectionToBeInsertedOrRemoved)
        {
            self.focusedIndexPath = nil;
        }
    }
    
    self.sectionToBeInsertedOrRemoved = 0;
    
    [super setItems:items];
}

- (void)setSelectionBlock:(WDPRTableSelectionBlock)selectionBlock
{
    _selectionBlock = (selectionBlock ?:
                       ^(UITableView* a, WDPRIndexPath * b,
                         WDPRTableDataDelegate * c){ notYetImplemented(nil); });
}

- (void)setFocusedIndexPath:(WDPRIndexPath *)newIndexPath
{
    THIS_MUST_BE_ON_MAIN_THREAD
    
    if (!((_focusedIndexPath == newIndexPath) ||
          [_focusedIndexPath isEqual:newIndexPath]))
    {
        WDPRIndexPath * oldIndexPath = _focusedIndexPath;
        
        _focusedIndexPath = newIndexPath;
        [self setTransitioningFocus:((newIndexPath == nil) !=
                                     (oldIndexPath == nil))];
        
        void (^closeFocus)(void) =
        ^{   // end a textEdit/picker session
            [self updateTableInsets:NO];
            if (self.focusedTextField)
            {
                self.focusedTextField = nil;
            }
            else if (self.pickerView)
            {
                NSDictionary *item = [self itemAtIndexPath:oldIndexPath];
                SAFE_CALLBACK(((WDPRPickerLostFocusBlockType)item[WDPRPickerLostFocusBlock]),item);
                
                [self tableView:self.tableView closePickerForRowAtIndexPath:oldIndexPath];
            }
        };
        
        if (!newIndexPath)
        {
            closeFocus();
        }
        else    // start/transition an edit/picker session
        {
            if (oldIndexPath)
            {
                closeFocus(); // first close the old one
            }
            
            [self updateTableInsets:YES];
            NSDictionary* item = [self itemAtIndexPath:newIndexPath];
            
            [self.tableView scrollToRowAtIndexPath:newIndexPath
                                  atScrollPosition:UITableViewScrollPositionNone animated:NO];
            
            // Creating a pickerView takes priority over a textField
            // so that WDPRPlaceholder can be used to prompt the user.
            // If the item has an WDPRCellOptions entry, open pickerView.
            // array indicates a UIPickerView, dictionary a UIDatePicker
            if ([item[WDPRCellOptions] isKindOfClass:NSArray.class] ||
                [item[WDPRCellOptions] isKindOfClass:NSDictionary.class])
            {
                [self tableView:self.tableView openPickerForRowAtIndexPath:newIndexPath];
            }
            else if (item[WDPRCellPlaceholder])
            {
                [self tableView:self.tableView addTextFieldToRowAtIndexPath:newIndexPath];
            }
        }
        
        MAKE_WEAK(self);
        executeOnNextRunLoop(^{
            MAKE_STRONG(self);
            strongself.transitioningFocus = NO;
            if (oldIndexPath && !newIndexPath) {
                [strongself setVoiceOverFocusToNextCell:oldIndexPath];
            }
        });
    }
}

- (void)setFocusedTextField:(UITextField *)newFocus
{
    THIS_MUST_BE_ON_MAIN_THREAD
    
    if (_focusedTextField != newFocus)
    {
        id oldFocus = _focusedTextField;
        
        _focusedTextField = newFocus;
        [newFocus becomeFirstResponder];
        
        self.switchingEditFields = NO;
        
        [oldFocus removeFromSuperview];
        [oldFocus resignFirstResponder];
    }
}

- (void)setVoiceOverFocusToNextCell:(NSIndexPath*) indexPath {
    
    THIS_MUST_BE_ON_MAIN_THREAD
    
    NSDictionary* item = [self itemAtIndexPath:indexPath];
    if (![item[WDPRCellErrorState] boolValue]) {
        NSInteger startRow = indexPath.row;
        for (NSInteger section = indexPath.section; section < [self.tableView numberOfSections]; section++) {
            for (NSInteger row = startRow; row < [self.tableView numberOfRowsInSection:section]; row++) {
                if (!(section == indexPath.section && row == indexPath.row)) {
                    NSIndexPath* path = [NSIndexPath indexPathForRow:row inSection:section];
                    NSDictionary* nextItem = [self itemAtIndexPath:path];
                    if (!nextItem[WDPRCellRowHeight] || [nextItem[WDPRCellRowHeight] integerValue] != 0) {
                        UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, [self.tableView cellForRowAtIndexPath:path]);
                        return;
                    }
                }
            }
            startRow = 0;
        }
    }
    UIAccessibilityPostNotification(UIAccessibilityLayoutChangedNotification, [self.tableView cellForRowAtIndexPath:indexPath]);
}

- (void)selectNextCell:(BOOL)forward tableView:(UITableView*)tableView
{
    THIS_MUST_BE_ON_MAIN_THREAD
    
    //    NSAssert(self.focusedIndexPath, @"");
    NSInteger direction = (forward ? 1 : -1);
    
    // select next editable cell (those with WDPRCellPlaceholder or WDPRCellOptions)
    NSUInteger startRow = self.focusedIndexPath.row;
    NSUInteger startIndex = self.focusedIndexPath.subItemIndex;
    
    for (NSUInteger section = self.focusedIndexPath.section; ; section += direction)
    {
        for (NSUInteger row = startRow;
             row < [self tableView:tableView numberOfRowsInSection:section]; row += direction)
        {
            NSIndexPath* indexPath =
            [NSIndexPath indexPathForRow:row inSection:section];
            
            NSDictionary* item = [self itemAtIndexPath:indexPath];
            
            // skip this row if it has no height (is hidden)
            if ([(item[WDPRCellRowHeight] ?:
                  @(self.tableView.rowHeight)) integerValue])
            {
                NSUInteger numSubItems = 1;
                
                if ([item isKindOfClass:WDPRTableMultipleItems.class])
                {
                    numSubItems = ((WDPRTableMultipleItems *)item).numItems;
                }
                
                if ((direction < 0) &&
                    (startIndex == NSUIntegerMax))
                {
                    startIndex = numSubItems;
                }
                
                for (NSUInteger subItemIndex = startIndex + direction;
                     subItemIndex < numSubItems; subItemIndex += direction)
                {
                    if ((row == self.focusedIndexPath.row) &&
                        (section == self.focusedIndexPath.section) &&
                        (subItemIndex == self.focusedIndexPath.subItemIndex))
                    {
                        return; // cycled back to original cell, stop
                    }
                    else
                    {
                        NSDictionary* theItem = item;
                        if ([item isKindOfClass:WDPRTableMultipleItems.class])
                        {
                            theItem = [(WDPRTableMultipleItems *)item
                                       objectAtIndexedSubscript:subItemIndex];
                            
                            indexPath = [indexPath indexPathWithSubItemIndex:subItemIndex];
                            if (!UIAccessibilityIsVoiceOverRunning()) {
                                WDPRTableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
                                [cell prepareForReuse];
                            }
                        }
                        
                        if (theItem[WDPRCellPlaceholder] || theItem[WDPRCellOptions])
                        {
                            [UIView
                             animateWithDuration:0.2 animations:
                             ^{
                                 [tableView selectRowAtIndexPath:indexPath animated:NO
                                                  scrollPosition:UITableViewScrollPositionNone];
                                 
                                 [tableView scrollToRowAtIndexPath:indexPath // yes, we need both
                                                  atScrollPosition:UITableViewScrollPositionNone animated:NO];
                             }
                             completion:^(BOOL finished)
                             {
                                 [tableView.delegate tableView:tableView didSelectRowAtIndexPath:indexPath];
                             }];
                            
                            self.switchingEditFields = YES;
                            return; // found next cell and selected it
                        }
                    }
                }
            }
            
            startIndex = NSUIntegerMax;
        }
        
        if (direction > 0)
        {
            startRow = 0;
            
            if (section == ([self numberOfSectionsInTableView:tableView] - 1))
            {
                section = NSUIntegerMax; // adding 1 will make us start with 0
            }
        }
        else
        {
            if (section == 0)
            {   // wrap to end of sections
                section = [self numberOfSectionsInTableView:tableView];
            }
            
            // start with last row in previous section
            startRow = [self tableView:tableView numberOfRowsInSection:section-1] - 1;
        }
    }
}

- (void)announceAlert:(NSString*)alert
            withDelay:(CGFloat)delay
        andCompletion:(PlainBlock)completion
{
    self.announcementCompletionBlock = completion;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, alert);
    });
}

- (void)announcementDidFinish
{
    // We want this to be performed only once
    SAFE_CALLBACK(self.announcementCompletionBlock);
    self.announcementCompletionBlock = nil;
}

#pragma mark - Item Manipulation

- (void)deleteSection:(NSUInteger)section
     withRowAnimation:(UITableViewRowAnimation)animation
{
    if (!NSThread.isMainThread)
    {
        executeOnMainThread
        (^{
            [self deleteSection:section withRowAnimation:animation];
        });
    }
    else
    {    // NOTE: this assumes 2-dimensional items
        
        if (section < self.items.count)
        {
            NSMutableArray* items = self.items.mutableCopy;
            [items removeObjectAtIndex:section];
            
            self.sectionToBeInsertedOrRemoved = section;
            
            self.items = items.copy;
            
            if (section < self.headers.count)
            {
                NSMutableArray* headers =  self.headers.mutableCopy;
                [headers removeObjectAtIndex:section];
                self.headers = headers.copy;
            }
            
            if (section < self.footers.count)
            {
                NSMutableArray* footers = self.footers.mutableCopy;
                [footers removeObjectAtIndex:section];
                self.footers = footers.copy;
            }
            
            [self.tableView deleteSections:
             [NSIndexSet indexSetWithIndex:section] withRowAnimation:animation];
        }
    }
}

- (id)replaceItem:(id)item with:(id)newItem
{
    return [self replaceItem:item with:newItem delayedRefresh:YES];
}

- (id)replaceItemAtIndexPath:(NSIndexPath*)indexPath with:(id)newItem
{
    return [self replaceItemAtIndexPath:indexPath with:newItem delayedRefresh:YES];
}

- (id)replaceItem:(id)item with:(id)newItem delayedRefresh:(BOOL)delayedRefresh
{
    THIS_MUST_BE_ON_MAIN_THREAD
    
    // NOTE: this works with both single and double dimension item
    // arrays, it does NOT support anything beyond that....YMMV
    
    if (item != newItem) // ptr, not content compare
    {
        __block BOOL found;
        MAKE_WEAK(self);
        MAKE_WEAK(_tableView);
        
        NSMutableArray *newItems = self.items.mutableCopy;
        
        if ([newItem isKindOfClass:NSDictionary.class])
        {
            newItem = [WDPRTableViewItem
                       tableDynamicItemWithData:newItem];
        }
        
        void (^refreshItem)(NSIndexPath*) = ^(NSIndexPath* indexPath)
        {
            MAKE_STRONG(self);
            MAKE_STRONG(_tableView);
            
            if ([strongself.focusedIndexPath isEqual:indexPath])
            {
                // Ensure we can resign before trying to do so
                if (strongself.focusedTextField.isFirstResponder &&
                    strongself.focusedTextField.canResignFirstResponder)
                {
                    [strongself.focusedTextField resignFirstResponder];
                }
            }
            
            if (!delayedRefresh)
            {
                [strong_tableView
                 reloadRowsAtIndexPaths:@[indexPath]
                 withRowAnimation:UITableViewRowAnimationNone];
            }
            else
            {
                // place in back of queue to work properly
                // eg, validate won't show red if not done.
                executeOnNextRunLoop
                (^{
                    MAKE_STRONG(_tableView);
                    if ((indexPath.section < strong_tableView.numberOfSections) &&
                        (indexPath.row < [strong_tableView numberOfRowsInSection:indexPath.section]))
                    {
                        [strong_tableView beginUpdates];
                        [strong_tableView
                         reloadRowsAtIndexPaths:@[indexPath]
                         withRowAnimation:UITableViewRowAnimationNone];
                        [strong_tableView endUpdates];
                    }
                });
            }
        };
        
        [self.items enumerateObjectsUsingBlock:
         ^(NSArray* rootItem, NSUInteger section, BOOL *stop1)
         {
             if (rootItem == item)
             {
                 *stop1 = found = YES;
                 newItems[section] = newItem;
                 
                 refreshItem([NSIndexPath indexPathForRow:section inSection:0]);
             }
             if ([rootItem isKindOfClass:NSArray.class])
             {
                 [rootItem.copy enumerateObjectsUsingBlock:
                  ^(id obj, NSUInteger row, BOOL *stop2)
                  {
                      if (obj == item) // ptr, not content compare
                      {
                          *stop1 = *stop2 = found = YES;
                          newItems[section] = rootItem.mutableCopy;
                          newItems[section][row] = newItem;
                          
                          refreshItem([NSIndexPath indexPathForRow:row
                                                         inSection:section]);
                      }
                  }];
             }
         }];
        
        if (found)
        {
            self.items = newItems.copy;
            if (newItem[WDPRCellValueChangedBlock])
            {
                ((WDPRCellValueChangedBlockType)
                 newItem[WDPRCellValueChangedBlock])(newItem);
            }
        }
        return found ? newItem : nil;
    }
    
    return item;
}

- (BOOL)changeDetailValueForItemAtIndexPath:(NSIndexPath*)indexPath to:(id)newValue
{
    NSMutableDictionary* item =
    [self itemAtIndexPath:indexPath];
    
    NSAssert(item.isMultiValueTableItem, nil);
    
    id oldValue = item[WDPRCellDetail];
    
    BOOL newValueIsValid = [self isItemValid:item
                                    forValue:newValue];
    
    if (!newValueIsValid)
    {
        [self addToInvalidItems:indexPath];
    }
    else
    {
        [self removeFromInvalidItems:indexPath];
    }
    
    void (^configCellBlock)(void) = ^{
        
        NSIndexPath* theIndexPath =
        [NSIndexPath indexPathForRow:indexPath.row
                           inSection:indexPath.section];
        
        UITableViewCell* cell =
        [self.tableView cellForRowAtIndexPath:indexPath];
        
        [self configureCell:cell forItem:nil
                atIndexPath:theIndexPath inTable:self.tableView];
        
    };
    
    if (![newValue isEqual:oldValue] || !newValueIsValid)
    {
        item[WDPRCellDetail] = newValue;
        
        // real-time validation is always enabled
        item[WDPRCellErrorState] = @(!newValueIsValid);
        
        executeOnNextRunLoop
        (^{
            [self.tableView beginUpdates];
            
            onExitFromScope
            (^{
                [self.tableView endUpdates];
            });
            
            if (item[WDPRCellValueChangedBlock])
            {
                ((WDPRCellValueChangedBlockType)
                 item[WDPRCellValueChangedBlock])(item);
            }
            
            if (self.focusedIndexPath && // editing same row?
                (self.focusedIndexPath.row == indexPath.row) &&
                (self.focusedIndexPath.section == indexPath.section))
            {                
                configCellBlock();
            }
            else
            {
                [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                                      withRowAnimation:UITableViewRowAnimationNone];
            }
        });
        
        return YES;
    }
    else
    {
         configCellBlock();
         return NO;
    }
}

- (void)insertItem:(id)item
       atIndexPath:(NSIndexPath*)indexPath
  withRowAnimation:(UITableViewRowAnimation)animation
{
    NSAssert(item, @"");
    NSAssert(self.items, @"");
    
    if (!NSThread.isMainThread)
    {
        executeOnMainThread
        (^{
            [self insertItem:item
                 atIndexPath:indexPath
            withRowAnimation:animation];
        });
    }
    else
    {   // NOTE: this assumes 2-dimensional items
#ifndef InsertEmptyElementsWhenInserting
        {
            NSInteger sectionIdx = MIN(indexPath.section,
                                       self.items.count);
            
            NSInteger rowIndex =
            ((sectionIdx == self.items.count) ? 0 :
             MIN(indexPath.row, [self.items[sectionIdx] count]));
            
            indexPath = [NSIndexPath indexPathForRow:rowIndex
                                           inSection:sectionIdx];
        }
#endif
        
        // ensure items is mutable and long enough
        NSMutableArray* items = [self.items mutableCopy];
        while (indexPath.section > (items.count-1))
        {
            [items addObject:@[]];
        }
        
        // create mutable copy of the section to which to add
        NSMutableArray* section = [items[indexPath.section] mutableCopy];
        
        // ensure the section is long enough
        while (indexPath.row > section.count)
        {
            [section addObject:@""];
        }
        
        // add the new item into the mutable section
        [section insertObject:item atIndex:indexPath.row];
        
        // replace the old section with the new version
        [items replaceObjectAtIndex:indexPath.section withObject:section.copy];
        
        // finally, replace the items with the new version
        self.items = items.copy;
        
        // update the tableView to include the new item
        [self.tableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
    }
}

- (void)deleteItemAtIndexPath:(NSIndexPath*)indexPath
             withRowAnimation:(UITableViewRowAnimation)animation
{
    if (!NSThread.isMainThread)
    {
        executeOnMainThread
        (^{
            [self deleteItemAtIndexPath:indexPath withRowAnimation:animation];
        });
    }
    else
    {   // NOTE: this assumes 2-dimensional items
        
        if ((indexPath.section < self.items.count) &&
            (indexPath.row < [self.items[indexPath.section] count]))
        {
            // ensure items is mutable
            NSMutableArray* items = [self.items mutableCopy];
            
            // create mutable copy of the section from which to delete
            NSMutableArray* section = [items[indexPath.section] mutableCopy];
            
            // remove the specified item
            [section removeObjectAtIndex:indexPath.row];
            
            // replace the old section with the new version
            [items replaceObjectAtIndex:indexPath.section withObject:section.copy];
            
            // finally, replace the items with the new version
            self.items = items.copy;
            
            // update the tableView to delete the item
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:animation];
        }
    }
}

- (id)replaceItemAtIndexPath:(NSIndexPath*)indexPath
                        with:(id)newItem delayedRefresh:(BOOL)delayedRefresh
{
    THIS_MUST_BE_ON_MAIN_THREAD
    NSAssert([self itemAtIndexPath:indexPath], @"");
    
    NSMutableArray* items = self.items.mutableCopy;
    NSMutableArray* section = self.items[indexPath.section];
    
    if (![section isKindOfClass:NSArray.class])
    {
        [items replaceObjectAtIndex:indexPath.section withObject:newItem];
    }
    else
    {
        section = [section mutableCopy];
        
        [section replaceObjectAtIndex:indexPath.row withObject:newItem];
        
        // replace the old section with the new version
        [items replaceObjectAtIndex:indexPath.section withObject:section.copy];
    }
    
    // finally, replace the items with the new version
    self.items = items.copy;
    
    if (!delayedRefresh)
    {
        [self.tableView reloadRowsAtIndexPaths:@[indexPath]
                              withRowAnimation:UITableViewRowAnimationNone];
    }
    else
    {
        MAKE_WEAK(_tableView);
        executeOnNextRunLoop
        (^{
            MAKE_STRONG(_tableView);
            if ((indexPath.section < strong_tableView.numberOfSections) &&
                (indexPath.row < [strong_tableView numberOfRowsInSection:indexPath.section]))
            {
                [strong_tableView reloadRowsAtIndexPaths:@[indexPath]
                                        withRowAnimation:UITableViewRowAnimationNone];
            }
        });
    }
    
    if (newItem[WDPRCellValueChangedBlock])
    {
        ((WDPRCellValueChangedBlockType)newItem[WDPRCellValueChangedBlock])(newItem);
    }
    
    return newItem;
}

- (void)insertSection:(NSArray*)newItems
              atIndex:(NSUInteger)section
           withHeader:(id)header andFooter:(id)footer
     withRowAnimation:(UITableViewRowAnimation)animation
{
    if (!NSThread.isMainThread)
    {
        executeOnMainThread
        (^{
            [self insertSection:newItems
                        atIndex:section withHeader:header
                      andFooter:footer withRowAnimation:animation];
        });
    }
    else
    {
#ifndef InsertEmptyElementsWhenInserting
        section = MIN(section, self.items.count);
#endif
        
        // inserting an empty section works too
        if (newItems) Require(newItems, NSArray);
        
        // NOTE: this assumes 2-dimensional items
        
        {   // ensure items is mutable and long enough
            NSMutableArray* items = [(self.items ?:@[]) mutableCopy];
            
            while (section > items.count)
            {
                [items addObject:@[]];
            }
            
            // insert the newItems into our items array
            [items insertObject:(newItems ?:@[]) atIndex:section];
            
            self.sectionToBeInsertedOrRemoved = section;
            
            self.items = items.copy;
        }
        
        if (header || // don't forget headers
            (self.headers && (section < self.headers.count)))
        {
            // ensure headers is mutable and long enough
            NSMutableArray* headers = [(self.headers ?:@[]) mutableCopy];
            
            while (section > headers.count)
            {
                [headers addObject:@""];
            }
            
            [headers insertObject:(header ?:@"") atIndex:section];
            
            self.headers = headers.copy;
        }
        
        if (footer || // don't forget footers
            (self.footers && (section < self.footers.count)))
        {
            // ensure footers is mutable and long enough
            NSMutableArray* footers = [(self.footers ?: @[]) mutableCopy];
            
            while (section > footers.count)
            {
                [footers addObject:@""];
            }
            
            [footers insertObject:(footer ?:@"") atIndex:section];
            
            self.footers = footers.copy;
        }
        
        // update the tableView to include the new section
        [self.tableView insertSections:
         [NSIndexSet indexSetWithIndex:section] withRowAnimation:animation];
    }
}

#pragma mark - Validation - invalid items
- (void)addToInvalidItems:(id)object
{
    self.invalidItems = [self.invalidItems setByAddingObject:object];
}

- (void)removeFromInvalidItems:(id)object
{
    if (!object)
    {
        return;
    }
    
    NSMutableSet *newSet = [NSMutableSet setWithSet:self.invalidItems];
    [newSet removeObject:object];
    
    self.invalidItems = newSet.copy;
}


#pragma mark - Internal Actions
- (void)customizeTable:(UITableView *)tableView
{
    self.tableView = tableView;
    [self registerCellsForReuse:tableView];
    
    if (tableView.style == UITableViewStylePlain)
    {
        if (!tableView.tableFooterView)
        {
            tableView.sectionHeaderHeight = 10;
            
            // create a dummy footerView to disable
            // lines in the blank space below content
            tableView.tableFooterView =
            [[UIView alloc] initWithFrame:CGRectZero];
        }
        
        enum { edgeInset = 16 };
        tableView.separatorInset = UIEdgeInsetsMake(0, edgeInset, 
                                                    0, edgeInset);
    }
    else
    {
        tableView.sectionHeaderHeight = 5;
        tableView.sectionFooterHeight = 5;
        
        [tableView setSeparatorStyle:
         UITableViewCellSeparatorStyleNone];
        
        [tableView setSeparatorColor:tableView.backgroundColor];
        
        if (!tableView.tableHeaderView)
        {
            // we need a little extra white space at the top
            [tableView setTableHeaderView:
             [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 10)]];
        }
    }
}

- (void)observeRelevantChanges
{
    MAKE_WEAK(self);
    
    [self observeNotificationName:
     UIContentSizeCategoryDidChangeNotification object:nil
                            queue:NSOperationQueue.mainQueue
                       usingBlock:^(NSNotification *note)
     {
         executeOnNextRunLoop
         (^{
             MAKE_STRONG(self);
             [strongself.tableView reloadData];
         });
     }];
    
    // detect changes to items
    [self addObserver:self keyPath:@"items" block:
     ^(id observedObject, NSString *keyPath, NSDictionary *change)
     {
         MAKE_STRONG(self);
         [strongself updateCurrentValidationStatus];
     }];
    
    // monitor changes to edited items
    [self addObserver:self keyPath:@"focusedIndexPath"
              options:NSKeyValueObservingOptionOld block:
     ^(WDPRTableDataDelegate * dataDelegate, NSString *keyPath, NSDictionary *change)
     {
         NSIndexPath* indexPath = change[NSKeyValueChangeOldKey];
         
         if ([indexPath isKindOfClass:NSIndexPath.class])
         {
             id item = [dataDelegate itemAtIndexPath:indexPath];
             
             if (![dataDelegate isItemValid:item])
             {
                 [dataDelegate addToInvalidItems:indexPath];
             }
             else
             {
                 [dataDelegate removeFromInvalidItems:indexPath];
             }
         }
     }];
}

- (void)updateTableInsets:(BOOL)show
{
    if (!self.tableView.scrollEnabled)
    {
        return;
    }
    NSIndexPath* indexPath = self.focusedIndexPath;
    
    if (show && self.keyboardHeight > 0 && self.tableHeightDiff == 0)
    {
        CGRect cellRect = [self.tableView
                           rectForRowAtIndexPath:self.focusedIndexPath];
        
        CGFloat yDiff  = SCREEN_HEIGHT -
        self.tableView.superview.superview.frame.size.height;
        
        UITableViewScrollPosition scrollPosition = (yDiff > 0) ?
        UITableViewScrollPositionMiddle : UITableViewScrollPositionBottom;
        
        UIToolbar *toolbar = [UIToolbar wdprKeyboardToolBar:nil
                                                    hasNext:YES
                                                hasPrevious:YES];
        
        self.tableHeightDiff = self.keyboardHeight
        - CGRectGetMinY(self.tableView.frame) - toolbar.frame.size.height - 20;
        
        NSDictionary *item = [self itemAtIndexPath:self.focusedIndexPath];
        self.tableHeightDiff += !item[WDPRCellOptions] ? 40 : 0;
        
        UIEdgeInsets tableInsets = self.tableView.contentInset;
        tableInsets.bottom += self.tableHeightDiff;
        self.tableView.contentInset = tableInsets;
        
        if ( (CGRectGetMaxY(cellRect) + toolbar.frame.size.height) + yDiff > self.keyboardHeight)
        {
            [self.tableView scrollToRowAtIndexPath:indexPath
                                  atScrollPosition:scrollPosition animated:NO];
        }
    }
    else
    {
        if (self.tableHeightDiff != 0 && !show)
        {
            UIEdgeInsets tableInsets = self.tableView.contentInset;
            tableInsets.bottom -= self.tableHeightDiff;
            self.tableHeightDiff = 0;
            self.tableView.contentInset = tableInsets;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    self.tableView = tableView;
    
    return [super numberOfSectionsInTableView:tableView];
}

- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tableView = tableView;
    
    if (!self.pickerView || !self.showPickersInline ||
        ![indexPath isEqual:
          [NSIndexPath indexPathForRow:self.focusedIndexPath.row+1
                             inSection:self.focusedIndexPath.section]])
    {
        return [super tableView:tableView cellForRowAtIndexPath:indexPath];
    }
    else return [self tableView:tableView cellWithPickerAtIndexPath:indexPath];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    self.tableView = tableView;
    
    return [super tableView:tableView titleForHeaderInSection:section];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    self.tableView = tableView;
    
    return [super tableView:tableView titleForFooterInSection:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    self.tableView = tableView;
    
    NSInteger numRows = [super tableView:tableView
                   numberOfRowsInSection:section];
    
    if (self.focusedIndexPath &&
        self.pickerView && self.showPickersInline &&
        (self.focusedIndexPath.section == section))
    {
        numRows++;
    }
    
    return numRows;
}

#pragma mark - UITableViewDelegate

- (NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tableView = tableView;
    
    NSDictionary* item = [self itemAtIndexPath:indexPath];
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    const BOOL isDisabled = [item[WDPRCellDisabled] boolValue];
    const BOOL isButtonCell = [cell.reuseIdentifier hasSubstring:ButtonCellReuseID];
    const BOOL isPickerCell = (item.isMultiValueTableItem && item[WDPRCellOptions]);
    const BOOL isTextFieldCell = (!item[WDPRCellOptions] && item[WDPRCellPlaceholder]);
    
    return ((!isDisabled &&
             (isButtonCell || isPickerCell || isTextFieldCell ||
              (cell.selectionStyle != UITableViewCellSelectionStyleNone))) ? indexPath : nil);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tableView = tableView;
    
    UITableViewCell* cell = 
    [tableView cellForRowAtIndexPath:indexPath];
    
    NSDictionary* item = [self itemAtIndexPath:indexPath];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if ([cell isKindOfClass:WDPRExpandableCell.class])
    {
        [(WDPRExpandableCell*)cell toggleExpansionState];
        item[WDPRCellExpanded] = cell[NSStringFromSelector
                                      (@selector(isExpanded))];
        
        SAFE_CALLBACK(((WDPRCellValueChangedBlockType)
                       item[WDPRCellValueChangedBlock]), item);
    }
    else if ([item isKindOfClass:WDPRTableDisclosureItem.class])
    {
        // disclosureItem was tapped
        
        NSIndexPath* detailIndexPath =
        [NSIndexPath indexPathForRow:indexPath.row+1
                           inSection:indexPath.section];
        
        item[WDPRCellExpanded] = @(![item[WDPRCellExpanded] boolValue]);
        
        [tableView reloadRowsAtIndexPaths:@[indexPath, detailIndexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
        
        if (((WDPRTableDisclosureItem *)item).expanded)
        {
            [tableView scrollToRowAtIndexPath:detailIndexPath
                             atScrollPosition:UITableViewScrollPositionNone
                                     animated:YES];
        }
        
        SAFE_CALLBACK(((WDPRCellValueChangedBlockType)
                       item[WDPRCellValueChangedBlock]), item);
    }
    else if (item.isMultiValueTableItem &&
             (item[WDPRCellOptions] || item[WDPRCellPlaceholder]))
    {
        // either a textEdit or pickerView item was tapped
        
        if ([indexPath isEqual:self.focusedIndexPath] &&
            item[WDPRCellOptions] && self.showPickersInline)
        {
            indexPath = nil; // close inline pickerView
        }
        
        // special-handling for multiple items in a row
        if ([cell isKindOfClass:WDPRTableViewCell.class] &&
            [item isKindOfClass:WDPRTableMultipleItems.class])
        {
            if (cell.asWDPRTableViewCell.touchedSubview &&
                !UIAccessibilityIsVoiceOverRunning()) {
                indexPath = [indexPath indexPathWithSubItemIndex:
                             cell.asWDPRTableViewCell.touchedSubview.tag];
            }
            else if (!indexPath.subItemIndex) {
                indexPath = [indexPath indexPathWithSubItemIndex:0];
            }
        }
        
        self.switchingEditFields = YES;
        self.focusedIndexPath = [WDPRIndexPath indexPath:indexPath];
    }
    else
    {   // "standard" (non textField/picker) handling
        // if there is a checkmarkedItem, maintain a single-checkmark
        if (self.checkmarkedItem &&
            ![self.checkmarkedItem isEqual:indexPath] &&
            ![cell isKindOfClass:NSClassFromString(@"WDPRTableCellButton")])
        {
            id old = self.checkmarkedItem;
            self.checkmarkedItem = indexPath;
            
            [tableView reloadRowsAtIndexPaths:@[old, indexPath]
                             withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        
        if (self.webNavigationBlock &&
            item.isMultiValueTableItem &&
            (item[WDPRCellURLLink] || item[WDPRCellPathLink]))
        {
            id url = (item[WDPRCellURLLink] ?: item[WDPRCellPathLink]);
            
            self.webNavigationBlock([url isKindOfClass:NSURL.class] ?
                                    url :[NSURL URLWithString:url], item);
        }
        else if (self.selectionBlock)
        {
            self.selectionBlock(tableView, indexPath, self);
        }
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.tableView = tableView;
    
    if (self.pickerView && self.showPickersInline &&
        [self.focusedIndexPath isEqual:
         [NSIndexPath indexPathForRow:indexPath.row-1
                            inSection:indexPath.section]])
    {
        return self.pickerView.frame.size.height - tableView.rowHeight;
    }
    
    CGFloat rowHeight = tableView.rowHeight;
    id item = [self itemAtIndexPath:indexPath];
    
    if (self.useAutolayout && !item[WDPRCellRowHeight])
    {
        return UITableViewAutomaticDimension;
    }
    else if ([item isMultiValueTableItem])
    {
        if (item[WDPRCellRowHeight])
        {
            rowHeight = [item[WDPRCellRowHeight] floatValue];
        }
        else if ([(item[WDPRCellStyle] ?: @(self.cellStyle))
                  isEqual:@(WDPRTableCellStyleFloatLabelField)])
        {
            BOOL detailHasLenght = ([item[WDPRCellDetail] isKindOfClass:[NSString class]] ||
                                    [item[WDPRCellDetail] isKindOfClass:[NSAttributedString class]])
                                    && [item[WDPRCellDetail] length];
            
            if (item[WDPRCellDetail] && detailHasLenght)
            {
                NSMutableAttributedString *detailString =
                [item[WDPRCellDetail] isA:[NSAttributedString class]] ?
                item[WDPRCellDetail] : [NSMutableAttributedString
                                        string:item[WDPRCellDetail] attributes:
                                        [WDPRTheme textAttributes:WDPRTextStyleB2D]];
                
                CGFloat titleHeight = 20;
                id title = item[WDPRCellTitle];
                if (title && [title length])
                {
                    NSMutableAttributedString *titleString =
                    [title isA:[NSAttributedString class]] ?
                    title : [NSMutableAttributedString
                             string:title attributes:
                             [WDPRTheme textAttributes:WDPRTextStyleC1D]];
                    titleHeight += [titleString heightWithBoundingWidth:
                                    CGRectGetWidth(self.tableView.frame) - kHorizontalInset * 2];
                    
                    
                }
                rowHeight = titleHeight + [detailString heightWithBoundingWidth:
                                           CGRectGetWidth(self.tableView.frame) - kHorizontalInset * 2];
                
                rowHeight = (item[WDPRCellObscureText] ?
                             kDefaultFloatLabelFieldHeight :
                             MAX(rowHeight, kDefaultFloatLabelFieldHeight));
            }
            else
            {
                rowHeight = kDefaultFloatLabelFieldHeight;
            }
            
        }
        // condition changed 12/23/14
        else if (// skip non-subtitled cellStyles
                 ([(item[WDPRCellStyle] ?: @(self.cellStyle))
                   isEqual:@(WDPRTableCellStyleSubtitleBelowImage)] ||
                  [(item[WDPRCellStyle] ?: @(self.cellStyle))
                   isEqual:@(WDPRTableCellStyleSubtitleRightOfImage)]) &&
                 
                 (tableView.rowHeight == UITableViewAutomaticDimension))
        {
            rowHeight = 20;
            
            // Get the cell type
            WDPRTableViewCellStyle cellType = [item[WDPRCellStyle] integerValue] ?: self.cellStyle;
            
            // Label Width
            CGFloat labelWidth = (self.tableView.bounds.size.width - 32); // Make sure to subtract the margin
            if ([item[WDPRCellDetail] length] &&
                (cellType == WDPRTableCellStyleLeftRightAligned ||
                 cellType == WDPRTableCellStyleRightLeftAligned ||
                 cellType == WDPRTableCellStyleWithBubble ||
                 cellType == WDPRTableCellStyleLeftLeftAligned))
            {
                labelWidth /= 2;
            }
            
            // Calculate the detail
            CGFloat detailHeight = 0;
            if (item[WDPRCellDetail] && [item[WDPRCellDetail] length])
            {
                NSMutableAttributedString *titleString;
                if ([item[WDPRCellDetail] isA:[NSAttributedString class]])
                {
                    titleString = item[WDPRCellDetail];
                }
                else
                {
                    titleString = [NSMutableAttributedString
                                   string:item[WDPRCellDetail] attributes:
                                   [WDPRTheme textAttributes:WDPRTextStyleB2D]];
                }
                
                CGSize sizeToFit = [titleString boundingRectWithSize:CGSizeMake(labelWidth, CGFLOAT_MAX)
                                                             options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                                             context:nil].size;
                detailHeight = sizeToFit.height;
                rowHeight += detailHeight;
            }
            
            // Calculate the title
            if ([item[WDPRCellTitle] length])
            {
                NSMutableAttributedString *titleString;
                if ([item[WDPRCellTitle] isA:[NSAttributedString class]])
                {
                    titleString = item[WDPRCellTitle];
                }
                else
                {
                    titleString = [NSMutableAttributedString
                                   string:item[WDPRCellTitle] attributes:
                                   [WDPRTheme textAttributes:WDPRTextStyleC1D]];
                }
                
                CGSize sizeToFit =
                [titleString boundingRectWithSize:
                 CGSizeMake(labelWidth, CGFLOAT_MAX)
                                          options:(NSStringDrawingUsesFontLeading |
                                                   NSStringDrawingUsesLineFragmentOrigin)
                                          context:nil].size;
                
                //In WDPRTableCellStyleWithBubble the textLabel and detailLabel are in the same Y origin
                //so (if detailLabel exists) we don't need the textLabel height
                if (cellType == WDPRTableCellStyleWithBubble)
                {
                    if (!item[WDPRCellDetail] || ![item[WDPRCellDetail] length])
                        rowHeight += sizeToFit.height;
                    else if (detailHeight < sizeToFit.height)
                        rowHeight += sizeToFit.height-detailHeight;
                    
                }
                else
                {
                    rowHeight += sizeToFit.height;
                }
                
            }
        }
    }
    else rowHeight = (tableView.rowHeight * ((([item isA:NSString.class] &&
                                               ((NSString*)item).length) ||
                                              [item isMultiValueTableItem]) ? 1.0 : 0.5));
    
    return rowHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    MAKE_WEAK(self);
    return [self tableView:tableView
            viewForSection:section
                   inArray:^(NSArray* newArray)
            {
                MAKE_STRONG(self);
                if (!newArray)
                {   // return existing array
                    return strongself.headers;
                }
                else
                {   // assign incoming array
                    return strongself.headers = newArray;
                }
            }
                 fromTitle:^(NSInteger section)
            {
                return [tableView.dataSource tableView:tableView
                               titleForHeaderInSection:section];
            }];
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    MAKE_WEAK(self);
    return [self tableView:tableView
            viewForSection:section
                   inArray:^(NSArray* newArray)
            {
                MAKE_STRONG(self);
                if (!newArray)
                {   // return existing array
                    return strongself.footers;
                }
                else
                {   // assign incoming array
                    return strongself.footers = newArray;
                }
            }
                 fromTitle:^(NSInteger section)
            {
                return [tableView.dataSource tableView:tableView
                               titleForFooterInSection:section];
            }];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    self.tableView = tableView;
    
    UIView* header = [tableView.delegate tableView:tableView
                            viewForHeaderInSection:section];
    
    return ([header isKindOfClass:UIView.class] ?
            header.frame.size.height : UITableViewAutomaticDimension);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    self.tableView = tableView;
    
    UIView* footer = [tableView.delegate tableView:tableView
                            viewForFooterInSection:section];
    
    return ([footer isKindOfClass:UIView.class] ?
            footer.frame.size.height : UITableViewAutomaticDimension);
}

#pragma mark - HeaderView & FooterView

- (void)setTableView:(UITableView*)tableView headerViewFromString:(NSString*)string
{
    [self setTableView:tableView headerViewFromString:string reloadBlock:nil];
}

- (void)setTableView:(UITableView*)tableView footerViewFromString:(NSString*)string
{
    [self setTableView:tableView footerViewFromString:string reloadBlock:nil];
}

- (UIView *)tableView:(UITableView *)tableView viewForSection:(NSInteger)section
              inArray:(NSArray* (^)(NSArray*))array fromTitle:(NSString* (^)(NSInteger section))title
{
    self.tableView = tableView;
    NSArray* viewArray = array(nil) ?: @[];
    
    id initialView = ((section < viewArray.count) ?
                      viewArray[section] : nil);
    
    if (![initialView isKindOfClass:UIView.class] &&
        ![initialView isKindOfClass:NSString.class] &&
        ![initialView isKindOfClass:NSDictionary.class] &&
        ![initialView isKindOfClass:NSAttributedString.class])
    {
        initialView = title(section);
    }
    
    MAKE_WEAK(self);
    __block UIView* finalView;
    
    finalView = [self tableView:tableView
    createViewForHeaderOrFooter:initialView
                    reloadBlock:^(BOOL reload, UIWebView* webView)
                 {
                     MAKE_STRONG(self);
                     if (!reload)
                     {
                         if (!strongself.pendingReloads)
                         {
                             strongself.pendingReloads = [NSMutableSet new];
                         }
                         
                         [strongself.pendingReloads addObject:webView];
                     }
                     else
                     {
                         [strongself.pendingReloads removeObject:webView];
                         
                         if (!strongself.pendingReloads.count)
                         { // reloadData first so KVO can respond
                             [strongself.tableView reloadData];
                             strongself.pendingReloads = nil;
                         }
                     }
                 }];
    
    if (finalView && (finalView != initialView))
    {
        viewArray = array(viewArray.mutableCopy ?: [NSMutableArray new]);
        
        for (NSUInteger ii = viewArray.count; ii <= section; ii++)
        {
            [(NSMutableArray*)viewArray addObject:NSNull.null];
        }
        
        [(NSMutableArray*)viewArray replaceObjectAtIndex:section withObject:finalView];
    }
    
    return ([finalView isKindOfClass:UIView.class] ? finalView : nil);
}

- (void)setTableView:(UITableView*)tableView
headerViewFromString:(NSString*)string reloadBlock:(void (^)(void))reloadBlock
{
    MAKE_WEAK(tableView);
    tableView.tableHeaderView =
    [self tableView:tableView
createViewForHeaderOrFooter:string
        reloadBlock:^(BOOL reload, UIWebView* webView)
     {
         if (reload && weaktableView)
         {
             MAKE_STRONG(tableView);
             if (reloadBlock) reloadBlock();
             strongtableView.tableHeaderView = strongtableView.tableHeaderView;
         }
     }];
}

- (void)setTableView:(UITableView*)tableView
footerViewFromString:(NSString*)string reloadBlock:(void (^)(void))reloadBlock
{
    MAKE_WEAK(tableView);
    tableView.tableFooterView =
    [self tableView:tableView
createViewForHeaderOrFooter:string
        reloadBlock:^(BOOL reload, UIWebView* webView)
     {
         if (reload && weaktableView)
         {
             MAKE_STRONG(tableView);
             if (reloadBlock) reloadBlock();
             strongtableView.tableFooterView = strongtableView.tableFooterView;
         }
     }];
}

- (UIView *)tableView:(UITableView *)tableView
createViewForHeaderOrFooter:(id)headerOrFooter
          reloadBlock:(void (^)(BOOL, UIWebView*))reloadBlock
{
    if ([headerOrFooter isKindOfClass:NSDictionary.class])
    {
        // pull out the icon and create imageView
        id image = headerOrFooter[WDPRCellIcon];
        
        if ([image isKindOfClass:NSString.class])
        {
            image = [UIImage imageNamed:(NSString*)image];
        }
        
        
        // recursively call self with the title element,
        headerOrFooter = [self tableView:tableView
             createViewForHeaderOrFooter:
                          headerOrFooter[WDPRCellTitle]
                             reloadBlock:reloadBlock];
        
        UILabel* label = ((UIView*)headerOrFooter).subviews[0];
        
        // now position the image and label relative to each other
        CGRect frame = ((UIView*)headerOrFooter).frame;
        
        if (image)
        {   // now embed the image to the left of the label
            [headerOrFooter addSubview:image =
             [[UIImageView alloc] initWithImage:image]];
            
            ((UIImageView*)image).frame = CGRectMake(0, 0,
                                                     frame.size.height,
                                                     frame.size.height);
            
            ((UIImageView*)image).frame = CGRectInset([image frame], 5, 5);
            ((UIImageView*)image).frame = CGRectOffset([image frame],
                                                       label.frame.origin.x, 0);
            
            enum { offset = 5 };
            const CGFloat inset = CGRectGetMaxX(((UIImageView*)image).frame);
            label.frame = CGRectMake(inset + offset,
                                     label.frame.origin.y,
                                     label.frame.size.width +
                                     label.frame.origin.x - (inset + offset),
                                     label.frame.size.height);
        }
        
        [headerOrFooter setBackgroundColor:label.backgroundColor];
        label.backgroundColor = UIColor.clearColor;
    }
    else if ([headerOrFooter isKindOfClass:NSString.class])
    {
        NSRange htmlTag = [headerOrFooter
                           rangeOfString:@"<html>"
                           options:NSCaseInsensitiveSearch];
        
        if (htmlTag.location != NSNotFound)
        {
            NSString *width = (IS_IPHONE ? @"device-width" :
                               [NSString stringWithFormat:@"%d",
                                (int)CGRectGetWidth(tableView.frame)]);
            
            NSString *head = [NSString stringWithFormat:@
                              "<head>"
                              "<link href=\"wdpr.css\" type=\"text/css\" rel=\"stylesheet\"/>"
                              "<meta name=\"viewport\" content=\"width=%@, height=false, initial-scale=1, maximum-scale=1\">"
                              "<script>"
                              "window.onload = function() {"
                              "window.location.href = \"height://\" + document.documentElement.scrollHeight;}"
                              "</script>"
                              "</head>",
                              width];
            NSMutableString *html = [headerOrFooter mutableCopy];
            [html insertString:head
                       atIndex:htmlTag.location + htmlTag.length];
            
            headerOrFooter = [[UIWebView alloc] initWithFrame:
                              CGRectMake(0, 0, tableView.frame.size.width, 0)];
            __weak UIWebView * headerOrFooterWeak = headerOrFooter;
            [headerOrFooter addDeallocBlock:^{
                ((UIWebView *)headerOrFooterWeak).delegate = nil;
                [((UIWebView *)headerOrFooterWeak) stopLoading];
            }];
            
            ((UIWebView *)headerOrFooter).scrollView.delaysContentTouches = NO;
            ((UIWebView *)headerOrFooter).contentMode = UIViewContentModeRedraw;
            [headerOrFooter setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
            
            ((UIWebView*)headerOrFooter).opaque = NO;
            ((UIWebView*)headerOrFooter).delegate = self;
            ((UIWebView*)headerOrFooter).scrollView.scrollEnabled = NO;
            ((UIWebView*)headerOrFooter).backgroundColor = UIColor.clearColor;
            
            if (reloadBlock)
            {
                reloadBlock(NO, headerOrFooter);
                objc_setAssociatedObject(headerOrFooter,
                                         WebViewBlock, reloadBlock,
                                         OBJC_ASSOCIATION_COPY_NONATOMIC);
            }
            
            [(UIWebView*)headerOrFooter loadHTMLString:html baseURL:
             [NSURL fileURLWithPath:[NSBundle.mainBundle.resourcePath
                                     stringByAppendingPathComponent:@"html"]]];
        }
    }
    
    // above if-block may have triggered and not converted, test again
    if ([headerOrFooter isKindOfClass:NSString.class] ||
        [headerOrFooter isKindOfClass:NSAttributedString.class])
    {
        id title = headerOrFooter;
        
        if ([title length])
        {
            headerOrFooter = [[UIView alloc] initWithFrame:
                              CGRectMake(0, 0, 100,
                                         tableView.sectionHeaderHeight)];
            
            UILabel* label;
            [headerOrFooter addSubview:label =
             [[UILabel alloc] initWithFrame:CGRectZero]];
            
            label.numberOfLines = 0;
            label.textOrAttributedText = title;
            label.backgroundColor = UIColor.clearColor;
            
            if (tableView.style == UITableViewStylePlain)
            {
                // 1/4/16, jfr
                // currently, MDX is the only client that hits
                // this particular block and it needs this 
                // (pre-snowball) color....at least for now
                // (wdprPowderBlueColor is the closest match)
                
                UIColor* lighterBlueColor = 
                [UIColor colorWithHexValue:0xE0E9F4];
                
                [headerOrFooter setBackgroundColor:
                 [lighterBlueColor colorWithAlphaComponent:0.75]];
            }
            else
            {
                ((UIView*)headerOrFooter).backgroundColor = UIColor.clearColor;
            }
            
            if ([title isKindOfClass:NSString.class])
            {
                WDPRTextStyle textStyle;
                [label applyStyle:textStyle =
                 ((tableView.style ==
                   UITableViewStyleGrouped) ?
                  WDPRTextStyleB2D : WDPRTextStyleC1D)];
                
                // respond to dynamicText notification
                MAKE_WEAK(label);
                [headerOrFooter observeNotificationName:
                 UIContentSizeCategoryDidChangeNotification object:nil
                                                  queue:NSOperationQueue.mainQueue
                                             usingBlock:^(NSNotification *note)
                 {
                     MAKE_STRONG(label);
                     [stronglabel applyStyle:textStyle];
                     
                     CGRect labelFrame = stronglabel.frame;
                     labelFrame.size = [weaklabel sizeThatFits:
                                        CGSizeMake(labelFrame.size.width, INT_MAX)];
                     
                     labelFrame.size.height += 10; // add some vertical buffer space
                     
                     // set frame of label and headerOrFooter
                     stronglabel.frame = labelFrame;
                     [stronglabel.superview setFrame:CGRectInset(labelFrame, -labelFrame.origin.x, 0)];
                 }];
            }
            
            CGRect labelFrame = CGRectZero;
            labelFrame.origin.x = 10; // inset somewhat
            labelFrame.size.width = tableView.frame.size.width - 2*labelFrame.origin.x;
            labelFrame.size = [label sizeThatFits:CGSizeMake(labelFrame.size.width, INT_MAX)];
            
            labelFrame.size.height += 10; // add some vertical buffer space
            
            // set frame of label and headerOrFooter
            label.frame = labelFrame;
            [headerOrFooter setFrame:CGRectInset(labelFrame, -labelFrame.origin.x, 0)];
            
            label.autoresizingMask = (UIViewAutoresizingFlexibleWidth |
                                      UIViewAutoresizingFlexibleTopMargin |
                                      UIViewAutoresizingFlexibleBottomMargin);
        }
    }
    
    return ([headerOrFooter isKindOfClass:UIView.class] ? headerOrFooter : nil);
}

#pragma mark - UIWebViewDelegate

-(BOOL) webView:(UIWebView *)webView
shouldStartLoadWithRequest:(NSURLRequest *)inRequest
 navigationType:(UIWebViewNavigationType)type
{
    // Use this event to switch to the Safari app for embedded links
    if (type == UIWebViewNavigationTypeLinkClicked)
    {
        if (self.webNavigationBlock)
        {
            self.webNavigationBlock(inRequest.URL, nil);
        }
        else if ([inRequest.URL.scheme isEqualToString:@"tel"])
        {
            return YES;
        }
        else
        {
            [[UIApplication sharedApplication] openURL:inRequest.URL];
        }
        
        return NO;
        
        // This event means the web view CSS/JS has been fully loaded. Use instead of webViewDidFinishLoad for getting content height.
    }
    else if (type == UIWebViewNavigationTypeOther)
    {
        NSURL *url = [inRequest URL];
        if ([[url scheme] isEqualToString:@"height"])
        {
            float contentHeight = [[url host] floatValue];
            CGRect frame = webView.frame;
            frame.size = CGSizeMake(webView.frame.size.width, contentHeight);
            webView.frame = frame;
            
            id reloadBlock =
            objc_getAssociatedObject(webView, WebViewBlock);
            
            (((void(^)(BOOL, UIWebView*))reloadBlock) ?:
             ^(BOOL x, UIWebView* webView){})(YES, webView);
            
            return NO;
        }
    }
    
    return YES;
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self setFocusedIndexPath:nil];
}

@end  // @implementation WDPRTableDataView
