//
//  UIColor+WDPR.m
//  
//
//  Created by Pierce, Owen on 12/5/14.
//
//

#import "UIColor+WDPR.h"
#import "UIColor+HexColors.h"

NS_ASSUME_NONNULL_BEGIN

@implementation UIColor (WDPR)

#pragma mark - One-off colors

+ (UIColor*)wdprRedColor
{
    return [UIColor colorWithHexValue:0XF82E0C];
}

+ (UIColor *)wdprGoldColor
{
    return [self colorWithHexValue:0xBE8740];
}

+ (UIColor *)wdprOrangeColor
{
    return [self colorWithHexValue:0xFF4605];
}

+ (UIColor *)wdprWhiteColor
{
    return [self colorWithHexValue:0xFFFFFF];
}

#pragma mark - Blue colors

+ (UIColor *)wdprBlueColor
{
    return [self colorWithHexValue:0x1994D7];
}

+ (UIColor *)wdprDarkBlueColor
{
    return [self colorWithHexValue:0x253B56];
}

+ (UIColor *)wdprLightBlueColor
{
    return [self colorWithHexValue:0x8CCAEB];
}

+ (UIColor *)wdprMediumBlueColor
{
    return [UIColor colorWithHexValue:0x303E57];
}

+ (UIColor *)wdprInactiveBlueColor
{
    return [UIColor colorWithHexValue:0xBBE0F3];
}

+ (UIColor *)wdprRoyalBlueColor
{
    return [self colorWithHexValue:0x1398e0];
}

+ (UIColor *)wdprPowderBlueColor
{
    return [self colorWithHexValue:0xC8DEEA];
}

#pragma mark - Gray colors

+ (UIColor *)wdprGrayColor
{
    return [self colorWithHexValue:0x8294AA];
}

+ (UIColor *)wdprLightGrayColor
{
    return [self colorWithHexValue:0xA1AFC0];
}

+ (UIColor *)wdprInactiveGrayColor
{
    return [self colorWithHexValue:0xD0D7DE];
}

+ (UIColor *)wdprMutedGrayColor
{
    return [self colorWithHexValue:0xE1EAF4];
}

+ (UIColor *)wdprPaleGrayColor
{
    return [self colorWithHexValue:0xECF1F4];
}

+ (UIColor *)wdprAnotherGrayColor
{
    // OP - we should use one of our MANY existing gray colors,
    //      implementing to ensure the design does not break
    //      in the interim.
    return [self colorWithHexValue:0xDBE0E4];
}

+ (UIColor *)wdprBorderGrayColor
{
    return [self colorWithHexValue:0xC6D0DA];
}

#pragma mark - Green colors

+ (UIColor *)wdprMossGreenColor
{
    return [self colorWithHexValue:0x81A436];
}

+ (UIColor *)wdprLimeGreenColor
{
    return [self colorWithHexValue:0x2DCC70];
}

#pragma mark - Button & Text colors

+ (UIColor *)wdprEnabledButtonColor
{
    return [self wdprBlueColor];
}

+ (UIColor *)wdprSelectedButtonColor
{
    return [self colorWithHexValue:0x23AFFC];
}

+ (UIColor *)wdprDisabledSecondaryButtonColor
{
    return [[self colorWithHexValue:0xEDF2F8] colorWithAlphaComponent:0.3];
}

+ (UIColor *)wdprEnabledSecondaryButtonColor
{
    return [self whiteColor];
}

+ (UIColor *)wdprSelectedSecondaryButtonColor
{
    // See DLR_Guide pg 11
    return [self wdprBlueColor];
}

+ (UIColor *)wdprSecondaryButtonBorderColor
{
    return [self colorWithHexValue:0x8CC9EB];
}

+ (UIColor *)wdprDisabledSecondaryDismissiveButtonColor
{
    return [[self wdprEnabledSecondaryDismissiveButtonColor] colorWithAlphaComponent:0.35];
}

+ (UIColor *)wdprEnabledSecondaryDismissiveButtonColor
{
    return [self wdprPaleGrayColor];
}

+ (UIColor *)wdprSelectedSecondaryDismissiveButtonColor
{
    return [self wdprGrayColor];
}

+ (UIColor *)wdprEnabledTertiaryButtonColor
{
    return [self wdprPaleGrayColor];
}

+ (UIColor *)wdprDisabledSecondaryTextColor
{
    return [[self wdprBlueColor] colorWithAlphaComponent:0.4];
}

+ (UIColor *)wdprEnabledTransactionButtonColor
{
    return [self colorWithHexValue:0x6FA623];
}

+ (UIColor *)wdprDisabledTransactionButtonColor
{
    return [self colorWithHexValue:0xABBE93];
}

+ (UIColor *)wdprTappedTransactionButtonColor
{
    return [self colorWithHexValue:0x57821b];
}

#pragma mark - Alert colors

+ (UIColor *)wdprAlertBackgroundLightBlueColor;
{
    return [self colorWithHexValue:0xEBF6FC];
}

+ (UIColor *)wdprAlertBackgroundYellowColor
{
    return [UIColor colorWithHexValue:0xE1B734];
}

#pragma mark - calendar colors

+ (UIColor *)wdprBlockOutSelectedCircleColor
{
    return [self wdprLimeGreenColor];
}

+ (UIColor *)wdprBlockOutSelectedBlockedCircleColor
{
    return [self wdprPowderBlueColor];
}

+ (UIColor *)wdprBlockOutSelectedTextColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)wdprBlockOutDayColor
{
    return [self wdprLimeGreenColor];
}

+ (UIColor *)wdprBlockOutDayBlockedColor
{
    return [self wdprPowderBlueColor];
}

+ (UIColor *)wdprBlockOutDayOfWeekTextColor
{
    return [self wdprDarkBlueColor];
}

#pragma mark - park hours

+ (UIColor *)wdprParkHoursSelectedCircleColor
{
    return [self wdprDarkBlueColor];
}

+ (UIColor *)wdprParkHoursSelectedTextColor
{
    return [UIColor whiteColor];
}

+ (UIColor *)wdprParkHoursDayColor
{
    return [self wdprBlueColor];
}

+ (UIColor *)wdprParkHoursDayOfWeekTextColor
{
    return [self wdprDarkBlueColor];
}

#pragma mark - dashboard

+ (UIColor *)wdprMapOverlayFirstGradient
{
    return [[UIColor wdprLightBlueColor] colorWithAlphaComponent:0.5];
}

+ (UIColor *)wdprMapOverlayLastGradient
{
    return [[UIColor colorWithHexValue:0x1A94D7] colorWithAlphaComponent:0.5];
}

#pragma mark - HR Lines

+ (UIColor *)wdprHRLineColor
{
    return  [UIColor colorWithHexValue:0xE3ECF3];
}

@end

NS_ASSUME_NONNULL_END
