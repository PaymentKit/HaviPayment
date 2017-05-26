//
//  UIColor+WDPR.h
//  
//
//  Created by Pierce, Owen on 12/5/14.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIColor+HexColors.h"

NS_ASSUME_NONNULL_BEGIN

@interface UIColor (WDPR)

#pragma mark - One-off colors

// An intense red: 0XF82E0C
+ (UIColor*)wdprRedColor;

// A gold color: 0xBE8740 
+ (UIColor *)wdprGoldColor;

/// A standard orange color (0xFF4605)
+ (UIColor *)wdprOrangeColor;

/// A standard white color (0xFFFFFF)
+ (UIColor *)wdprWhiteColor;

#pragma mark - Blue colors

/// A standard blue color (0x1994D7)
+ (UIColor *)wdprBlueColor;

/// A standard dark blue color (0x253B56)
+ (UIColor *)wdprDarkBlueColor;

/// A standard light blue color (0x8CCAEB)
+ (UIColor *)wdprLightBlueColor;

// A light blue: 0x303E57
+ (UIColor *)wdprMediumBlueColor;

// An inactive blue: 0xBBE0F3
+ (UIColor *)wdprInactiveBlueColor;

/// A standard powder blue color (0xC8DEEA)
+ (UIColor *)wdprPowderBlueColor;

/// A blue color that matches the tutorial image base color (0x1398e0)
+ (UIColor *)wdprRoyalBlueColor;

#pragma mark - Gray colors

/// A standard gray color (0x8294AA)
+ (UIColor *)wdprGrayColor;

/// A standard light gray color (0xA1AFC0)
+ (UIColor *)wdprLightGrayColor;

/// A standard light gray color (0xD0D7DE)
+ (UIColor *)wdprInactiveGrayColor;

/// A standard grayed out color (0xE1EAF4)
+ (UIColor *)wdprMutedGrayColor;

/// Another gray color (0xDBE0E4)
//  OP - this color should be phased out
+ (UIColor *)wdprAnotherGrayColor DEPRECATED_ATTRIBUTE;

/// A standard pale gray color (0xECF1F4)
+ (UIColor *)wdprPaleGrayColor;

/// A standar gray color (0xC6D0DA)
+ (UIColor *)wdprBorderGrayColor;

#pragma mark - Green colors

/// A standard moss green color (0x81A436)
+ (UIColor *)wdprMossGreenColor;

/// A standard lime green color (0x2DCC70)
+ (UIColor *)wdprLimeGreenColor;

#pragma mark - Button & Text colors

/// A standard blue color (0x1994D7)
+ (UIColor *)wdprEnabledButtonColor;

/// A standard bright blue color (0x23AFFC)
+ (UIColor *)wdprSelectedButtonColor;

/// A standard transparent gray color (0xEDF2F8) @40% opacity
+ (UIColor *)wdprDisabledSecondaryButtonColor;

/// A standard gray color (0xFFFFFF)
+ (UIColor *)wdprEnabledSecondaryButtonColor;

/// A standard pale blue color (0x1994D7)
+ (UIColor *)wdprSelectedSecondaryButtonColor;

/// A standard blue color (0x8CC9EB)
+ (UIColor *)wdprSecondaryButtonBorderColor;

/// A standard transparent gray color (0xECF1F4) @ 35% opacity
+ (UIColor *)wdprDisabledSecondaryDismissiveButtonColor;

/// A standard light gray color (0xECF1F4)
+ (UIColor *)wdprEnabledSecondaryDismissiveButtonColor;

/// A standard gray color (wdprGrayColor)
+ (UIColor *)wdprSelectedSecondaryDismissiveButtonColor;

/// A standard gray color (0xECF1F4)
+ (UIColor *)wdprEnabledTertiaryButtonColor;

/// A standard transparent gray color (0x1994D7) @40% opacity
+ (UIColor *)wdprDisabledSecondaryTextColor;

// A green color: 0x6FA623
+ (UIColor *)wdprEnabledTransactionButtonColor;

// A light green color: 0xABBE93
+ (UIColor *)wdprDisabledTransactionButtonColor;

// A dark green color: 0x57821b
+ (UIColor *)wdprTappedTransactionButtonColor;

#pragma mark - AlertColor

// A light blue color : (0xEBF6FC)
+ (UIColor *)wdprAlertBackgroundLightBlueColor;

// A yellow color : (0xE1B734)
+ (UIColor *)wdprAlertBackgroundYellowColor;

#pragma mark - calendar colors

// A green color : (wdprLimeGreenColor)
+ (UIColor *)wdprBlockOutSelectedCircleColor;

// A light gray color (wdprPowderBlueColor)
+ (UIColor *)wdprBlockOutSelectedBlockedCircleColor;

/// Standard whiteColor (0xFFFFFF)
+ (UIColor *)wdprBlockOutSelectedTextColor;

// A green color : (wdprLimeGreenColor)
+ (UIColor *)wdprBlockOutDayColor;

/// A light grayish color : (wdprPowderBlueColor)
+ (UIColor *)wdprBlockOutDayBlockedColor;

/// A dark blue color: (wdprDarkBlueColor)
+ (UIColor *)wdprBlockOutDayOfWeekTextColor;

#pragma mark - park hours

/// A dark black color : 0x253b56
+ (UIColor *)wdprParkHoursSelectedCircleColor;

/// Standard whiteColor
+ (UIColor *)wdprParkHoursSelectedTextColor;

/// A light blue color : 0x1994d7
+ (UIColor *)wdprParkHoursDayColor;

/// A black color: 0x253b56
+ (UIColor *)wdprParkHoursDayOfWeekTextColor;

#pragma mark - dashboard
/// A blue color: 0x8ccaeb
+ (UIColor *)wdprMapOverlayFirstGradient;

/// A blue color: 0x1a94d7
+ (UIColor *)wdprMapOverlayLastGradient;

#pragma mark - HR Lines
// A light green grey: 0xe3ecf3
+ (UIColor *)wdprHRLineColor;

@end
NS_ASSUME_NONNULL_END
