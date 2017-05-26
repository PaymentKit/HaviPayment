//
//  WDPRAuthenticationService.h
//  Mdx
//
//  Created by Wright, Byron on 7/7/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import <WDPRCore/WDPRFoundation.h>
#import "WDPRPrivateDataService.h"

@class AFOAuthCredential;

FOUNDATION_EXTERN NSString * const WDPRLoginPreloadIsCompleteNotification;

@protocol WDPRAuthenticationServiceDelegate <NSObject>

@optional

- (void)authenticationServiceStarting:(NSString *)accountId;
- (void)authenticationServiceSucceeded:(NSDictionary *)result;
- (void)authenticationServiceFailed:(NSError *)error;

@end

@interface WDPRAuthenticationService : WDPRPrivateDataService

/** A flag which returns true if the user is successfully authenticated with a valid token.
 */
@property (nonatomic, assign, readonly, getter=isLoggedIn) BOOL loggedIn;

/** @return the auth credential (based on the @class AFNetworking 3rd party library)
 */
@property (atomic, strong) AFOAuthCredential *credential;


@property (atomic, copy, readonly) NSString *swid;
@property (atomic, copy, readonly) NSString *emailAddress;

@property (nonatomic, weak) id<WDPRAuthenticationServiceDelegate> delegate;

+ (WDPRAuthenticationService *)sharedInstance;

/** Attempts a network-based login with the provided @param username and @param password, and invokes the corresponding @param successBlock on successful authentication or @param failureBlock based on failed authentication attempt
 */
- (void)loginWithUsername:(NSString *)username
              andPassword:(NSString *)password
                  success:(ServiceSuccess)successBlock
                  failure:(ServiceFailure)failureBlock;

/** Logs out the already signed in user, and invalidates the existing auth-token
 */
- (void)logoutwithSuccess:(ServiceSuccess)success
                  failure:(ServiceFailure)failure;

- (BOOL)autoLoginWithCredential;

- (void)storeCredential:(AFOAuthCredential *)credential;

/*
 * Method to set credetials
 * @param dictionary dictionary which contains tokens and all necessary information to ser credentials
 * @param username username to set credentials
 **/
- (void)setCredentialsByDictionary:(NSDictionary *)dictionary forUsername:(NSString *)username error:(NSError **)error;

@end
