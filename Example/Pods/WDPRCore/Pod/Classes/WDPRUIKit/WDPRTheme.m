//
//  WDPRTheme.m
//  DLR
//
//  Created by Rodden, James on 12/22/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"

static CGFloat const kPhotoshopTracking = -25.0;
static CGFloat const kLabelLineSpacing = -5.0f;

@implementation UILabel (WDPRTheme)

- (void)applyStyle:(WDPRTextStyle)textStyle
{
    NSDictionary* chosenTextStyle =
    [WDPRTheme textAttributes:textStyle];
    
    self.adjustsFontSizeToFitWidth = NO;
    self.font = chosenTextStyle[NSFontAttributeName];
    self.textColor = chosenTextStyle[NSForegroundColorAttributeName];
}

- (void)applyFontFromStyle:(WDPRTextStyle)textStyle
{
    NSDictionary* chosenTextStyle =
    [WDPRTheme textAttributes:textStyle];
    
    self.font = chosenTextStyle[NSFontAttributeName];
}

- (void)applyColorFromStyle:(WDPRTextStyle)textStyle
{
    NSDictionary* chosenTextStyle =
    [WDPRTheme textAttributes:textStyle];
    
    self.textColor = chosenTextStyle[NSForegroundColorAttributeName];
}

@end // @implementation UILabel (WDPRTheme)

#pragma mark -

@implementation UIButton (WDPRTheme)

- (void)applyStyle:(WDPRTextStyle)textStyle withTitle:(NSString *)title
{
    NSParameterAssert(title);
            
    [self setAttributedTitle:[title attributedStringWithAttributes:[WDPRTheme textAttributes:textStyle]]
                    forState:UIControlStateNormal];
}

@end // @implementation UIButton (WDPRTheme)

#pragma mark -

@implementation WDPRTheme

+ (WDPRTheme*)currentTheme
{
    return self.defaultTheme;
}

+ (WDPRTheme*)defaultTheme
{
    static WDPRTheme* defaultTheme;
    
    void (^initializeItemsBlock)() =
    ^{
        defaultTheme = [WDPRTheme new];
    };
    executeOnlyOnce(initializeItemsBlock);
    
    return defaultTheme;
}

+ (NSDictionary*)allTextStyles
{
    return self.currentTheme.allTextStyles;
}

+ (NSDictionary*)textAttributes:(WDPRTextStyle)textStyle
{
    NSMutableDictionary *attributes = [self.currentTheme textAttributes:textStyle].mutableCopy;
    
    attributes[NSKernAttributeName] = [self kernAttributeForFont:attributes[NSFontAttributeName]];
    return attributes.copy;
}

+ (NSNumber *)kernAttributeForFont:(UIFont *)font
{
    // Mapping photoshop value to iOS
    // characterSpacing = fontSize * tracking / 1000
    // See: http://www.devsign.co/notes/tracking-and-character-spacing
    return @(font.pointSize * kPhotoshopTracking / 1000);
}

+ (NSDictionary *)finderListTextAttributesForStyle:(WDPRTextStyle)textStyle
{
    NSMutableParagraphStyle *paragraphStyle = [NSMutableParagraphStyle new];
    paragraphStyle.lineSpacing = kLabelLineSpacing;
    
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[WDPRTheme textAttributes:textStyle]];
    attributes[NSParagraphStyleAttributeName] = paragraphStyle;
    
    return [attributes copy];
}

#pragma mark -

