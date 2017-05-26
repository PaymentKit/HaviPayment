//
//  WDPRCommonDataService.m
//  Mdx
//
//  Created by Vidos, Hugh on 8/2/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import "WDPRCommonDataService.h"

#import <WDPRCore/WDPRFoundation.h>

#import "WDPRServices.h"
#import "WDPRAppCache.h"
#import "NSCachedURLResponse+CacheExpiration.h"
#import "WDPRCacheMetadata.h"
#import "WDPRCacheMetadataFactory.h"
#import "WDPRCoreServiceConstants.h"
#import "WDPRCoreServiceLoggingManager.h"
#import "WDPRCoreServices.h"
#import "WDPRAuthenticationService.h"
#import "WDPRHTTPConstants.h"
#import "WDPRObservableCacheDelegate.h"

static const NSTimeInterval WDPROAuthTokenTimeout = 6.0;
static const NSTimeInterval WDPRMaxResponseDateDelta = 2.0;

AFNSuccess AFNServiceSuccess(ServiceSuccess serviceSuccess)
{
    return ^(id response)
    {
        if (serviceSuccess)
        {
            serviceSuccess(response);
        }
    };
}

AFNSuccessWithHeader AFNServiceSuccessWithHeader(ServiceSuccessWithHeader serviceSuccessWithHeader)
{
    return ^(id response, NSDictionary *responseHeader)
    {
        if (serviceSuccessWithHeader)
        {
            serviceSuccessWithHeader(response, responseHeader);
        }
    };
}

AFNFailure AFNServiceFailure(ServiceFailure serviceFailure)
{
    return ^(NSError* error)
    {
        if (serviceFailure)
        {
            serviceFailure(error);
        }
    };
}

@interface WDPRCommonDataService ()

@property (nonatomic) NSString *secret;
@property (nonatomic, strong) NSMutableDictionary *trackData;
@property (nonatomic, strong, readwrite) NSMutableDictionary *cacheMetadata;
@property (nonatomic, strong) WDPRCacheMetadata *defaultCacheMetadata;
@property (nonatomic, strong) id<WDPRCacheDelegate> defaultCacheDelegate;

@end

@implementation WDPRCommonDataService

// HACK!
// TODO: Hugh - Need to remove dependency on AFOAuthClient and put functionality
// here instead.  That does not return a response on login success and we need
// to get the SWID out of the response.  I've hacked the version checked in,
// however if we get a new version it will break.  AFOAuthClient really doesn't
// buy us much more than just building the headers and authenticating. Rewriting
// won't be hard.

- (id)init
{
    self = [super init];
    
    if (self)
    {
        [self initClassMapping];
    }
    
    return self;
}

- (id)initWithBaseURL:(NSURL *)url
             clientID:(NSString *)clientID
               secret:(NSString *)secret
{
    self = [super initWithBaseURL:url clientID:clientID secret:secret];
    
    if (self)
    {
        [self initClassMapping];
    }
    
    return self;
}

- (void)initClassMapping
{
    // This is looking in the application for this file
    _classResponseMapping = [NSDictionary dictionaryFromPList:@"ServicesClassMapping"];
    if (!_classResponseMapping)
    {
        WDPRCoreServicesLogWarning(@"\n\n\n\n\n\n\n--------------------------------\nWARNING: No class mapping plist found in ServicesClassMapping. If you don't specify a class mapping file you have to explicitly set MdxCommonDataServices.classResponseMapping to a dictionary containing service end point keys and the classes the response will be mapped too.\n\n\n\n\n\n\n");
    }
}

- (void)registerCacheMetadata:(WDPRCacheMetadata *)cacheMetadata
{
    if (cacheMetadata.requestId && !self.cacheMetadata[cacheMetadata.requestId])
    {
        self.cacheMetadata[cacheMetadata.requestId] = cacheMetadata;
    }
}

- (WDPRCacheMetadata *)cacheMetadataForRequestId:(NSString *)requestId
{
    WDPRCacheMetadata *cachedMetadata = self.cacheMetadata[requestId];
    if (!cachedMetadata)
    {
        cachedMetadata = self.defaultCacheMetadata;
    }
    return cachedMetadata;
}

- (Class)classForEndpoint:(NSString *)endpoint
{
    NSAssert(endpoint, @"endpoint cannot be nil");
    //TODO: externalize?
    NSString * classString = self.classResponseMapping[endpoint];
    if (!classString)
    {
        return nil;
    }
    return NSClassFromString(self.classResponseMapping[endpoint]);
}

/*
 http://wiki.wdpro.wdig.com/display/Tech/App+Instance+ID+for+Mobile
 */
- (NSString *)appInstanceId
{
    NSString *appInstanceId = [[NSUserDefaults standardUserDefaults] stringForKey:MdxAppInstanceId];
    
    if (!appInstanceId)
    {
        NSDictionary *servicesDictionary = [NSDictionary dictionaryFromPList:@"Services"
                                                                    inBundle:[WDPRCoreServices wdprCoreServicesResourceBundle]
                                                                allowNewKeys:YES];
        
        NSString *appInstanceIdPrefix = [servicesDictionary valueForKeyPath:@"default.appInstanceIdPrefix"];
        
        if (!appInstanceIdPrefix.length)
        {
            WDPRCoreServicesLogError(@"missing default.appInstanceIdPrefix from Services.plist");
            return nil;
        }
        
        appInstanceId = [NSString stringWithFormat:@"%@%@", appInstanceIdPrefix, [WDPRServices generateGuid]];
        [[NSUserDefaults standardUserDefaults] setObject:appInstanceId forKey:MdxAppInstanceId];
    }
    
    return appInstanceId;
}

- (void)commonAFNSuccess:(AFNSuccess)successHandler
                   param:(id)param
{
    if (successHandler)
    {
        successHandler(param);
    }
}

- (void)commonAFNFailure:(AFNFailure)failureHandler
                   error:(NSError *)error
{
#  if LOG_CALL_FAILURE
    WDPRCoreServicesLogError(@"AFN Service failure:\n%@", [error description]);
#  endif
    
    // show the error to devs but not to others.
#ifdef DEBUG
    //    [self showCommonErrors:error];
#endif
    
    // TODO: Handle common errors here.  Likely requires a change to the
    // handler to include a BOOL indicating if it was handled.  (i.e.
    // Some common errors like no connection could be messaged here.
    if (failureHandler)
    {
        failureHandler(error);
    }
    
    //TODO: come back and figure out how to add the url and response here
    /* if (operation)
     {
     #ifdef WDPR_ANALYTICS
     [MdxAnalytics.defaultInstance logError:error message:nil info:
     @{
     @"service.name" : (operation.request.URL ?: @""),
     @"service.response" : (operation.response ?: @"" ),
     }];
     
     #endif
     }*/
}

