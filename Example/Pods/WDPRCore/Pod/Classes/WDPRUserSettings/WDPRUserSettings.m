//
//  WDPRUserSettings.m
//  WDPRFinderCore
//
//  Created by Hart, Nick on 6/23/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import "WDPRUserSettings.h"
#import "WDPRLog.h"

// a global instance to enable +userSettings and +configureUserSettings:
static id<WDPRUserSettingsProtocol> globalUserSettings = nil;

// to silence the compiler
@interface NSUserDefaults (WDPRUserSettings)<WDPRUserSettingsProtocol>
@end

@implementation WDPRUserSettings

+ (id<WDPRUserSettingsProtocol>)userSettings
{
    // if this is unset, use NSUserDefaults
    return globalUserSettings ?: [NSUserDefaults standardUserDefaults];
}

+ (void)configureUserSettings:(id<WDPRUserSettingsProtocol>)userSettings
{
    @synchronized(self)
    {
        if (globalUserSettings)
        {
            WDPRLogWarning("calling +[WDPRUserSettings configureUserSettings:] after globalUserSettings has already been set!");
            return;
        }

        if (![userSettings conformsToProtocol:@protocol(WDPRUserSettingsProtocol)])
        {
            WDPRLogWarning("calling +[WDPRUserSettings configureUserSettings:] with invalid instance!");
            return;
        }

        globalUserSettings = userSettings;
    }
}

@end
