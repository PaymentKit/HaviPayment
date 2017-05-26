//
//  WDPRPrivateDataService.m
//  Mdx
//
//  Created by Garcia, Jesus on 8/1/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRPrivateDataService.h"
#import "WDPRPublicDataService.h"
#import "WDPRCommonDataService.h"
#import "WDPRServices.h"
#import "NSError+WDPR.h"
#import "AFOAuthCredential+WDPR.h"

#import "WDPRCoreServiceLoggingManager.h"
#import "WDPRAuthenticationService.h"

NSString * const WDPRUserSwitchedAccountsNotification = @"UserSwitchedAccounts";
NSString * const kNewUserCreatedNotification = @"Service_kNewUserCreatedNotificationName";
NSString * const WDPRLoggedInStatusChangedNotification = @"LoggedInStatusChanged";
NSString * const WDPRReauthenticationRequiredNotification = @"WDPRReauthenticationRequiredNotification";

//This constants must be removed once the toggle for Guest Controller v5 is removed
NSString * const kEnableProfileGCv5FromRemoteConfiguration = @"enableProfileGCv5";
NSString * const kRemoteConfigurationStoredKey = @"WDPRRemoteConfigurationStore";

NSString * const kGuestControllerUseV5RequestHeaderKey = @"Accept";
NSString * const kGuestControllerUseV5RequestHeaderValue = @"application/json;version=5";

@interface WDPRPrivateDataService ()
{
    BOOL _loggedIn;
}

@property (nonatomic, copy) NSString *ngeHost;
@property (nonatomic, copy) NSString *grxHost;
@property (atomic, strong) NSMutableArray *pendingCallers;

@end

@implementation WDPRPrivateDataService

+ (WDPRPrivateDataService *)sharedInstance
{
    static dispatch_once_t onceToken;
    static WDPRPrivateDataService *instance;
    dispatch_once(&onceToken, ^{
        instance = [[WDPRPrivateDataService alloc] initInternal];
    });
    return instance;
}

- (id)init
{
    NSAssert(false, @"Use |sharedInstance| instead.");
    return nil;
}

- (id)initInternal
{
    NSString* clientID = [WDPRServices.environment valueForKey:kServiceKeyOAuthClientID];
    NSURL *url = [NSURL URLWithString:
                  [WDPRServices.environment valueForKey:WDPRServicesHost]];

    self = [super initWithBaseURL:url clientID:clientID secret:@""];

    if (self)
    {
        self.ngeHost =
        [[NSURL URLWithString:[WDPRServices.environment
                               valueForKey:WDPRServicesNgeHost]] host];
        self.grxHost =
        [[NSURL URLWithString:[WDPRServices.environment
                               valueForKey:kServicesSecurityHost]] host];

        self.operationQueue.maxConcurrentOperationCount = NSOperationQueueDefaultMaxConcurrentOperationCount;
    }

    return self;
}

- (WDPRPublicDataService *)publicDataServiceInstance
{
    static dispatch_once_t onceToken;
    static WDPRPublicDataService *instance;
    
    dispatch_once(&onceToken, ^{
        instance = [[WDPRPublicDataService alloc] init];
    });
    
    return instance;
}

#pragma mark - Private

