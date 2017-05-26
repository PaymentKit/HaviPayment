//  WDPRCommonDataService+WDPRCoreServices.h
//  Pods
//
//  Created by Sun, Amy on 11/20/15.
//
//

#import "WDPRCommonDataService.h"

@interface WDPRCommonDataService (WDPRCoreServices)

/**
 Returns a NSOperation for performing a service call using parameters, success and failure blocks,
 uses AFJSONParameterEncoding and sends JSON results to success block
 @param path NSString of the URL to call
 @param methodType ServiceMethod, Get, Post, Header, Put, Deleted, etc
 @param parameters a dictionary of key value pairs to build a query string
 or post header parameters
 @param overrideHeaders a dictionary of key value pairs to set additional request headers
 @param success block is what is executed when the service execution is successful
 @param failure block is what is executed when the service execution has failed
 */
- (NSOperation *)operationForQueryPath:(NSString *)path
                                ofType:(ServiceMethod)methodType
                            parameters:(NSDictionary *)parameters
                       overrideHeaders:(NSDictionary *)overrideHeaders
                               success:(ServiceSuccess)success
                               failure:(ServiceFailure)failure;

/**
 Returns a NSOperation for performing a service call using parameters, success and failure blocks,
 uses AFJSONParameterEncoding and sends JSON results to success block
 @discussion Provides support for NSURLCache mechanism using WDPRCacheMetadata delegation
 @param path NSString of the URL to call
 @param methodType ServiceMethod, Get, Post, Header, Put, Deleted, etc
 @param parameters a dictionary of key value pairs to build a query string
 or post header parameters
 @param cacheMetadataId Id for a cache meta data object that will provide caching info for this request
 @param overrideHeaders a dictionary of key value pairs to set additional request headers
 @param success block is what is executed when the service execution is successful
 @param failure block is what is executed when the service execution has failed
 */
- (NSOperation *)operationForQueryPath:(NSString *)path
                                ofType:(ServiceMethod)methodType
                            parameters:(NSDictionary *)parameters
                       cacheMetadataId:(NSString *)cacheMetadataId
                       overrideHeaders:(NSDictionary *)overrideHeaders
                               success:(ServiceSuccess)success
                               failure:(ServiceFailure)failure;

/**
 Creates an NSMutableURLRequest object with the specified HTTP method and URL string.
 
 @param method The HTTP method for the request, such as GET, POST, PUT, or DELETE. This parameter must not be nil.
 @param path The URL string used to create the request URL.
 @param parameters The parameters to be either set as a query string for GET requests, or the request HTTP body.
 */
- (NSMutableURLRequest *)requestWithMethod:(NSString *)method
                                      path:(NSString *)path
                                parameters:(NSDictionary *)parameters;

/**
 Creates an enqueues a NSOperation to execute a NSMutableURLRequest.
 
 @param request The HTTP request to be executed in the operation
 @param success Block called upon success, with data dictionary containing any detailed info returned
 by the link.
 @param failure Block called, with error object, if service call fails.
 */
- (void)requestOperationWithRequest:(NSMutableURLRequest *)request
                            success:(ServiceSuccess)success
                            failure:(ServiceFailure)failure;

/**
 Creates and executes an AFHTTPRequestOperation with the path and the parameters
 
 @param path The URL string used to create the request URL.
 @param parameters The parameters to be set as the request HTTP body.
 @param success Block called upon success, with the responseObject, operation and credential
 @param failure Block called, with error object and operation, if service call fails.
 */
- (void)wdprAuthenticateUsingOAuthWithPath:(NSString *)path
                                parameters:(NSDictionary *)parameters
                                   success:(void (^)(id responseObject, AFHTTPRequestOperation *operation, AFOAuthCredential *credential))success
                                   failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@end
