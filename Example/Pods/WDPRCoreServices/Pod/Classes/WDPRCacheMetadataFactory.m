//
//  WDPRCacheMetadataFactory.m
//  Pods
//
//  Created by Uribe, Martin on 2/15/16.
//
//

#import "WDPRCacheMetadataFactory.h"
#import "WDPREmptyCacheDelegate.h"
#import "WDPRStandardCacheDelegate.h"
#import "WDPRAppCache.h"

@implementation WDPRCacheMetadataFactory

+ (WDPRCacheMetadata *)cacheMetadataWithCacheOptions:(WDPRCacheOptions)cacheOptions
                                      requestId:(NSString *)requestId
{
    WDPRCacheMetadata *cacheMetadata;
    if ((cacheOptions & WDPRCacheOptionsNone) != 0)
    {
        cacheMetadata = [[WDPRCacheMetadata alloc]
                         initWithConfiguratorClass:[WDPRCacheMetadataDefaultConfigurator class]
                         requestId:requestId];
    }
    else
    {
        cacheMetadata = [[WDPRCacheMetadata alloc]
                         initWithConfiguratorClass:[WDPRCacheMetadataSimpleCacheConfigurator class]
                         requestId:requestId];
        BOOL isExpirationControlRequired = (cacheOptions & WDPRCacheOptionsExpirationTimeControlled) != 0;
        cacheMetadata.expirationControlRequired = isExpirationControlRequired;
    }
    cacheMetadata.cachePriority = [cacheMetadata.cacheDelegate.appCacheDelegate cachePriorityForCacheOptions:cacheOptions];
    
    return cacheMetadata;
}

+ (id<WDPRCacheDelegate>)cacheDelegateWithCacheOptions:(WDPRCacheOptions)cacheOptions
{
    id<WDPRCacheDelegate> cacheDelegate;
    if ((cacheOptions & WDPRCacheOptionsNone) != 0)
    {
        cacheDelegate = [WDPREmptyCacheDelegate new];
    }
    else
    {
        cacheDelegate = [WDPRStandardCacheDelegate new];
        [WDPRCacheMetadataFactory configureStandardCacheDelegate:cacheDelegate withCacheOptions:cacheOptions];
    }
    
    return cacheDelegate;
}

+ (void)configureStandardCacheDelegate:(WDPRStandardCacheDelegate *)standardDelegate
                      withCacheOptions:(WDPRCacheOptions)cacheOptions
{
    BOOL isPrivate = (cacheOptions & WDPRCacheOptionsPrivate) != 0; // Private option takes precedence over Public!
    BOOL isExpirationTimeEnabled = (cacheOptions & WDPRCacheOptionsExpirationTimeControlled) != 0;
    standardDelegate.isPrivate = isPrivate;
    standardDelegate.expirationTimeEnabled = isExpirationTimeEnabled;
}

@end

@implementation WDPRCacheMetadataDefaultConfigurator

+ (void)configureCacheMetadata:(WDPRCacheMetadata *)cacheMetadata
{
    cacheMetadata.cacheEnabled = NO; // By default caching will be disabled, clients can change this later if required
    cacheMetadata.forceStorageIfResponseSizeTooLarge = NO; // Clients can change this later if required
}

@end

@implementation WDPRCacheMetadataSimpleCacheConfigurator

+ (void)configureCacheMetadata:(WDPRCacheMetadata *)cacheMetadata
{
    cacheMetadata.cacheEnabled = YES;
    cacheMetadata.forceStorageIfResponseSizeTooLarge = NO; // Clients can change this later if required
    [cacheMetadata updateCachePolicy]; // Required so that cachePolicy updates can take place
}

@end
