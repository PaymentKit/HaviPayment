//
//  WDPRCoreServices.h
//  Mdx
//
//  Created by Wright, Byron on 7/8/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import "WDPRServices.h"

#import "WDPRAuthenticationService.h"
#import "WDPRCacheMetadataFactory.h"
#import "WDPRCommonDataService.h"
#import "WDPRPublicDataService.h"
#import "WDPRPrivateDataService.h"
#import "WDPRTimeEventTracker.h"
#import "NSError+WDPR.h"

@interface WDPRCoreServices : NSObject

+ (NSBundle *) wdprCoreServicesResourceBundle;

@end