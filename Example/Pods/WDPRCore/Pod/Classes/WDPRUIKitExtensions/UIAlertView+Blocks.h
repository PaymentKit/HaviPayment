//
//  UIAlertView+Blocks.h
//  WDPR
//
//  Created by Rodden, James on 7/12/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDPRActionBlockDelegate.h"
#import "WDPRNotificationUserInfo+AlertView.h"

/**
 A notification sent by UIAlertView+Blocks when an alert view is shown.  This is primarily used for logging an alert
 to our analytics and is a temporary measure until we figure out a better way to do this without introducing a
 dependency on WDPRAnalytics.  The userInfo will contain a dictionary with the title and message of the alert view.
 */
extern NSString* const kWDPRAlertViewWillShowNotification;
//Deprecated constants 
extern NSString* const kWDPRAlertViewUserInfoTitle;
extern NSString* const kWDPRAlertViewUserInfoMessage;

@interface UIAlertView (Blocks)

// Used to show a simple alert with an "OK" button.
+ (UIAlertView*)showAlertWithTitle:(NSString*)title
                   message:(NSString*)message;

/// First check for network reachability. If reachability fails,
/// the no connection alert is shown, with an OK button.
/// Otherwise, a customized alert view is shown.
+ (UIAlertView*)showAlertForError:(NSError *)error
                            title:(NSString*)title
                          message:(NSString*)message;

// Used to execute blocks after a button is clicked on the alert view
// Each button / block array should be NSString 0 index, block 1 index. Blocks are optional.
+ (UIAlertView*)showAlertWithTitle:(NSString*)title
                   message:(NSString*)message
 cancelButtonTitleAndBlock:(NSArray*)cancelButtonTitleAndBlock;

// Used to execute blocks after a button is clicked on the alert view
// Each button / block array should be NSString 0 index, block 1 index. Blocks are optional.
// Array / Button Examples: @[@"Cancel"]]. @[@"Show Status", ^{...}]. @[@[@"Show Status", ^{...}], @[@"Hide Status"]]
+ (UIAlertView*)showAlertWithTitle:(NSString*)title
                   message:(NSString*)message
 cancelButtonTitleAndBlock:(NSArray*)cancelButtonTitleAndBlock
otherButtonTitlesAndBlocks:(NSArray*)otherButtonTitlesAndBlocks;

// Used to execute blocks after a button is clicked on the alert view. Also is posible to set a timeout and a block
// that will be called after the time is reached
// Each button / block array should be NSString 0 index, block 1 index. Blocks are optional.
// Array / Button Examples: @[@"Cancel"]]. @[@"Show Status", ^{...}]. @[@[@"Show Status", ^{...}], @[@"Hide Status"]]
// timeOutBlock: block to be executed once the time expired
// timeOut: time in seconds
+ (void)showAlertWithTitle:(NSString*)title
                   message:(NSString*)message
 cancelButtonTitleAndBlock:(NSArray*)cancelButtonTitleAndBlock
otherButtonTitlesAndBlocks:(NSArray*)otherButtonTitlesAndBlocks
              timeOutBlock:(PlainBlock)timeOutBlock
                andTimeOut:(NSUInteger)timeOut;

@end
