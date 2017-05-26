//
//  WDPRTableViewCell.h
//  WDPR
//
//  Created by Rodden, James on 9/26/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//
//  TODO: We really ought to sit down soon when we're less busy and merge
//  the standardizeLabels and autosizeLabels methods. It looks like
//  autosizeLabels tries to make the detailLabel as large as possible,
//  which conflicts with standardizeLabels, whose goal is to make the
//  textLabel uniformly large.
//

#import <UIKit/UIKit.h>
#import "WDPRFoundation.h"

#define ButtonCellReuseID @"_buttonCell"

typedef NS_ENUM(NSInteger, WDPRTableViewCellStyle)
{
    /// a renamed mapping of UITableViewCellStyleDefault
    WDPRTableCellStyleDefault = UITableViewCellStyleDefault,
    
    /// a renamed mapping of UITableViewCellStyleValue1
    WDPRTableCellStyleLeftRightAligned = UITableViewCellStyleValue1,
    
    /// a renamed mapping of UITableViewCellStyleValue2
    WDPRTableCellStyleRightLeftAligned = UITableViewCellStyleValue2,
    
    /// a renamed mapping of UITableViewCellStyleSubtitle, which places the
    /// subtitle text immediately below the primary text label, to the right
    /// of the imageView
    WDPRTableCellStyleSubtitleRightOfImage = UITableViewCellStyleSubtitle,
    
    /// a custom layout variation upon
    /// WDPRTableCellStyleSubtitleRightOfImage/UITableViewCellStyleSubtitle
    /// which center aligns both the textLabel and detailTextLabel text
    WDPRTableCellStyleCenterAligned,
    
    /// a custom layout variation upon
    /// WDPRTableCellStyleSubtitleRightOfImage/UITableViewCellStyleSubtitle which
    /// moves the subtitle text below the imageView as well as the primary text label
    WDPRTableCellStyleSubtitleBelowImage,
    
    /// a custom layout variation upon
    /// WDPRTableCellStyleRightLeftAligned/UITableViewCellStyleValue2 which
    /// makes both the textLabel and detailTextLabel left aligned
    WDPRTableCellStyleLeftLeftAligned,
    
    /// a custom behavior variation upon 
    /// WDPRTableCellStyleSubtitleRightOfImage/UITableViewCellStyleSubtitle which
    /// exhibits the new form text entry appearance and behaviors
    WDPRTableCellStyleFloatLabelField,
    
    /// a custom layout variation upon
    /// WDPRTableCellStyleRightLeftAligned/UITableViewCellStyleValue2 which
    /// makes both the textLabel and detailTextLabel left aligned, adds auto-layout
    /// of the 2 labels
    WDPRTableCellStyleLeftLeftAutoSized,
    
    /// Custom layout variations upon UITableViewCellStyleSubtitle
    /// which implements an app stylized "button". Taps on such
    /// "buttons" can be detected via tableView:didSelectRowAtIndexPath:
    WDPRTableCellStyleStandardButton, WDPRTableCellStylePlainButton,
    WDPRTableCellStyleDeleteButton, WDPRTableCellStyleSolidGrayButton,

    WDPRTableCellStylePrimaryButton, WDPRTableCellStyleSecondaryButton,
    WDPRTableCellStyleTertiaryButton,

    /// a custom layout variation upon
    /// WDPRTableCellStyleLeftLeftAligned which
    /// makes both the textLabel and detailTextLabel left aligned and adds a bubble
    /// around them
    WDPRTableCellStyleWithBubble,
};

typedef NS_ENUM(NSInteger, WDPRTableViewCellBubble)
{
    WDPRTableViewCellBubbleNone     = 0,
    WDPRTableViewCellBubbleTop      = 1 << 0,
    WDPRTableViewCellBubbleMiddle   = 1 << 1,
    WDPRTableViewCellBubbleBottom   = 1 << 2,
   
    // special-case modifiers
    WDPRTableViewCellBubbleNoFrame  = 1 << 3,
    WDPRTableViewCellBubbleNoInset  = 1 << 4,
   
    // convenience constant
    WDPRTableViewCellBubbleSection = (WDPRTableViewCellBubbleTop |
                                      WDPRTableViewCellBubbleBottom),
};

