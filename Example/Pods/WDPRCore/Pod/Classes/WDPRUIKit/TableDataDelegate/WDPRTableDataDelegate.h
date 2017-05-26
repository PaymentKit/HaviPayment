//
//  WDPRTableDataDelegate.h
//  WDPR
//
//  Created by Rodden, James on 6/28/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "WDPRDataSource.h"
#import "WDPRTableViewCell.h"

@class WDPRTableDataDelegate;

/// utility function to wrap text in <html></html>
/// and optionally include standard "*required field" suffix
NSString* htmlify(NSString* string, BOOL includeRequiredFieldText);

/// for use with WDPRTableDataDelegate's selectionBlock property
typedef void(^WDPRTableSelectionBlock)(UITableView*,
                                       NSIndexPath*,
                                       WDPRTableDataDelegate *);

/// for use with embedded url content (WDPRCellURLLink, etc)
typedef void (^WDPRTableWebNavigationBlock)(NSURL* url, NSDictionary* item);

/**
 WDPRTableDataDelegate is a base class that implements both the UITableViewDataSource and
 UITableViewDelegate protocols. It makes getting a simple set of items into a table very
 quick and easy by managing the low-level details of UITableView data management. Providing
 an array of items, or the name of a plist file containing an array of items, and assigning
 an instance of this class as the dataSource and delegate of a UITableView instance is all
 it takes to get a fully functional table presentation. Items can be any combination NSStrings,
 NSAttributedStrings, NSDictionaries containing pre-defined key/value pairs, or objects that 
 implement the WDPRTableViewItem protocol. Two dimensional arrays can be used to group items
 into table sections and section headers can also be easily added via an array of any 
 combination of NSStrings, NSAttributedStrings, or pre-configured UIViews. NSStrings that 
 have the prefix of "\<html\>" will be loaded into UIWebView instances with a common 
 app-wide css file for standardized styling.
 */

@protocol WDPRTableViewDelegate <UITableViewDelegate>

@optional

/// Called when the popover/picker of the cell dimissed/closes.
/// For example, if you select something from a picker and later 
/// tap on a different area or press close button.
- (void)tableView:(UITableView *)tableView 
didDismissPickerAtIndexPath:(WDPRIndexPath *)indexPath;

@end // @protocol WDPRTableViewDelegate


///Called when the text field is enabled to look up
///for results in the same table.
@protocol WDPRSuggestAsYouTypeDelegate <NSObject>

@required

-(NSArray *) suggestionsForCell:(NSNumber *)cellIdentifier 
                       fromText:(NSString *)text andTextField:(UITextField *)textField;

@end

@interface WDPRSuggestAsYouType : NSObject

@property (nonatomic,strong) id suggestionsDelegate;

-(NSArray *) suggestionsForCell:(NSNumber *)cellIdentifier 
                       fromText:(NSString *)text andTextField:(UITextField *)textField;

@end


@interface WDPRTableDataDelegate : WDPRDataSource
    <WDPRTableViewDelegate, UIPopoverControllerDelegate >

/// @name Initialization Methods

/// initialize items, headers and footers arrays with provided values
- (id)initWithArray:(NSArray *)array
     sectionHeaders:(NSArray *)headers
     sectionFooters:(NSArray *)footers;


/// @name Accessors

/// Hook method called by WDPRTableControllerDelegate which allows subclasses
/// to configure the UITableView (set row heights, etc). Be sure to
/// call base class implementation.
- (void)customizeTable:(UITableView *)tableView;

/// Calculate the cumulative height of all rows, section headers, etc
- (CGFloat)idealContentHeight:(UITableView *)tableView __deprecated_msg("use UITableView's idealContentHeight");

/// Dynamically swap in a new item (such as mutableCopy of an item).
/// Returns the final item, the original if unsuccessful, newItem
/// if replacement was successfull. Also triggers cell refresh.
/// Works with 1 & 2 dimensional items array.
- (id)replaceItem:(id)item 
             with:(id)newItem 
   delayedRefresh:(BOOL)delayedRefresh;

/// Calls replaceItem:with:delayedRefresh:YES
- (id)replaceItem:(id)item with:(id)newItem;

