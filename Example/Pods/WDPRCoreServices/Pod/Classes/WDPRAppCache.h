//
//  WDPRAppCache.h
//  Pods
//
//  Created by Uribe, Martin on 8/29/16.
//
//

#import <Foundation/Foundation.h>
#import "WDPRCacheDelegate.h"
#import "WDPRCacheDatasource.h"
#import "WDPRCacheMetadataFactory.h"
@class WDPRPublicDataService;

@protocol WDPRAppCacheDelegate <NSObject>

- (BOOL)enoughCacheStorageForBytes:(NSUInteger)bytes cachePriority:(WDPRCachePriority)cachePriority;

@end

@interface WDPRAppCache : NSObject <WDPRAppCacheDelegate>

// NSCoding 
extern NSString * _Nonnull const CacheEnabledKey;

/**
 Important: All clients requiring cache capabilities using NSURLCache+WDPR must use this instance
 of WDPRPublicDataService, since it is there where cacheMetadata objects are kept for public
 requests.
 */
@property (strong, nonatomic) WDPRPublicDataService * _Nonnull publicDataService;

/**
 * Alternative way of keeping strong references to the cache delegates. A dictionary helps in retrieving
 * a cacheDelegate given a unique request ID
 */
@property (strong, nonatomic) NSMutableDictionary * _Nonnull cacheDelegates;

/**
 Returns a shared instance of this class
 */
+ (instancetype _Nonnull)sharedInstance;

/**
 * Set a subclass of WDPRAppCache in order to make it the sharedInstance. Doing this may change previous rules and caching
 * behavior. 
 * @discussion This option should usually pertain a Host App developer, and should not be used outside of that scope.
 */
+ (void)setSharedInstance:(WDPRAppCache * _Nonnull)appCache;

/**
 * To be Overridden by subclasses. You can implement here all the logic required to set the 
 * caching delegate to the cache metadata objects you need prior app launching.
 * i.e self.cacheDelegates[@"ExampleID"] = exampleCacheDelegate
 *     cacheMetadata.cacheDelegate = exampleCacheDelegate
 */
- (void)loadCacheDatasource;

/**
 * Auxiliary method that helps preparing cached metadata and assigning a cache delegate to each WDPRCacheMetadata
 * object.
 * @param datasourceClass an object conforming to WDPRCacheDatasource protocol
 */
- (void)prepareCacheWithDatasource:(id<WDPRCacheDatasource> _Nonnull)datasourceClass;

/**
 IMPORTANT: To be called from AppDelegate upon app termination
 This will persist WDPRCacheMetadata elements with a known cached response
 */
- (void)saveCachedMetadata;

/**
 Returns a cache storage policy based on business rules defined by each host application
 @param cacheMetadata The cache metadata object for which a storage policy will be determined
 */
- (NSURLCacheStoragePolicy)cacheStoragePolicyForCacheMetadata:(WDPRCacheMetadata * _Nonnull)cacheMetadata;

/**
 Returns a cache priority level given some cache options
 @param cacheOptions Cache Options that will determine what priority level should be used
 @discussion Priority levels will usually affect how a cached response will be stored; for
 example, a low priority call might only be cached in memory, whereas a high priority call
 might be stored in disk
 */
- (WDPRCachePriority)cachePriorityForCacheOptions:(WDPRCacheOptions)cacheOptions;

/**
 * Invalidates cached service calls using NSURLCache+WDPR strategy. 
 * @param cacheOptions Determines if public, private or both cache cache metadata types should be invalidated
 */
- (void)invalidateAppCacheWithOptions:(WDPRCacheOptions)cacheOptions;

/**
 * Attempts to remove cached service calls using NSURLCache+WDPR strategy.
 * @param cacheOptions Determines if public, private or both cache cache metadata types should be removed
 * @discussion Cache removals will usually be effective if the NSURLRequest pointer was kept and was accurate, otherwise
 * an attempt to replace the cache with a blank, placeholder cache will be done. This is a limitation due to the fact
 * that NSURLCache requires a pointer of a NSURLRequest object (for which a response was originally cached) to be passed
 * as a parameter in order to retrieve or remove a cached response.
 */
- (void)removeAppCacheWithOptions:(WDPRCacheOptions)cacheOptions;

/**
 Returns a response object to be passed to a success block (usually) after comparing an operation response with
 the cached response.
 @param operationRequest The URL Request object which would be used in case a force cache is required by client
 @param operationResponse The URL Response object which is required to compare to the cached response
 @param operationData The NSData object that would contain the response data
 @param swid The swid for the current operation
 @param cacheMetadata The cache metadata object for the actual operation
 @return The latest known response object, usually in the form of an NSData object, nil in case it's not possible to compare
 @discussion This method helps in an issue found  with, presumably, NSURLSession where the responseObject used to
 invoke a success block in AFNetworking contained stale data - old data and not the actual cached data. In order
 to address this issue in the most logical and safe way possible, this method attempts to find out which response
 contains the most recent information for this request.
 In case the cached response lacks of vital information, such as the date it was received, this method will return nil.
 */
- (id _Nullable)responseObjectForOperationRequest:(NSURLRequest * _Nullable)operationRequest
                                operationResponse:(NSHTTPURLResponse * _Nullable)operationResponse
                                    operationData:(NSData * _Nullable)operationData
                                             swid:(NSString * _Nullable)swid
                                    cacheMetadata:(WDPRCacheMetadata * _Nonnull)cacheMetadata;

@end