- (NSInteger)statusCode:(NSError *)error
{
    return [[[error userInfo] objectForKey:AFNetworkingOperationFailingURLResponseErrorKey] statusCode];
}

- (void) showCommonErrors:(NSError*)error
{
    // show alert to user about error
    
    // TODO: replace or add custom message for some error
    // Use this lookup table for custom error messages:
    
    NSDictionary* mdxErrors= @{
                               @"-800"    :    @"User is not logged in",
                               };
    
    NSString* msg;
    NSString* key;
    if ([[error domain] isEqualToString:@"MdxErrors"])
        key= [NSString stringWithFormat:@"%d", (int)[error code]];
    
    if (key && mdxErrors[key])
    {
        msg= mdxErrors[key];
    }
    else if (error.userInfo && error.userInfo[@"NSLocalizedDescription"])
    {
        msg= error.userInfo[@"NSLocalizedDescription"];
    }
    else
    {
        msg= @"unspecified error";
    }
    if (self.serviceDelegate)
    {
        if ([self.serviceDelegate respondsToSelector:@selector(commonDataServiceWantsToShowCommonError: withMessage:)])
        {
            [self.serviceDelegate commonDataServiceWantsToShowCommonError:error withMessage:msg];
        }
    }
}

- (NSSet *)buildSetFromService:(NSString *)service
                    withTokens:(NSArray *)tokens
                 andParameters:(NSDictionary *)parameters
{
    NSMutableSet *builtURLs = nil;
    
    if (service)
    {
        // Lazy Loading
        if (!builtURLs)
        {
            builtURLs = [NSMutableSet new];
        }
        
        // Build the urls
        [tokens enumerateObjectsUsingBlock:
         ^(id obj, NSUInteger idx, BOOL *stop)
         {
             if ([obj isKindOfClass:[NSDictionary class]])
             {
                 NSString *finalURL =
                 [WDPRServices.environment valueForKey:service
                                            withTokens:tokens[idx]];
                 
                 // Build the parameter string
                 if (parameters)
                 {
                     NSMutableString *parameterString = [NSMutableString new];
                     [parameters enumerateKeysAndObjectsUsingBlock:
                      ^(NSString *key, NSString *value, BOOL *stop)
                      {
                          [parameterString appendFormat:@"&%@=%@", key, value];
                      }];
                     
                     finalURL = [NSString stringWithFormat:@"%@%@", finalURL, parameterString];
                 }
                 
                 // Add the url
                 [builtURLs addObject:finalURL];
             }
         }];
    }
    
    return [NSSet setWithSet:builtURLs];
}

- (void)batchServiceWithHost:(NSString *)serviceHost
                        urls:(NSSet*)serviceURLs
                      method:(NSString *)method
                     localID:(NSString *)localID
                     success:(ServiceSuccess)success
                     failure:(ServiceFailure)failure
{
    NSString* host = [WDPRServices.environment valueForKey:serviceHost];
    NSString* path = [NSString stringWithFormat:@"%@/bulk-service/execute%@",
                      host, (localID ? [NSString stringWithFormat:@"?localid=%@", localID] : @"")];
    WDPRCoreServicesLogDebug(@"Host: %@ - Path: %@", host, path);
    
    NSArray *urls = [self buildBatchServiceWithURLs:serviceURLs method:method];
    
    NSDictionary *json = @{@"requests": urls};
    
    [self postDataUsingPath:path
                 parameters:json
                    success:success
                    failure:failure];
}

- (NSArray *)buildBatchServiceWithURLs:(NSSet*)serviceURLs
                                method:(NSString *)method
{
    __block NSMutableArray *urls = [NSMutableArray new];
    [serviceURLs enumerateObjectsUsingBlock:
     ^(NSString *serviceURL, BOOL *stop)
     {
         [urls addObject:@{@"url": serviceURL,
                           @"method": method}];
     }];
    
    return [NSArray arrayWithArray:urls];
}


#pragma mark - Common Services Layer

- (void)getDataUsingEndpoint:(NSString *)path
                      tokens:(NSDictionary *)tokens
                  parameters:(NSDictionary *)parameters
                     success:(ServiceSuccess)success
                     failure:(ServiceFailure)failure
{
    [self getDataUsingEndpoint:path
                        tokens:tokens
                    parameters:parameters
           maxAgeCacheOverride:NSIntegerMin
                       success:success
                       failure:failure];
}

