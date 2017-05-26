//
//  WDPRCacheMetadataFactory.h
//  Pods
//
//  Created by Uribe, Martin on 2/15/16.
//
//

#import <Foundation/Foundation.h>
#import "WDPRCacheMetadata.h"

typedef NS_OPTIONS(NSUInteger, WDPRCacheOptions)
{
    WDPRCacheOptionsNone                        = (1 << 0),
    WDPRCacheOptionsPublic                    	= (1 << 1),
    WDPRCacheOptionsPrivate                     = (1 << 2),
    WDPRCacheOptionsExpirationTimeControlled    = (1 << 3),
};

@class WDPRStandardCacheDelegate;

/**
 This class will leverage code duplication while creating common cache meta data and cache delegate objects, by
 specifying standard options. Usually the objects created herein should satisfy a considerable number of caching
 requirements. If you need more customization please feel free to create your own class conforming to WDPRCacheDelegate
 and where you can include specific needs. You could actually keep using some utilities in this class, like 
 constructing a cache meta data object with your custom delegate.
 */

@interface WDPRCacheMetadataFactory : NSObject

/**
 Returns a cache meta data object already configured based on the cacheOptions, you may use this instance
 for registering to a manager (like a subclass of WDPRCommonDataService etc). Beware! The meta data object has a weak
 reference to its cacheDelegate, therefore it is the responsibility of the caller to guarantee the existence of the
 delegate in order to accomplish the desired caching behavior.
 @param cacheOptions A bitmask that will give clues to configure a cache meta data object
 @param requestId A unique identifier for the cache meta data (1 cache meta data for each service call!). 
                    Can be nil, in which case an anonymous identifier is given
 @return an instance of WDPRCacheMetadata configured with a basic type, an identifier and a delegate
 */
+ (WDPRCacheMetadata *)cacheMetadataWithCacheOptions:(WDPRCacheOptions)cacheOptions
                                           requestId:(NSString *)requestId;

/**
 Returns a cache delegate instance based on a basic meta data configuration type.
 @discussion This method would usually be used along with cacheMetadataForBaseType:requestId:cacheDelegate: since it 
 is able to provide the cache delegate available as an argument in the aforementioned method.
 @param cacheOptions A bitmask that will give clues as to which type of delegate is appropriate and what extra
 configurations might be required
 @return an instance of a class conforming to WDPRCacheDelegate protocol.
 */
+ (id<WDPRCacheDelegate>)cacheDelegateWithCacheOptions:(WDPRCacheOptions)cacheOptions;

/**
 Auxiliary method that facilitates applying common settings over a WDPRStandardCacheDelegate object, based on a set
 of options by using WDPRCacheOptions bitmask. 
 @param standardDelegate The delegate that needs to apply some specific settings
 @param cacheOptions A bitmask that will indicate which settings should be turned on in the instance inheriting from
 WDPRStandardCacheDelegate
 */
+ (void)configureStandardCacheDelegate:(WDPRStandardCacheDelegate *)standardDelegate
                      withCacheOptions:(WDPRCacheOptions)cacheOptions;

@end

@interface WDPRCacheMetadataDefaultConfigurator : NSObject<WDPRCacheMetadataConfigurator>

@end

@interface WDPRCacheMetadataSimpleCacheConfigurator : NSObject<WDPRCacheMetadataConfigurator>

@end
