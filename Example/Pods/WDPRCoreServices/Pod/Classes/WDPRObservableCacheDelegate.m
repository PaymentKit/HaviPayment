//
//  WDPRObservableCacheDelegate.m
//  Pods
//
//  Created by Uribe, Martin on 3/02/17.
//
//

#import "WDPRObservableCacheDelegate.h"
#import "WDPRCacheMetadata.h"

@implementation WDPRObservableCacheDelegate

- (void)notifyFetchingRequest:(WDPRCacheMetadata*)metadata
{
    if (self.observableCacheDelegate
        && [self.observableCacheDelegate respondsToSelector:@selector(notifyFetchingRequest:)]
        && !metadata.isCached)
    {
        [self.observableCacheDelegate notifyFetchingRequest:self];
    }
}

- (void)notifyFetchingSuccess:(WDPRCacheMetadata*)metadata withHttpStatusCode:(long)code andPayloadSize:(NSString*)size
{
    if (self.observableCacheDelegate
        && [self.observableCacheDelegate respondsToSelector:@selector(notifyFetchingSuccess:)])
    {
        self.httpStatus = code;
        self.payloadSize = size;
        self.requestTotalTime = CFAbsoluteTimeGetCurrent() - self.requestStartTime;
        [self.observableCacheDelegate notifyFetchingSuccess:self];
    }
}

- (void)notifyFetchingFailure:(WDPRCacheMetadata*)metadata operation:(AFHTTPRequestOperation*)operation
{
    if (self.observableCacheDelegate
        && [self.observableCacheDelegate respondsToSelector:@selector(notifyFetchingFailure:)])
    {
        self.httpStatus = operation.response.statusCode;
        self.requestTotalTime = CFAbsoluteTimeGetCurrent() - self.requestStartTime;
        [self.observableCacheDelegate notifyFetchingFailure:self];
    }
}

@end
