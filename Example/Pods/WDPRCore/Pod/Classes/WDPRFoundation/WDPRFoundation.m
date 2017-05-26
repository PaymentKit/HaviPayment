//
// Created by Clark, Daniel on 11/17/15.
// Copyright (c) 2015 Daniel Clark. All rights reserved.
//

#import "WDPRFoundation.h"

@implementation WDPRFoundation

+ (NSBundle *) wdprCoreResourceBundle
{
    static NSBundle *coreResourceBundle;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        coreResourceBundle = [NSBundle bundleFromMainBundleOrFramework:WDPRCoreFrameworkName
                                                            bundleName:WDPRCoreResourceBundleName];
    });
    return coreResourceBundle;
}

@end