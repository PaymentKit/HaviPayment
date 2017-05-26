//
//  UIAlertView+Blocks.m
//  WDPR
//
//  Created by Rodden, James on 7/12/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRUIKit.h"
//#import "NSError+WDPR.h"
//#import "WDPRAnalytics.h"
#import "WDPRLocalization.h"

NSString* const kWDPRAlertViewWillShowNotification = @"WDPRAlertViewWillShowNotification";
NSString* const kWDPRAlertViewUserInfoTitle = @"WDPRAlertViewUserInfoTitle";
NSString* const kWDPRAlertViewUserInfoMessage = @"WDPRAlertViewUserInfoMessage";

@implementation UIAlertView (Blocks)

+ (UIAlertView*)showAlertWithTitle:(NSString*)title
                           message:(NSString*)message
{
    return [self showAlertWithTitle:title
                            message:message
          cancelButtonTitleAndBlock:@[WDPRLocalizedStringInBundle(@"com.wdprcore.alertviewblock.okbutton", WDPRCoreResourceBundleName, nil)]];
}

+ (UIAlertView*)showAlertForError:(NSError *)error
                            title:(NSString*)title
                          message:(NSString*)message
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wundeclared-selector"
    BOOL canCheckForConnectionError = [error respondsToSelector:@selector(isConnectionError)];
    if (canCheckForConnectionError && [error performSelector:@selector(isConnectionError)])
    {
#pragma clang diagnostic pop
        return [self showAlertWithTitle:nil
                                message:WDPRLocalizedStringInBundle(@"com.wdprcore.alertviewblock.message", WDPRCoreResourceBundleName, nil)];
    }
    else
    {
        return [UIAlertView showAlertWithTitle:title
                                       message:message];
    }
}

+ (UIAlertView*)showAlertWithTitle:(NSString*)title
                           message:(NSString*)message
         cancelButtonTitleAndBlock:(NSArray*)cancelButtonTitleAndBlock
{
    return [self showAlertWithTitle:title 
                            message:message 
          cancelButtonTitleAndBlock:cancelButtonTitleAndBlock 
         otherButtonTitlesAndBlocks:nil];
}

+ (UIAlertView*)showAlertWithTitle:(NSString*)title
                           message:(NSString*)message
         cancelButtonTitleAndBlock:(NSArray*)cancelButtonTitleAndBlock
        otherButtonTitlesAndBlocks:(NSArray*)otherButtonTitlesAndBlocks
{
    UIAlertView* alertView = nil;
    if (![NSThread isMainThread])
    {
        executeOnMainThread
        (^{
            [self showAlertWithTitle:title
                             message:message
           cancelButtonTitleAndBlock:cancelButtonTitleAndBlock
          otherButtonTitlesAndBlocks:otherButtonTitlesAndBlocks];
        });
    }
    else
    {
        NSString* cancelButtonTitle =
        (([cancelButtonTitleAndBlock isKindOfClass:NSArray.class] &&
          cancelButtonTitleAndBlock.count) ? cancelButtonTitleAndBlock[0] :
         [cancelButtonTitleAndBlock
          isKindOfClass:NSString.class] ? (NSString*)cancelButtonTitleAndBlock : nil);
        
        WDPRActionBlockDelegate* delegate = [WDPRActionBlockDelegate new];
        
        if ([cancelButtonTitleAndBlock
             isKindOfClass:NSArray.class] && (cancelButtonTitleAndBlock.count > 1))
        {
            [delegate.blocks addObject:cancelButtonTitleAndBlock[1]];
        }
        else
        {
            [delegate.blocks addObject:^{ }];
        }
        
        // SLING-10423 Analytics -- Implement Adobe Alert Monitoring
        [self logAlertView:alertView title:title message:message];
        
        alertView = [[UIAlertView alloc]
                                  initWithTitle:title message:message delegate:delegate
                                  cancelButtonTitle:cancelButtonTitle otherButtonTitles:nil];
        
        WDPRActionBlockDelegate.map[@((unsigned long long)alertView)] = delegate;
        
        for (id item in otherButtonTitlesAndBlocks)
        {
            PlainBlock block = ^{ };
            
            if ([item isKindOfClass:NSString.class])
            {
                [alertView addButtonWithTitle:item];
            }
            else if ([item isKindOfClass:NSArray.class] && ((NSArray*)item).count)
            {
                [alertView addButtonWithTitle:item[0]];
                block = ((((NSArray*)item).count > 1) ? (PlainBlock)item[1] : ^{ });
            }
            
            [delegate.blocks addObject:block];
        }
        
        [alertView show];
    }
    return alertView;
}

+ (void)showAlertWithTitle:(NSString*)title
                   message:(NSString*)message
 cancelButtonTitleAndBlock:(NSArray*)cancelButtonTitleAndBlock
otherButtonTitlesAndBlocks:(NSArray*)otherButtonTitlesAndBlocks
         timeOutBlock:(void (^)(void))timeOutBlock
               andTimeOut:(NSUInteger)timeOut
{
    __weak UIAlertView *alertView =  [self showAlertWithTitle:title message:message
                                    cancelButtonTitleAndBlock:cancelButtonTitleAndBlock
                                   otherButtonTitlesAndBlocks:otherButtonTitlesAndBlocks];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(timeOut * NSEC_PER_SEC)), dispatch_get_main_queue(),
                   ^{
                       __strong UIAlertView *strongAlert = alertView;
                       if (strongAlert && timeOutBlock) {
                           timeOutBlock();
                       }
                       
                       [strongAlert dismissWithClickedButtonIndex:0 animated:YES];
                  });
}

+ (void)logAlertView:(UIAlertView *)alertView title:(NSString *)title message:(NSString *)message
{
    WDPRNotificationUserInfo *userInfo = [WDPRNotificationUserInfo new];
    
    userInfo.title = title;
    userInfo.message = message;
    [[NSNotificationCenter defaultCenter] postNotificationName:kWDPRAlertViewWillShowNotification
                                                        object:alertView
                                                      userInfo:[userInfo.userInfoDictionary copy]];
}

@end
