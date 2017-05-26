//
//  WDPRTableViewItem.h
//  WDPR
//
//  Created by Rodden, James on 10/15/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDPRFoundation.h"

#pragma mark - primary Key-Value Tags
/// @name WDPRCell primary Key-Value Tags

/// uniqueID key, for client use. Can be *ANY* NSObject.
/// For example: name of the data model's corresponding property
/// the name of a method to dispatch to when selected (or a block)
#define WDPRCellRowID @"rowID" // (perhaps rename to UserData?)

/// cell icon key (NSString filename, UIImage, NSURL, or NSDictionary)
/// NSDictionary keys recognized: 
/// WDPRCellPlaceholder (NSString or UIImage) and WDPRCellIcon (NSURL)
#define WDPRCellIcon @"icon"    // keep consistent with WDPRDataIcon

/// cell iconID key (unichar code of PEP Icon Font glyph)
#define WDPRCellIconID @"iconID"

/// cell icon size key (CGSize as NSValue)
#define WDPRCellIconSize @"iconSize"    // keep consistent with WDPRDataIconSize

/// cell title key (NSString or NSAttributedString)
#define WDPRCellTitle @"title"  // keep consistent with WDPRDataTitle

/// cell detail key (NSString or NSAttributedString)
#define WDPRCellDetail @"detail"


#pragma mark - expandable Key-Value Tags
#define WDPRCellExpanded @"expanded"


#pragma mark - visual customization Key-Value Tags
/// @name WDPRCell visual customization Key-Value Tags

/// cell disabled key (BOOL)
/// When set to YES, cell textLabel and detailTextLabel 
/// are set to lightGrayColor in WDPRTableDataDelegate
#define WDPRCellDisabled @"disabled"

/// cell background color (UIColor)
#define WDPRCellBGColor @"cellBGColor"


#pragma mark - customization Key-Value Tags
/// @name WDPRCell customization Key-Value Tags

/// cell row height key (NSNumber)
#define WDPRCellRowHeight @"rowHeight"

/// cell style key (WDPRTableViewCellStyle as NSNumber)
/// overrides the cellStyle property of the
/// WDPRTableDataDelegate, used as the style argument to
/// UITableViewCell's initWithStyle:reuseIdentifier: initializer
#define WDPRCellStyle @"cellStyle"

/// cell type key (Class, which must be subclass of UITableViewCell)
/// overrides the cellType property of the WDPRTableDataDelegate. The Class is initialized
/// via the initWithStyle:reuseIdentifier: initializer and must either support,
/// or stub out (override to a no-op) the imageView, textLabel, and detailTextLabel properties.
#define WDPRCellType @"cellType"

/// cell reuseIndentifier to use instead of auto-generated one
#define WDPRCellReuseIdentifier @"reuseIdentifier"

/// a UIView* positioned left of imageView
#define WDPRCellLeftAccessoryView @"leftAccessoryView"

/// secondary accessoryView (UIView*) positioned left of accessoryType/View
#define WDPRCellAuxiliaryAccessoryView @"auxiliaryAccessoryView"

/// styled UILabel version of WDPRCellAuxiliaryAccessoryView
#define WDPRCellAuxiliaryAccessoryText @"auxiliaryAccessoryText"

/// cell accessoryType key (UITableViewCellAccessoryType as NSNumber)
/// overrides the default accessoryType for the WDPRTableDataDelegate
/// (either disclosure or no-disclosure specified via the
/// dataDelegate's noDisclosureIndicators property)
#define WDPRCellAccessoryType @"accessoryType"

/// cell accessoryView key (UIView*). overrides accessoryType.
#define WDPRCellAccessoryView @"accessoryView"

/// cell selectionStyle key (WDPRTableViewCellSelectionStyle as NSNumber)
/// overrides the default selectionStyle for the WDPRTableDataDelegate
#define WDPRCellSelectionStyle @"selectionStyle"

