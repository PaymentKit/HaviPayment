//
//  WDPRAppCache.m
//  Pods
//
//  Created by Uribe, Martin on 8/29/16.
//
//

#import "WDPRAppCache.h"

#import "WDPRAuthenticationService.h"
#import "WDPRPublicDataService.h"
#import "WDPRPrivateDataService.h"

// DO NOT USE @import:
// BuildPhase needs this file
// and it doesn't use frameworks
#import <WDPRCore/WDPRFoundation.h>

@interface WDPRAppCache ()

@property (nonatomic, strong) NSString *privateCachedMetadataURL;
@property (nonatomic, strong) NSString *publicCachedMetadataURL;

@end

const NSUInteger WDPRKB = 1024;
const NSUInteger WDPRNSURLSessionResponseSizeLimit = 50*WDPRKB; //NSURLSession does not caches responses above 50KB
const NSUInteger WDPRAppMinimumNSURLCacheThreshold = WDPRKB * WDPRKB; // 1 MB

@implementation WDPRAppCache
static dispatch_once_t onceToken = 0;
static WDPRAppCache *instance = nil;

NSString *const CacheEnabledKey = @"CacheEnabled";
@synthesize publicDataService = _publicDataService;

#pragma mark - Public

+ (instancetype)sharedInstance
{    
    dispatch_once(&onceToken, ^{
        if (instance == nil)
        {
            instance = [[WDPRAppCache alloc] init];
        }
    });
    
    return instance;
}

+ (void)setSharedInstance:(WDPRAppCache *)appCache
{
    onceToken = 0;
    instance = appCache;
}

- (instancetype)init
{
    if (self = [super init])
    {
        [self loadCacheMetadata];
    }
    
    return self;
}

- (void)loadCacheDatasource
{
    // OVERRIDE IN SUBCLASS - This is Host-App specific
    WDPRLogWarning(@"loadCacheDatasource method of WDPRAppCache was not overridden and therefore"
                   " it is possible cache metadata may behave unexpectedly, please preload cache"
                   " metadata every time the app starts after it was *suspended*");
}

- (void)prepareCacheWithDatasource:(id<WDPRCacheDatasource>)datasourceClass
{
    NSArray<NSString *> *requestIds = [datasourceClass cacheRequestIds];
    for (NSString *requestId in requestIds) {
        if ([requestId isKindOfClass:[NSString class]]) {
            [self prepareCacheWithDatasource:datasourceClass requestId:requestId];
        }
    }
}

- (void)prepareCacheWithDatasource:(id<WDPRCacheDatasource>)datasourceClass requestId:(NSString *)requestId
{
    BOOL isPrivate = [datasourceClass isPrivateForRequestId:requestId];
    WDPRCacheMetadata *cacheMetadata = [self cacheMetadataForRequestId:requestId
                                                             isPrivate:isPrivate];
    id<WDPRCacheDelegate> cacheDelegate = [datasourceClass cacheDelegateForRequestId:requestId];
    if (!cacheMetadata)
    {
        cacheMetadata = [datasourceClass cacheMetadataForRequestId:requestId];
        if (isPrivate)
        {
            [[WDPRPrivateDataService sharedInstance] registerCacheMetadata:cacheMetadata];
        }
        else
        {
            [self.publicDataService registerCacheMetadata:cacheMetadata];
        }
    }
    cacheMetadata.cacheDelegate = cacheDelegate;
    if (cacheDelegate)
    {
        self.cacheDelegates[requestId] = cacheDelegate;
    }
    else
    {
        NSLog(@"Cache with Id: %@ was created without a valid cache delegate", requestId);
    }
}

- (WDPRCacheMetadata *)cacheMetadataForRequestId:(NSString *)requestId isPrivate:(BOOL)isPrivate
{
    WDPRCacheMetadata *cacheMetadata;
    if (isPrivate)
    {
        cacheMetadata = [WDPRPrivateDataService sharedInstance].cacheMetadata[requestId];
    }
    else
    {
        cacheMetadata = self.publicDataService.cacheMetadata[requestId];
    }
    
    return cacheMetadata;
}

