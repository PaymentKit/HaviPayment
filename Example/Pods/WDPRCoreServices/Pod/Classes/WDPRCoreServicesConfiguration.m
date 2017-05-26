//
// Created by Clark, Daniel on 6/26/15.
// Copyright (c) 2015 Daniel Clark. All rights reserved.
//

#import "WDPRCoreServicesConfiguration.h"
#import "WDPREnvironment.h"
#import "WDPRServices.h"

#import <WDPRCore/WDPRFoundation.h>

@implementation WDPRCoreServicesConfiguration

+ (id) configValueForKey:(NSString *)key
{
    id value;
    // Check Services.plist
    if ([[WDPRServices environment] details][key])
    {
        value = [[WDPRServices environment] details][key];
    }
    // Check the Info.plist
    else
    {
        value = [NSBundle.mainBundle objectForInfoDictionaryKey:key];
    }

    return value;
}

@end
