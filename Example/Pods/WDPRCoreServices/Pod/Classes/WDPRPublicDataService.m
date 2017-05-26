//
//  WDPRPublicDataService.m
//  WDPR
//
//  Created by Garcia, Jesus on 7/10/13.
//  Updated by Clark, Daniel on 06/25/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRPublicDataService.h"
#import "WDPRPublicDataService+Internal.h"

// Data Objects
#import "WDPRServices.h"

#import "WDPRCommonDataService+Private.h"
#import "WDPRCoreServiceLoggingManager.h"
#import "WDPRCoreServiceConstants.h"

@interface WDPRPublicDataService ()

@property(atomic, strong) AFOAuthCredential *credential;
@property(atomic, strong) NSMutableArray* pendingCallers;
@property(atomic) BOOL queryingAuthorization;

@property (nonatomic, copy) NSString *ngeHost;
@property (nonatomic, copy) NSString *grxHost;

@end

@implementation WDPRPublicDataService

#pragma mark - Instance Methods

- (id)init
{
    NSString *clientID = WDPRServices.environment[kServiceKeyOAuthClientID];
    
    NSURL *url = [NSURL URLWithString:WDPRServices.environment[WDPRServicesHost]];
    
    self = [super initWithBaseURL:url clientID:clientID secret:@""];
    
    if (self) 
    {
        //[self setDefaultHeader:@"Accept-Encoding" value:nil];
        
        self.ngeHost = [[NSURL URLWithString:
                         WDPRServices.environment[WDPRServicesNgeHost]] host];
        
        self.grxHost = [[NSURL URLWithString:
                         WDPRServices.environment[kServicesSecurityHost]] host];
    }
    
    return self;
}

#pragma mark - Profile Service Methods

- (void)checkDirtyWords:(NSString *)text
                success:(ServiceSuccess)success
                failure:(ServiceFailure)failure
{
    [self
     getDataUsingPath:[WDPRServices.environment
                       valueForKey:kServiceEndPointDirtyWordsCheck
                       withTokens:@{@"text": [text urlEncode]}]
     parameters:nil
     overrideHeaders:nil
     authVersion:MdxAuthorizationHeaderValueBearer
     success:^(id responseObject)
     {
         if (!responseObject)
         {
             [self commonAFNFailure:AFNServiceFailure(failure) error:nil];
         }
         else
         {
             [self commonAFNSuccess:AFNServiceSuccess(success) param:responseObject];
         }
     }
     failure:^(NSError *error)
     {
         [self commonAFNFailure:AFNServiceFailure(failure) error:error];
     }];
}

#pragma mark - Private Instance Methods

- (void)enqueueHTTPRequestOperation:(AFHTTPRequestOperation *)operation
{
    
    // SLING-5977: instrument service calls to report response times
    [self.operationQueue addOperation:[NSBlockOperation blockOperationWithBlock:
                                      ^{
                                          __weak AFHTTPRequestOperation* weakRef = operation;
                                          void (^completionBlock)(void) = weakRef.completionBlock;
                                          
                                          [weakRef setCompletionBlock:
                                           ^{
                                               if (completionBlock) 
                                               {
                                                   completionBlock();
                                               }
                                           }];
                                          
                                          [weakRef start];
                                      }]];
}

- (void)setAuthorizationHeaderForRequest:(NSMutableURLRequest *)request
{
    NSString *tokenName = [request.URL.host isEqualToString:self.grxHost] ? @"oauth_token" :  @"BEARER";
    
    NSString *value = [NSString stringWithFormat:@"%@ %@", tokenName, self.credential.accessToken];
    
    [request setValue:value forHTTPHeaderField:@"Authorization"];
}

