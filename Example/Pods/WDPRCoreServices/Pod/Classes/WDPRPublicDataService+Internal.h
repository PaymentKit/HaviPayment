//
//  WDPRPublicDataService+Internal.h
//  Mdx
//
//  Created by Brooks, Tim on 7/23/14.
//  Copyright (c) 2014 WDPRO. All rights reserved.
//

#import "WDPRPublicDataService.h"

@interface WDPRPublicDataService (Internal)

#pragma mark - Common Services Layer Helpers

/**
 Generic GET service call that wraps returns results into a dictionary from raw json data.
 
 @param authHeaderValue - Header Auth type {ValueBearer, OAuthToken}.
 @param success - Block called upon success, with data dictionary containing any detailed info returned
 by the link.
 @param failure - Block called, with error object, if service call fails.
 */
- (void)applyPublicTokenForAuthVersion:(MdxAuthorizationHeaderValue)authHeaderValue
                               success:(AFNSuccess)success
                               failure:(AFNFailure)failure;

@end