/// Calls replaceItemAtIndexPath:with:delayedRefresh:YES
- (id)replaceItemAtIndexPath:(NSIndexPath*)indexPath with:(id)newItem;

/// Delete an item from the items array
/// (and update the last referenced tableView).
/// Assumes 2-dimensional items array.
- (void)deleteItemAtIndexPath:(NSIndexPath*)indexPath 
             withRowAnimation:(UITableViewRowAnimation)animation;

/// Insert an item into the items array
/// (and update the last referenced tableView).
/// Assumes 2-dimensional items array.
- (void)insertItem:(id)item 
       atIndexPath:(NSIndexPath*)indexPath 
  withRowAnimation:(UITableViewRowAnimation)animation;

/// Delete specified section from items
/// (and update the last referenced tableView).
/// Assumes 2-dimensional items array.
- (void)deleteSection:(NSUInteger)section 
     withRowAnimation:(UITableViewRowAnimation)animation;

/// Insert items at specified section index
/// (and update the last referenced tableView).
/// Assumes 2-dimensional items array.
- (void)insertSection:(NSArray*)newItems
              atIndex:(NSUInteger)section
           withHeader:(id)header andFooter:(id)footer 
     withRowAnimation:(UITableViewRowAnimation)animation;

/// Adds an item to the invalid items set
- (void)addToInvalidItems:(id)object;

/// Removes an item from the invalid items set
- (void)removeFromInvalidItems:(id)object;

- (void)setTableView:(UITableView*)tableView headerViewFromString:(NSString*)string;
- (void)setTableView:(UITableView*)tableView
headerViewFromString:(NSString*)string reloadBlock:(void (^)(void))reloadBlock;

- (void)setTableView:(UITableView*)tableView footerViewFromString:(NSString*)string;
- (void)setTableView:(UITableView*)tableView
footerViewFromString:(NSString*)string reloadBlock:(void (^)(void))reloadBlock;

- (void)updateTableInsets:(BOOL)show;

/// Announce an alert using VoiceOver
/// after an specified delay and using a provided
/// completion block to be executed after the
/// announcement is completed
- (void)announceAlert:(NSString*)alert
            withDelay:(CGFloat)delay
        andCompletion:(PlainBlock)completion;

/// @name Properties

/// Default value is NO.
/// YES inserts UIPickerViews and UIDatePickers inline.
/// NO displays UIPickerViews and UIDatePickers at the bottom
/// of the screen like a keyboard and attaches the same UIToolbar
/// used by the keyboard with the previous/next controls.
@property (nonatomic) BOOL showPickersInline;

/// Currently focused textField or pickerView row.
/// Set this to nil to commit any edit in progress, stop the
/// edit session and call resignFirstResponder (dismiss the keyboard).
/// This will transfer the current edit value back to the items array.
@property (nonatomic) WDPRIndexPath * focusedIndexPath;

@property (nonatomic, readonly) UITextField* focusedTextField;

/// The tableview that this delegate is attached to.
@property (nonatomic, weak) UITableView* tableView;

/// Ephemoral state of opening/closing an edit session,
/// UIPickerView, or UIDatePicker
@property (nonatomic, readonly) BOOL transitioningFocus;

/// Current validation state of all items
@property (nonatomic, readonly) BOOL allItemsAreValid;

/// Optional block to receive notification of selection.
/// This is intended for use by clients who haven't subclassed
/// from WDPRTableDataDelegate or WDPRTableControllerDelegate, but
/// compsed them together instead.
@property (nonatomic, copy) WDPRTableSelectionBlock selectionBlock;

/// Optional block to receive notification of taps on embedded URL links.
@property (nonatomic, copy) WDPRTableWebNavigationBlock webNavigationBlock;

/// Set to NO by default. Set to YES to enable form assistant wrapping.
@property (nonatomic) BOOL wrapEnabled;

/// Suggestions results
@property (nonatomic) NSMutableArray *suggestionsResults;

// TODO this shouldn't be exported, at least not in this form
@property (nonatomic) CGFloat keyboardHeight;

// TODO this shouldn't be exported, at least not in this form
@property (nonatomic) NSSet* invalidItems;


@end // @interface WDPRTableData