- (void)refreshPrivateTokenSuccess:(ServiceSuccess)successBlock
                           failure:(ServiceFailure)failureBlock
{
    if (![WDPRAuthenticationService sharedInstance].isLoggedIn)
    {
        [self commonAFNFailure:AFNServiceFailure(failureBlock) error:nil];
        return;
    }

    @synchronized(self)
    {
        // keep a queue of callers waiting for a token
        self.pendingCallers = (self.pendingCallers ?: [NSMutableArray new]);

        enum { kSuccessBlock = 0, kFailureBlock };

        [self.pendingCallers addObject:
         @[
           successBlock ?: ^(id result) {},
           failureBlock ?: ^(NSError *error) {}
           ]];

        if (self.pendingCallers.count == 1)
        {
            NSString *refreshToken = [[WDPRAuthenticationService sharedInstance].credential refreshToken];
            NSDictionary *tokens = @{ @"refreshToken" : refreshToken };
            NSString *path = [WDPRServices.environment valueForKey:kServiceKeyRefreshToken withTokens:tokens];
            NSDictionary *parameters = nil;
            
            NSString *clientID = [WDPRServices.environment valueForKey:kServiceKeyOAuthClientID];
            NSString *storedClientID = [WDPRAuthenticationService sharedInstance].credential.clientID;
            
            // Checking for the stored clientID because the refresh token from the old clientID will not work
            // on the new clientID.  If the stored clientID is nil or doesn't match the current clientID, the
            // general refresh token endpoint will be used instead.
            if (!storedClientID || ![clientID isEqualToString:storedClientID])
            {
                parameters = tokens;
                path = [WDPRServices.environment valueForKey:kServiceKeyLoginRefreshToken withTokens:nil];
            }
            
            MAKE_WEAK(self);
            
            void (^refreshTokenSuccess)() =
            ^{
                MAKE_STRONG(self);
                
                // If token is refreshed successfully, execute the success blocks and clear the pending callers
                while (strongself.pendingCallers.count)
                {
                    ServiceSuccess success;
                    
                    @synchronized(strongself)
                    {
                        success = (ServiceSuccess)(strongself.pendingCallers.firstObject[kSuccessBlock]);
                        
                        if (strongself.pendingCallers.count == 1)
                        {
                            strongself.pendingCallers = nil;
                        }
                        else
                        {
                            [strongself.pendingCallers removeObjectAtIndex:0];
                        }
                    }
                    
                    [strongself commonAFNSuccess:AFNServiceSuccess(success) param:nil];
                }
            };
            
            AFNFailure refreshTokenFailure = ^(NSError *error)
            {
                MAKE_STRONG(self);
                
                // If refresh token fails and user dismisses the sign in when prompted,
                // clear the pending callers and log user out.
                strongself.pendingCallers = nil;
                [[WDPRAuthenticationService sharedInstance] logoutwithSuccess:nil failure:nil];
            };
            
            // This is a temporary workaround for 4.7 to use a toggle to see if we have to use Guest Controller v4 or v5.
            // We don't want to add the WDPRRemoteConfiguration dependency in CoreServices, as the toggle will be removed in the near future.
            NSDictionary *remoteConfiguration = [[NSUserDefaults standardUserDefaults] objectForKey:kRemoteConfigurationStoredKey];
            BOOL isProfileGCv5Enabled = [remoteConfiguration[kEnableProfileGCv5FromRemoteConfiguration] boolValue];
            
            [[self publicDataServiceInstance]
             postDataUsingPath:path
             parameters:parameters
             overrideHeaders:isProfileGCv5Enabled? @{ kGuestControllerUseV5RequestHeaderKey : kGuestControllerUseV5RequestHeaderValue } : nil
             authVersion:MdxAuthorizationHeaderValueBearer
             success:^(id result)
             {
                 WDPRCoreServicesLogDebug(@"OAuth SUCCESS: User token refreshed.");
                 
                 NSError *error = nil;
                 AFOAuthCredential *newCredential = [AFOAuthCredential credentialWithOneIDPayload:result error:&error];
                 if (!newCredential)
                 {
                     [[NSNotificationCenter defaultCenter]
                      postNotificationName:WDPRReauthenticationRequiredNotification
                      object:nil
                      userInfo:@{@"success" : refreshTokenSuccess,
                                 @"failure" : refreshTokenFailure,
                                 @"error"   : error}];
                     return;
                 }
                 
                 AFOAuthCredential *oldCredential = [WDPRAuthenticationService sharedInstance].credential;
                 
                 newCredential.swid = oldCredential.swid;
                 newCredential.xid = oldCredential.xid;
                 newCredential.firstName = oldCredential.firstName;
                 newCredential.lastName = oldCredential.lastName;
                 newCredential.avatar = oldCredential.avatar;
                 newCredential.highTrustExpiration = oldCredential.highTrustExpiration;
                 newCredential.ageBand = oldCredential.ageBand;
                 newCredential.clientID = [WDPRServices.environment valueForKey:kServiceKeyOAuthClientID];
                 
                 [[WDPRAuthenticationService sharedInstance] storeCredential:newCredential];
                 
                 refreshTokenSuccess();
             }
             failure:^(NSError *error)
             {
                 WDPRCoreServicesLogError(@"OAuth FAILED: Failed to refresh user token: %@", error);
                 
                 [[NSNotificationCenter defaultCenter]
                  postNotificationName:WDPRReauthenticationRequiredNotification
                  object:nil
                  userInfo:@{@"success" : refreshTokenSuccess,
                             @"failure" : refreshTokenFailure,
                             @"error"   : error}];
             }];
        }
    }
}

- (void)setAuthorizationHeaderForRequest:(NSMutableURLRequest *)request
{
    NSString *tokenName = [request.URL.host isEqualToString:self.grxHost] ? @"oauth_token" :  @"BEARER";

    NSString *value = [NSString stringWithFormat:@"%@ %@", tokenName,
                     [WDPRAuthenticationService sharedInstance].credential.accessToken];

    [request setValue:value forHTTPHeaderField:@"Authorization"];
}

- (AFNFailure)failureBlockForRequest:(NSMutableURLRequest *)request
                             success:(AFNSuccess)clientSuccess
                             failure:(AFNFailure)clientFailure
{
    return [self failureBlockForRequest:request
                                success:clientSuccess
                      successWithHeader:nil
                                failure:clientFailure];
}

