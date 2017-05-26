//
//  MdxPublicDataService.h
//  Mdx
//
//  Created by Garcia, Jesus on 7/10/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDPRCommonDataService.h"

// The DTSS profile services require a different header value, than what is used by the WDPRO services.
typedef NS_ENUM(NSInteger, MdxAuthorizationHeaderValue) {
    MdxAuthorizationHeaderValueBearer,
    MdxAuthorizationHeaderValueOauthToken
};


@interface WDPRPublicDataService : WDPRCommonDataService

/**
 Perform dirty words check.
 
 @param text
 @param success - Block called upon success with nil data reference.
 @param failure - Block called, with error object, if service call fails.
 */
- (void)checkDirtyWords:(NSString *)text
                success:(ServiceSuccess)success
                failure:(ServiceFailure)failure;

/**
 Returns a NSOperation with the GET request and MdxAuthorizationHeaderValueBearer authorization
 
 @param path - A fully qualified url path.
 @param parameters The parameters to be set as a query string
 @param overrideHeaders a dictionary of key value pairs to set additional request headers
 @param success - Block called upon success, with data dictionary containing any detailed info returned
 by the link.
 @param failure - Block called, with error object, if service call fails.
 */
- (void)operationForGetDataUsingPath:(NSString *)path
                          parameters:(NSDictionary *)parameters
                     overrideHeaders:(NSDictionary *)overrideHeaders
                             success:(ServiceSuccess)success
                             failure:(ServiceFailure)failure
                            callback:(void (^)(NSOperation *))callback;

/**
 Returns a NSOperation with the GET request and MdxAuthorizationHeaderValueBearer authorization
 
 @discussion Provides support for NSURLCache mechanism using WDPRCacheMetadata delegation
 @param path - A fully qualified url path.
 @param parameters The parameters to be set as a query string
 @param overrideHeaders a dictionary of key value pairs to set additional request headers
 @param cacheMetadataId Id for a cache meta data object that will provide caching info for this request
 @param authVersion Determines the authorization type (Bearer, Oauth Token)
 @param success - Block called upon success, with data dictionary containing any detailed info returned
 by the link.
 @param failure - Block called, with error object, if service call fails.
 */
- (void)operationForGetDataUsingPath:(NSString *)path
                          parameters:(NSDictionary *)parameters
                     overrideHeaders:(NSDictionary *)overrideHeaders
                     cacheMetadataId:(NSString *)cacheMetadataId
                         authVersion:(MdxAuthorizationHeaderValue)authVersion
                             success:(ServiceSuccess)success
                             failure:(ServiceFailure)failure
                            callback:(void (^)(NSOperation *))callback;

/**
 Authorized GET service call that wraps returns results into a dictionary from raw json data.
 
 @param path - A fully qualified url path.
 @param parameters The parameters to be set as a query string
 @param overrideHeaders a dictionary of key value pairs to set additional request headers
 @param authVersion Determines the authorization type (Bearer, Oauth Token)
 @param success - Block called upon success, with data dictionary containing any detailed info returned
 by the link.
 @param failure - Block called, with error object, if service call fails.
 */
- (void)getDataUsingPath:(NSString *)path
              parameters:(NSDictionary *)parameters
         overrideHeaders:(NSDictionary *)overrideHeaders
             authVersion:(MdxAuthorizationHeaderValue)authVersion
                 success:(ServiceSuccess)success
                 failure:(ServiceFailure)failure;

/**
 Authorized GET service call that wraps returns results into a dictionary from raw json data.
 
 @discussion Provides support for NSURLCache mechanism using WDPRCacheMetadata delegation
 @param path - A fully qualified url path.
 @param parameters The parameters to be set as a query string
 @param overrideHeaders a dictionary of key value pairs to set additional request headers
 @param cacheMetadataId Id for a cache meta data object that will provide caching info for this request
 @param authVersion Determines the authorization type (Bearer, Oauth Token)
 @param success - Block called upon success, with data dictionary containing any detailed info returned
 by the link.
 @param failure - Block called, with error object, if service call fails.
 */
- (void)getDataUsingPath:(NSString *)path
              parameters:(NSDictionary *)parameters
         overrideHeaders:(NSDictionary *)overrideHeaders
         cacheMetadataId:(NSString *)cacheMetadataId
             authVersion:(MdxAuthorizationHeaderValue)authVersion
                 success:(ServiceSuccess)success
                 failure:(ServiceFailure)failure;

/**
 Generic user authenticated PUT service call.
 
 @param path - A fully-qualified path.
 @param parameters - JSON dictionary to put into the server.
 @param authVersion Determines the authorization type (Bearer, Oauth Token)
 @param success - Block called upon success, with data dictionary containing any detailed info returned
 by the link.
 @param failure - Block called, with error object, if service call fails.
 */
- (void)putDataUsingPath:(NSString *)path
               parameters:(id)parameters
              authVersion:(MdxAuthorizationHeaderValue)authVersion
                  success:(ServiceSuccess)success
                  failure:(ServiceFailure)failure;

/**
 Generic user authenticated POST service call.
 
 @param path - A fully-qualified path.
 @param parameters - JSON dictionary to post to the server.
 @param authVersion Determines the authorization type (Bearer, Oauth Token)
 @param success - Block called upon success, with data dictionary containing any detailed info returned
 by the link.
 @param failure - Block called, with error object, if service call fails.
 */
