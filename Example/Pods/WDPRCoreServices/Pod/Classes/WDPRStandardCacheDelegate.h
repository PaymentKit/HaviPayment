//
//  WDPRStandardCacheDelegate.h
//  Mdx
//
//  Created by Uribe, Martin on 2/2/16.
//  Copyright © 2016 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDPRCacheDelegate.h"

extern const float WDPRDailyExpirationTime;

@interface WDPRStandardCacheDelegate : NSObject<WDPRCacheDelegate>

/**
 A string identifying the guest which started a request for the last time. This could be used for avoiding
 wrong guest data to be used for a user that is not logged in anymore. (Private cache)
 */
@property (nonatomic, strong, readonly) NSString *swid;

/**
 Indicates the date for which a cached response was last received. Please note, if cache was turned off then
 any responses during that time will NOT be stored as cached responses, only the last cached response (when 
 cache was turned on for this call) will be used to get the last date.
 */
@property (nonatomic, strong, readonly) NSDate *lastCacheDate;

/**
 A float indicating an expiration time for the cached response. Should this time, in seconds, passes by the time a new
 request is made, this will cause a new request to be executed to update the response and restart the expiration time
 */
@property (nonatomic) float cacheExpirationTime; //Seconds!

/**
 Flag indicating if expiration time condition is enabled.
 @post If this flag is turned on, then expiration time will be considered for invalidation purposes, 
 otherwise expiration time will be ignored and should not represent an invalidation reason
 @WARNING: This delegate will extract the date from the service response (NSHTTPURLResponse), more precisely,
 from the 'Date' field in the HTTP Header response, therefore if this date is not the 'Date we stored the 
 cached response' then you would probably have unexpected behavior. Of course, as a client you could choose
 your own strategy to handle this.
 */
@property (nonatomic) BOOL expirationTimeEnabled;

/**
 Indicates if this service call will require authentication (guest has to log in)
 */
@property (nonatomic) BOOL isPrivate;

/**
 Auxiliary method used when the expiration time is dynamically changed, therefore we need to force an update
 */
- (void)updateExpirationDate;

@end