- (NSURLCacheStoragePolicy)cacheStoragePolicyForCacheMetadata:(WDPRCacheMetadata *)cacheMetadata
{
    WDPRCachePriority cachePriority = cacheMetadata.cachePriority;
    
    return (cachePriority < WDPRCachePriorityHigh) ? NSURLCacheStorageAllowedInMemoryOnly : NSURLCacheStorageAllowed;
}

- (WDPRCachePriority)cachePriorityForCacheOptions:(WDPRCacheOptions)cacheOptions
{
    BOOL isPrivate = (cacheOptions & WDPRCacheOptionsPrivate) != 0;
    return isPrivate ? WDPRCachePriorityHigh : WDPRCachePriorityLow;
}

- (BOOL)enoughCacheStorageForBytes:(NSUInteger)bytes cachePriority:(WDPRCachePriority)cachePriority
{
    BOOL isEnoughCacheStorage = [self enoughCacheStorageForBytes:bytes];
    
    if (cachePriority > WDPRCachePriorityHigh && !isEnoughCacheStorage)
    {
        [self couldFreeEnoughCacheSpaceRequiredToStoreBytes:bytes];
    }
    else if (![self enoughCacheStorageForBytes:WDPRAppMinimumNSURLCacheThreshold])
    {
        [self couldFreeEnoughCacheSpaceRequiredToStoreBytes:WDPRAppMinimumNSURLCacheThreshold];
    }
    
    return isEnoughCacheStorage;
}

- (void)invalidateAppCacheWithOptions:(WDPRCacheOptions)cacheOptions
{
    BOOL invalidatePublicCalls = (cacheOptions & WDPRCacheOptionsPublic) != 0;
    BOOL invalidatePrivateCalls = (cacheOptions & WDPRCacheOptionsPrivate) != 0;
    if (invalidatePublicCalls)
    {
        NSArray *publicMetadata = [self.publicDataService.cacheMetadata allValues];
        [self invalidateCacheMetadata:publicMetadata];
    }
    if (invalidatePrivateCalls)
    {
        NSArray *privateMetadata = [[WDPRPrivateDataService sharedInstance].cacheMetadata allValues];
        [self invalidateCacheMetadata:privateMetadata];
    }
}

- (void)removeAppCacheWithOptions:(WDPRCacheOptions)cacheOptions
{
    BOOL removePublicCalls = (cacheOptions & WDPRCacheOptionsPublic) != 0;
    BOOL removePrivateCalls = (cacheOptions & WDPRCacheOptionsPrivate) != 0;
    if (removePublicCalls)
    {
        NSArray *publicMetadata = [self.publicDataService.cacheMetadata allValues];
        [self removeCacheMetadata:publicMetadata];
        
    }
    if (removePrivateCalls)
    {
        NSArray *privateMetadata = [[WDPRPrivateDataService sharedInstance].cacheMetadata allValues];
        [self removeCacheMetadata:privateMetadata];
    }
}

