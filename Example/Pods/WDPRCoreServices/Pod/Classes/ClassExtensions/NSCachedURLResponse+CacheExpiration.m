//
//  NSCachedURLResponse+CacheExpiration.m
//  DLR
//
//  Created by Delafuente, Rob on 2/27/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "NSCachedURLResponse+CacheExpiration.h"

#define kHTTPCacheControlHeader @"Cache-Control"
#define kHTTPExpiresHeader @"Expires"
#define kHTTPMaxAgeHeader @"s-maxage"

#define kHTTPMaxAgeKey @"max-age"
#define kHTTPVersion @"HTTP/1.1"


@implementation NSCachedURLResponse (CacheExpiration)

- (NSCachedURLResponse*)responseWithExpirationDuration:(NSUInteger)duration
{
    NSCachedURLResponse* cachedResponse = self;
    NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse*)[cachedResponse response];
    NSDictionary *headers = [httpResponse allHeaderFields];
    NSMutableDictionary* newHeaders = [headers mutableCopy];
    
    newHeaders[kHTTPCacheControlHeader] = [NSString stringWithFormat:@"%@=%ld", kHTTPMaxAgeKey, (unsigned long)duration];
    [newHeaders removeObjectForKey:kHTTPExpiresHeader];
    [newHeaders removeObjectForKey:kHTTPMaxAgeHeader];
    
    NSHTTPURLResponse* newResponse = [[NSHTTPURLResponse alloc] initWithURL:httpResponse.URL
                                                                 statusCode:httpResponse.statusCode
                                                                HTTPVersion:kHTTPVersion
                                                               headerFields:newHeaders];
    
    cachedResponse = [[NSCachedURLResponse alloc] initWithResponse:newResponse
                                                              data:[cachedResponse.data mutableCopy]
                                                          userInfo:newHeaders
                                                     storagePolicy:cachedResponse.storagePolicy];
    return cachedResponse;
}


@end
