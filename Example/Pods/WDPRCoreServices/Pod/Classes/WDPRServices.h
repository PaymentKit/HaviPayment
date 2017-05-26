//
//  WDPRServices.h
//  Mdx
//
//  Created by Rodden, James on 7/10/13.
//  Copyright (c) 2013 WDPRO. All rights reserved.
//

#import <WDPRCore/WDPRFoundation.h>

#import "WDPREnvironment.h"

// Common strings.

#define WDPRServicesHost @"host"
#define WDPRServicesMapTiles @"mapTiles"
#define WDPRServicesNgeHost @"ngeHost"
#define kServicesSecurityHost @"securityHost"
#define kServiceKeyOAuthURL @"OAuthURL"
#define kServiceKeyOAuthClientID @"OAuthClientID"
#define kServiceUsesSoftlaunchKey @"useSoftLaunchEnvironment"
#define kServiceKeyLoginUser @"login-user"
#define kServiceKeyRefreshToken @"refresh-token"
#define kServiceKeyLoginRefreshToken @"login-refresh-token"

@protocol WDPRServicesOverrideDictionaryProvider <NSObject>
@required
- (nullable NSDictionary *)wdprServicesOverrideDictionary;
@end

@interface WDPRServices : NSObject

+ (void)initializeWithOverrideDictionaryProvider:(nonnull id <WDPRServicesOverrideDictionaryProvider>)overrideDictionaryProvider;

+ (nullable NSDictionary *)configData;

+ (nullable NSArray *)environmentNames;
+ (nullable id<WDPREnvironment>)environment;
+ (void)setEnvironment:(nonnull NSString *)name;
+ (nonnull NSString *)generateGuid;
+ (void)appendServices:(nonnull NSDictionary*)moduleServices;

@end  // @interface WDPRServices