- (NSDictionary*)allTextStyles
{
    static NSDictionary* textStyles = nil;
    
    textStyles = textStyles ?: // these could go into a plist, etc
    @{
      @(WDPRTextStyleB1B) :
          @{
              WDPRCellTitle : @"B1B",
              NSFontAttributeName : UIFont.wdprFontStyleB1,
              NSForegroundColorAttributeName : UIColor.wdprBlueColor,
              },
      @(WDPRTextStyleB1D) :
          @{
              WDPRCellTitle : @"B1D",
              NSFontAttributeName : UIFont.wdprFontStyleB1,
              NSForegroundColorAttributeName : UIColor.wdprDarkBlueColor,
              },
      @(WDPRTextStyleB1G) :
          @{
              WDPRCellTitle : @"B1G",
              NSFontAttributeName : UIFont.wdprFontStyleB1,
              NSForegroundColorAttributeName : UIColor.wdprGrayColor,
              },
      @(WDPRTextStyleB1N) :
          @{
              WDPRCellTitle : @"B1N",
              NSFontAttributeName : UIFont.wdprFontStyleB1,
              NSForegroundColorAttributeName : UIColor.wdprDarkBlueColor,
              },
      @(WDPRTextStyleB1O) :
          @{
              WDPRCellTitle : @"B1O",
              NSFontAttributeName : UIFont.wdprFontStyleB1,
              NSForegroundColorAttributeName : UIColor.wdprOrangeColor,
              },
      @(WDPRTextStyleB1W) :
          @{
              WDPRCellTitle : @"B1W",
              NSFontAttributeName : UIFont.wdprFontStyleB1,
              NSForegroundColorAttributeName : UIColor.wdprWhiteColor,
              },
      @(WDPRTextStyleB2B) :
          @{
              WDPRCellTitle : @"B2B",
              NSFontAttributeName : UIFont.wdprFontStyleB2,
              NSForegroundColorAttributeName : UIColor.wdprBlueColor,
              },
      @(WDPRTextStyleB2D) :
          @{
              WDPRCellTitle : @"B2D",
              NSFontAttributeName : UIFont.wdprFontStyleB2,
              NSForegroundColorAttributeName : UIColor.wdprDarkBlueColor,
              },
      @(WDPRTextStyleB2G) :
          @{
              WDPRCellTitle : @"B2G",
              NSFontAttributeName : UIFont.wdprFontStyleB2,
              NSForegroundColorAttributeName : UIColor.wdprGrayColor,
              },
      @(WDPRTextStyleB2N) :
          @{
              WDPRCellTitle : @"B2N",
              NSFontAttributeName : UIFont.wdprFontStyleB2,
              NSForegroundColorAttributeName : UIColor.wdprDarkBlueColor
              },
      @(WDPRTextStyleB2O) :
          @{
              WDPRCellTitle : @"B2O",
              NSFontAttributeName : UIFont.wdprFontStyleB2,
              NSForegroundColorAttributeName : UIColor.wdprOrangeColor,
              },
      @(WDPRTextStyleB2W) :
          @{
              WDPRCellTitle : @"B2W",
              NSFontAttributeName : UIFont.wdprFontStyleB2,
              NSForegroundColorAttributeName : UIColor.wdprWhiteColor,
              },
      @(WDPRTextStyleC1B) :
          @{
              WDPRCellTitle : @"C1B",
              NSFontAttributeName : UIFont.wdprFontStyleC1,
              NSForegroundColorAttributeName : UIColor.wdprBlueColor,
              },
      @(WDPRTextStyleC1D) :
          @{
              WDPRCellTitle : @"C1D",
              NSFontAttributeName : UIFont.wdprFontStyleC1,
              NSForegroundColorAttributeName : UIColor.wdprDarkBlueColor,
              },
      @(WDPRTextStyleC1G) :
          @{
              WDPRCellTitle : @"C1G",
              NSFontAttributeName : UIFont.wdprFontStyleC1,
              NSForegroundColorAttributeName : UIColor.wdprGrayColor,
              },
      @(WDPRTextStyleC1I):
          @{
              WDPRCellTitle : @"C1I",
              NSFontAttributeName : UIFont.wdprFontStyleC1,
              NSForegroundColorAttributeName : UIColor.wdprInactiveGrayColor,
              },
      @(WDPRTextStyleC1L):
          @{
              WDPRCellTitle : @"C1L",
              NSFontAttributeName : UIFont.wdprFontStyleC1,
              NSForegroundColorAttributeName : UIColor.wdprLightGrayColor,
              },
      @(WDPRTextStyleC1N) :
          @{
              WDPRCellTitle : @"C1N",
              NSFontAttributeName : UIFont.wdprFontStyleC1,
              NSForegroundColorAttributeName : UIColor.wdprDarkBlueColor,
              },
      @(WDPRTextStyleC1O) :
          @{
              WDPRCellTitle : @"C1O",
              NSFontAttributeName : UIFont.wdprFontStyleC1,
              NSForegroundColorAttributeName : UIColor.wdprOrangeColor,
              },
      @(WDPRTextStyleC1W) :
          @{
              WDPRCellTitle : @"C1W",
              NSFontAttributeName : UIFont.wdprFontStyleC1,
              NSForegroundColorAttributeName : UIColor.wdprWhiteColor,
              },
      @(WDPRTextStyleC2B) :
          @{
              WDPRCellTitle : @"C2B",
              NSFontAttributeName : UIFont.wdprFontStyleC2,
              NSForegroundColorAttributeName : UIColor.wdprBlueColor,
              },
      @(WDPRTextStyleC2D) :
          @{
              WDPRCellTitle : @"C2D",
              NSFontAttributeName : UIFont.wdprFontStyleC2,
              NSForegroundColorAttributeName : UIColor.wdprDarkBlueColor,
              },
      @(WDPRTextStyleC2G) :
          @{
              WDPRCellTitle : @"C2G",
              NSFontAttributeName : UIFont.wdprFontStyleC2,
              NSForegroundColorAttributeName : UIColor.wdprGrayColor,
              },
      @(WDPRTextStyleC2I) :
          @{
              WDPRCellTitle : @"C2I",
              NSFontAttributeName : UIFont.wdprFontStyleC2,
              NSForegroundColorAttributeName : UIColor.wdprInactiveGrayColor,
              },
      @(WDPRTextStyleC2L) :
          @{
              WDPRCellTitle : @"C2L",
              NSFontAttributeName : UIFont.wdprFontStyleC2,
              NSForegroundColorAttributeName : UIColor.wdprLightGrayColor,
              },
      @(WDPRTextStyleC2N) :
          @{
              WDPRCellTitle : @"C2N",
              NSFontAttributeName : UIFont.wdprFontStyleC2,
              NSForegroundColorAttributeName : UIColor.wdprDarkBlueColor,
              },
      @(WDPRTextStyleC2O) :
          @{
              WDPRCellTitle : @"C2O",
              NSFontAttributeName : UIFont.wdprFontStyleC2,
              NSForegroundColorAttributeName : UIColor.wdprOrangeColor,
              },
      @(WDPRTextStyleC2W) :
          @{
              WDPRCellTitle : @"C2W",
              NSFontAttributeName : UIFont.wdprFontStyleC2,
              NSForegroundColorAttributeName : UIColor.wdprWhiteColor,
              },
      @(WDPRTextStyleH1B) :
          @{
              WDPRCellTitle : @"H1B",
              NSFontAttributeName : UIFont.wdprFontStyleH1,
              NSForegroundColorAttributeName : UIColor.wdprBlueColor,
              },
      @(WDPRTextStyleH1D) :
          @{
              WDPRCellTitle : @"H1D",
              NSFontAttributeName : UIFont.wdprFontStyleH1,
              NSForegroundColorAttributeName : UIColor.wdprDarkBlueColor,
              },
      @(WDPRTextStyleH1N) :
          @{
              WDPRCellTitle : @"H1N",
              NSFontAttributeName : UIFont.wdprFontStyleH1,
              NSForegroundColorAttributeName : UIColor.wdprDarkBlueColor,
              },
      @(WDPRTextStyleH1RDL) :
          @{
              WDPRCellTitle : @"H1RDLeading",
              NSFontAttributeName : UIFont.wdprFontStyleH1RDL,
              NSForegroundColorAttributeName : UIColor.wdprDarkBlueColor,
              },
      @(WDPRTextStyleH1W) :
          @{
              WDPRCellTitle : @"H1W",
              NSFontAttributeName : UIFont.wdprFontStyleH1,
              NSForegroundColorAttributeName : UIColor.wdprWhiteColor,
              },
      @(WDPRTextStyleH2B) :
          @{
              WDPRCellTitle : @"H2B",
              NSFontAttributeName : UIFont.wdprFontStyleH2,
              NSForegroundColorAttributeName : UIColor.wdprDarkBlueColor,
              },
      @(WDPRTextStyleH2D) :
          @{
              WDPRCellTitle : @"H2D",
              NSFontAttributeName : UIFont.wdprFontStyleH2,
              NSForegroundColorAttributeName : UIColor.wdprDarkBlueColor,
              },
      @(WDPRTextStyleH2N) :
          @{
              WDPRCellTitle : @"H2N",
              NSFontAttributeName : UIFont.wdprFontStyleH1H,
              NSForegroundColorAttributeName : UIColor.wdprDarkBlueColor,
              },
      @(WDPRTextStyleH2G) :
          @{
              WDPRCellTitle : @"H2G",
              NSFontAttributeName : UIFont.wdprFontStyleH2,
              NSForegroundColorAttributeName : UIColor.wdprGrayColor,
              },
      @(WDPRTextStyleH2W) :
          @{
              WDPRCellTitle : @"H2W",
              NSFontAttributeName : UIFont.wdprFontStyleH1H,
              NSForegroundColorAttributeName : UIColor.wdprWhiteColor,
              },
      @(WDPRTextStyleH3D) :
          @{
              WDPRCellTitle : @"H3D",
              NSFontAttributeName : UIFont.wdprFontStyleH3,
              NSForegroundColorAttributeName : UIColor.wdprDarkBlueColor,
              },
      @(WDPRTextStyleH3N) :
          @{
              WDPRCellTitle : @"H3N",
              NSFontAttributeName : UIFont.wdprFontStyleH1R,
              NSForegroundColorAttributeName : UIColor.wdprDarkBlueColor,
              },
      @(WDPRTextStyleH3W) :
          @{
              WDPRCellTitle : @"H3W",
              NSFontAttributeName : UIFont.wdprFontStyleH1R,
              NSForegroundColorAttributeName : UIColor.wdprWhiteColor,
              },
      @(WDPRTextStyleH4D) :
          @{
              WDPRCellTitle : @"H4D",
              NSFontAttributeName : UIFont.wdprFontStyleH4,
              NSForegroundColorAttributeName : UIColor.wdprDarkBlueColor,
              },
      @(WDPRTextStyleH4W) :
          @{
              WDPRCellTitle : @"H4W",
              NSFontAttributeName : UIFont.wdprFontStyleH4,
              NSForegroundColorAttributeName : UIColor.wdprWhiteColor,
              },
      @(WDPRTextStyleS1W) :
          @{
              WDPRCellTitle : @"S1W",
              NSFontAttributeName : UIFont.wdprFontStyleS1,
              NSForegroundColorAttributeName : UIColor.wdprWhiteColor,
              },
      @(WDPRTextStyleS1N) :
          @{
              WDPRCellTitle : @"S1N",
              NSFontAttributeName : UIFont.wdprFontStyleS1,
              NSForegroundColorAttributeName : UIColor.wdprDarkBlueColor,
              },
      @(WDPRTextStyleS1B) :
          @{
              WDPRCellTitle : @"S1B",
              NSFontAttributeName : UIFont.wdprFontStyleS1,
              NSForegroundColorAttributeName : UIColor.wdprBlueColor,
              },
      @(WDPRTextStyleS2W) :
          @{
              WDPRCellTitle : @"S2W",
              NSFontAttributeName : UIFont.wdprFontStyleS2,
              NSForegroundColorAttributeName : UIColor.wdprWhiteColor,
              },
      @(WDPRTextStyleS2N) :
          @{
              WDPRCellTitle : @"S2N",
              NSFontAttributeName : UIFont.wdprFontStyleS2,
              NSForegroundColorAttributeName : UIColor.wdprDarkBlueColor,
              },
      @(WDPRTextStyleS2B) :
          @{
              WDPRCellTitle : @"S2B",
              NSFontAttributeName : UIFont.wdprFontStyleS2,
              NSForegroundColorAttributeName : UIColor.wdprBlueColor,
              },
      @(WDPRTextStyleS3W) :
          @{
              WDPRCellTitle : @"S3W",
              NSFontAttributeName : UIFont.wdprFontStyleS3,
              NSForegroundColorAttributeName : UIColor.wdprWhiteColor,
              },
      @(WDPRTextStyleS3N) :
          @{
              WDPRCellTitle : @"S3N",
              NSFontAttributeName : UIFont.wdprFontStyleS3,
              NSForegroundColorAttributeName : UIColor.wdprDarkBlueColor,
              },
      @(WDPRTextStyleS3B) :
          @{
              WDPRCellTitle : @"S3B",
              NSFontAttributeName : UIFont.wdprFontStyleS3,
              NSForegroundColorAttributeName : UIColor.wdprBlueColor,
              }
      };
    
    return textStyles;
}