enum
{
    kHorizontalInset = 16
};

#pragma mark -

/// this is a class cluster and should/can not be
/// subclassed outside of the private implementation
@interface WDPRTableViewCell : UITableViewCell

- (WDPRTableViewCell* _Nonnull)asWDPRTableViewCell;

/// remove all extra textLabels and detailsTextLabels
/// (if any exist) in preparation for cell reuse
- (void)removeExtraLabels;

/// Return an extra textLabel with specified index,
/// creating intervening such labels as needed.
/// Intended only for two-line cellStyles w/o
/// an image or any type of accessoryView (YMMV)
- (UILabel* _Nullable)textLabelAtIndex:(NSUInteger)index;

/// Return an extra detailTextLabel with specified
/// index, creating intervening such labels as needed.
/// Intended only for two-line cellStyles w/o
/// an image or any type of accessoryView (YMMV)
- (UILabel* _Nullable)detailTextLabelAtIndex:(NSUInteger)index;

/// subview element affected by the last touch event 
@property (nonatomic, readonly, nullable) UIView* touchedSubview;

/// an accessoryView to the left of imageView
@property (nonatomic, nullable) UIView* leftAccessoryView;

/// the relative bubble styling of this cell 
@property (nonatomic) WDPRTableViewCellBubble bubbleType;

/// only non-nil for WDPRTableCellStyleXXXButton cellStyles
@property (nonatomic, readonly, nullable) UIButton* button;

/// read-only, access to textLabels created via 
/// textLabelAtIndex (does not create any new ones)
@property (nonatomic, readonly, nullable) NSArray* textLabels;

/// read-only, access to detailTextLabels created via 
/// detailTextLabelAtIndex (does not create any new ones)
@property (nonatomic, readonly, nullable) NSArray* detailTextLabels;

/// only non-nil for WDPRTableCellWithBubble cellStyles
@property (nonatomic, readonly, nullable) UILabel* extraTextLabel;

/// an accessoryView to the left of accessoryType/View
/// and to the right of textLabel & detailTextLabel
@property (nonatomic, nullable) UIView* auxiliaryAccessoryView;

/// block called after layoutSubviews has completed
@property (nonatomic, copy, nullable) PlainBlock postLayoutBlock;

/// whether or not custom styling is applied to this cell
@property (nonatomic, readonly) BOOL styleGuideAdjustments;

/// specific (styled) version of auxiliaryAccessoryView.
/// will return nil if auxiliaryAccessoryView is set to
/// anything other than a UILabel
@property (nonatomic, readonly, nullable) UILabel* auxiliaryAccessoryLabel;

/// whether or not show custom separator
@property (nonatomic) BOOL showSeparator;

/// whether or not set Accessibility Value
@property (nonatomic) BOOL shouldSetAccessibilityValue;

@end // @interface WDPRTableViewCell

#pragma mark -

@interface WDPRTableViewCell (Autolayout)

// NOTE: this is experimental/alpha/WIP!!
@property (nonatomic, assign) BOOL useAutolayout;

@end // @interface WDPRTableViewCell (Autolayout)

#pragma mark -

@interface UITableViewCell (WDPRTableViewCell)

- (WDPRTableViewCell* _Nullable)asWDPRTableViewCell;

/// defaults to UITableViewCell's imageView property
@property (nonatomic, readonly, strong, nullable) UIImageView *mainImageView;

/// defaults to UITableViewCell's textLabel property
@property (nonatomic, readonly, strong, nullable) UILabel *primaryTextLabel;

/// defaults to UITableViewCell's detailTextLabel property
@property (nonatomic, readonly, strong, nullable) UILabel *secondaryTextLabel; 

@end // @interface UITableViewCell (WDPRTableViewCell)
