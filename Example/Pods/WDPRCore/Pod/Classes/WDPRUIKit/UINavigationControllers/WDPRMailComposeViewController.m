//
//  WDPRMailComposeViewController.m
//  DLR
//
//  Created by Delafuente, Rob on 5/10/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRMailComposeViewController.h"
#import "WDPRFoundation.h"
#import "WDPRLocalization.h"

static NSString *kWDPREmailContentPlist = @"WDPREmailContent";
static NSString *kWDPREmailSubjectKey = @"kWDPREmailSubjectKey";
static NSString *kWDPREmailRecipientsKey = @"kWDPREmailRecipientsKey";

@implementation WDPRMailComposeViewController


- (instancetype)initWithEmailContentKey:(NSString *)emailContentKey
{
    self = [super init];
    if (self)
    {
        [self setSubject:WDPRLocalizedString(@"com.wdprcore.mailcomposerview.subject",)];
        [self setToRecipients:[self emailRecipientsWithKey:emailContentKey]];
    }
    return self;
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (NSString *)emailSubjectWithKey:(NSString *)emailContentKey
{
    NSDictionary *content = [WDPRMailComposeViewController emailContent][emailContentKey];
    NSString *emailSubject = content[kWDPREmailSubjectKey];
    return emailSubject;
}

- (NSArray *)emailRecipientsWithKey:(NSString *)emailContentKey
{
    NSDictionary *content = [WDPRMailComposeViewController emailContent][emailContentKey];
    NSArray *recipients = content[kWDPREmailRecipientsKey];
    return recipients;
}

+ (NSDictionary *)emailContent
{
    static NSDictionary *content;

    void (^initializeItemsBlock)() =
    ^{
        content = [NSDictionary dictionaryFromPList:kWDPREmailContentPlist];
    };
    executeOnlyOnce(initializeItemsBlock);

    return content;
}

@end
