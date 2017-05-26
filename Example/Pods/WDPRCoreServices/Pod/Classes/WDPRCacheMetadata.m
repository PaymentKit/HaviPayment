//
//  WDPRCacheMetadata.m
//  Pods
//
//  Created by Uribe, Martin on 1/19/16.
//
//

#import "WDPRAppCache.h"
#import "WDPRCacheMetadata.h"
#import <WDPRCore/NSDateFormatter+WDPR.h>
#import <WDPRCore/NSDate+WDPR.h>
#import "WDPRCacheMetadataFactory.h"

@interface WDPRCacheMetadata ()

@property (nonatomic, strong, readwrite) NSString *requestId;
@property (nonatomic, assign, readwrite) NSURLRequestCachePolicy cachePolicy;
@property (nonatomic, assign, readwrite) NSURLCacheStoragePolicy cacheStoragePolicy;
@property (readwrite) BOOL reloadRequired;
@property (nonatomic, strong, readwrite) NSURLRequest *cachedURLRequest;
@property (nonatomic, strong) id<WDPRCacheDelegate> defaultCacheDelegate;

@end

@implementation WDPRCacheMetadata
NSString *const WDPRCacheMetadataDefaultId = @"Default";
// NSCoding Keys
NSString *const ExpirationControlRequiredKey = @"ExpirationControlRequired";
NSString *const ForceStorageIfResponseSizeTooLargeKey = @"ForceStorageIfResponseSizeTooLarge";
NSString *const RequestIdKey = @"RequestId";
NSString *const URLCachePolicyKey = @"URLCachePolicy";
NSString *const URLCacheStoragePolicyKey = @"URLCacheStoragePolicy";
NSString *const WDPRCachePriorityKey = @"CachePriority";
NSString *const ReloadRequiredKey = @"ReloadRequired";
NSString *const URLRequestKey = @"URLRequest";
NSString *const CachedKey = @"isCached";

- (instancetype)initWithConfiguratorClass:(Class<WDPRCacheMetadataConfigurator>)configuratorClass
                                requestId:(NSString *)requestId
{
    if (self = [self initWithRequestId:requestId])
    {
        self.cachePolicy = NSURLRequestUseProtocolCachePolicy; // By default we leave this policy
        [configuratorClass configureCacheMetadata:self];
    }
    return self;
}

- (instancetype)initWithRequestId:(NSString *)requestId
{
    if (self = [super init])
    {
        self.requestId = requestId ?: WDPRCacheMetadataDefaultId;
        self.reloadRequired = NO;
        self.isCached = NO;
        [self updateCachePolicy];
    }
    return self;
}

- (void)invalidateCache
{
    if (![self.requestId isEqualToString:WDPRCacheMetadataDefaultId])
    {
        self.cachePolicy = NSURLRequestReloadIgnoringLocalCacheData;
        self.reloadRequired = YES;
        self.isCached = NO;        
        if ([self.cacheDelegate respondsToSelector:@selector(cacheWasInvalidated)])
        {
            [self.cacheDelegate cacheWasInvalidated];
        }
    }
}

- (void)removeFromCache
{
    [self removeFromCacheAndInvalidate:YES];
}

#pragma mark - Private

/**
 Forces the removal of the cached response from memory and disk.
 @param invalidate If YES, then the cache metadata object will be invalidated as well, NO will not invalidate cache
 @discussion in case NSURLCache fails to remove a cache in disk, a blank response will be forced-stored
 to remove any traces of the previous cached response.
 */
- (void)removeFromCacheAndInvalidate:(BOOL)invalidate
{
    if (invalidate)
    {
        [self invalidateCache];
    }
    if (_cachedURLRequest)
    {
        [[NSURLCache sharedURLCache] removeCachedResponseForRequest:_cachedURLRequest];
        if (self.cacheStoragePolicy == NSURLCacheStorageAllowed)
        {
            // HEADS UP: Hack to workaround possible caches persisting in disk
            NSHTTPURLResponse *httpResponse = [[NSHTTPURLResponse alloc] initWithURL:[NSURL URLWithString:@""]
                                                                          statusCode:200 HTTPVersion:@"HTTP/1.1"
                                                                        headerFields:nil];
            NSCachedURLResponse *response = [[NSCachedURLResponse alloc]
                                             initWithResponse:httpResponse
                                             data:[NSData data]
                                             userInfo:nil
                                             storagePolicy:NSURLCacheStorageAllowed];
            [[NSURLCache sharedURLCache] storeCachedResponse:response forRequest:_cachedURLRequest];
        }
    }
}

