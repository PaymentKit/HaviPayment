//
//  WDPRCacheDelegate.h
//  Pods
//
//  Created by Uribe, Martin on 2/2/16.
//
//

#ifndef WDPRCacheValidationProtocol_h
#define WDPRCacheValidationProtocol_h
@class WDPRCacheMetadata;
@class WDPRAppCache;

@protocol WDPRCacheDelegate <NSObject>

@required

/**
 WARNING: This property should be configured by some central authority, ideally, there shouldn't be any cacheDelegates
 with a reference to a different class. This property should be set under the consent of the host app owner.
 */
@property (weak, nonatomic) WDPRAppCache *appCacheDelegate;

/**
 WDPRCacheMetadata will call this method when a new cached response is received. The delegate must make decisions
 based on this update, such as wanting to update the date for when caching will expire, or updating the swid.
 Please be careful and thorough when developing business logic in here, you may use examples such as 
 WDPRSampleCacheDelegate in the Example application of the WDPRCore project
 @param swid The current logged in guest's unique identifier
 @param response The response object containing HTTP response information
 */
- (void)cacheMetadataWillUpdateWithSwid:(NSString *)currentSwid response:(NSURLResponse *)response;

/**
 Indicates whether the cache is currently valid given the *current* logged in user's swid
 @param swid The current user's unque identifier. This parameter should be irrelevant if the request is PUBLIC
 @discussion Cache SHOULD NOT be valid if 1. The expiration time has passed, 2. Caching is disabled
 3. The request is PRIVATE and the passed swid does NOT match with the last known swid
 However, it is responsibility of the delegate object to say whether the cache has become invalid, this will
 cause the WDPRCacheMetadata to invoke invalidateCache, forcing the cache having to reload its data.
 */
- (BOOL)isCacheValidForSwid:(NSString *)swid;

@optional

/**
 WDPRCacheMetadata will notify its delegate when the caching has been invalidated. The delegate can execute
 post-state events such as nilifying the swid. Bear in mind that whatever you decide to do after invalidation
 might be needed later on for caching again. Please see WDPRSampleCacheDelegate for examples.
 */
- (void)cacheWasInvalidated;

/**
 Notifies the delegate after cache was disabled
 @pre Cache was enabled
 */
- (void)cacheWasDisabled;

/**
 Notifies the delegate after cache was enabled
 @pre Cache was disabled
 */
- (void)cacheWasEnabled;

/**
 Notifies the delegate after cache was removed
 @pre A valid NSURLRequest attribute was related to the cache metadata object, indicating 
 that effectively a cached response existed before attempting to remove
 */
- (void)cacheWasRemoved;

/**
 Notifies the delegate after forcing storage if response size is too large was disabled
 @pre Forcing storage option was enabled
 */
- (void)forceStorageIfResponseSizeTooLargeWasDisabled;

/**
 Notifies the delegate after forcing storage if response size is too large was enabled
 @pre Forcing storage option was disabled
 */
- (void)forceStorageIfResponseSizeTooLargeWasEnabled;

/**
 Called only if it is detected that a service response could not be cached because there is no available cache 
 (disk or memory) space to store such response. The delegate may take actions such as cleaning up the cache.
 Please bear in mind that NSURLCache shares cache with other requests, so during cleaning you might affect others!
 */
- (void)cacheSpaceDidReachLimit;

/**
 In the event that the NSURLCache instance does NOT update its cache after receiving a service response, the
 cache delegate can specify to force store the updated service response.
 @param cacheMetadata A WDPRCacheMetadata object linked to this delegate that could be used to gather information that
 may help determining if a force update should take place
 @return Whether the delegate wants to force storage of an updated service response that was NOT automatically
 cached (for NSURL reasons).
 */
- (BOOL)shouldForceUpdateCacheMetadata:(WDPRCacheMetadata*)cacheMetadata;

@end

#endif /* WDPRCacheDelegate_h */