- (void)getDataUsingEndpoint:(NSString *)path
                      tokens:(NSDictionary *)tokens
                  parameters:(NSDictionary *)parameters
         maxAgeCacheOverride:(NSInteger)cacheTime
                     success:(ServiceSuccess)success
                     failure:(ServiceFailure)failure
{
    NSURL * fullPath =
    [WDPRServices.environment urlForService:path withTokens:tokens];
    
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                      path:[fullPath absoluteString]
                                                parameters:parameters];
    
    WDPRLocaleInfo *localeInfo = [WDPRLocalization localeInfoWithPreferredLanguages:[NSLocale preferredLanguages]];
    [request setValue:localeInfo.language forHTTPHeaderField:kRequestHeaderAcceptLanguage];
    
    Class mappingClass = [self classForEndpoint:path];
    
    [self setAuthorizationHeaderForRequest:request];
    
    AFNSuccess clientSuccess = ^(id responseObject)
    {
        NSError *error;
        id data = nil;
        if (responseObject)
        {
            if (![responseObject isKindOfClass:[NSData class]])
            {
                data = responseObject;
            }
            else
            {
                data = [NSJSONSerialization JSONObjectWithData:responseObject
                                                       options:NSJSONReadingAllowFragments
                                                         error:&error];
            }
        }
        
        if ([[request HTTPMethod] isEqualToString:@"GET"] && !data)
        {
            [self commonAFNFailure:AFNServiceFailure(failure) error:error];
            return;
        }
        
        if ([self statusCode:error] == 204)
        {
            //TODO: figure out if we still need this
            
            /* WDPRLog(@"Need to get url header here: %@", operation.request.allHTTPHeaderFields);
             if ([operation.request.allHTTPHeaderFields objectForKey:@"Location"])
             {
             self.returnURL = [operation.request.allHTTPHeaderFields objectForKey:@"Location"];
             }*/
        }
        if (mappingClass)
        {
            if (self.serviceDelegate && [self.serviceDelegate respondsToSelector:@selector(modelWithClass:andData:)])
            {
                id model = [self.serviceDelegate modelWithClass:mappingClass andData:data];
                [self commonAFNSuccess:AFNServiceSuccess(success) param:model];
            }
            else
            {
                NSAssert(NO,@"A mapping class was set, but the serviceDelegate is not set");
            }
        }
        else
        {
            [self commonAFNSuccess:AFNServiceSuccess(success) param:data];
        }
        
    };
    
    AFNFailure clientFailureAfterRetry = ^(NSError *error)
    {
        [self commonAFNFailure:AFNServiceFailure(failure) error:error];
    };
    
    AFNFailure clientFailure = [self failureBlockForRequest:request
                                                    success:clientSuccess
                                          successWithHeader:nil
                                                    failure:clientFailureAfterRetry];
    
    AFHTTPRequestOperation *requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    if (self.allowInvalidCertificatesOnOperations)
    {
        [self allowInvalidCertificateFor:requestOperation];
    }
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (clientSuccess)
         {
             clientSuccess(responseObject);
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
         if (clientFailure)
         {
             clientFailure(error);
         }
     }];
    
    if(cacheTime > -1)
    {
        [requestOperation setCacheResponseBlock:^NSCachedURLResponse *(NSURLConnection *connection, NSCachedURLResponse *cachedResponse)
         {
             if([connection currentRequest].cachePolicy == NSURLRequestUseProtocolCachePolicy)
             {
                 cachedResponse = [cachedResponse responseWithExpirationDuration:cacheTime];
             }
             return cachedResponse;
         }];
    }
    
    // Some service calls involve redirects. The redirect requires the authorization header value to be set,
    // otherwise it will return a 401 Unauthorized. This block will allow interception of the redirect.
    [requestOperation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse)
     {
         NSURLRequest *returnRequest = request;
         
         // A non-nil redirectResponse indicates a redirect call is taking place. Intercept it, and set the authorization header.
         if (redirectResponse)
         {
             NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:request.URL];
             [mutableRequest setHTTPBody:request.HTTPBody];
             [mutableRequest setAllHTTPHeaderFields:request.allHTTPHeaderFields];
             [self setAuthorizationHeaderForRequest:mutableRequest];
             returnRequest = mutableRequest;
         }
         
         return returnRequest;
     }];
    [self.operationQueue addOperation:requestOperation];
}

- (void)getDataUsingPath:(NSString *)path
              parameters:(NSDictionary *)parameters
                 success:(ServiceSuccess)success
                 failure:(ServiceFailure)failure
{
    [self getDataUsingPath:path
                parameters:parameters
           overrideHeaders:nil
                   success:success
                   failure:failure];
}


- (void)getDataUsingPath:(NSString *)path
              parameters:(NSDictionary *)parameters
            turnOffCache:(BOOL)turnOffCache
                 success:(ServiceSuccess)success
                 failure:(ServiceFailure)failure
{
    [self getDataUsingPath:path
                parameters:parameters
           overrideHeaders:nil
              turnOffCache:turnOffCache
                   success:success
                   failure:failure];
}

- (void)getDataUsingPath:(NSString *)path
              parameters:(NSDictionary *)parameters
         overrideHeaders:(NSDictionary *)overrideHeaders
                 success:(ServiceSuccess)success
                 failure:(ServiceFailure)failure
{
    [self getDataUsingPath:path
                parameters:parameters
           overrideHeaders:overrideHeaders
              turnOffCache:NO
                   success:success
                   failure:failure];
}

- (void)getDataUsingPath:(NSString *)path
              parameters:(NSDictionary *)parameters
         overrideHeaders:(NSDictionary *)overrideHeaders
       successWithHeader:(ServiceSuccessWithHeader)successWithHeader
                 failure:(ServiceFailure)failure
{
    [self getDataUsingPath:path
                parameters:parameters
           overrideHeaders:overrideHeaders
              turnOffCache:NO
         successWithHeader:successWithHeader
                   failure:failure];
}

- (void)getDataUsingPath:(NSString *)path
              parameters:(NSDictionary *)parameters
         overrideHeaders:(NSDictionary *)overrideHeaders
            turnOffCache:(BOOL)turnOffCache
       successWithHeader:(ServiceSuccessWithHeader)successWithHeader
                 failure:(ServiceFailure)failure
{
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                      path:path
                                                parameters:parameters];
    if (turnOffCache)
    {
        request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    }
    
    [self requestOperationWithRequest:request
                      overrideHeaders:overrideHeaders
                      cacheMetadataId:nil
                              success:nil
                    successWithHeader:successWithHeader
                              failure:failure];
}

- (void)getDataUsingPath:(NSString *)path
              parameters:(NSDictionary *)parameters
         overrideHeaders:(NSDictionary *)overrideHeaders
            turnOffCache:(BOOL)turnOffCache
                 success:(ServiceSuccess)success
                 failure:(ServiceFailure)failure
{
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                      path:path
                                                parameters:parameters];
    
    if (turnOffCache)
    {
        request.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
    }
    
    [self requestOperationWithRequest:request
                      overrideHeaders:overrideHeaders
                      cacheMetadataId:nil
                              success:success
                    successWithHeader:nil
                              failure:failure];
}


- (void)getDataUsingPath:(NSString *)path
              parameters:(NSDictionary *)parameters
         overrideHeaders:(NSDictionary *)overrideHeaders
         cacheMetadataId:(NSString *)cacheMetadataId
                 success:(ServiceSuccess)success
                 failure:(ServiceFailure)failure
{
    NSMutableURLRequest *request = [self requestWithMethod:@"GET"
                                                      path:path
                                                parameters:parameters];
    // Use default settings if no cache settings exist for this request
    WDPRCacheMetadata *cacheMetadata = [self cacheMetadataForRequestId:cacheMetadataId];
    request.cachePolicy = cacheMetadata.cachePolicy;
    
    [self requestOperationWithRequest:request
                      overrideHeaders:overrideHeaders
                      cacheMetadataId:cacheMetadataId
                              success:^(id result) {
                                  // Evaluate if a request needs to be rescheduled, this should happen only if
                                  // a cached response expired, we need to mark the meta data as requiring reload and
                                  // execute the request again. Infinite loops are prevented in the meta data object.
                                  if (cacheMetadata.reloadRequired)
                                  {
                                      [self getDataUsingPath:path
                                                  parameters:parameters
                                             overrideHeaders:overrideHeaders
                                             cacheMetadataId:cacheMetadataId
                                                     success:success
                                                     failure:failure];
                                  }
                                  else if (success)
                                  {
                                      success(result);
                                  }
                              }
                    successWithHeader:nil
                              failure:failure];
}