- (void)updateCacheMetadataForSwid:(NSString *)swid
                           request:(NSURLRequest *)request
                          response:(NSURLResponse *)response
{
    [self.cacheDelegate cacheMetadataWillUpdateWithSwid:swid response:response];
    if (!self.cacheEnabled || !response)
    {
        return; // If caching is not supported then the logic below is irrelevant
    }
    self.isCached = response != nil;
    if (self.reloadRequired)
    {
        self.cachePolicy = NSURLRequestReturnCacheDataElseLoad;
        self.reloadRequired = NO;
    }
    else if (![self.cacheDelegate isCacheValidForSwid:swid])
    {
        [self invalidateCache];
    }
    self.cachedURLRequest = request;
}

- (void)updateCachePolicy
{
    self.cachePolicy = self.cacheEnabled ?
    NSURLRequestReturnCacheDataElseLoad : NSURLRequestReloadIgnoringLocalCacheData;
}

- (void)cacheSpaceDidReachLimit
{
    if ([self.cacheDelegate respondsToSelector:@selector(cacheSpaceDidReachLimit)])
    {
        [self.cacheDelegate cacheSpaceDidReachLimit];
    }
}

#pragma mark - Setters

// TODO: Still under review, determining if the approach we should take should be a delegate or a strategy design, the
// setters below might change
- (void)setCacheEnabled:(BOOL)cacheEnabled
{
    BOOL cacheOriginallyEnabled = _cacheEnabled;
    _cacheEnabled = cacheEnabled;
    if (!cacheOriginallyEnabled && cacheEnabled &&
        [self.cacheDelegate respondsToSelector:@selector(cacheWasEnabled)])
    {
        [self.cacheDelegate cacheWasEnabled];
    }
    else if (cacheOriginallyEnabled && !_cacheEnabled &&
             [self.cacheDelegate respondsToSelector:@selector(cacheWasDisabled)])
    {
        [self.cacheDelegate cacheWasDisabled];
    }
}

- (void)setForceStorageIfResponseSizeTooLarge:(BOOL)forceStorageIfResponseSizeTooLarge
{
    BOOL storageEnforcingOriginallyEnabled = _forceStorageIfResponseSizeTooLarge;
    _forceStorageIfResponseSizeTooLarge = forceStorageIfResponseSizeTooLarge;
    if (!storageEnforcingOriginallyEnabled && _forceStorageIfResponseSizeTooLarge &&
        [self.cacheDelegate respondsToSelector:@selector(forceStorageIfResponseSizeTooLargeWasEnabled)])
    {
        [self.cacheDelegate forceStorageIfResponseSizeTooLargeWasEnabled];
    }
    else if (storageEnforcingOriginallyEnabled && !_forceStorageIfResponseSizeTooLarge &&
             [self.cacheDelegate respondsToSelector:@selector(forceStorageIfResponseSizeTooLargeWasDisabled)])
    {
        [self.cacheDelegate forceStorageIfResponseSizeTooLargeWasDisabled];
    }
}

- (BOOL)shouldForceUpdatingCacheStorage
{
    // It makes sense to return the value set for forceStorageIfResponseSizeTooLarge since if it is required
    // in the case of exceeding NSURLCache's default maximum size, it would be needed otherwise as well
    BOOL shouldForceUpdatingCacheStorage = self.forceStorageIfResponseSizeTooLarge;
    // Anyways, the final decision will be given by the delegate, who can implement the behavior:
    if ([self.cacheDelegate respondsToSelector:@selector(shouldForceUpdateCacheMetadata:)])
    {
        shouldForceUpdatingCacheStorage = [self.cacheDelegate shouldForceUpdateCacheMetadata:self];
    }
    
    return shouldForceUpdatingCacheStorage;
}

- (void)setCachedURLRequest:(NSURLRequest *)request
{
    if (!_cachedURLRequest)
    {
        _cachedURLRequest = request;
    }
    else if (![_cachedURLRequest.URL isEqual:request.URL]) // If URL addresses are different
    {
        [self removeFromCacheAndInvalidate:NO];
        if ([self.cacheDelegate respondsToSelector:@selector(cacheWasRemoved)])
        {
            [self.cacheDelegate cacheWasRemoved];
        }
        _cachedURLRequest = request;
    }
}

