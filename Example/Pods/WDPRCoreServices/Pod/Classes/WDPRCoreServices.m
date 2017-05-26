//
// Created by Clark, Daniel on 11/17/15.
// Copyright (c) 2015 Daniel Clark. All rights reserved.
//

#import "WDPRCoreServices.h"
#import "WDPRCoreServiceConstants.h"


@implementation WDPRCoreServices

+ (NSBundle *) wdprCoreServicesResourceBundle
{
    static NSBundle *_coreServicesResourceBundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _coreServicesResourceBundle = [NSBundle bundleFromMainBundleOrFramework:WDPRCoreServicesFrameworkName
                                                                     bundleName:WDPRCoreServicesResourceBundleName];
    });
    return _coreServicesResourceBundle;
}


@end