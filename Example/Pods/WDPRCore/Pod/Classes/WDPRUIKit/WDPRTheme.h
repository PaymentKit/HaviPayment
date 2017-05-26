//
//  WDPRTheme.h
//  DLR
//
//  Created by Rodden, James on 12/22/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import "WDPRTableViewItem.h"

typedef NS_ENUM(NSUInteger, WDPRTextStyle)
{
    WDPRTextStyleB1B,
    WDPRTextStyleB1D,
    WDPRTextStyleB1G,
    WDPRTextStyleB1N,
    WDPRTextStyleB1O,
    WDPRTextStyleB1W,
    WDPRTextStyleB2B,
    WDPRTextStyleB2D,
    WDPRTextStyleB2G,
    WDPRTextStyleB2N,
    WDPRTextStyleB2O,
    WDPRTextStyleB2W,
    WDPRTextStyleC1B,
    WDPRTextStyleC1D,
    WDPRTextStyleC1G,
    WDPRTextStyleC1I,
    WDPRTextStyleC1L,
    WDPRTextStyleC1N,
    WDPRTextStyleC1O,
    WDPRTextStyleC1W,
    WDPRTextStyleC2B,
    WDPRTextStyleC2D,
    WDPRTextStyleC2G,
    WDPRTextStyleC2I,
    WDPRTextStyleC2L,
    WDPRTextStyleC2N,
    WDPRTextStyleC2O,
    WDPRTextStyleC2W,
    WDPRTextStyleH1B,
    WDPRTextStyleH1D,
    WDPRTextStyleH1N,
    WDPRTextStyleH1RDL,
    WDPRTextStyleH1W,
    WDPRTextStyleH2B,
    WDPRTextStyleH2D,
    WDPRTextStyleH2G,
    WDPRTextStyleH2N,
    WDPRTextStyleH2W,
    WDPRTextStyleH3D,
    WDPRTextStyleH3W,
    WDPRTextStyleH3N,
    WDPRTextStyleH4D,
    WDPRTextStyleH4W,
    WDPRTextStyleS1W,
    WDPRTextStyleS1N,
    WDPRTextStyleS1B,
    WDPRTextStyleS2W,
    WDPRTextStyleS2N,
    WDPRTextStyleS2B,
    WDPRTextStyleS3W,
    WDPRTextStyleS3N,
    WDPRTextStyleS3B
};


@interface UILabel (WDPRTheme)

/// applies font and coloring per style
- (void)applyStyle:(WDPRTextStyle)textStyle;

/// applies only font per style
- (void)applyFontFromStyle:(WDPRTextStyle)textStyle;

/// applies only coloring per style
- (void)applyColorFromStyle:(WDPRTextStyle)textStyle;

@end // @interface UILabel (WDPRTheme)

#pragma mark -

@interface UIButton (WDPRTheme)

/// applies font and coloring per style
- (void)applyStyle:(WDPRTextStyle)textStyle withTitle:(NSString *)title;

@end // @interface UIButton (WDPRTheme)

#pragma mark -

@interface WDPRTheme : NSObject

+ (NSDictionary*)allTextStyles;

+ (NSDictionary*)textAttributes:(WDPRTextStyle)textStyle;

+ (WDPRCellConfigurationBlockType)applyStyleB1DtoTextLabel;
+ (WDPRCellConfigurationBlockType)applyStyleB1BtoTextLabel;
+ (WDPRCellConfigurationBlockType)applyStyleB2DtoTextLabel;
+ (WDPRCellConfigurationBlockType)applyStyleC1BtoTextLabel;
+ (WDPRCellConfigurationBlockType)applyStyleH2DtoTextLabel;
+ (NSNumber *)kernAttributeForFont:(UIFont *)font;
+ (NSDictionary *)finderListTextAttributesForStyle:(WDPRTextStyle)textStyle;

@end // @interface WDPRTheme

#pragma mark -

@interface NSString (WDPRTheme)

- (NSAttributedString*)attributedStringWithStyle:(WDPRTextStyle)textStyle;

@end // @interface NSString (WDPRTheme)

#pragma mark -

@interface NSAttributedString (WDPRTheme)

+ (instancetype)string:(NSString *)str textStyle:(WDPRTextStyle)textStyle;

@end // @interface NSAttributedString (WDPRTheme)