- (void)applyPublicTokenForAuthVersion:(MdxAuthorizationHeaderValue)authHeaderValue
                               success:(AFNSuccess)success
                               failure:(AFNFailure)failure 
{
    @synchronized(self)
    {
        if (self.credential != nil && !self.credential.isExpired)
        { // current time is before the token expiration time
            // The DTSS profile services require a different header value,
            // than what is used by the WDPRO services.
            if (authHeaderValue == MdxAuthorizationHeaderValueOauthToken) 
            {
                [self.requestSerializer setValue:[NSString stringWithFormat:@"oauth_token %@", self.credential.accessToken]
                              forHTTPHeaderField:@"Authorization"];
            }
            else
            {
                [self.requestSerializer setValue:[NSString stringWithFormat:@"BEARER %@", self.credential.accessToken]
                              forHTTPHeaderField:@"Authorization"];
            }
            
            [self commonAFNSuccess:success param:nil];
        } 
        else
        {
            // keep a queue of callers waiting for a token
            self.pendingCallers = (self.pendingCallers ?: 
                                   [NSMutableArray new]);
            
            enum { kSuccessBlock = 0, kFailureBlock };
            [self.pendingCallers addObject:
             @[
               success ?: ^(id b){},
               failure ?: ^(NSError* b){}
               ]];
            
            if (self.pendingCallers.count == 1)
            {
                NSDate *startTime = [NSDate date];
                
                NSAssert(WDPRServices.environment[kServiceKeyOAuthClientID],
                         @"kServiceKeyOAuthClientID is a required key in Services.plist");
                
                if (self.queryingAuthorization)
                {
                    return;
                }
                
                self.queryingAuthorization =  YES;

                [self
                 wdprAuthenticateUsingOAuthWithPath:WDPRServices.environment[kServiceKeyOAuthURL]
                 
                 parameters:@{
                              @"grant_type": @"assertion",
                              @"assertion_type": @"public",
                              @"client_id": WDPRServices.environment[kServiceKeyOAuthClientID]
                              }
                 
                 success:^(id responseObject, AFHTTPRequestOperation *operation, AFOAuthCredential *newCredential)
                 {
                     NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:startTime];
                     WDPRCoreServicesLogDebug(@"I have a token! %@ [%4.3f ms to acquire]", newCredential.accessToken, diff * 1000);
                     
                     [self.eventTimes addTimeEvent:kServiceKeyOAuthToken time:diff error:nil];
                     self.credential = newCredential;

                     // The DTSS profile services require a different header value, than what is used by the WDPRO services.
                     if (authHeaderValue == MdxAuthorizationHeaderValueOauthToken)
                     {
                         [self.requestSerializer setValue:[NSString stringWithFormat:@"oauth_token %@", self.credential.accessToken]
                                       forHTTPHeaderField:@"Authorization"];
                     }
                     else
                     {
                         [self.requestSerializer setValue:[NSString stringWithFormat:@"BEARER %@", self.credential.accessToken]
                                       forHTTPHeaderField:@"Authorization"];
                     }

                     WDPRCoreServicesLogDebug(@"Running Service");
                     
                     while (self.pendingCallers.count)
                     {
                         AFNSuccess success;
                         @synchronized(self)
                         {
                             success = (AFNSuccess)
                             (self.pendingCallers.firstObject[kSuccessBlock]);
                             
                             if (self.pendingCallers.count == 1)
                             {
                                 self.pendingCallers = nil;
                             }
                             else [self.pendingCallers removeObjectAtIndex:0];
                         }
                         
                         [self commonAFNSuccess:success param:nil];
                     }
                     
                     self.queryingAuthorization = NO;
                 }
                 
                 failure:^(AFHTTPRequestOperation * op,  NSError *error)
                 {
                     NSTimeInterval diff = [[NSDate date] timeIntervalSinceDate:startTime];
                     [self.eventTimes addTimeEvent:kServiceKeyOAuthToken time:diff error:error];
                     
                     while (self.pendingCallers.count)
                     {
                         AFNFailure failure;
                         @synchronized(self)
                         {
                             failure = (AFNFailure)
                             (self.pendingCallers.firstObject[kFailureBlock]);
                             
                             if (self.pendingCallers.count == 1)
                             {
                                 self.pendingCallers = nil;
                             }
                             else [self.pendingCallers removeObjectAtIndex:0];
                         }
                         
                         [self commonAFNFailure:failure error:error];
                     }
                     
                     self.queryingAuthorization = NO;
                 }];
            }
        }
    }
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
    return clientFailure;
}

