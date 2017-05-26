//
//  AFOAuthCredential+WDPR.m
//  Pods
//
//  Created by Hart, Nick on 12/30/15.
//
//

#import "AFOAuthCredential+WDPR.h"
#import "NSDate+WDPR.h"

NSString * const WDPRGuestAuthTokenType = @"com.disney.wdpro.ios.guest";

CGFloat const WDPRHighTrustInterval = kNumberOfSecondsInMinute * 30;

@implementation AFOAuthCredential (WDPR)

+ (instancetype)credentialWithOneIDPayload:(NSDictionary *)payload error:(NSError **)error
{
    // OneID TODO: Temporary workaround until SHDR profile service returns the same token key as US
    // NSString *accessToken = [payload valueForKeyPath:@"data.token.access_token"] ;
    // NSString *refreshToken = [payload valueForKeyPath:@"data.token.refresh_token"];
    NSString *accessToken = [payload valueForKeyPath:@"data.token.access_token"] ?: [payload valueForKeyPath:@"data.token.accessToken"];
    NSString *refreshToken = [payload valueForKeyPath:@"data.token.refresh_token"] ?: [payload valueForKeyPath:@"data.token.refreshToken"];
    
    if ([accessToken isKindOfClass:[NSNull class]] || [refreshToken isKindOfClass:[NSNull class]] ||
        !accessToken.length || !refreshToken.length)
    {
        if (error)
        {
            *error = [NSError errorWithDomain:@"login failed" code:0 userInfo:payload];
        }
        return nil;
    }
    
    AFOAuthCredential *newCredential = [AFOAuthCredential credentialWithOAuthToken:accessToken tokenType:WDPRGuestAuthTokenType];
    
    NSDate *expireDate = nil;    
    id refreshTtl = [payload valueForKeyPath:@"data.token.ttl"];
    
    if (refreshTtl != nil && ![refreshTtl isEqual:[NSNull null]])
    {
        expireDate = [NSDate dateWithTimeIntervalSinceNow:[refreshTtl doubleValue]];
    }
    
    [newCredential setRefreshToken:refreshToken expiration:expireDate];
    
    NSDate *highTrustExpireDate = [NSDate dateWithTimeIntervalSinceNow:WDPRHighTrustInterval];
    
    newCredential.highTrustExpiration = highTrustExpireDate;
    
    return newCredential;
}

@end