/// cell NSDate time-formatting key (NSDateFormatterStyle as NSNumber)
#define WDPRCellTimeFormat @"timeFormat"

/// cell NSDate date-formatting key (NSDateFormatterStyle as NSNumber)
#define WDPRCellDateFormat @"dateFormat"


#pragma mark - web content Key-Value Tags
/// @name WDPRCell web content Key-Value Tags
          
/// cell url key,
/// (NSString or NSURL) WDPRTableControllerDelegate
/// opens WDPRWebViewController to specified URL
#define WDPRCellURLLink @"url"

/// cell path key,
/// (NSString or NSURL) WDPRTableControllerDelegate
/// opens WDPRWebViewController to specified
/// html file in the app bundle
#define WDPRCellPathLink @"path"

/// (BOOL as NSNumber)
/// Should the content allow zooming?
/// Only applicable for web content.
#define WDPRCellAllowZoom @"allowzoom"

/// (BOOL as NSNumber)
/// Enable bar with back, next, refresh buttons
/// Only applicable for web content.
#define WDPRCellEnableWebControls @"enablewebcontrols"

/// (BOOL as NSNumber)
/// Hide navigation bar
/// Only applicable for web content.
#define WDPRCellHideNavigationBar @"hidenavigationbar"

/// cell web title
/// (NSString)
/// Override for title at top of web views.
#define WDPRCellWebViewTitle @"webTitle"

#pragma mark - date & timePicker Key-Value Tags
/// @name WDPRCell date & timePicker Key-Value Tags

/// Either an NSArray of strings or model objects
/// to present in a UIPickerView when the item's
/// row is selected, -or- an NSDictionary describing
/// a datePicker (since a row can't support both).
/// Model objects should override 'formattedDescription'
/// and return an appropiate string to use as cell detail.
#define WDPRCellOptions @"pickerOptions"

/// Either an NSArray of strings or model objects
/// to set as accessibility labels for the UIPickerView
/// options.
#define WDPRCellOptionAccessibilityLabels @"pickerOptionAccessibilityLabels"

/// Specifies datePicker mode in dictionary
/// for WDPRCellOptions (WDPRDatePickerModeType as NSNumber)
#define WDPRDatePickerMode @"datePickerMode"

/// Specify datePicker minimun date in
/// dictionary for WDPRCellOptions (NSDate)
#define WDPRCellMinimumDate @"minimumDate"

/// Specify datePicker maximum date in
/// dictionary for WDPRCellOptions (NSDate)
#define WDPRCellMaximumDate @"maximumDate"

/// Specifies the minute interval in
/// dictionary for WDPRCellOptions (NSNumber)
#define WDPRCellMinuteInterval @"minuteInterval"
          

#pragma mark - textEdit Key-Value Tags
/// @name WDPRCell textEdit Key-Value Tags

/// Placeholder NSString or NSAttributedString
/// for embedded UITextField.
/// The presence of this in an item dictionary
/// will trigger automatic UITextField support,
/// unless WDPRCellOptions key is present
/// (can be used with UIDatePicker and UIPickerView)
#define WDPRCellPlaceholder @"placeholder"

/// cell (validation) error (BOOL)
/// When set to YES, display cell in error state
#define WDPRCellErrorState @"errorState"

/// When set to YES, displays inline error if invalid
#define WDPRCellDisplayInlineError @"displayError"

/// Specifies keyboard type for embedded textfield.
/// (UIKeyboardType as NSNumber)
#define WDPRCellKeyboardType @"keyboardType"

/// Specifies the keyboard return key, defaults to UIReturnKeyNext
/// (UIKeyboardReturnKey as NSNumber)
#define WDPRCellKeyboardReturnKey @"keyboardReturnKey"

/// Set if the UITTextField will contain password data.
/// (BOOL as NSValue/NSNumber)
#define WDPRCellObscureText @"obscureText"

/// Update the behavior of autocapitalization.
/// (UITextAutocapitalizationType as NSNumber)
#define WDPRCellAutocapitalization @"autocapitalization"

