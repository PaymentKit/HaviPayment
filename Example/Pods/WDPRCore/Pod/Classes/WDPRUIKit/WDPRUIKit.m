//
//  WDPRUIKit.m
//  DLR
//
//  Created by Rodden, James on 11/3/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"
#import "WDPRLocalization.h"
#import <Foundation/Foundation.h>

void notYetImplemented(NSString* message) 
{
#if (DEBUG || PRERELEASE)
    [UIAlertView
     showAlertWithTitle:WDPRLocalizedStringInBundle(@"com.wdprcore.wdpruikit.alertwarning.title", WDPRCoreResourceBundleName, nil)
     message:message ?: WDPRLocalizedStringInBundle(@"com.wdprcore.wdpruikit.alertwarning.message", WDPRCoreResourceBundleName, nil)
     cancelButtonTitleAndBlock:@[WDPRLocalizedStringInBundle(@"com.wdprcore.wdpruikit.alertwarning.button", WDPRCoreResourceBundleName, nil)]
     otherButtonTitlesAndBlocks:nil];
#endif
}

@implementation NSObject (WDPRUIKit)

- (void)notYetImplemented
{
    [self notYetImplemented:nil];
}

- (void)notYetImplemented:(NSString*)message
{
    notYetImplemented(message);
}

@end // @implementation NSObject (WDPRUIKit)

