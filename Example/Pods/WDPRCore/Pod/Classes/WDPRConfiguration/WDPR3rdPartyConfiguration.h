//
//  WDPR3rdPartyConfiguration.h
//  DLR
//
//  Created by Delafuente, Rob on 7/17/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

FOUNDATION_EXTERN NSString *const kWDPR3rdPartyConfigurationPlist;

@interface WDPR3rdPartyConfiguration : NSObject

+ (NSString *)apiTokenForServiceKey:(NSString *)serviceKey;

@end
