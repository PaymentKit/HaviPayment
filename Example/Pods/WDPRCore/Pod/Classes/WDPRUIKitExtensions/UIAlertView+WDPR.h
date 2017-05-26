//
//  UIAlertView+WDPR.h
//  DLR
//
//  Created by Jeremias Nuñez on 2/24/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIAlertView (WDPR)

// Used to present an alert with a tappable phone number, which will call the given number when tapped
// if the device supports phone calls.

/**
* Show an alert with a title and message. If phone number is not nil,
* make it clickable in the message.
* @param title The title to show in the alertview
* @param message The message to show in the alertview
* @param phoneNumber The phone number as is in the message to make clickable as a link
*/
+ (void)showPhoneCallAlertWithTitle:(NSString *)title
                            message:(NSString *)message
                        phoneNumber:(NSString *)phoneNumber;

/**
* Show an alert with a title and message. If phone number is not nil,
* make it clickable in the message.
* @param title The title to show in the alertview
* @param message The message to show in the alertview
* @param phoneNumber The phone number as is in the message to make clickable as a link
* @param confirmBlock A block that is executed on clicking the confirmation or on clicking the phone number
* @param cancelBlock A block that is executed on clicking the cancellation button
*/
+ (void)showPhoneCallAlertWithTitle:(NSString *)title
                            message:(NSString *)message
                        phoneNumber:(NSString *)phoneNumber
                       confirmBlock:(void (^)(void))confirmBlock
                        cancelBlock:(void (^)(void))cancelBlock;

/**
* Shows an error banner with a title and message. If phone number is not nil, make it clickable in the message.
* @param title The title to show in the alertview
* @param message The message to show in the alertview
* @param phoneNumber The phone number as is in the message to make clickable as a link
* @param retryBlock A block that is executed on clicking the confirmation or on clicking the phone number
*/
+ (void)showPhoneCallAlertForError:(NSError *)error
                             title:(NSString*)title
                           message:(NSString*)message
                       phoneNumber:(NSString *)phoneNumber
                             retry:(void (^)(void))retryBlock;

/**
* Show an alert for clicking a link that will go to Safari
* @param url The url to load in Safari
*/
+ (void)showNavigateToSafariAlertWithURL:(NSURL *)url;

/**
 * Show an alert for clicking a link that will go to Safari
 * @param url The url to load in Safari
 * @param confirmationBlock A block that is executed on clicking the confirmation
 */
+ (void)showNavigateToSafariAlertWithURL:(NSURL *)url
                       confirmationBlock:(void (^)(void))confirmationBlock
                             cancelBlock:(void (^)(void))cancelBlock;

@end
