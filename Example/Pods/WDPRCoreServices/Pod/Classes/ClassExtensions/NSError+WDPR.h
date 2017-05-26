//
//  NSError+WDPR.h
//  DLR
//
//  Created by Fuerle, Dmitri on 2/13/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, HttpStatusCodes)
{
    HttpStatusCodeOK = 200,
    HttpStatusCodeNoContent = 204,
    
    HttpStatusCodeBadRequest = 400,
    HttpStatusCodeUnauthorized = 401,
    HttpStatusCodeForbidden = 403,
    HttpStatusCodeNotFound = 404,
    HttpStatusCodeConflict = 409,
    HttpStatusCodeGone = 410,
    
    HttpStatusCodeInternalServerError = 500,
    HttpStatusCodeServiceUnavailable = 503,
    HttpStatusCodeGatewayTimeout = 504
};

@interface NSError (WDPR)

- (BOOL)isConnectionError;

- (NSInteger)httpStatusCode;

- (NSString *)responseObjectErrorCode;

- (NSDictionary *)jsonResponse;

@end
