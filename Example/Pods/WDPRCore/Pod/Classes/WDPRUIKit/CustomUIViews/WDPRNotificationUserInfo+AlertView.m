//
//  WDPRNotificationUserInfo+AlertView.m
//  Pods
//
//  Created by Julian Osorio on 2/16/16.
//
//

#import "WDPRMacros.h"
#import "WDPRNotificationUserInfo+AlertView.h"

@implementation WDPRNotificationUserInfo (AlertView)

PassthroughDictionaryProperty(NSString, self.userInfoDictionary, title, setTitle, @"WDPRAlertViewUserInfoTitle")
PassthroughDictionaryProperty(NSString, self.userInfoDictionary, message, setMessage, @"WDPRAlertViewUserInfoMessage")

@end