#pragma mark - WDPRPublicDataService (Internal)

#pragma mark NSURLCache Mechanism approach

- (void)getDataUsingPath:(NSString *)path
              parameters:(NSDictionary *)parameters
         overrideHeaders:(NSDictionary *)overrideHeaders
         cacheMetadataId:(NSString *)cacheMetadataId
             authVersion:(MdxAuthorizationHeaderValue)authVersion
                 success:(ServiceSuccess)success
                 failure:(ServiceFailure)failure
{
    __weak WDPRPublicDataService *weakSelf = self;
    void (^addOperation)(NSOperation *) = ^(NSOperation *operation)
    {
        [weakSelf.operationQueue addOperation:operation];
    };
    
    [self operationForGetDataUsingPath:path
                            parameters:parameters
                       overrideHeaders:overrideHeaders
                       cacheMetadataId:cacheMetadataId
                           authVersion:authVersion
                               success:success
                               failure:failure
                              callback:addOperation];
}

- (void)operationForGetDataUsingPath:(NSString *)path
                          parameters:(NSDictionary *)parameters
                     overrideHeaders:(NSDictionary *)overrideHeaders
                     cacheMetadataId:(NSString *)cacheMetadataId
                         authVersion:(MdxAuthorizationHeaderValue)authVersion
                             success:(ServiceSuccess)success
                             failure:(ServiceFailure)failure
                            callback:(void (^)(NSOperation *))callback
{
    __weak WDPRPublicDataService *weakSelf = self;
    ServiceSuccess successHandler = ^(id data)
    {
        [weakSelf commonAFNSuccess:AFNServiceSuccess(success) param:data];
    };
    ServiceFailure failureHandler = ^(NSError *error)
    {
        [weakSelf commonAFNFailure:AFNServiceFailure(failure) error:error];
    };
    ServiceSuccess operationHandler = ^(id responseObject)
    {
        NSOperation *operation = [weakSelf operationForQueryPath:path
                                                          ofType:kServiceGet
                                                      parameters:parameters
                                                 cacheMetadataId:cacheMetadataId
                                                 overrideHeaders:overrideHeaders
                                                         success:successHandler
                                                         failure:failureHandler];
        
        SAFE_CALLBACK(callback, operation);
    };
    
    [self applyPublicTokenForAuthVersion:authVersion
                                 success:operationHandler
                                 failure:failureHandler];
}

#pragma mark Original Get methods

- (void)getDataUsingPath:(NSString *)path
              parameters:(NSDictionary *)parameters
         overrideHeaders:(NSDictionary *)overrideHeaders
                 success:(ServiceSuccess)success
                 failure:(ServiceFailure)failure
{
    [self getDataUsingPath:path
                parameters:parameters
           overrideHeaders:overrideHeaders
               authVersion:MdxAuthorizationHeaderValueBearer
                   success:success
                   failure:failure];
}

- (void)getDataUsingPath:(NSString *)path
              parameters:(NSDictionary *)parameters
         overrideHeaders:(NSDictionary *)overrideHeaders
             authVersion:(MdxAuthorizationHeaderValue)authVersion
                 success:(ServiceSuccess)success
                 failure:(ServiceFailure)failure
{
    __weak WDPRPublicDataService *weakSelf = self;
    void (^addOperation)(NSOperation *) = ^(NSOperation *operation)
    {
        [weakSelf.operationQueue addOperation:operation];
    };
    
    [self operationForGetDataUsingPath:path
                            parameters:parameters
                       overrideHeaders:overrideHeaders
                           authVersion:authVersion
                               success:success
                               failure:failure
                              callback:addOperation];
}