- (id)responseObjectForOperationRequest:(NSURLRequest *)operationRequest
                      operationResponse:(NSHTTPURLResponse *)operationResponse
                          operationData:(NSData *)operationData
                                   swid:(NSString *)swid
                          cacheMetadata:(WDPRCacheMetadata *)cacheMetadata
{
    // Workaround for AFNetworking sending us stale cache data
    NSCachedURLResponse *cachedResponse = [[NSURLCache sharedURLCache] cachedResponseForRequest:cacheMetadata.cachedURLRequest];
    BOOL shouldUseCachedResponse = [self
                                    shouldUseCachedResponseForOperationResponse:operationResponse
                                    cachedResponse:(NSHTTPURLResponse *)cachedResponse.response
                                    operationData:operationData cachedData:cachedResponse.data];
    // Update the final response info
    id responseObject = shouldUseCachedResponse ? cachedResponse.data : nil;
    NSURLResponse *response = shouldUseCachedResponse ? cachedResponse.response : operationResponse;
    NSData *data = shouldUseCachedResponse ? cachedResponse.data : operationData;
    
    // Update the cache metadata
    BOOL forceUpdatingCacheStorage = [cacheMetadata shouldForceUpdatingCacheStorage];
    [cacheMetadata updateCacheMetadataForSwid:swid
                                      request: forceUpdatingCacheStorage ? nil : operationRequest
                                     response: response];
    // Ping the current disk and memory space status
    if (![self enoughCacheStorageForBytes:data.length
                            cachePriority:cacheMetadata.cachePriority])
    {
        [cacheMetadata cacheSpaceDidReachLimit];
    }
    // Check if the client explicitly requests to re-cache the response
    if (!cachedResponse && (forceUpdatingCacheStorage || (data.length > WDPRNSURLSessionResponseSizeLimit &&
                                      cacheMetadata.forceStorageIfResponseSizeTooLarge && !cacheMetadata.reloadRequired)))
    {
        NSCachedURLResponse *cachedResponse = [[NSCachedURLResponse alloc]
                                         initWithResponse:response
                                         data:data
                                         userInfo:nil
                                         storagePolicy:cacheMetadata.cacheStoragePolicy];
        [[NSURLCache sharedURLCache] storeCachedResponse:cachedResponse forRequest:operationRequest];
    }
    
    return responseObject;
}

#pragma mark - Private