- (void)postDataUsingPath:(NSString *)path
               parameters:(id)parameters
                  success:(ServiceSuccess)success
                  failure:(ServiceFailure)failure
{
    [self postDataUsingPath:path
                 parameters:parameters
            overrideHeaders:nil
                    success:success
                    failure:failure];
}

- (void)postDataUsingPath:(NSString *)path
               parameters:(id)parameters
          overrideHeaders:(NSDictionary *)overrideHeaders
                  success:(ServiceSuccess)success
                  failure:(ServiceFailure)failure
{
    [self postDataUsingPath:path
                 parameters:parameters
          parameterEncoding:WDPRJSONParameterEncoding
            overrideHeaders:overrideHeaders
                    success:success
                    failure:failure];
}

- (void)postDataUsingPath:(NSString *)path
               parameters:(id)parameters
          overrideHeaders:(NSDictionary *)overrideHeaders
        successWithHeader:(ServiceSuccessWithHeader)successWithHeader
                  failure:(ServiceFailure)failure
{
    [self postDataUsingPath:path
                 parameters:parameters
          parameterEncoding:WDPRJSONParameterEncoding
            overrideHeaders:overrideHeaders
          successWithHeader:successWithHeader
                    failure:failure];
}

- (void)postDataUsingPath:(NSString *)path
               parameters:(id)parameters
        parameterEncoding:(WDPRParameterEncoding)paramEncoding
          overrideHeaders:(NSDictionary *)overrideHeaders
                  success:(ServiceSuccess)success
                  failure:(ServiceFailure)failure
{
    NSMutableURLRequest * request;
    
    switch (paramEncoding)
    {
        case WDPRJSONParameterEncoding:
            self.requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        default:
            self.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
    }
    
    BOOL continueChecks = YES;
    if (self.serviceDelegate)
    {
        if ([self.serviceDelegate respondsToSelector:@selector(isParameterAModelObject:)] &&
            [self.serviceDelegate respondsToSelector:@selector(jsonDictionaryFromModel:)] )
        {
            if ([self.serviceDelegate isParameterAModelObject:parameters])
            {
                NSDictionary *jsonDictionary = [self.serviceDelegate jsonDictionaryFromModel:parameters];
                request = [self requestWithMethod:@"POST"
                                             path:path
                                       parameters:jsonDictionary];
                continueChecks = NO;
            }
        }
    }
    if(continueChecks)
    {
        Require(parameters ?: @{}, NSDictionary);
        request = [self requestWithMethod:@"POST"
                                     path:path
                               parameters:parameters];
    }
    
    if (paramEncoding == WDPRJSONParameterEncoding)
    {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    [self requestOperationWithRequest:request
                      overrideHeaders:overrideHeaders
                      cacheMetadataId:nil
                              success:success
                    successWithHeader:nil
                              failure:failure];
}

- (void)postDataUsingPath:(NSString *)path
               parameters:(id)parameters
        parameterEncoding:(WDPRParameterEncoding)paramEncoding
          overrideHeaders:(NSDictionary *)overrideHeaders
        successWithHeader:(ServiceSuccessWithHeader)successWithHeader
                  failure:(ServiceFailure)failure
{
    NSMutableURLRequest * request;
    
    switch (paramEncoding)
    {
        case WDPRJSONParameterEncoding:
            self.requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        default:
            self.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
    }
    
    BOOL continueChecks = YES;
    if (self.serviceDelegate)
    {
        if ([self.serviceDelegate respondsToSelector:@selector(isParameterAModelObject:)] &&
            [self.serviceDelegate respondsToSelector:@selector(jsonDictionaryFromModel:)] )
        {
            if ([self.serviceDelegate isParameterAModelObject:parameters])
            {
                NSDictionary *jsonDictionary = [self.serviceDelegate jsonDictionaryFromModel:parameters];
                request = [self requestWithMethod:@"POST"
                                             path:path
                                       parameters:jsonDictionary];
                continueChecks = NO;
            }
        }
    }
    if(continueChecks)
    {
        Require(parameters ?: @{}, NSDictionary);
        request = [self requestWithMethod:@"POST"
                                     path:path
                               parameters:parameters];
    }
    
    if (paramEncoding == WDPRJSONParameterEncoding)
    {
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    }
    
    [self requestOperationWithRequest:request
                      overrideHeaders:overrideHeaders
                      cacheMetadataId:nil
                              success:nil
                    successWithHeader:successWithHeader
                              failure:failure];
}

- (void)postDataUsingPath:(NSString *)path
               jsonObject:(id)object
                  success:(ServiceSuccess)success
                  failure:(ServiceFailure)failure
{
    NSError *error;
    NSParameterAssert(object);
    
    NSData *data = [NSJSONSerialization dataWithJSONObject:object options:0 error:&error];
    
    if (!data)
    {
        if (error)
        {
            WDPRCoreServicesLogError(@"Error serializing json object into data: %@", error);
        }
        return;
    }
    
    NSMutableURLRequest *request = [self requestWithMethod:@"POST"
                                                      path:path
                                                parameters:nil];
    
    [request setHTTPBody:data];
    
    [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    
    [self requestOperationWithRequest:request
                      cacheMetadataId:nil
                              success:success
                              failure:failure];
}

- (void)postDataUsingPath:(NSString *)path
 formUrlEncodedParameters:(NSString *)parameters
                  success:(ServiceSuccess)success
                  failure:(ServiceFailure)failure
{
    [self postDataUsingPath:path
   formUrlEncodedParameters:parameters
            overrideHeaders:nil
                    success:success
                    failure:failure];
}

- (void)postDataUsingPath:(NSString *)path
 formUrlEncodedParameters:(NSString *)parameters
          overrideHeaders:(NSDictionary *)overrideHeaders
                  success:(ServiceSuccess)success
                  failure:(ServiceFailure)failure
{
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:path parameters:nil];
    [request setHTTPBody:[parameters dataUsingEncoding:NSUTF8StringEncoding]];
    
    [self requestOperationWithRequest:request
                      overrideHeaders:overrideHeaders
                      cacheMetadataId:nil
                              success:success
                    successWithHeader:nil
                              failure:failure];
}

- (void)putDataUsingPath:(NSString *)path
              parameters:(id)parameters
                 success:(ServiceSuccess)success
                 failure:(ServiceFailure)failure
{
    [self putDataUsingPath:path
                parameters:parameters
           overrideHeaders:nil
                   success:success
                   failure:failure];
}

- (void)putDataUsingPath:(NSString *)path
              parameters:(id)parameters
         overrideHeaders:(NSDictionary *)overrideHeaders
                 success:(ServiceSuccess)success
                 failure:(ServiceFailure)failure
{
    [self putDataUsingPath:path
                parameters:parameters
         parameterEncoding:WDPRJSONParameterEncoding
           overrideHeaders:overrideHeaders
                   success:success
                   failure:failure];
}

- (void)putDataUsingPath:(NSString *)path
              parameters:(id)parameters
         overrideHeaders:(NSDictionary *)overrideHeaders
       successWithHeader:(ServiceSuccessWithHeader)successWithHeader
                 failure:(ServiceFailure)failure
{
    [self putDataUsingPath:path
                parameters:parameters
         parameterEncoding:WDPRJSONParameterEncoding
           overrideHeaders:overrideHeaders
         successWithHeader:successWithHeader
                   failure:failure];
}

- (void)putDataUsingPath:(NSString *)path
              parameters:(id)parameters
       parameterEncoding:(WDPRParameterEncoding)paramEncoding
         overrideHeaders:(NSDictionary *)overrideHeaders
                 success:(ServiceSuccess)success
                 failure:(ServiceFailure)failure
{
    switch (paramEncoding)
    {
        case WDPRJSONParameterEncoding:
            self.requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        default:
            self.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
    }
    
    NSMutableURLRequest *request = [self requestWithMethod:@"PUT"
                                                      path:path
                                                parameters:parameters];
    
    [self requestOperationWithRequest:request
                      overrideHeaders:overrideHeaders
                      cacheMetadataId:nil
                              success:success
                    successWithHeader:nil
                              failure:failure];
}

- (void)putDataUsingPath:(NSString *)path
              parameters:(id)parameters
       parameterEncoding:(WDPRParameterEncoding)paramEncoding
         overrideHeaders:(NSDictionary *)overrideHeaders
       successWithHeader:(ServiceSuccessWithHeader)successWithHeader
                 failure:(ServiceFailure)failure
{
    switch (paramEncoding)
    {
        case WDPRJSONParameterEncoding:
            self.requestSerializer = [AFJSONRequestSerializer serializer];
            break;
        default:
            self.requestSerializer = [AFHTTPRequestSerializer serializer];
            break;
    }
    
    NSMutableURLRequest *request = [self requestWithMethod:@"PUT"
                                                      path:path
                                                parameters:parameters];
    
    [self requestOperationWithRequest:request
                      overrideHeaders:overrideHeaders
                      cacheMetadataId:nil
                              success:nil
                    successWithHeader:successWithHeader
                              failure:failure];
}

- (void)deleteDataUsingPath:(NSString *)path
                 parameters:(NSDictionary *)parameters
                    success:(ServiceSuccess)success
                    failure:(ServiceFailure)failure
{
    NSMutableURLRequest *request = [self requestWithMethod:@"DELETE"
                                                      path:path
                                                parameters:parameters];
    
    [self requestOperationWithRequest:request
                      cacheMetadataId:nil
                              success:success
                              failure:failure];
}

- (void)performHeadUsingPath:(NSString *)path
                  parameters:(NSDictionary *)parameters
                     success:(ServiceSuccess)success
                     failure:(ServiceFailure)failure
{
    NSMutableURLRequest *request = [self requestWithMethod:@"HEAD"
                                                      path:path
                                                parameters:parameters];
    
    [self requestOperationWithRequest:request
                      cacheMetadataId:nil
                              success:success
                              failure:failure];
}

- (NSOperation *)operationForQueryPath:(NSString *)path
                                ofType:(ServiceMethod)methodType
                            parameters:(NSDictionary *)parameters
                       overrideHeaders:(NSDictionary *)overrideHeaders
                               success:(ServiceSuccess)success
                               failure:(ServiceFailure)failure
{
    NSString *method = !(methodType & kServicePost) ? @"GET" : @"POST";
    
    NSMutableURLRequest *request = [self requestWithMethod:method
                                                      path:path
                                                parameters:parameters];
    
    return [self operationWithRequest:request
                      overrideHeaders:overrideHeaders
                      cacheMetadataId:nil
                              success:success
                    successWithHeader:nil
                              failure:failure];
}

- (NSOperation *)operationForQueryPath:(NSString *)path
                                ofType:(ServiceMethod)methodType
                            parameters:(NSDictionary *)parameters
                       cacheMetadataId:(NSString *)cacheMetadataId
                       overrideHeaders:(NSDictionary *)overrideHeaders
                               success:(ServiceSuccess)success
                               failure:(ServiceFailure)failure
{
    NSString *method = !(methodType & kServicePost) ? @"GET" : @"POST";
    
    NSMutableURLRequest *request = [self requestWithMethod:method
                                                      path:path
                                                parameters:parameters];
    // Use default settings if no cache settings exist for this request
    WDPRCacheMetadata *cacheMetadata = [self cacheMetadataForRequestId:cacheMetadataId];
    request.cachePolicy = cacheMetadata.cachePolicy;
    
    return [self operationWithRequest:request
                      overrideHeaders:overrideHeaders
                      cacheMetadataId:cacheMetadataId
                              success:^(id result) {
                                  // Evaluate if a request needs to be rescheduled, this should happen only if
                                  // a cached response expired, we need to mark the meta data as requiring reload and
                                  // execute the request again. Infinite loops are prevented in the meta data object.
                                  if (cacheMetadata.reloadRequired)
                                  {
                                      [self getDataUsingPath:path
                                                  parameters:parameters
                                             overrideHeaders:overrideHeaders
                                             cacheMetadataId:cacheMetadataId
                                                     success:success
                                                     failure:failure];
                                  }
                                  else if (success)
                                  {
                                      success(result);
                                  }
                              }
                    successWithHeader:nil
                              failure:failure];
}

#pragma mark - Special case methods

- (void)setAuthorizationHeaderForRequest:(NSMutableURLRequest *)request
{
    NSAssert(NO, @"Descendants must override");
}

- (AFNFailure)failureBlockForRequest:(NSMutableURLRequest *)request
                             success:(AFNSuccess)clientSuccess
                             failure:(ServiceFailure)failure
{
    NSAssert(NO, @"Descendants must override");
    return nil;
}

- (AFNFailure)failureBlockForRequest:(NSMutableURLRequest *)request
                             success:(AFNSuccess)clientSuccess
                   successWithHeader:(AFNSuccessWithHeader)clientSuccessWithHeader
                             failure:(ServiceFailure)failure
{
    NSAssert(NO, @"Descendants must override");
    return nil;
}

#pragma mark - Assemble requests

- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters
{
#if PRERELEASE
    if ([path hasPrefix:@" "] || [path hasSuffix:@" "])
    {
        NSAssert(NO, @"%@ has leading or trailing space in services.plist - %@",
                 path, @"this will break on iOS7");
    }
#endif
    
#if DEBUG
    // make sure the url is valid so devs can catch this
    NSURL * url = [NSURL URLWithString:path];
    NSAssert(url, @"url is invalid %@", path);
#endif
    
    NSMutableURLRequest* request = [self.requestSerializer requestWithMethod:method URLString:path parameters:parameters error:nil];
    
    // respect defaultHeader values
    // ??? Is this the best way/place to do this ???
    // some of our services require custom header fields,
    // including Content-Type, which gets set inside
    // AFNetworking's call of this method, this re-instates
    // header fields that have been specified by the client
    
    [request.allHTTPHeaderFields
     enumerateKeysAndObjectsUsingBlock:
     ^(NSString* key, id value, BOOL *stop)
     {
         id defaultValue = [self.requestSerializer valueForHTTPHeaderField:key];
         if (defaultValue && ![defaultValue isEqualToString:value])
         {
             [request setValue:defaultValue forHTTPHeaderField:key];
         }
     }];
    
    if ([WDPRServices.environment useSoftLaunchEnvironment])
    {
        [request setValue:kServiceValueSoftLaunchHeader forHTTPHeaderField:kServiceKeySoftLaunchHeader];
    }
    
    NSString *oneViewEnvOverride = [WDPRServices.environment valueForKey:kServiceKeyOneViewEnvOverride];
    if (oneViewEnvOverride.length)
    {
        [request setValue:oneViewEnvOverride forHTTPHeaderField:kServiceOneViewEnvOverrideHeader];
    }
    
    [request setValue:[self appInstanceId] forHTTPHeaderField:XConversationId];
    
    return request;
}

- (void)requestOperationWithRequest:(NSMutableURLRequest *)request
                    cacheMetadataId:(NSString *)cacheMetadataId
                            success:(ServiceSuccess)success
                            failure:(ServiceFailure)failure
{
    [self requestOperationWithRequest:request
                      overrideHeaders:nil
                      cacheMetadataId:cacheMetadataId
                              success:success
                    successWithHeader:nil
                              failure:failure];
}

- (void)requestOperationWithRequest:(NSMutableURLRequest *)request
                    overrideHeaders:(NSDictionary *)overrideHeaders
                    cacheMetadataId:(NSString *)cacheMetadataId
                            success:(ServiceSuccess)success
                  successWithHeader:(ServiceSuccessWithHeader)successWithHeader
                            failure:(ServiceFailure)failure
{
    NSOperation *operation = [self operationWithRequest:request
                                        overrideHeaders:overrideHeaders
                                        cacheMetadataId:cacheMetadataId
                                                success:success
                                      successWithHeader:successWithHeader
                                                failure:failure];
    
    [self.operationQueue addOperation:operation];
}

- (NSOperation *)operationWithRequest:(NSMutableURLRequest *)request
                      overrideHeaders:(NSDictionary *)overrideHeaders
                      cacheMetadataId:(NSString *)cacheMetadataId
                              success:(ServiceSuccess)success
                    successWithHeader:(ServiceSuccessWithHeader)successWithHeader
                              failure:(ServiceFailure)failure
{
    __block WDPRCacheMetadata *currentCacheMetadata = [self cacheMetadataForRequestId:cacheMetadataId];
    BOOL __block responseFromCache = YES;
    NSString *swid = [WDPRAuthenticationService sharedInstance].swid;
    [self setAuthorizationHeaderForRequest:request];
    
    for (NSString *headerName in overrideHeaders)
    {
        [request setValue:[overrideHeaders objectForKey:headerName] forHTTPHeaderField:headerName];
    }
    
    WDPRLocaleInfo *localeInfo = [WDPRLocalization localeInfoWithPreferredLanguages:[NSLocale preferredLanguages]];
    
    NSAssert(localeInfo.language, @"The WDPRLocalization.plist needs to be set up properly.");
    
    [request setValue:localeInfo.language forHTTPHeaderField:kRequestHeaderAcceptLanguage];
    
    AFNSuccess clientSuccess = ^(id responseObject)
    {
        NSError *error;
        id data = nil;
        if (responseObject)
        {
            if (![responseObject isKindOfClass:[NSData class]])
            {
                data = responseObject;
            }
            else
            {
                data = [NSJSONSerialization JSONObjectWithData:responseObject
                                                       options:NSJSONReadingAllowFragments
                                                         error:&error];
            }
        }
        
        if ([[request HTTPMethod] isEqualToString:@"GET"] && !data)
        {
            [self commonAFNFailure:AFNServiceFailure(failure) error:error];
            return;
        }
        
        if ([self statusCode:error] == 204)
        {
            // TODO: figure out if we still need this
            //  WDPRLog(@"Need to get url header here: %@", operation.request.allHTTPHeaderFields);
            /* if ([operation.request.allHTTPHeaderFields objectForKey:@"Location"])
             {
             self.returnURL = [operation.request.allHTTPHeaderFields objectForKey:@"Location"];
             }*/
        }
        
        [self commonAFNSuccess:AFNServiceSuccess(success) param:data];
    };
    
    AFNSuccessWithHeader clientSuccessWithResponseHeader = ^(id responseObject, NSDictionary *responseHeader)
    {
        NSError *error;
        id data = nil;
        if (responseObject)
        {
            if (![responseObject isKindOfClass:[NSData class]])
            {
                data = responseObject;
            }
            else
            {
                data = [NSJSONSerialization JSONObjectWithData:responseObject
                                                       options:NSJSONReadingAllowFragments
                                                         error:&error];
            }
        }
        
        if ([[request HTTPMethod] isEqualToString:@"GET"] && !data)
        {
            if (failure) {
                failure(error);
            }
            return;
        }
        
        if (successWithHeader) {
            successWithHeader(data, responseHeader);
        }
    };
    
    
    AFNFailure clientFailureAfterRetry = ^(NSError *error)
    {
        [self commonAFNFailure:AFNServiceFailure(failure) error:error];
    };
    
    AFNFailure clientFailure = [self failureBlockForRequest:request
                                                    success:clientSuccess
                                          successWithHeader:(successWithHeader ? clientSuccessWithResponseHeader : nil)
                                                    failure:clientFailureAfterRetry];
    
    if ([currentCacheMetadata.cacheDelegate isKindOfClass:[WDPRObservableCacheDelegate class]])
    {
        WDPRObservableCacheDelegate* cacheDelegate = currentCacheMetadata.cacheDelegate;
        if ([cacheDelegate respondsToSelector:@selector(notifyFetchingRequest:)])
        {
            [cacheDelegate notifyFetchingRequest:currentCacheMetadata];
        }
    }
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    if (self.allowInvalidCertificatesOnOperations)
    {
        [self allowInvalidCertificateFor:operation];
    }
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if (success) {
             if (clientSuccess)
             {
                 if (currentCacheMetadata.cacheEnabled && responseFromCache)
                 {
                     WDPRAppCache *appCache = currentCacheMetadata.cacheDelegate.appCacheDelegate ?: [WDPRAppCache sharedInstance];
                     responseObject = [appCache responseObjectForOperationRequest:operation.request
                                                                operationResponse:operation.response
                                                                    operationData:operation.responseData
                                                                             swid:swid cacheMetadata:currentCacheMetadata]
                     ?: responseObject;
                 }
                 clientSuccess(responseObject);
             }
         } else if (successWithHeader) {
             if (clientSuccessWithResponseHeader) {
                 clientSuccessWithResponseHeader(responseObject, operation.response.allHeaderFields);
             }
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if ([currentCacheMetadata.cacheDelegate isKindOfClass:[WDPRObservableCacheDelegate class]])
         {
             WDPRObservableCacheDelegate* cacheDelegate = currentCacheMetadata.cacheDelegate;
             if ([cacheDelegate respondsToSelector:@selector(notifyFetchingFailure:operation:)])
             {
                 [cacheDelegate notifyFetchingFailure:currentCacheMetadata operation:operation];
             }
         }
         clientFailure(error);
     }];
    
    if (currentCacheMetadata)
    {
        [operation setCacheResponseBlock:^NSCachedURLResponse *(NSURLConnection *connection, NSCachedURLResponse *cachedResponse)
         {
             responseFromCache = NO;
             NSURLResponse *response = cachedResponse.response;
             if (cachedResponse)
             {
                 if (currentCacheMetadata.expirationControlRequired &&
                     [response respondsToSelector:@selector(allHeaderFields)]) // TODO: This might not be necessary anymore!
                 {
                     NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)response;
                     response = [WDPRCommonDataService formatResponseIfNeeded:httpResponse] ? : response;
                 }
                 
                 if ([currentCacheMetadata.cacheDelegate isKindOfClass:[WDPRObservableCacheDelegate class]])
                 {
                     WDPRObservableCacheDelegate* cacheDelegate = currentCacheMetadata.cacheDelegate;
                     if ([cacheDelegate respondsToSelector:@selector(notifyFetchingSuccess:withHttpStatusCode:andPayloadSize:)])
                     {
                         NSString *payloadSize = [NSString stringWithFormat:@"%lu",(unsigned long)cachedResponse.data.length];
                         long statusCode = (long)[(NSHTTPURLResponse *) response statusCode];
                         [cacheDelegate notifyFetchingSuccess:currentCacheMetadata withHttpStatusCode:statusCode andPayloadSize:payloadSize];
                     }
                 }
                 
                 [currentCacheMetadata updateCacheMetadataForSwid:swid
                                                          request:request
                                                         response:response];
                 if (!currentCacheMetadata.cacheEnabled || currentCacheMetadata.reloadRequired)
                 {
                     return nil;
                 }
             }
             cachedResponse = [[NSCachedURLResponse alloc]
                               initWithResponse:response
                               data:cachedResponse.data
                               userInfo:cachedResponse.userInfo
                               storagePolicy:currentCacheMetadata.cacheEnabled ?
                               [currentCacheMetadata cacheStoragePolicy] : cachedResponse.storagePolicy];
             
             return cachedResponse;
         }];
    }
    
    // Some service calls involve redirects. The redirect requires the authorization header value to be set,
    // otherwise it will return a 401 Unauthorized. This block will allow interception of the redirect.
    [operation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *connection, NSURLRequest *request, NSURLResponse *redirectResponse)
     {
         NSURLRequest *returnRequest = request;
         
         // A non-nil redirectResponse indicates a redirect call is taking place. Intercept it, and set the authorization header.
         if (redirectResponse)
         {
             NSMutableURLRequest *mutableRequest = [NSMutableURLRequest requestWithURL:request.URL];
             [mutableRequest setHTTPBody:request.HTTPBody];
             [mutableRequest setAllHTTPHeaderFields:request.allHTTPHeaderFields];
             [self setAuthorizationHeaderForRequest:mutableRequest];
             returnRequest = mutableRequest;
         }
         
         return returnRequest;
     }];
    
    return operation;
}