- (void)operationForGetDataUsingPath:(NSString *)path
                          parameters:(NSDictionary *)parameters
                     overrideHeaders:(NSDictionary *)overrideHeaders
                             success:(ServiceSuccess)success
                             failure:(ServiceFailure)failure
                            callback:(void (^)(NSOperation *))callback
{
   [self operationForGetDataUsingPath:path
                           parameters:parameters
                      overrideHeaders:overrideHeaders
                          authVersion:MdxAuthorizationHeaderValueBearer
                              success:success
                              failure:failure
                             callback:callback];
}

- (void)operationForGetDataUsingPath:(NSString *)path
                          parameters:(NSDictionary *)parameters
                     overrideHeaders:(NSDictionary *)overrideHeaders
                         authVersion:(MdxAuthorizationHeaderValue)authVersion
                             success:(ServiceSuccess)success
                             failure:(ServiceFailure)failure
                            callback:(void (^)(NSOperation *))callback
{
    __weak WDPRPublicDataService *weakSelf = self;
    ServiceSuccess successHandler = ^(id data)
    {
        [weakSelf commonAFNSuccess:AFNServiceSuccess(success) param:data];
    };
    ServiceFailure failureHandler = ^(NSError *error)
    {
        [weakSelf commonAFNFailure:AFNServiceFailure(failure) error:error];
    };
    ServiceSuccess operationHandler = ^(id responseObject)
    {
        NSOperation *operation = [weakSelf operationForQueryPath:path
                                                          ofType:kServiceGet
                                                      parameters:parameters
                                                 overrideHeaders:overrideHeaders
                                                         success:successHandler
                                                         failure:failureHandler];
        
        SAFE_CALLBACK(callback, operation);
    };
    
    [self applyPublicTokenForAuthVersion:authVersion
                                 success:operationHandler
                                 failure:failureHandler];
}

- (void)putDataUsingPath:(NSString *)path
               parameters:(id)parameters
              authVersion:(MdxAuthorizationHeaderValue)authVersion
                  success:(ServiceSuccess)success
                  failure:(ServiceFailure)failure
{
    MAKE_WEAK(self);
    
    [self
     applyPublicTokenForAuthVersion:authVersion
     success:^(id result) {
         [weakself putDataUsingPath:path
                          parameters:parameters
                             success:success
                             failure:failure];
     } failure:^(NSError *error) {
         [weakself commonAFNFailure:failure error:error];
     }];
}

- (void)postDataUsingPath:(NSString *)path
               parameters:(id)parameters
              authVersion:(MdxAuthorizationHeaderValue)authVersion
                  success:(ServiceSuccess)success
                  failure:(ServiceFailure)failure
{
    [self postDataUsingPath:path
                 parameters:parameters
          parameterEncoding:WDPRJSONParameterEncoding
            overrideHeaders:nil
                authVersion:authVersion
                    success:success
                    failure:failure];
}

- (void)postDataUsingPath:(NSString *)path
              authVersion:(MdxAuthorizationHeaderValue)authVersion
        successWithHeader:(ServiceSuccessWithHeader)successWithHeader
                  failure:(ServiceFailure)failure
{
    [self postDataUsingPath:path
                 parameters:nil
            overrideHeaders:nil
                authVersion:authVersion
          successWithHeader:successWithHeader
                    failure:failure];
}

- (void)postDataUsingPath:(NSString *)path
               parameters:(id)parameters
          overrideHeaders:(NSDictionary *)overrideHeaders
              authVersion:(MdxAuthorizationHeaderValue)authVersion
                  success:(ServiceSuccess)success
                  failure:(ServiceFailure)failure
{
    [self postDataUsingPath:path
                 parameters:parameters
          parameterEncoding:WDPRJSONParameterEncoding
            overrideHeaders:overrideHeaders
                authVersion:authVersion
                    success:success
                    failure:failure];
}