/// Update the behavior of autocorrection.
/// (UITextAutocorrectionType as NSNumber)
#define WDPRCellAutocorrection @"autocorrection"

/// Update the behavior of spellChecking
/// (UITextSpellCheckingType as NSNumber)
#define WDPRCellSpellChecking @"spellchecking"

/// Specifies whether the cell should use custom
/// Accessibility style (BOOL)
/// When set to YES, cell will use custom style
#define WDPRCellUsesExtendedAccessibility @"usesExtendedAccessibility"

/// Specifies whether the cell should use custom
/// Accessibility label (string)
#define WDPRCellAccessibilityLabel @"accessibilityLabelKey"

/// Specifies whether the cell should use custom
/// Accessibility hint (string)
#define WDPRCellAccessibilityHint @"accessibilityHintKey"

#pragma mark - action key-value tags
/// @name WDPRCell action key-value tags

/// block executed as last step of tableView:cellForRowAtIndexPath:
/// (WDPRCellConfigurationBlockType)
#define WDPRCellConfigurationBlock @"cellConfigurationBlock"
typedef void (^WDPRCellConfigurationBlockType)(UITableViewCell*);

/// block executed when value of the cell changes (WDPRCellValueChangedBlockType)
/// For example, if you select something from a picker or commit text field changes.
#define WDPRCellValueChangedBlock @"valueChangedBlock"
typedef void (^WDPRCellValueChangedBlockType)(NSDictionary* item);

/// block executed when the focus on a picker is lost (WDPRPickerLostFocusBlockType)
/// For example, when a picker is dismissed
#define WDPRPickerLostFocusBlock @"pickerLostFocusBlock"
typedef void (^WDPRPickerLostFocusBlockType)(NSDictionary* item);

/// The cell implements the suggestAsYouTypeDelegate
#define WDPRCellSuggestionsDelegate @"suggestionsDelegate"


/// block executed when the user taps keyboard button (WDPRCellValueChangedBlockType)
#define WDPRCellKeyboardButtonTapped @"WDPRCellKeyboardButtonTapped"
typedef void (^WDPRCellKeyboardButtonTappedBlockType)(void);

// TODO: Why do we have these two enums? - Daniel Clark
typedef NS_ENUM(NSInteger, WDPRDatePickerModeType)
{
    WDPRDatePickerModeMonthYear = -1,
    
    WDPRDatePickerModeTime = UIDatePickerModeTime,
    WDPRDatePickerModeDate = UIDatePickerModeDate,
    WDPRDatePickerModeDateAndTime = UIDatePickerModeDateAndTime,
    WDPRDatePickerModeCountDownTimer = UIDatePickerModeCountDownTimer,
};

typedef NS_ENUM(NSInteger, WDPRTableViewCellSelectionStyle)
{
    WDPRTableViewCellSelectionStyleLogicalOnly = -1,
    
    WDPRTableViewCellSelectionStyleNone = UITableViewCellSelectionStyleNone,
    WDPRTableViewCellSelectionStyleBlue = UITableViewCellSelectionStyleBlue,
    WDPRTableViewCellSelectionStyleGray = UITableViewCellSelectionStyleGray,
    WDPRTableViewCellSelectionStyleDefault = UITableViewCellSelectionStyleDefault,
};

#pragma mark -

@protocol WDPRTableViewItem <NSObject>

@required

// these two methods are implemented in NSObject+WDPR
// and provide glue to map subscripted references to
// Key-Value tags listed above into the optional
// properties listed below.

- (id)objectForKeyedSubscript:(NSString*)key;
- (void)setObject:(id)obj forKeyedSubscript:(NSString*)key;

@optional

@property (nonatomic) id rowID;     // arbitrary unique identifier

@property (nonatomic) id icon;      // NSString filename or UIImage
@property (nonatomic) id title;     // NSString or NSAttributedString
@property (nonatomic) id detail;    // NSString or NSAttributedString