- (void)postDataUsingPath:(NSString *)path
               parameters:(id)parameters
              authVersion:(MdxAuthorizationHeaderValue)authVersion
                  success:(ServiceSuccess)success
                  failure:(ServiceFailure)failure;

/**
 Generic user authenticated POST service call.
 
 @param path - A fully-qualified path.
 @param parameters - JSON dictionary to post to the server.
 @param overrideHeaders a dictionary of key value pairs to set additional request headers
 @param authVersion Determines the authorization type (Bearer, Oauth Token)
 @param success - Block called upon success, with data dictionary containing any detailed info returned
 by the link.
 @param failure - Block called, with error object, if service call fails.
 */
- (void)postDataUsingPath:(NSString *)path
               parameters:(id)parameters
          overrideHeaders:(NSDictionary *)overrideHeaders
              authVersion:(MdxAuthorizationHeaderValue)authVersion
                  success:(ServiceSuccess)success
                  failure:(ServiceFailure)failure;

/**
 Generic user authenticated POST service call.
 
 @param path - A fully-qualified path.
 @param parameters - JSON dictionary to post to the server.
 @param parameterEncoding set the request encoding
 @param overrideHeaders a dictionary of key value pairs to set additional request headers
 @param authVersion Determines the authorization type (Bearer, Oauth Token)
 @param success - Block called upon success, with data dictionary containing any detailed info returned
 by the link.
 @param failure - Block called, with error object, if service call fails.
 */
- (void)postDataUsingPath:(NSString *)path
               parameters:(id)parameters
        parameterEncoding:(WDPRParameterEncoding)paramEncoding
          overrideHeaders:(NSDictionary *)overrideHeaders
              authVersion:(MdxAuthorizationHeaderValue)authVersion
                  success:(ServiceSuccess)success
                  failure:(ServiceFailure)failure;

/**
 Generic user authenticated POST service call.
 
 @param path - A fully-qualified path.
 @param authVersion Determines the authorization type (Bearer, Oauth Token)
 @param successWithHeader - Block called upon success, with data dictionary containing any detailed info returned
 by the link and response header.
 @param failure - Block called, with error object, if service call fails.
 */
- (void)postDataUsingPath:(NSString *)path
              authVersion:(MdxAuthorizationHeaderValue)authVersion
        successWithHeader:(ServiceSuccessWithHeader)successWithHeader
                  failure:(ServiceFailure)failure;

/**
 Generic user authenticated POST service call.
 
 @param path - A fully-qualified path.
 @param parameters - JSON dictionary to post to the server.
 @param overrideHeaders a dictionary of key value pairs to set additional request headers
 @param authVersion Determines the authorization type (Bearer, Oauth Token)
 @param successWithHeader - Block called upon success, with data dictionary containing any detailed info returned
 by the link and response header.
 @param failure - Block called, with error object, if service call fails.
 */
- (void)postDataUsingPath:(NSString *)path
               parameters:(id)parameters
          overrideHeaders:(NSDictionary *)overrideHeaders
              authVersion:(MdxAuthorizationHeaderValue)authVersion
        successWithHeader:(ServiceSuccessWithHeader)successWithHeader
                  failure:(ServiceFailure)failure;

/**
 Generic user authenticated POST service call.
 
 @param path - A fully-qualified path.
 @param object - object to add to the HTTP body
 @param authVersion Determines the authorization type (Bearer, Oauth Token)
 @param success - Block called upon success, with data dictionary containing any detailed info returned
 by the link.
 @param failure - Block called, with error object, if service call fails.
 */
- (void)postDataUsingPath:(NSString *)path
               jsonObject:(id)object
              authVersion:(MdxAuthorizationHeaderValue)authVersion
                  success:(ServiceSuccess)success
                  failure:(ServiceFailure)failure;

/**
 Generic user authenticated POST service call.
 
 @param path - A fully-qualified path.
 @param parameters - JSON dictionary to post to the server.
 @param overrideHeaders a dictionary of key value pairs to set additional request headers
 @param authVersion Determines the authorization type (Bearer, Oauth Token)
 @param success - Block called upon success, with data dictionary containing any detailed info returned
 by the link.
 @param failure - Block called, with error object, if service call fails.
 */
- (void)postDataUsingPath:(NSString *)path
 formUrlEncodedParameters:(NSString *)parameters
          overrideHeaders:(NSDictionary *)overrideHeaders
              authVersion:(MdxAuthorizationHeaderValue)authVersion
                  success:(ServiceSuccess)success
                  failure:(ServiceFailure)failure;

/**
 Authenticated HEAD service call
 
 @param path - A fully qualified url path.
 @param parameters The parameters to be set as a query string
 @param authVersion Determines the authorization type (Bearer, Oauth Token)
 @param success - Block called upon success, with data dictionary containing any detailed info returned
 by the link.
 @param failure - Block called, with error object, if service call fails.
 */
- (void)performHeadUsingPath:(NSString *)path
                  parameters:(NSDictionary *)parameters
                 authVersion:(MdxAuthorizationHeaderValue)authVersion
                     success:(ServiceSuccess)success
                     failure:(ServiceFailure)failure;

@end
