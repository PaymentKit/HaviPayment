#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "KeychainItemWrapper.h"
#import "AFOAuthCredential.h"
#import "GROAuth2SessionManager.h"
#import "AFOAuthCredential+WDPR.h"
#import "NSCachedURLResponse+CacheExpiration.h"
#import "NSError+WDPR.h"
#import "WDPRAppCache.h"
#import "WDPRAuthenticationService.h"
#import "WDPRCacheDatasource.h"
#import "WDPRCacheDelegate.h"
#import "WDPRCacheMetadata.h"
#import "WDPRCacheMetadataFactory.h"
#import "WDPRCommonDataService.h"
#import "WDPRCoreServiceConstants.h"
#import "WDPRCoreServiceLoggingManager.h"
#import "WDPRCoreServices.h"
#import "WDPRCoreServicesConfiguration.h"
#import "WDPREmptyCacheDelegate.h"
#import "WDPREnvironment.h"
#import "WDPRHTTPConstants.h"
#import "WDPRKeychainWrapper.h"
#import "WDPRObservableCacheDelegate.h"
#import "WDPRPrivateDataService.h"
#import "WDPRPublicDataService+Internal.h"
#import "WDPRPublicDataService.h"
#import "WDPRServiceCallHeader.h"
#import "WDPRServices.h"
#import "WDPRStandardCacheDelegate.h"
#import "WDPRTimeEventTracker.h"

FOUNDATION_EXPORT double WDPRCoreServicesVersionNumber;
FOUNDATION_EXPORT const unsigned char WDPRCoreServicesVersionString[];