// cell customization
@property (nonatomic) NSNumber* rowHeight;

@property (nonatomic) NSNumber* cellStyle;      // WDPRTableViewCellStyle
@property (nonatomic) Class cellType;           // subclass of UITableViewCell

@property (nonatomic) UIView* accessoryView;    // overrides accessoryType
@property (nonatomic) UIView* leftAccessoryView;// left of default imageView
@property (nonatomic) UIView* auxiliaryAccessoryView; // left of accessoryType/View

@property (nonatomic) id auxiliaryAccessoryText; // auxiliaryAccessoryView as label

@property (nonatomic) NSNumber* accessoryType;  // UITableViewCellAccessoryType
@property (nonatomic) NSNumber* selectionStyle; // WDPRTableViewCellSelectionStyle

// content formatting
@property (nonatomic) NSNumber* timeFormat; // NSDateFormatterStyle
@property (nonatomic) NSNumber* dateFormat; // NSDateFormatterStyle

// linked web/html content
@property (nonatomic) id url;               // NSString or NSURL
@property (nonatomic) id path;              // NSString or NSURL
@property (nonatomic) NSNumber* allowzoom;  // BOOL

// UIDatePicker & UIPickerView support
@property (nonatomic) id pickerOptions; // NSArray of NSStrings or NSDictionary
                                        // with WDPRDatePickerMode, and optionally
                                        // WDPRCellMinimumDate &/or WDPRCellMaximumDate

// inline textEdit support
@property (nonatomic) id placeholder;               // NSString or NSAttributesString
@property (nonatomic) NSNumber* keyboardType;       // UIKeyboardType
@property (nonatomic) NSNumber* obscureText;        // BOOL
@property (nonatomic) NSNumber* autocapitalization; // UITextAutocapitalizationType
@property (nonatomic) NSNumber* autocorrection;     // UITextAutocorrectionType
@property (nonatomic) NSNumber* spellchecking;      // UITextSpellCheckingType

@end // @protocol WDPRTableViewItem

#pragma mark -

@class WDPRTableViewItem;
@class WDPRTableDynamicItem;
@class WDPRTableMultipleItems;
@class WDPRTableDisclosureItem;

typedef id (^WDPRTableDynamicItemProperty)(WDPRTableViewItem * item);

@interface WDPRTableViewItem : NSObject <WDPRTableViewItem>

@end // @interface WDPRTableViewItem

#pragma mark -

@interface WDPRTableDynamicItem : WDPRTableViewItem

+ (id)tableDynamicItemWithData:(NSDictionary*)data;

@end // @interface WDPRTableDynamicItem

#pragma mark -

@interface WDPRTableDisclosureItem : WDPRTableDynamicItem

@property (nonatomic) BOOL expanded;

@end // @interface WDPRTableDisclosureItem

#pragma mark -

@interface WDPRTableMultipleItems : WDPRTableViewItem

- (id)objectAtIndexedSubscript:(NSUInteger)idx;

+ (id)tableItemWithMultipleItems:(NSArray*)items;

@property (nonatomic, readonly) NSUInteger numItems;

@end // @interface WDPRTableMultipleItems

#pragma mark -

@interface WDPRTableViewItem ()

+ (id)tableItemWithMultipleItems:(NSArray*)items;
+ (id)tableDynamicItemWithData:(NSDictionary*)data;
+ (id)tableSeparatorItemWithHeight:(NSUInteger)height;
+ (id)emptyCellItemWithHeight:(CGFloat)height
                showSeparator:(BOOL)showSeparator;

/// returns a pair of items configured as parent/child
/// in which the "parent" toggles appearance of "child"
+ (NSArray*)tableDisclosureItems:(NSDictionary*)data;

/// returns the error message for the WDPRTableViewItem
/// based on its configuration
- (NSString*)errorMessage;

@end // @interface WDPRTableViewItem ()

