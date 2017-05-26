//
//  WDPRAuthenticationService.m
//  Mdx
//
//  Created by Wright, Byron on 7/7/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import "WDPRAuthenticationService.h"

#import "WDPRCoreServiceConstants.h"
#import "WDPRServices.h"
#import "WDPRPublicDataService.h"
#import "WDPRCoreServiceLoggingManager.h"
#import "AFOAuthCredential+WDPR.h"

#define kServiceKeyOAuthScope @"OAuthScope"
#define kWDPRUsername @"MdxUsername"

NSString * const WDPRLoginPreloadIsCompleteNotification = @"WDPRLoginPreloadIsCompleteNotification";

@interface WDPRAuthenticationService()

@property (nonatomic, copy) NSString *ngeHost;
@property (nonatomic, copy) NSString *grxHost;

@property (atomic, copy) NSString *swid;
@property (atomic, copy) NSString *emailAddress;

@end

@implementation WDPRAuthenticationService

+ (WDPRAuthenticationService *)sharedInstance
{
    static dispatch_once_t onceToken;
    static WDPRAuthenticationService *instance;
    
    dispatch_once(&onceToken, ^{
        instance = [[WDPRAuthenticationService alloc] initInternal];
    });
    
    return instance;
}

- (id)initInternal
{
    // TODO
    // self.delegateInstance = [WDPRCommonDataServiceDelegateHandler new];
    // self.serviceDelegate = self.delegateInstance;

    NSString *clientID = [WDPRServices.environment valueForKey:kServiceKeyOAuthClientID];
    NSURL *url = [NSURL URLWithString:
                  [WDPRServices.environment valueForKey:WDPRServicesHost]];

    self = [super initWithBaseURL:url clientID:clientID secret:@""];

    if (self)
    {
        if ([WDPRServices.environment useSoftLaunchEnvironment])
        {
            [self.requestSerializer setValue:kServiceValueSoftLaunchHeader forHTTPHeaderField:kServiceKeySoftLaunchHeader];
        }

        self.ngeHost =
        [[NSURL URLWithString:[WDPRServices.environment
                               valueForKey:WDPRServicesNgeHost]] host];
        self.grxHost =
        [[NSURL URLWithString:[WDPRServices.environment
                               valueForKey:kServicesSecurityHost]] host];
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

- (void)loginWithUsername:(NSString *)username
              andPassword:(NSString *)password
                  success:(ServiceSuccess)successBlock
                  failure:(ServiceFailure)failureBlock
{
    NSString *path = [WDPRServices.environment valueForKey:kServiceKeyLoginUser withTokens:nil];
    NSDictionary *parameters = @{ @"loginValue" : username,
                                  @"password" : password };
    NSDictionary *overrideHeaders = @{ @"Always-OK-Response" : @"true" };

    MAKE_WEAK(self);

    [[self publicDataServiceInstance]
     postDataUsingPath:path
     parameters:parameters
     overrideHeaders:overrideHeaders
     authVersion:MdxAuthorizationHeaderValueBearer
     success:^(id result) {
         MAKE_STRONG(self);

         NSError *error = nil;
         [strongself setCredentialsByDictionary:result forUsername:username error:&error];
         
         if (!strongself.credential)
         {
             SAFE_CALLBACK(failureBlock, error);
             return;
         }

         NSString *swid = [result valueForKeyPath:@"data.profile.swid"];
         if (!swid.length)
         {
             SAFE_CALLBACK(failureBlock, error);
             return;
         }
         
         [strongself commonAFNSuccess:AFNServiceSuccess(successBlock) param:result];
     }
     failure:^(NSError *error)
     {
         MAKE_STRONG(self);
         WDPRCoreServicesLogFailure(@"OAauth FAILED: Failed to aquire user token");
         WDPRCoreServicesLogError(@"ERROR: %@",error);

         [strongself commonAFNFailure:AFNServiceFailure(failureBlock) error:error];
     }];
}

- (BOOL)isLoggedIn
{
    return self.swid.length > 0;
}

- (BOOL)autoLoginWithCredential
{
    if (self.emailAddress)
    {
        self.credential = [AFOAuthCredential retrieveCredentialWithIdentifier:self.serviceProviderIdentifier];
    }
    
    if (self.credential.swid)
    {
        self.swid = self.credential.swid;
        return YES;
    }
    else
    {
        return NO;
    }
}

- (void)storeCredential:(AFOAuthCredential *)credential
{
    self.credential = credential;
    
    [AFOAuthCredential storeCredential:credential
                        withIdentifier:self.serviceProviderIdentifier];
}

- (void)logoutwithSuccess:(ServiceSuccess)success
                  failure:(ServiceFailure)failure
{
    self.credential = nil;
    self.swid = nil;

    [[NSNotificationCenter defaultCenter]
     postNotificationName:WDPRLoggedInStatusChangedNotification object:nil];

    if ([AFOAuthCredential deleteCredentialWithIdentifier:self.serviceProviderIdentifier])
    {
        WDPRCoreServicesLog(@"OAuth SUCCESS: User logged out.");

        [self commonAFNSuccess:AFNServiceSuccess(success) param:nil];

        [[NSNotificationCenter defaultCenter]
         postNotificationName:WDPRLoggedInStatusChangedNotification object:nil];
    }
    else if (failure)
    {
        WDPRCoreServicesLogWarning(@"OAuth FAILED: User not logged out.");

        [self commonAFNFailure:AFNServiceFailure(failure) error:nil];
    }
}

- (NSString *)emailAddress
{
    return [[NSUserDefaults standardUserDefaults] stringForKey:kWDPRUsername];
}

- (void)setEmailAddress:(NSString *)emailAddress
{
    [[NSUserDefaults standardUserDefaults] setObject:emailAddress forKey:kWDPRUsername];

    // Synch to the persistent plist file immediately, in case the user shuts down the app
    // before the automatic synch occurs.
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)setCredentialsByDictionary:(NSDictionary *)dictionary forUsername:(NSString *)username error:(NSError **)error
{
    AFOAuthCredential *newCredential = [AFOAuthCredential credentialWithOneIDPayload:dictionary error:error];
    
    if (!newCredential)
    {
        return;
    }
    
    NSString *swid = [dictionary valueForKeyPath:@"data.profile.swid"];
    if (!swid.length)
    {
        return;
    }
    
    newCredential.swid = swid;
    newCredential.clientID = [WDPRServices.environment valueForKey:kServiceKeyOAuthClientID];
    
    self.swid = swid;
    self.credential = newCredential;
    [self storeCredential:newCredential];
    [self setEmailAddress:username];
}

@end
