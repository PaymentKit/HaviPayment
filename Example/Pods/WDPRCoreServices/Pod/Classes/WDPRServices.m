//
//  WDPRServices.m
//  Mdx
//
//  Created by Rodden, James on 7/10/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#include "WDPRServices.h"
#import "WDPRCoreServiceLoggingManager.h"
#import "WDPRCoreServiceConstants.h"
#import "WDPRCoreServices.h"

#define ALTERNATE_SERVICE_CONFIGURATION DEBUG==1

static NSDictionary *_configData;
static id<WDPRServicesOverrideDictionaryProvider> overrideDictionaryProviderDelegate;

@implementation WDPRServices

static WDPREnvironment *env;

+ (nullable NSDictionary *)configData
{
    [WDPRServices configDataWithOverrideDictionaryProvider:nil];

    return _configData;
}

+ (nullable NSDictionary *)configDataWithOverrideDictionaryProvider:(nullable id <WDPRServicesOverrideDictionaryProvider>)overrideDictionaryProvider
{
    void (^initializeItemsBlock)() =
    ^{
        _configData = [NSDictionary dictionaryFromPList:@"Services"
                                              inBundle:[WDPRCoreServices wdprCoreServicesResourceBundle]
                                          allowNewKeys:YES];
        overrideDictionaryProviderDelegate = overrideDictionaryProvider;
        
#if ALTERNATE_SERVICE_CONFIGURATION
        _configData = [WDPRServices applyAlternativeServiceConfigurationToDictionary:_configData];
#endif
    };
    executeOnlyOnce(initializeItemsBlock);
    
    return _configData;
}

+ (void)initializeWithOverrideDictionaryProvider:(nonnull id <WDPRServicesOverrideDictionaryProvider>)overrideDictionaryProvider
{
    [WDPRServices configDataWithOverrideDictionaryProvider:overrideDictionaryProvider];
}

#if ALTERNATE_SERVICE_CONFIGURATION
// This method askse the overrideDictionaryProviderDelegate for an override dictionary
// If it finds a delegate, and the delegate returns an override dictionary, then the method
// returns a new dictionary whose elements are the supplied configData
// overridden by keys and values read from the retreived dictionary.
+ (nullable NSDictionary *)applyAlternativeServiceConfigurationToDictionary:(NSDictionary *)configData
{
    NSDictionary *selectedConfigData = configData;
    
    if (overrideDictionaryProviderDelegate)
    {
        NSDictionary *overrideSource = [overrideDictionaryProviderDelegate wdprServicesOverrideDictionary];
        NSMutableDictionary *overRideDictionary = [NSMutableDictionary dictionaryWithDictionary:overrideSource];
        
        if ([overRideDictionary count] > 0)
        {
            NSDictionary *overrideDefault = overRideDictionary[WDPRDefaultEnvironment];
            NSMutableDictionary *configDefault = [configData[WDPRDefaultEnvironment] mutableCopy];
            [configDefault addEntriesFromDictionary:overrideDefault];
            [overRideDictionary setValue:configDefault forKey:WDPRDefaultEnvironment];
            selectedConfigData = [overRideDictionary copy];
        }
    }
    
    return selectedConfigData;
}
#endif

+ (void) appendServices:(nonnull NSDictionary *)moduleServices
{
    NSMutableDictionary *oldConfigData = [NSMutableDictionary dictionaryWithDictionary:[WDPRServices configData]];
    NSMutableDictionary *defaultDict = [NSMutableDictionary dictionaryWithDictionary:oldConfigData[WDPRDefaultEnvironment]];
    [defaultDict addEntriesFromDictionary:moduleServices];
    oldConfigData[WDPRDefaultEnvironment] = defaultDict;

    _configData = [oldConfigData copy];
}

+ (void)recreateEnvironment
{
    @synchronized(self)
    {
        env = [WDPREnvironment new];
    }
}

+ (nullable id <WDPREnvironment>) environment
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^
    {
        [self recreateEnvironment];
        WDPRCoreServicesLogDebug(@"******** %@ Services Environment", env.name);
    });

    return env;
}

+ (void) setEnvironment:(nonnull NSString *)newName
{
    if (![newName isEqualToString:self.environment.name])
    {
        [NSUserDefaults.standardUserDefaults setValue:newName
                                               forKey:WDPRChosenEnvironment];

        [NSUserDefaults.standardUserDefaults synchronize];
        
        [self recreateEnvironment];

        [NSNotificationCenter.defaultCenter
                postNotificationName:WDPREnvironmentChangedNotification
                              object:nil];
    }
}

+ (nullable NSArray *) environmentNames
{
    return self.configData.allKeys;
}

+ (nonnull NSString *) generateGuid
{
    CFUUIDRef newUniqueId = CFUUIDCreate(kCFAllocatorDefault);
    NSString *uuidString = (__bridge_transfer NSString *) CFUUIDCreateString(kCFAllocatorDefault, newUniqueId);
    CFRelease(newUniqueId);

    return uuidString;
}

@end  // @@implementation WDPRServices


