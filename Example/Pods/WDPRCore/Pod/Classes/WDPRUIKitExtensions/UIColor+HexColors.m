//
//  UIColor+HexColors.m
//  KiwiHarness
//
//  Created by Tim on 07/09/2012.
//  Copyright (c) 2012 Charismatic Megafauna Ltd. All rights reserved.
//

#import "WDPRUIKit.h"

static NSString *const kEmptyString = @"";
static NSString *const kPoundSign = @"#";

@implementation UIColor (HexColors)

+ (UIColor *)colorWithHexValue:(NSUInteger)hexValue
{
    return [UIColor colorWithRed:((hexValue & 0xFF0000) >> 16)/255.0 
                           green:((hexValue & 0x00FF00) >>  8)/255.0 
                            blue:((hexValue & 0x0000FF) >>  0)/255.0 alpha:1.0];
}

+ (UIColor *)colorWithHexString:(NSString *)hexString
{
    // remove '#' from hexString
    hexString = [hexString stringByReplacingOccurrencesOfString:kPoundSign withString:kEmptyString];
    
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    unsigned hexNum;
    if (![scanner scanHexInt:&hexNum]) return nil;
    
    if (hexString.length == 6)
    {
        return [UIColor colorWithRGBHex:hexNum];
    }
    else if (hexString.length == 8)
    {
        return [UIColor colorWithRGBAHex:hexNum];
    }
    else
    {
        return [UIColor blackColor];
    }
}

+ (UIColor *)colorWithRGBHex:(UInt32)hex
{
    int r = (hex >> 16) & 0xFF;
    int g = (hex >> 8) & 0xFF;
    int b = (hex) & 0xFF;
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:1.0f];
}

+ (UIColor *)colorWithRGBAHex:(UInt32)hex
{
    int r = (hex >> 24) & 0xFF;
    int g = (hex >> 16) & 0xFF;
    int b = (hex >> 8) & 0xFF;
    int a = (hex) & 0xFF;
    return [UIColor colorWithRed:r / 255.0f
                           green:g / 255.0f
                            blue:b / 255.0f
                           alpha:a / 255.0f];
}

+ (NSString *)hexValuesFromUIColor:(UIColor *)color 
{

    if (!color) 
    {
        return nil;
    }
    
    if (color == [UIColor whiteColor]) 
    {
        // Special case, as white doesn't fall into the RGB color space
        return @"ffffff";
    }
 
    CGFloat red;
    CGFloat blue;
    CGFloat green;
    CGFloat alpha;
    
    [color getRed:&red green:&green blue:&blue alpha:&alpha];
    
    int redDec = (int)(red * 255);
    int greenDec = (int)(green * 255);
    int blueDec = (int)(blue * 255);
    
    NSString *returnString = [NSString stringWithFormat:@"%02x%02x%02x", 
                              (unsigned int)redDec, (unsigned int)greenDec, (unsigned int)blueDec];

    return returnString;
    
}

@end