- (AFNFailure)failureBlockForRequest:(NSMutableURLRequest *)request
                             success:(AFNSuccess)clientSuccess
                   successWithHeader:(AFNSuccessWithHeader)clientSuccessWithHeader
                             failure:(AFNFailure)clientFailure
{
    void (^serviceCallBlock)() =
    ^{
        [self serviceCallForRequest:request success:clientSuccess successWithHeader:clientSuccessWithHeader failure:clientFailure];
    };

    AFNFailure retryFailureBlock = ^(NSError *error)
    {
        NSInteger statusCode = [self statusCode:error];

        if (statusCode == HttpStatusCodeForbidden && [self requiresSecureScope:error])
        {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:WDPRReauthenticationRequiredNotification
             object:nil
             userInfo:@{@"success" : serviceCallBlock,
                        @"failure" : clientFailure,
                        @"error"   : error}];
        }
        else
        {
            SAFE_CALLBACK(clientFailure, error);
        }
    };

    void (^serviceRetryBlock)() =
    ^{
        [self serviceCallForRequest:request success:clientSuccess successWithHeader:clientSuccessWithHeader failure:retryFailureBlock];
    };

    AFNFailure result = ^(NSError *error)
    {
        NSInteger statusCode = [self statusCode:error];

        if (statusCode == HttpStatusCodeUnauthorized &&
            [WDPRAuthenticationService sharedInstance].credential.isExpired)
        {
            [self
             refreshPrivateTokenSuccess:^(NSDictionary *result)
             {
                 serviceRetryBlock();
             }
             failure:^(NSError *error)
             {
                 SAFE_CALLBACK(clientFailure, error);
             }];
        }
        else if (statusCode == HttpStatusCodeForbidden && [self requiresSecureScope:error])
        {
            [[NSNotificationCenter defaultCenter]
             postNotificationName:WDPRReauthenticationRequiredNotification
             object:nil
             userInfo:@{@"success" : serviceCallBlock,
                        @"failure" : clientFailure,
                        @"error"   : error}];
        }
        else
        {
            SAFE_CALLBACK(clientFailure, error);
        }
    };

    return result;
}

- (void)serviceCallForRequest:(NSMutableURLRequest *)request
                      success:(AFNSuccess)clientSuccess
            successWithHeader:(AFNSuccessWithHeader)clientSuccessWithheader
                      failure:(AFNFailure)clientFailure
{
    [self setAuthorizationHeaderForRequest:request];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [operation
     setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (clientSuccessWithheader) {
             SAFE_CALLBACK(clientSuccessWithheader, responseObject, operation.response.allHeaderFields);
         } else {
             SAFE_CALLBACK(clientSuccess, responseObject);
         }
     }
     failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         SAFE_CALLBACK(clientFailure, error);
     }];
    
    [self.operationQueue addOperation:operation];
}

- (BOOL)requiresSecureScope:(NSError *)error
{
    NSDictionary *errorResponse = [error jsonResponse];
    
    /* Handle APIm error (currently used by SHDR and credit cards updates)
       Example error response:
       Forbidden - APIM Error Code: 91821403 -  Scope is unsecured Request UUID: ccfb4a6f-4efa-4fe9-b734-02150a3d66c2
       Forbidden - APIM Error Code: 91821403 -  Scope is unsecure Request UUID: fd221c31-00fd-4f24-a8c8-e7c23e917ba0
    */
    if (!errorResponse)
    {
        NSString *errorMsg = [[NSString alloc] initWithData:error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey]
                                                   encoding:NSUTF8StringEncoding];
        
        if ([errorMsg containsString:@"Scope is unsecure"])
        {
            return YES;
        }
    }
    
    /* Handle Apigee error (currently used by DLR and MDX)
       Example error response:
       {
         "errors": [{"typeId": "FORBIDDEN",
                     "message": "Client does not have one of the required scopes",
                     "systemErrorCode": "403"
                   }]
       }
    */
    NSDictionary *errorDict = [errorResponse[@"errors"] firstObject];

    if (errorDict &&
        [errorDict[@"typeId"] isEqualToString:@"FORBIDDEN"] &&
        [errorDict[@"systemErrorCode"] isEqualToString:@"403"] &&
        ([errorDict[@"message"] isEqualToString:@"Client does not have one of the required scopes"] ||
         [errorDict[@"message"] isEqualToString:@"Guest is not in secure state"]))
    {
        return YES;
    }
    
    return NO;
}

- (BOOL)preConditionsValidWithFailure:(ServiceFailure)failure {
    if (![WDPRAuthenticationService sharedInstance].isLoggedIn) {
        if (failure) {

            // TODO: a better Mdx error handling
            NSError *error = [NSError errorWithDomain:@"MdxErrors" code:-800 userInfo:nil];
            [self commonAFNFailure:AFNServiceFailure(failure) error:error];
        }
        return NO;
    }

    // If no guest ID (swid).
    if (![WDPRAuthenticationService sharedInstance].swid.length) {
        if (failure) {
            NSError *error = [NSError errorWithDomain:@"No guest ID (swid)" code:0 userInfo:nil];
            [self commonAFNFailure:AFNServiceFailure(failure) error:error];
        }
        return NO;
    }
    return YES;
}

@end
