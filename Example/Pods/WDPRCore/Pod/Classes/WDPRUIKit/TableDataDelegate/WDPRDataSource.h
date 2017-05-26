//
//  WDPRTableViewDataSource.h
//  Pods
//
//  Created by J.Rodden on 8/29/15.
//
//

#import <UIKit/UIKit.h>
#import "WDPRTableViewCell.h"

#define WDPRSectionItems @"items"
#define WDPRSectionHeader @"header"
#define WDPRSectionFooter @"footer"
#define WDPRAccessibilitySeparator @", "

// depricated constants, use constants above
#define WDPRTableSectionItems WDPRSectionItems
#define WDPRTableSectionHeader WDPRSectionHeader
#define WDPRTableSectionFooter WDPRSectionFooter

#pragma mark -

@interface NSObject (WDPRTableItem)

@property (nonatomic, readonly) BOOL isMultiValueTableItem;

@end // @interface NSObject (WDPRTableItem)

#pragma mark -

@interface WDPRIndexPath : NSIndexPath

@property (nonatomic) NSUInteger subItemIndex;
+ (instancetype)indexPath:(NSIndexPath*)indexPath;

@end // @interface WDPRIndexPath

typedef WDPRIndexPath WDPRTableIndexPath;

#pragma mark -

@interface NSIndexPath (WDPRIndexPath)

@property (nonatomic) NSUInteger subItemIndex;
- (WDPRIndexPath *)indexPathWithSubItemIndex:(NSUInteger)index;

@end // @interface NSIndexPath (WDPRIndexPath)

#pragma mark -

@protocol WDPRTableViewDataSource <UITableViewDataSource>

@end // @protocol WDPRTableViewDataSource

@protocol WDPRCollectionViewDataSource <UICollectionViewDataSource>

@end // @protocol WDPRCollectionViewDataSource

#pragma mark -

@protocol WDPRDataSource <WDPRTableViewDataSource, 
                          WDPRCollectionViewDataSource>

@end // @protocol WDPRTableViewDataSource



@interface WDPRDataSource : NSObject<WDPRDataSource>

/// @name Initialization Methods

/// initialize items with specified array
- (id)initWithArray:(NSArray *)array;

/// initialize items and headers arrays with provided values
- (id)initWithArray:(NSArray *)array
     sectionHeaders:(NSArray *)headers;

/// initialize items, headers and footers arrays with provided values
- (id)initWithArray:(NSArray *)array
     sectionHeaders:(NSArray *)headers
     sectionFooters:(NSArray *)footers;

/// initialize items array with the contents of specified plist file
- (id)initWithPlist:(NSString *)fileName;

/// call registerClass:forCellReuseIdentifier: for each item in self.items
- (void)registerCellsForReuse:(UITableView*)tableView;

/// @name Properties

/*
 * NOTE: Changing the properties here
 * from @property (nonatomic)
 * to   @property (nonatomic, copy)
 * caused some weird flickering in DLR on the Create Account screen amoung others.
 */

/// Content items, a one or two dimensional array of NSString,
/// NSAttributedString, NSDictionaries, or objects that
/// implement the WDPRTableViewItem protocol
@property (nonatomic) NSArray *items;

/// section headers, a mix of NSString, NSAttributedString, and UIViews.
/// NSString's prefixed with <html> are converted into UIWebView with
/// specified html string content.
@property (nonatomic) NSArray *headers;

/// section footers, a mix of NSString, NSAttributedString, and UIViews.
/// NSString's prefixed with <html> are converted into UIWebView with
/// specified html string content.
@property (nonatomic) NSArray *footers;


// Experimental/alpha
@property (nonatomic) BOOL useAutolayout;

/// Specifies a subclass of UITableViewCell to use for cells.
/// Set class must be a subclass of UITableViewCell and respond
/// to the textLabel, detailTextLabel, and imageView getters and
/// have the designated initializer initWithStyle:reuseIdentifier:
@property (nonatomic) Class cellType;

/// Which cell style to use when creating new instances of
/// cellType, defaults to WDPRTableCellStyleLeftRightAligned
@property (nonatomic) WDPRTableViewCellStyle cellStyle;

/// Specifies accessoryType used for cells, if not overridden
/// by WDPRCellAccessoryType tag for individual items.
/// Defaults to UITableViewCellAccessoryDisclosureIndicator.
/// Can also be manipulated by noDisclosureIndicators property.
@property (nonatomic) UITableViewCellAccessoryType accessoryType;

/// Specifies visual selectionStyle used for selectable cells,
/// if not overridden by WDPRCellSelectionStyle for individual items.
/// Defaults to UITableViewCellSelectionStyleBlue.
@property (nonatomic) UITableViewCellSelectionStyle selectionStyle;

/// Default value is NO. Needed for MDX compatability.
@property (nonatomic) BOOL iOS6StyleGroupBubbles;

/// Enable single-checkmark support when this property is 
/// non-nil, the corresponding row will have its accessoryType 
/// set to UITableViewCellAccessoryTypeCheckmark and row 
/// selections will move the checkmark to the newly selected row
@property (nonatomic) NSIndexPath* checkmarkedItem;


/// @name Accessors

/// Accessor to get the item entry corresponding
/// to the specified indexPath
- (id)itemAtIndexPath:(NSIndexPath *)indexPath;

/// We frequently have to look up the index path for an item by the row ID.
/// This calls the bulk version (indexPathsForRowIDs) as a convenience.
- (NSIndexPath *)indexPathForRowID:(id)rowID;

/// We frequently have to look up index paths for items by their ID.
/// This enumerates through all cells. A TODO for the future would be to optimize this with a dict.
- (NSDictionary *)indexPathsForRowIDs:(NSArray *)rowIDArray;

- (UITableViewCell*)configureCell:(UITableViewCell*)cell forItem:(id)item 
                      atIndexPath:(NSIndexPath*)indexPath inTable:(UITableView*)tableView;

- (void)enumerateObjectsUsingBlock:(void (^)(id item, WDPRIndexPath *idx, BOOL *stop))block;

@end