- (NSDictionary*)textAttributes:(WDPRTextStyle)textStyle
{
    return self.allTextStyles[@(textStyle)];
}

#pragma mark -

+ (WDPRCellConfigurationBlockType)applyStyleB1BtoTextLabel
{
    return ^(UITableViewCell* cell)
    {
        [cell.textLabel applyStyle:WDPRTextStyleB1B];
    };
}

+ (WDPRCellConfigurationBlockType)applyStyleB1DtoTextLabel
{
    return ^(UITableViewCell* cell)
    {
        [cell.textLabel applyStyle:WDPRTextStyleB1D];
    };
}

+ (WDPRCellConfigurationBlockType)applyStyleB2DtoTextLabel
{
    return ^(UITableViewCell* cell)
    {
        [cell.textLabel applyStyle:WDPRTextStyleB2D];
    };
}

+ (WDPRCellConfigurationBlockType)applyStyleC1BtoTextLabel
{
    return ^(UITableViewCell* cell)
    {
        [cell.textLabel applyStyle:WDPRTextStyleC1B];
    };
}

+ (WDPRCellConfigurationBlockType)applyStyleH2DtoTextLabel
{
    return ^(UITableViewCell* cell)
    {
        [cell.textLabel applyStyle:WDPRTextStyleH2D];
        cell.accessibilityTraits = UIAccessibilityTraitHeader;
        
    };
}

@end

#pragma mark -

@implementation NSString (WDPRTheme)

- (NSAttributedString*)attributedStringWithStyle:(WDPRTextStyle)textStyle
{
    return [self attributedStringWithAttributes:[WDPRTheme textAttributes:textStyle]];
}

@end // @@implementation NSString (WDPRTheme)

#pragma mark -

@implementation NSAttributedString (WDPRTheme)

+ (instancetype)string:(NSString *)str textStyle:(WDPRTextStyle)textStyle
{
    return [self string:str attributes:[WDPRTheme textAttributes:textStyle]];
}

@end // @@implementation NSAttributedString (WDPRTheme)
