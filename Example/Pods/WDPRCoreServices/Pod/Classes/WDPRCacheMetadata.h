//
//  WDPRCacheMetadata.h
//  Pods
//
//  Created by Uribe, Martin on 1/19/16.
//
// WARNING: PLEASE BEWARE THAT NSURLSession DOES *NOT* CACHES RESPONSES OF OVER 50KB
// See property forceStorageIfResponseSizeTooLarge
//

#import <Foundation/Foundation.h>
#import "WDPRCacheDelegate.h"

extern NSString *const WDPRCacheMetadataDefaultId;

@class WDPRCacheMetadata;

/**
 Cache Priority levels. Please note, having maximum priority does not guarantee that your cache will be stored at all
 times and throughout a period of time. Remember that NSURLCache can be flushed by anyone at anytime, app sustainers will
 need to keep such actions undersight.
 */
typedef float WDPRCachePriority;
static const WDPRCachePriority WDPRCachePriorityRequired = 1000; // A Response that MUST be cached.  Do not exceed this.
static const WDPRCachePriority WDPRCachePriorityHigh = 750; // Caching is required, but it is not so bad if removed.
static const WDPRCachePriority WDPRCachePriorityLow = 250; // Cache is available but could be removed without major issues.

@protocol WDPRCacheMetadataConfigurator <NSObject>

+ (void)configureCacheMetadata:(WDPRCacheMetadata *)cacheMetadata;

@end

/**
 Model used to keep details to facilitate caching while using NSURLCache with AFNetworking. Please use one of the two
 exposed initialisers for creating an instance of this class.
 */
@interface WDPRCacheMetadata : NSObject <NSCoding>

/**
 A string identifying the response which needs caching management
 */
@property (nonatomic, strong, readonly) NSString *requestId;

/**
 The cache policy used by the networking stack to determine if a response should be cached and how. 
 See http://nshipster.com/nsurlcache/ for more information
 */
@property (nonatomic, assign, readonly) NSURLRequestCachePolicy cachePolicy;

/**
 The cache storage policy used by the networking layer to determine if a response should be cached
 in memory, in disk, both, or none.
 */
@property (nonatomic, assign, readonly) NSURLCacheStoragePolicy cacheStoragePolicy;

/**
 Gives a hint for App Sustainment methods that regulate usage of Memory and Disk cache using NSURLCache.
 Usually, when cache starts running out of memory or disk space, the host application, through one of its delegates,
 could make decisions to free cache space; it would make sense to start removing cache based on cache priority.
 */
@property (nonatomic) WDPRCachePriority cachePriority;

/**
 Delegate for caching business logic. Such instance will make caching decisions at runtime.
 */
@property (nonatomic, weak) id<WDPRCacheDelegate> cacheDelegate;

/**
 Flag which marks if the response should be cached or not, basically at runtime this will be used by the
 network stack to change the cachePolicy type or the storagePolicy of an NSURLRequest, NSURLResponse respectively.
 */
@property (nonatomic) BOOL cacheEnabled;

/**
 Indicates that this cache metadata requires some sort of expiration time management. Please remember that
 expiration time logic is handled in your Cache Delegate object. This property will be inquired once a new
 service response arrives and to decide whether to correct the service response date or not. See private method
 formatResponseIfNeeded: from WDPRCommonDataService for more information.
 */
@property (nonatomic) BOOL expirationControlRequired;

/**
 Returns whether an NSCachedURLResponse object that exceeds 50KB should be stored in NSURLCache. By default
 NSURLSession WILL NOT cache responses that exceed 50KB, therefore this is an option you can use in your
 delegate to force a response to be cached. It is NOT encouraged, however, to use the NSURLCache mechanism
 implemented here to handle large responses, please be sure that you want to use this feature for large
 responses, unexpected behavior may occur.
 http://stackoverflow.com/questions/7166422/nsurlconnection-on-ios-doesnt-try-to-cache-objects-larger-than-50kb
 */
@property (nonatomic) BOOL forceStorageIfResponseSizeTooLarge;

/**
 Readonly property that lets the networking stack know if the cached response needs to be updated, and hence a new
 request must be made. Normally this would happen because a cached response has expired.
 */
@property (readonly) BOOL reloadRequired;

/**
 Keeps a reference to the cached url response after successfully obtaining a result from a service call.
 This request needs to be known in order to take advantage of NSURLCache APIs
 */
@property (nonatomic, strong, readonly) NSURLRequest *cachedURLRequest;

/** 
  Flag which marks if the request was cached or not. This would allow to track request before or after the request and response was cached.
 */
@property (atomic) BOOL isCached;

/**
 Returns an instance of this class with a desired configuration and a specific delegate
 @param configuratorClass Class that will set the defaults for the brand new CacheMetadata object
 @param requestId The string identifier for the cache metadata. Cannot be the reserved string "Default"!
 */
- (instancetype)initWithConfiguratorClass:(Class<WDPRCacheMetadataConfigurator>)configuratorClass
                                requestId:(NSString *)requestId;

/**
 Auxiliary method for invalidating cache for the response being tracked. Basically this will cause the 
 cachePolicy to become of type NSURLRequestReloadIgnoringLocalCacheData and the reloadRequired to be true
 @discussion This method will have different actions on a DEFAULT meta data object (that is, and object of
 this class for which a requestId == "Default". In the latter case, only the swid will become nil
 */
- (void)invalidateCache;

/**
 Forces the removal of the cached response from memory and disk, the cache metadata object will
 be invalidated as well.
 @discussion in case NSURLCache fails to remove a cache in disk, a blank response will be forced-stored
 to remove any traces of the previous cached response.
*/
- (void)removeFromCache;

/**
 Auxiliary method that will assign the cache policy based on whether caching is enabled (using the 
 WDPRCacheDelegate instance)
 */
- (void)updateCachePolicy;

/**
 Critical method needed to update response results for cache tracking, such as the Swid of the current logged in
 guest, and the NSURLResponse object.
 forbids a normal update (please see method cacheCanBeUpdated)
 @param swid The current logged in guest's unique identifier
 @param response The response object containing HTTP response information
 */
- (void)updateCacheMetadataForSwid:(NSString *)swid
                           request:(NSURLRequest *)request
                          response:(NSURLResponse *)response;

/**
 Called only if it is detected that a service response could not be cached because there is no available cache
 (disk or memory) space to store such response. The delegate will be notified of this event.
 @discussion based on business rules, we could globally clean the whole cache or try to remove some using for
 instance [NSURLCache sharedURLCache] removeCachedResponsesSinceDate:
 */
- (void)cacheSpaceDidReachLimit;

/**
 In the event that the NSURLCache instance does NOT update its cache after receiving a service response, the
 cache delegate can specify to force store the updated service response. By default 
 forceStorageIfResponseSizeTooLarge value is returned.
 @return Whether the delegate wants to force storage of an updated service response that was NOT automatically
 cached (for NSURL reasons). Otherwise forceStorageIfResponseSizeTooLarge value is returned.
 */
- (BOOL)shouldForceUpdatingCacheStorage;

@end
