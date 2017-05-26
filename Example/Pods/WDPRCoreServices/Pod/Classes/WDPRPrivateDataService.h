//
//  WDPRPrivateDataService.h
//  Mdx
//
//  Created by Garcia, Jesus on 8/1/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRCommonDataService.h"

FOUNDATION_EXTERN NSString * const WDPRUserSwitchedAccountsNotification;
FOUNDATION_EXTERN NSString * const kNewUserCreatedNotification;
FOUNDATION_EXTERN NSString * const WDPRLoggedInStatusChangedNotification;
FOUNDATION_EXTERN NSString * const WDPRReauthenticationRequiredNotification;

/**
* WDPRPrivateDataService is a subclass of @class WDPRCommonDataService.
* It provides a single @param sharedInstance, which can be used to make network requests
* for user authentication and user-specific data.
**/

@interface WDPRPrivateDataService : WDPRCommonDataService


+ (WDPRPrivateDataService *)sharedInstance;


// TODO Greg - I believe this needs to go bye bye. Refreshing the user token, based on
// a timer, violates Disney security policy.
- (void)refreshPrivateTokenSuccess:(ServiceSuccess)successBlock
                           failure:(ServiceFailure)failureBlock;

/**
 Methods in header to be used by class categories
 */
- (BOOL)preConditionsValidWithFailure:(ServiceFailure)failure;

@end