- (void)setCachePriority:(WDPRCachePriority)cachePriority
{
    _cachePriority = cachePriority; // Need to set this first
    [self updateCacheStoragePolicy];
}

- (void)updateCacheStoragePolicy
{
    NSURLCacheStoragePolicy newCacheStoragePolicy = [self.cacheDelegate.appCacheDelegate cacheStoragePolicyForCacheMetadata:self];
    if (self.cachedURLRequest && self.cacheStoragePolicy != newCacheStoragePolicy)
    {
        NSCachedURLResponse *cachedURLResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:self.cachedURLRequest];
        cachedURLResponse = [[NSCachedURLResponse alloc]
                             initWithResponse:cachedURLResponse.response
                             data:cachedURLResponse.data
                             userInfo:cachedURLResponse.userInfo
                             storagePolicy:newCacheStoragePolicy];
        if (self.cacheStoragePolicy == NSURLCacheStorageAllowed)
        {
            // HEADS UP, it means that the disk probably cached the call, so we must remove it
            [self removeFromCacheAndInvalidate:NO];
            [[NSURLCache sharedURLCache] storeCachedResponse:cachedURLResponse forRequest:self.cachedURLRequest];
        }
        else if (newCacheStoragePolicy == NSURLCacheStorageAllowed)
        {
            // Re-add the cached service response to disk
            [[NSURLCache sharedURLCache] storeCachedResponse:cachedURLResponse forRequest:self.cachedURLRequest];
        }
    }
    self.cacheStoragePolicy = newCacheStoragePolicy;
}

- (id<WDPRCacheDelegate>)cacheDelegate
{
    if (!_cacheDelegate)
    {
        _cacheDelegate = self.defaultCacheDelegate;
    }
    
    return _cacheDelegate;
}

- (id<WDPRCacheDelegate>)defaultCacheDelegate
{
    if (!_defaultCacheDelegate)
    {
        _defaultCacheDelegate = [WDPRCacheMetadataFactory cacheDelegateWithCacheOptions:WDPRCacheOptionsNone];
    }
    return _defaultCacheDelegate;
}

#pragma mark - NSCoding

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    NSString *requestId = [aDecoder decodeObjectForKey:RequestIdKey];
    if (self = [self initWithRequestId:requestId])
    {
        _cacheEnabled = [aDecoder decodeBoolForKey:CacheEnabledKey];
        _expirationControlRequired = [aDecoder decodeBoolForKey:ExpirationControlRequiredKey];
        _forceStorageIfResponseSizeTooLarge = [aDecoder decodeBoolForKey:ForceStorageIfResponseSizeTooLargeKey];
        _cachePolicy = [aDecoder decodeIntegerForKey:URLCachePolicyKey];
        _cacheStoragePolicy = [aDecoder decodeIntegerForKey:URLCacheStoragePolicyKey];
        _cachePriority = [aDecoder decodeIntegerForKey:WDPRCachePriorityKey];
        _reloadRequired = [aDecoder decodeBoolForKey:ReloadRequiredKey];
        _cachedURLRequest = [aDecoder decodeObjectForKey:URLRequestKey];
        _isCached = [aDecoder decodeBoolForKey:CachedKey];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeBool:self.cacheEnabled forKey:CacheEnabledKey];
    [aCoder encodeBool:self.expirationControlRequired forKey:ExpirationControlRequiredKey];
    [aCoder encodeBool:self.forceStorageIfResponseSizeTooLarge forKey:ForceStorageIfResponseSizeTooLargeKey];
    [aCoder encodeObject:self.requestId forKey:RequestIdKey];
    [aCoder encodeInteger:self.cachePolicy forKey:URLCachePolicyKey];
    [aCoder encodeInteger:self.cacheStoragePolicy forKey:URLCacheStoragePolicyKey];
    [aCoder encodeInteger:self.cachePriority forKey:WDPRCachePriorityKey];
    [aCoder encodeBool:self.reloadRequired forKey:ReloadRequiredKey];
    [aCoder encodeObject:self.cachedURLRequest forKey:URLRequestKey];
    [aCoder encodeBool:self.isCached forKey:CachedKey];
}

@end