- (void)allowInvalidCertificateFor:(AFHTTPRequestOperation *)operation
{
    WDPRLogWarning(@"Allowing invalid certificates for AFHTTPRequestOperation: %@", operation);
    AFSecurityPolicy *sec=[[AFSecurityPolicy alloc] init];
    [sec setAllowInvalidCertificates:YES];
    operation.securityPolicy = sec;
}

/**
 Private method that returns an instance of a NSHTTPURLResponse or nil, depending on the delta between the date stated
 in the response, versus the current date the response was received. It is possible that the service will NOT provide the
 appropriate service response date, but a different old one. Since for caching reasons we may need to store the NSURLResponse
 object in NSURLCache, we may need to update the date in the response header. If the delta is very small then we return
 nil.
 */
+ (NSHTTPURLResponse *)formatResponseIfNeeded:(NSHTTPURLResponse *)response
{
    NSHTTPURLResponse *httpResponse;
    NSDateFormatter *formatter = [NSDateFormatter systemFormatterWithFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
    [formatter setTimeZone:[NSTimeZone localTimeZone]];
    NSString *lastModifiedDate = [response allHeaderFields][@"Date"];
    NSDate *responseDate = [formatter dateFromString:lastModifiedDate];
    NSDate *now = [NSDate date];
    if (!responseDate || (responseDate && ABS([responseDate timeIntervalSinceDate:now]) > WDPRMaxResponseDateDelta))
    {
        NSMutableDictionary *allHeaderFields = [[response allHeaderFields] mutableCopy];
        allHeaderFields[@"Date"] = [formatter stringFromDate:now];
        httpResponse = [[NSHTTPURLResponse alloc] initWithURL:response.URL
                                                   statusCode:response.statusCode HTTPVersion:@"HTTP/1.1"
                                                 headerFields:allHeaderFields];
    }
    
    return httpResponse;
}

- (void)wdprAuthenticateUsingOAuthWithPath:(NSString *)path
                                parameters:(NSDictionary *)parameters
                                   success:(void (^)(id responseObject, AFHTTPRequestOperation *operation, AFOAuthCredential *credential))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure
{
    NSMutableDictionary *mutableParameters = [NSMutableDictionary dictionaryWithDictionary:parameters];
    [mutableParameters setObject:self.clientID forKey:@"client_id"];
    [mutableParameters setValue:self.secret forKey:@"client_secret"];
    parameters = [NSDictionary dictionaryWithDictionary:mutableParameters];
    self.requestSerializer = [AFHTTPRequestSerializer serializer];
    NSMutableURLRequest *mutableRequest = [self requestWithMethod:@"POST"
                                                             path:path
                                                       parameters:parameters];
    
    
    [mutableRequest setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    
    [mutableRequest setTimeoutInterval:WDPROAuthTokenTimeout];
    
    NSString *charset = (__bridge NSString *)CFStringConvertEncodingToIANACharSetName(CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding));
    [mutableRequest setValue:[NSString stringWithFormat:@"application/x-www-form-urlencoded; charset=%@", charset]
          forHTTPHeaderField:@"Content-Type"];
    /*[mutableRequest setHTTPBody:[AFQueryStringFromParametersWithEncoding(parameters, self.stringEncoding)
     dataUsingEncoding:self.stringEncoding]];*/
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:mutableRequest];
    
    requestOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject)
     {
         if ([responseObject valueForKey:@"error"])
         {
             if (failure)
             {
                 WDPRCoreServicesLogError(@"AFNetworking Error: %@", [responseObject valueForKey:@"error"]);
                 // TODO: Resolve the `error` field into a proper NSError object
                 // http://tools.ietf.org/html/rfc6749#section-5.2
                 failure(operation, nil);
             }
             
             return;
         }
         
         NSString *refreshToken = [responseObject valueForKey:@"refresh_token"];
         if (refreshToken == nil || [refreshToken isEqual:[NSNull null]])
         {
             refreshToken = [parameters valueForKey:@"refresh_token"];
         }
         
         AFOAuthCredential *credential = [AFOAuthCredential credentialWithOAuthToken:[responseObject valueForKey:@"access_token"] tokenType:[responseObject valueForKey:@"token_type"]];
         
         NSDate *expireDate = nil;
         id expiresIn = [responseObject valueForKey:@"expires_in"];
         if (expiresIn != nil && ![expiresIn isEqual:[NSNull null]])
         {
             expireDate = [NSDate dateWithTimeIntervalSinceNow:[expiresIn doubleValue]];
         }
         
         [credential setRefreshToken:refreshToken expiration:expireDate];
         
         [self setAuthorizationHeaderWithCredential:credential];
         
         if (success)
         {
             success(responseObject, operation, credential);
         }
     } failure:^(AFHTTPRequestOperation *operation, NSError *error)
     {
         if (failure)
         {
             failure(operation, error);
         }
     }];
    
    [self.operationQueue addOperation:requestOperation];
}