- (BOOL)shouldUseCachedResponseForOperationResponse:(NSHTTPURLResponse *)operationResponse
                                     cachedResponse:(NSHTTPURLResponse *)cachedResponse
                                      operationData:(NSData *)operationData
                                         cachedData:(NSData *)cachedData
{
    BOOL shouldUseCachedResponse = NO;
    // CHECK #1: Verify if the operation's response data is identical to the already cached one
    if ([cachedResponse respondsToSelector:@selector(allHeaderFields)])
    {
        NSDictionary *cachedHeaderFields = [(NSHTTPURLResponse *)cachedResponse allHeaderFields];
        NSDictionary *operationHeaderFields = [operationResponse allHeaderFields];
        BOOL isSameData = [operationData isEqualToData:cachedData];
        BOOL isSameHeaderFields = [cachedHeaderFields isEqualToDictionary:operationHeaderFields];
        
        if (!isSameData || !isSameHeaderFields)
        {
            // CHECK #2: Look which response is the most recent
            NSDateFormatter *formatter = [NSDateFormatter systemFormatterWithFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
            [formatter setTimeZone:[NSTimeZone localTimeZone]];
            NSDate *cachedLastModifiedDate = [formatter dateFromString:cachedHeaderFields[@"Date"]];
            NSDate *operationLastModifiedDate = [formatter dateFromString:operationHeaderFields[@"Date"]];
            shouldUseCachedResponse = [cachedLastModifiedDate isLaterThan:operationLastModifiedDate];
            // TODO: Use Analytics for Developers to track any NSURLSession issues!
            NSLog(@"NSURLCache+WDPR WARNING! \nDetected a difference between a presumed cached response with headers:"
                  @"\n%@\n\nAnd the actual cached response with headers:\n%@\n\nWill attempt to use the latest, which "
                  @"contains headers:\n%@", operationHeaderFields, cachedHeaderFields,
                  shouldUseCachedResponse ? cachedHeaderFields : operationHeaderFields);
        }
    }
    return shouldUseCachedResponse;
}

- (void)invalidateCacheMetadata:(NSArray *)cacheMetadataArray
{
    NSString *swid = [WDPRAuthenticationService sharedInstance].swid;
    for (WDPRCacheMetadata *metadata in cacheMetadataArray)
    {
        if (![metadata.cacheDelegate isCacheValidForSwid:swid])
        {
            [metadata invalidateCache];
        }
    }
}

- (void)removeCacheMetadata:(NSArray *)cacheMetadataArray
{
    NSString *swid = [WDPRAuthenticationService sharedInstance].swid;
    for (WDPRCacheMetadata *metadata in cacheMetadataArray)
    {
        if (metadata.cachedURLRequest && ![metadata.cacheDelegate isCacheValidForSwid:swid])
        {
            [metadata removeFromCache];
            [metadata updateCacheMetadataForSwid:swid request:nil response:nil];
        }
    }
}

- (BOOL)enoughCacheStorageForBytes:(NSUInteger)bytes
{
    NSInteger availableMemoryStorage = [[NSURLCache sharedURLCache] memoryCapacity] -
    [[NSURLCache sharedURLCache] currentMemoryUsage];
    NSInteger availableDiskStorage = [[NSURLCache sharedURLCache] diskCapacity] -
    [[NSURLCache sharedURLCache] currentDiskUsage];
    
    return availableMemoryStorage > bytes && availableDiskStorage > bytes;
}

- (BOOL)couldFreeEnoughCacheSpaceRequiredToStoreBytes:(NSUInteger)bytes
{
    // From the context of THIS object, we only know of the public and private data service classes that keep track of cache metadata
    __block BOOL couldFreeEnoughCache = [self enoughCacheStorageForBytes:bytes];
    
    NSMutableArray *higherPriorityMetadata = [NSMutableArray array];
//    NSMutableArray *requiredPriorityMetadata = [NSMutableArray array];
    
    void (^enumerationBlock)(WDPRCacheMetadata *, NSUInteger, BOOL *) = ^(WDPRCacheMetadata *metadata, NSUInteger index, BOOL *stop)
    {
        if (metadata.cachePriority < WDPRCachePriorityHigh)
        {
            // Try to free cache for this object
            [self freeCacheSpaceForMetadata:metadata];
        }
        else if (metadata.cachePriority < WDPRCachePriorityRequired)
        {
            // Store for later use
            [higherPriorityMetadata addObject:metadata];
        }
//        else
//        {
//            [requiredPriorityMetadata addObject:metadata];
//        }
        *stop = couldFreeEnoughCache = [self enoughCacheStorageForBytes:bytes];
    };
    
    NSArray *publicCacheMetadata = [self.publicDataService.cacheMetadata allValues];
    [publicCacheMetadata enumerateObjectsUsingBlock:enumerationBlock];
    
    NSArray *privateCacheMetadata = [[WDPRPrivateDataService sharedInstance].cacheMetadata allValues];
    [privateCacheMetadata enumerateObjectsUsingBlock:enumerationBlock];
    
    if (!couldFreeEnoughCache)
    {
        // Last resource option: Start clearing out Higher priority cached data. This is more sensible and would
        // DEFINITELY require care from app sustainers. You could consider heuristics here that can but is not limited
        // to, use the date the response was cached (you might have preference for removing very recently cached data,
        // or on the contrary more older data. Conceptually, we should never remove required cache data, but this is up
        // to the app sustainer.
        [self freeCacheSpaceGivenHigherPriorityMetadataObjects:higherPriorityMetadata];
    }
    
    return couldFreeEnoughCache;
}

- (void)freeCacheSpaceForMetadata:(WDPRCacheMetadata *)metadata
{
    // TODO: WIP - Find a way how to remove the cached response, would it be safe for WDPRCacheMetadata objects to
    // keep a reference to the NSURLRequest? Otherwise how could we remove that piece of cache, will it be even possible?
    //[NSURLCache sharedURLCache] removeCachedResponseForRequest:<#(nonnull NSURLRequest *)#>
}

- (void)freeCacheSpaceGivenHigherPriorityMetadataObjects:(NSArray *)higherPriorityMetadata
{
    // TODO: No heuristics determined thus far
}

// TODO: Observe Login status changes and execute upon a logout or login change
- (void)removePrivateCache
{
    for (WDPRCacheMetadata *metadata in [[WDPRPrivateDataService sharedInstance].cacheMetadata allValues])
    {
        [metadata removeFromCache];
    }
}

- (void)saveCachedMetadata
{
    NSArray *privateMetadata = [[WDPRPrivateDataService sharedInstance].cacheMetadata allValues];
    NSMutableArray *privateCachedMetadata = [NSMutableArray arrayWithCapacity:privateMetadata.count];
    NSArray *publicMetadata = [self.publicDataService.cacheMetadata allValues];
    NSMutableArray *publicCachedMetadata = [NSMutableArray arrayWithCapacity:publicMetadata.count];
    for (WDPRCacheMetadata *metadata in privateMetadata)
    {
        if (metadata.cachedURLRequest) // Means that something was cached
        {
            [privateCachedMetadata addObject:metadata];
        }
    }
    for (WDPRCacheMetadata *metadata in publicMetadata)
    {
        if (metadata.cachedURLRequest) // Means that something was cached
        {
            [publicCachedMetadata addObject:metadata];
        }
    }
    
    BOOL successfulSave = [NSKeyedArchiver archiveRootObject:privateCachedMetadata toFile:self.privateCachedMetadataURL];
    if (!successfulSave)
    {
        NSLog(@"NSURLCache+WDPR ERROR! Could NOT save PRIVATE cached Metadata");
    }
    successfulSave = [NSKeyedArchiver archiveRootObject:publicCachedMetadata toFile:self.publicCachedMetadataURL];
    if (!successfulSave)
    {
        NSLog(@"NSURLCache+WDPR ERROR! Could NOT save PUBLIC cached Metadata");
    }
}

- (void)loadCacheMetadata
{
    NSArray *privateCachedMetadata = [NSKeyedUnarchiver unarchiveObjectWithFile:self.privateCachedMetadataURL];
    for (WDPRCacheMetadata *cachedMetadata in privateCachedMetadata)
    {
        [[WDPRPrivateDataService sharedInstance] registerCacheMetadata:cachedMetadata];
    }
    NSArray *publicCachedMetadata = [NSKeyedUnarchiver unarchiveObjectWithFile:self.publicCachedMetadataURL];
    for (WDPRCacheMetadata *cachedMetadata in publicCachedMetadata)
    {
        [self.publicDataService registerCacheMetadata:cachedMetadata];
    }
}

- (NSString *)privateCachedMetadataURL
{
    if (!_privateCachedMetadataURL)
    {
        NSURL *privateCachedMetadataURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                           inDomains:NSUserDomainMask] lastObject];
        privateCachedMetadataURL = [privateCachedMetadataURL URLByAppendingPathComponent:@"NSURLCachePrivateMetadata"];
        _privateCachedMetadataURL = [privateCachedMetadataURL path];
    }
    
    return _privateCachedMetadataURL;
}

- (NSString *)publicCachedMetadataURL
{
    if (!_publicCachedMetadataURL)
    {
        NSURL *publicCachedMetadataURL = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                                  inDomains:NSUserDomainMask] lastObject];
        publicCachedMetadataURL = [publicCachedMetadataURL URLByAppendingPathComponent:@"NSURLCachePublicMetadata"];
        _publicCachedMetadataURL = [publicCachedMetadataURL path];
    }
    
    return _publicCachedMetadataURL;
}

- (WDPRPublicDataService *)publicDataService
{
    if (!_publicDataService)
    {
        _publicDataService = [[WDPRPublicDataService alloc] init];
    }
    return _publicDataService;
}

- (NSMutableDictionary *)cacheDelegates
{
    if (!_cacheDelegates)
    {
        _cacheDelegates = [NSMutableDictionary dictionary];
    }
    return _cacheDelegates;
}

- (void)dealloc
{
    // This shouldn't be needed, but just in case
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
