//
//  UIAlertView+WDPR.m
//  DLR
//
//  Created by Jeremias Nuñez on 2/24/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"
#import "WDPRNotificationBanner.h"
#import "WDPRLocalization.h"

@implementation UIAlertView (WDPR)

+ (void)showPhoneCallAlertWithTitle:(NSString *)title
                            message:(NSString *)message
                        phoneNumber:(NSString *)phoneNumber
                       confirmBlock:(void (^)(void))confirmBlock
                        cancelBlock:(void (^)(void))cancelBlock
{
    PlainBlock callBlock = ^
    {
        NSURL *phoneUrl = [NSURL URLWithString:
                           [NSString stringWithFormat:@"tel:%@",
                            phoneNumber.stripDecorationsOfPhoneNumber]];
        
        if (![[UIApplication sharedApplication] canOpenURL:phoneUrl] ||
            ![[UIApplication sharedApplication] openURL:phoneUrl])
        {
            [self showAlertWithTitle:WDPRLocalizedStringInBundle(@"com.wdprcore.alertviewwdpr.title", WDPRCoreResourceBundleName, nil)
                             message:WDPRLocalizedStringInBundle(@"com.wdprcore.alertviewwdpr.message", WDPRCoreResourceBundleName, nil)];
        }
        else
        {
            SAFE_CALLBACK(confirmBlock);
        }
    };
    
    [UIAlertView showAlertWithTitle:title
                            message:message
          cancelButtonTitleAndBlock:@[WDPRLocalizedStringInBundle(@"com.wdprcore.alertviewwdpr.cancelbutton", WDPRCoreResourceBundleName, nil), cancelBlock ?: ^{}]
         otherButtonTitlesAndBlocks:@[@[WDPRLocalizedStringInBundle(@"com.wdprcore.alertviewwdpr.callbutton", WDPRCoreResourceBundleName, nil), callBlock]]];
}


+ (void)showPhoneCallAlertWithTitle:(NSString *)title
                            message:(NSString *)message
                        phoneNumber:(NSString *)phoneNumber
{
    [UIAlertView showPhoneCallAlertWithTitle:title
                                     message:message
                                 phoneNumber:phoneNumber
                                confirmBlock:nil
                                 cancelBlock:nil];
}

+ (void)showPhoneCallAlertForError:(NSError *)error
                             title:(NSString*)title
                           message:(NSString*)message
                       phoneNumber:(NSString *)phoneNumber
                             retry:(void (^)(void))retryBlock
{
    // Display error banner
    
    WDPRNotificationBannerRetryBlock notificationBannerRetry;
    if (retryBlock)
    {
        notificationBannerRetry = ^(WDPRNotificationBanner *notificationBanner) { retryBlock(); };
    }
    else
    {
        notificationBannerRetry = nil;
    }
    
    WDPRNotificationBanner *banner = [WDPRNotificationBanner serviceErrorBannerWithError:error
                                                                                   title:title
                                                                                 message:message];
    banner.phoneNumber = phoneNumber;
    banner.retryBlock = notificationBannerRetry;
    [banner show];
}

+ (void)showNavigateToSafariAlertWithURL:(NSURL *)url
{
    [UIAlertView showNavigateToSafariAlertWithURL:url
                                confirmationBlock:nil
                                      cancelBlock:nil];
}

+(void)showNavigateToSafariAlertWithURL:(NSURL *)url
                      confirmationBlock:(void (^)(void))confirmationBlock
                            cancelBlock:(void (^)(void))cancelBlock
{
    PlainBlock navigateBlock = ^
    {
        if (![[UIApplication sharedApplication] canOpenURL:url] ||
            ![[UIApplication sharedApplication] openURL:url])
        {
            [self showAlertWithTitle:WDPRLocalizedStringInBundle(@"com.wdprcore.alertviewwdpr.titlesorry", WDPRCoreResourceBundleName, nil)
                             message:WDPRLocalizedStringInBundle(@"com.wdprcore.alertviewwdpr.messagesupportexternalurl" , WDPRCoreResourceBundleName, nil)];
        }
        else
        {
            SAFE_CALLBACK(confirmationBlock);
        }
    };
    
    NSArray *confirmBlock = @[@[WDPRLocalizedStringInBundle(@"com.wdprcore.alertviewwdpr.confirmblock", WDPRCoreResourceBundleName, nil), navigateBlock, confirmationBlock ?: ^{}]];
    NSString *title = WDPRLocalizedStringInBundle(@"com.wdprcore.alertviewwdpr.title.opensafari", WDPRCoreResourceBundleName, nil);
    
    [UIAlertView showAlertWithTitle:title
                            message:nil
          cancelButtonTitleAndBlock:@[WDPRLocalizedStringInBundle(@"com.wdprcore.alertviewwdpr.cancelblocktitle", WDPRCoreResourceBundleName, nil), cancelBlock ?: ^{}]
         otherButtonTitlesAndBlocks:confirmBlock];
}

@end
