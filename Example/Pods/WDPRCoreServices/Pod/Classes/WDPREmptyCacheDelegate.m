//
//  WDPREmptyCacheDelegate.m
//  Pods
//
//  Created by Uribe, Martin on 2/2/16.
//
//

#import "WDPREmptyCacheDelegate.h"
#import "WDPRAppCache.h"

@implementation WDPREmptyCacheDelegate
@synthesize appCacheDelegate = _appCacheDelegate;

- (void)cacheMetadataWillUpdateWithSwid:(NSString *)currentSwid response:(NSURLResponse *)response
{
    // Nothing needed to do here
}

- (BOOL)isCacheValidForSwid:(NSString *)swid
{
    return YES;
}

- (WDPRAppCache *)appCacheDelegate
{
    if (!_appCacheDelegate)
    {
        return [WDPRAppCache sharedInstance];
    }
    
    return _appCacheDelegate;
}

@end
