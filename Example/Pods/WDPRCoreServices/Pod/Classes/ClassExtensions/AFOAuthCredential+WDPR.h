//
//  AFOAuthCredential+WDPR.h
//  Pods
//
//  Created by Hart, Nick on 12/30/15.
//
//

#import "AFOAuthCredential.h"

@interface AFOAuthCredential (WDPR)

/**
 Return a new instance of AFOAuthCredential initialized with the values from the provided payload.
 @param payload the OneID response payload
 @param error an optional out NSError parameter to contain error info if the payload is invalid.
 @return an instance of AFOAuthCredential on success, or nil on failure.
 */
+ (instancetype)credentialWithOneIDPayload:(NSDictionary *)payload error:(NSError **)error;

@end
