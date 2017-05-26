//
//  WDPRObservableCacheDelegate.h
//  Pods
//
//  Created by Uribe, Martin on 3/02/17.
//
//  This delegate helps giving insight of network information, usually useful for analytics purposes
//  You may subclass from this delegate in case you may need to track other data specific to your feature
//

#import "WDPRStandardCacheDelegate.h"
// Temporary hack until BuildPhase supports modules
#if TARGET_OS_IOS
@import AFNetworking;
#else
#import <AFNetworking/AFNetworking.h>
#endif

@class WDPRObservableCacheDelegate;

@protocol WDPRNetworkEventCacheDelegate <NSObject>
@required
- (void)notifyFetchingRequest:(WDPRObservableCacheDelegate*)delegate;
- (void)notifyFetchingSuccess:(WDPRObservableCacheDelegate*)delegate;
- (void)notifyFetchingFailure:(WDPRObservableCacheDelegate*)delegate;
@end

@interface WDPRObservableCacheDelegate : WDPRStandardCacheDelegate

@property (nonatomic, weak) id<WDPRNetworkEventCacheDelegate> observableCacheDelegate;

/**
 A string identifying the request/response url or name which needs to be tracked.
 */
@property (nonatomic, strong) NSString *serviceName;

/**
 A string which can co-relate between request and response/error
 */
@property (nonatomic, strong) NSString *correlationId;

/**
 Payload size would be set only by success/failure response. This will identify what size was returned as body of the response.
 */
@property (nonatomic, strong) NSString *payloadSize;

/**
 A http status code received from success/failure response.
 */
@property (nonatomic) long httpStatus;

/**
 Request start time to be set when the request call is made. requestStartTime and requestEndTime would be used to calculate the requestTotalTime.
 */
@property (nonatomic) CFAbsoluteTime requestStartTime;

/**
 Request start time to be set when the response/error is received in response. 
 requestStartTime and requestEndTime would be used to calculate the requestTotalTime.
 */
@property (nonatomic) CFAbsoluteTime requestEndTime;

/**
 The time from when the service call was made until the response it received. 
 requestStartTime and requestEndTime would be used to calculate the requestTotalTime.
 */
@property (nonatomic) CFAbsoluteTime requestTotalTime;

- (void)notifyFetchingRequest:(WDPRCacheMetadata*)metadata;
- (void)notifyFetchingSuccess:(WDPRCacheMetadata*)metadata withHttpStatusCode:(long)code andPayloadSize:(NSString*)size;
- (void)notifyFetchingFailure:(WDPRCacheMetadata*)metadata operation:(AFHTTPRequestOperation*)operation;

@end
