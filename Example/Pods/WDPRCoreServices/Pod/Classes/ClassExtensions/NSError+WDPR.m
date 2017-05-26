//
//  NSError+WDPR.m
//  DLR
//
//  Created by Fuerle, Dmitri on 2/13/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import <AFNetworking/AFNetworking.h>
#import "NSError+WDPR.h"

static NSString * const kErrorsKey = @"errors";
static NSString * const kSystemErrorCodeKey = @"systemErrorCode";

@implementation NSError (WDPR)

- (BOOL)isConnectionError
{
    if (self.code == NSURLErrorNotConnectedToInternet  ||
        self.code == NSURLErrorTimedOut                ||
        self.code == NSURLErrorCannotFindHost          ||
        self.code == NSURLErrorCannotConnectToHost     ||
        self.code == NSURLErrorInternationalRoamingOff ||
        self.code == NSURLErrorNetworkConnectionLost)
    {
        return YES;
    }
    
    return NO;
}

- (NSInteger)httpStatusCode
{
    return ((self.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] != nil) ?
            [self.userInfo[AFNetworkingOperationFailingURLResponseErrorKey] statusCode] : 0);
}

- (NSString *)responseObjectErrorCode
{
    NSString *errorString = [NSString stringWithFormat:@"%ld", (long)self.code];
    
    NSDictionary *json = [self jsonResponse];
    NSString *newErrorCode = [json[kErrorsKey] firstObject][kSystemErrorCodeKey];
    if (newErrorCode)
    {
        errorString = newErrorCode;
    }
    
    return errorString;
}

- (NSDictionary *)jsonResponse
{
    NSError *error = nil;
    NSData *errorData = self.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey];
    
    if (!errorData)
    {
        return nil;
    }
    
    NSDictionary *jsonResponse = [NSJSONSerialization JSONObjectWithData:errorData options:kNilOptions error:&error];
    
    if (error)
    {
        return nil;
    }
    
    return jsonResponse;
}

@end
