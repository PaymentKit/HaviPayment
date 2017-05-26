//
//  WDPRStandardCacheDelegate.m
//  Mdx
//
//  Created by Uribe, Martin on 2/2/16.
//  Copyright © 2016 WDPRO. All rights reserved.
//

#import "WDPRStandardCacheDelegate.h"

#import "WDPRAppCache.h"
#import "WDPRCacheMetadata.h"
#import "WDPRAuthenticationService.h"

// DO NOT USE @import:
// BuildPhase needs this file
// and it doesn't use frameworks
#import <WDPRCore/WDPRFoundation.h>

@interface WDPRStandardCacheDelegate ()

@property (nonatomic, strong, readwrite) NSString *swid;
@property (nonatomic, strong, readwrite) NSDate *lastCacheDate;
@property (nonatomic, strong) NSDate *expirationDate;
@property (nonatomic) BOOL cacheEnabled;

@end

@implementation WDPRStandardCacheDelegate

@synthesize appCacheDelegate = _appCacheDelegate;

const float WDPRDailyExpirationTime = kNumberOfSecondsInMinute * kNumberOfMinutesInHour * kNumberOfHoursInDay;

- (instancetype)init
{
    if (self = [super init])
    {
        self.swid = [WDPRAuthenticationService sharedInstance].swid;
        self.cacheExpirationTime = kNumberOfSecondsInMinute * kNumberOfMinutesInHour * kNumberOfHoursInDay;
        self.cacheEnabled = YES;
    }
    return self;
}

- (void)cacheMetadataWillUpdateWithSwid:(NSString *)currentSwid response:(NSURLResponse *)response
{
    [self updateLastCacheDateGivenURLResponse:response];
    if ((self.isPrivate && !currentSwid) || !response)
    {
        return; // Cannot update if these arguments are invalid
    }
    else if ([self cacheCanBeUpdated])
    {
        self.swid = currentSwid;
        [self updateExpirationDate];
    }
}

- (BOOL)isCacheValidForSwid:(NSString *)swid
{
    NSDate *now = [NSDate date];
    return (!self.isPrivate || [self.swid isEqualToString:swid]) &&
    (!self.expirationTimeEnabled || ![now isLaterThan:[self expirationDate]]);
}

- (BOOL)cacheCanBeUpdated
{
    return self.cacheEnabled;
}

- (void)cacheWasInvalidated
{
    self.swid = nil;
}

- (void)cacheWasEnabled
{
    self.cacheEnabled = YES;
}

- (void)cacheWasDisabled
{
    self.swid = nil;
    self.cacheEnabled = NO;
}

- (void)updateExpirationDate
{
    if (self.expirationTimeEnabled)
    {
        self.expirationDate = [self.lastCacheDate dateByAddingTimeInterval:self.cacheExpirationTime];
    }
}

- (void)cacheSpaceDidReachLimit
{
    
}

- (BOOL)shouldForceUpdateCacheMetadata:(WDPRCacheMetadata *)cacheMetadata
{
    return cacheMetadata.cachePolicy == NSURLRequestReloadIgnoringLocalCacheData;
}

#pragma mark - Private

- (void)updateLastCacheDateGivenURLResponse:(NSURLResponse *)response
{
    if (!self.cacheEnabled || !response)
    {
        return; // We must not update the last date if cache is disabled or response is nil
    }
    if ([response respondsToSelector:@selector(allHeaderFields)])
    {
        NSDateFormatter *formatter = [NSDateFormatter systemFormatterWithFormat:@"EEE, dd MMM yyyy HH:mm:ss zzz"];
        [formatter setTimeZone:[NSTimeZone localTimeZone]];
        NSString *lastModifiedDate = [((NSHTTPURLResponse *)response) allHeaderFields][@"Date"];
        self.lastCacheDate = [formatter dateFromString:lastModifiedDate];
    }
    else
    {
        NSLog(@"CACHE WARNING! Tried to set expiration time, but the service "
              @"response date could NOT be retrieved from the HTTP Response Header. Now using default timestamp...");
        self.lastCacheDate = [NSDate date];
    }
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