- (void)postDataUsingPath:(NSString *)path
               parameters:(id)parameters
          overrideHeaders:(NSDictionary *)overrideHeaders
              authVersion:(MdxAuthorizationHeaderValue)authVersion
        successWithHeader:(ServiceSuccessWithHeader)successWithHeader
                  failure:(ServiceFailure)failure
{
    [self postDataUsingPath:path
                 parameters:parameters
          parameterEncoding:WDPRJSONParameterEncoding
            overrideHeaders:overrideHeaders
                authVersion:authVersion
          successWithHeader:successWithHeader
                    failure:failure];
}

- (void)postDataUsingPath:(NSString *)path
               parameters:(id)parameters
        parameterEncoding:(WDPRParameterEncoding)paramEncoding
          overrideHeaders:(NSDictionary *)overrideHeaders
              authVersion:(MdxAuthorizationHeaderValue)authVersion
                  success:(ServiceSuccess)success
                  failure:(ServiceFailure)failure
{
    MAKE_WEAK(self);
    
    [self
     applyPublicTokenForAuthVersion:authVersion
     success:^(id result) {
         [weakself postDataUsingPath:path
                          parameters:parameters
                   parameterEncoding:paramEncoding
                     overrideHeaders:overrideHeaders
                             success:success
                             failure:failure];
     } failure:^(NSError *error) {
         [weakself commonAFNFailure:failure error:error];
     }];
}

- (void)postDataUsingPath:(NSString *)path
               parameters:(id)parameters
        parameterEncoding:(WDPRParameterEncoding)paramEncoding
          overrideHeaders:(NSDictionary *)overrideHeaders
              authVersion:(MdxAuthorizationHeaderValue)authVersion
        successWithHeader:(ServiceSuccessWithHeader)successWithHeader
                  failure:(ServiceFailure)failure
{
    MAKE_WEAK(self);
    
    [self
     applyPublicTokenForAuthVersion:authVersion
     success:^(id result) {
         [weakself postDataUsingPath:path
                          parameters:parameters
                   parameterEncoding:paramEncoding
                     overrideHeaders:overrideHeaders
                   successWithHeader:successWithHeader
                             failure:failure];
     } failure:^(NSError *error) {
         [weakself commonAFNFailure:failure error:error];
     }];
}

- (void)postDataUsingPath:(NSString *)path
               jsonObject:(id)object
              authVersion:(MdxAuthorizationHeaderValue)authVersion
                  success:(ServiceSuccess)success
                  failure:(ServiceFailure)failure
{
    MAKE_WEAK(self);
    
    [self
     applyPublicTokenForAuthVersion:authVersion
     success:^(id result) {
         [weakself postDataUsingPath:path
                          jsonObject:object
                             success:success
                             failure:failure];
     } failure:^(NSError *error) {
         [weakself commonAFNFailure:failure error:error];
     }];
}

- (void)postDataUsingPath:(NSString *)path
 formUrlEncodedParameters:(NSString *)parameters
          overrideHeaders:(NSDictionary *)overrideHeaders
              authVersion:(MdxAuthorizationHeaderValue)authVersion
                  success:(ServiceSuccess)success
                  failure:(ServiceFailure)failure
{
    MAKE_WEAK(self);
    
    [self
     applyPublicTokenForAuthVersion:authVersion
     success:^(id result) {
         [weakself postDataUsingPath:path
            formUrlEncodedParameters:parameters
                     overrideHeaders:overrideHeaders
                             success:success
                             failure:failure];
     } failure:^(NSError *error) {
         [weakself commonAFNFailure:failure error:error];
     }];
}

- (void)performHeadUsingPath:(NSString *)path
                  parameters:(NSDictionary *)parameters
                 authVersion:(MdxAuthorizationHeaderValue)authVersion
                     success:(ServiceSuccess)success
                     failure:(ServiceFailure)failure
{
    
    MAKE_WEAK(self);
    
    [self
     applyPublicTokenForAuthVersion:authVersion
     success:^(id result) {
         [weakself performHeadUsingPath:path
                             parameters:parameters
                                success:success
                                failure:failure];
     } failure:^(NSError *error) {
         [weakself commonAFNFailure:failure error:error];
     }];
}

@end
