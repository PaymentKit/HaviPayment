//
//  WDPRMailComposeViewController.h
//  DLR
//
//  This MFMailComposeViewController will load the plist named "WDPREmailContent.plist" and
//  based on the EmailContentKey, will load in the corresponding email content.
//  This controller will parse each loaded email with the following keys:
//
//  kWDPREmailSubjectKey - Subject String.
//  kWDPREmailRecipientsKey - Array of Recipient Strings.
//
//  Created by Delafuente, Rob on 5/10/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import <MessageUI/MessageUI.h>

@interface WDPRMailComposeViewController : MFMailComposeViewController

- (instancetype)initWithEmailContentKey:(NSString *)emailContentKey;

@end
