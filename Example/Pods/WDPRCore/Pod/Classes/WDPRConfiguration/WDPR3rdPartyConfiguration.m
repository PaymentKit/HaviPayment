//
//  WDPR3rdPartyConfiguration.m
//  DLR
//
//  Created by Delafuente, Rob on 7/17/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPR3rdPartyConfiguration.h"
#import <WDPRCore/WDPRFoundation.h>

NSString *const kWDPR3rdPartyConfigurationPlist = @"WDPR3rdPartyConfiguration";

@implementation WDPR3rdPartyConfiguration

+ (NSString *)apiTokenForServiceKey:(NSString *)serviceKey
{
    NSString *keyToUse = serviceKey;
#ifdef DEBUG
    keyToUse = [keyToUse stringByAppendingString:@"_DEV"];
#else
    keyToUse = [keyToUse stringByAppendingString:@"_PROD"];
#endif
    return [self infoDictionary][serviceKey][keyToUse] ?: [self infoDictionary][serviceKey];
}

+ (NSDictionary *)infoDictionary
{
    static NSDictionary *infoDictionary;
    
    void (^initializeInfoDictBlock)() =
    ^{
        infoDictionary = [NSDictionary dictionaryFromPList:kWDPR3rdPartyConfigurationPlist];
    };
    executeOnlyOnce(initializeInfoDictBlock);
    
    return infoDictionary;
}

@end
