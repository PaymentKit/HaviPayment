//
//  WDPRNotificationUserInfo.m
//  Pods
//
//  Created by Julian Osorio on 2/12/16.
//
//

#import "WDPRNotificationUserInfo.h"

@implementation WDPRNotificationUserInfo

#pragma mark - NSObject

- (instancetype)init
{
    if (self = [super init])
    {
        _userInfoDictionary = [NSMutableDictionary new];
    }
    
    return self;
}

#pragma mark - WDPRNotificationUserInfo

+ (instancetype)buildWithUserInfo:(NSDictionary *)userInfoDictionary
{
    WDPRNotificationUserInfo *userInfo = [WDPRNotificationUserInfo new];
    
    [userInfo.userInfoDictionary addEntriesFromDictionary:userInfoDictionary];    
    return userInfo;
}

@end
