//
//  WDPRNotificationUserInfo.h
//  Pods
//
//  Created by Julian Osorio on 2/12/16.
//
//

#import <Foundation/Foundation.h>
/**
 `WDPRNotificationUserInfo` is a model class that ensures encapsulation when working with NSNotification's user info dictionary.
 
 The class is meant to be extended via categories. So each category that you require will have properties that are internally saved in the userInfoDictionary providing a typed interface and at the same time storing data in a Dictionary. See WDPRNotificationUserInfo+AlertView as guidance.
 */
@interface WDPRNotificationUserInfo : NSObject

/**
 It stores all the properties defined in categories as Key - Value pairs
 */
@property (nonatomic, readonly) NSMutableDictionary *userInfoDictionary;

/**
 Creates and returns a notification user info object based on the userInfo Dictionary.
 
 @param userInfo NSNotification's user info Dictionary.
 
 @return A new WDPRNotificationUserInfo object.
 */
+ (instancetype)buildWithUserInfo:(NSDictionary *)userInfo;

@end
