//
//  NSCachedURLResponse+CacheExpiration.h
//  DLR
//
//  Created by Delafuente, Rob on 2/27/15.
//  Copyright (c) 2015 WDPRO. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSCachedURLResponse (CacheExpiration)

-(NSCachedURLResponse*)responseWithExpirationDuration:(NSUInteger)duration;

@end
