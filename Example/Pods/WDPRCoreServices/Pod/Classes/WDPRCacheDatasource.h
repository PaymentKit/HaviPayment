//
//  WDPRCacheDatasource.h
//  Pods
//
//  Created by Uribe, Martin on 10/2/16.
//
//

#ifndef WDPRCacheDatasource_h
#define WDPRCacheDatasource_h

#import "WDPRCacheMetadata.h"

@protocol WDPRCacheDatasource <NSObject>

/**
 * Returns an array of Strings which represent the supported *unique* cache Request Ids.
 * Such Ids will allow the current cache system to recover, store and manage caches appropriately using Ids
 * @return an array of Cache string identifiers
 */
- (NSArray<NSString *> * _Nonnull)cacheRequestIds;

/**
 * Indicates if a cache for a specific request Identifier should be treated as public or private
 * @param requestId The identifier for the Cache metadata in matter
 * @return YES if the cache should consider authentication, NO otherwise
 */
- (BOOL)isPrivateForRequestId:(NSString * _Nonnull)requestId;

/**
 * Returns a Cache Metadata object that corresponds to a request Id
 * @param requestId The identifier for the Cache metadata in matter
 * @return An instance of WDPRCacheMetadata built with the requestId
 */
- (WDPRCacheMetadata * _Nullable)cacheMetadataForRequestId:(NSString * _Nonnull)requestId;

/**
 * Returns a Cache Delegate object that corresponds to a request Id
 * @param requestId The identifier for the Cache metadata in matter
 * @return An instance of WDPRCacheDelegate that will advocate for cache events related to the requestId
 */
- (id<WDPRCacheDelegate> _Nullable)cacheDelegateForRequestId:(NSString * _Nonnull)requestId;

@end

#endif /* WDPRCacheDatasource_h */