#pragma mark - Expand Service

- (void)expandService:(NSString *)url
           parameters:(NSDictionary *)parameters
              success:(ServiceSuccess)success
              failure:(ServiceFailure)failure
{
    NSString *path = [WDPRServices.environment
                      valueForPath:@"{ngeHost}/expand-service/expand?url={url}"
                      withTokens:@{@"url" : [url urlEncode]}];
    
    [self getDataUsingPath:path
                parameters:parameters
                   success:^(NSDictionary*results){
                       {
                           // verify that json contents has no errors
                           NSDictionary* errorInfo;
                           if ([self errorsInResult:results errorInfo:&errorInfo])
                           {
                               if (failure)
                               {
                                   NSError* error= [NSError errorWithDomain:@"Mdx" code:-801 userInfo:errorInfo];
                                   failure(error);
                               }
                               
                           }
                           else
                           {
                               if (success)
                                   success(results);
                           }
                       }
                   }
                   failure:^(NSError*error){
                       // TODO: check expand errors
                       if (failure)
                           failure(error);
                   }];
}

- (BOOL)errorsInResult:(NSDictionary*)results errorInfo:(NSDictionary**)errorInfo
{
    // helper to determine if an "errors" item exists in given json.
    // (currently only works for 2 levels down into the json)
    __block BOOL bret= NO;
    NSString* errorKey= @"errors";
    [results enumerateKeysAndObjectsUsingBlock:^(NSString* key, id obj, BOOL *stop) {
        if ([key isEqualToString:errorKey])
        {
            bret= YES;
            *stop= YES;
            if (errorInfo)
                *errorInfo= obj[0];
        }
        else if ([obj isKindOfClass:[NSDictionary class]])
        {
            NSDictionary* nextLevel= (NSDictionary*)obj;
            [nextLevel enumerateKeysAndObjectsUsingBlock:^(NSString* key2, id obj2, BOOL *stop2) {
                
                if ([key2 isEqualToString:errorKey])
                {
                    bret= YES;
                    *stop= *stop2= YES;
                    if (errorInfo)
                        *errorInfo= obj;
                    
                }
                
            }];
            
        }
    }];
    return bret;
}

- (NSMutableDictionary *)cacheMetadata {
    if (!_cacheMetadata)
    {
        _cacheMetadata = [NSMutableDictionary dictionary];
    }
    return _cacheMetadata;
}

- (WDPRCacheMetadata *)defaultCacheMetadata {
    if (!_defaultCacheMetadata)
    {
        _defaultCacheMetadata = [WDPRCacheMetadataFactory
                                 cacheMetadataWithCacheOptions:WDPRCacheOptionsNone
                                 requestId:nil];
    }
    return _defaultCacheMetadata;
}

@end
