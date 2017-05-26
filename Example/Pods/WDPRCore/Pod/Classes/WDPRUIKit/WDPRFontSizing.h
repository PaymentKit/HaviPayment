//
//  WDPRFontSizing.h
//  Pods
//
//  Created by Marcos Garcia on 8/26/16.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, WDPRFontSizingElement)
{
    WDPRCTAButtons = 0,
    WDPRHeaders,
    WDPRDashboardFooter
};

@interface WDPRFontSizing : NSObject

//Initialize with the default font size for the specific element
- (nonnull instancetype)initWithDefaultFontSize:(CGFloat)defaultFontSize forElement:(WDPRFontSizingElement)element;

//Returns the preferred font size regarding each language
- (CGFloat)preferredFontSize;

@end
