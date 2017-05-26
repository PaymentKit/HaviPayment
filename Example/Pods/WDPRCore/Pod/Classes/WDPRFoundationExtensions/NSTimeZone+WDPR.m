//
//  NSTimeZone+WDPR.m
//  WDPRCore
//
//  Created by Ignacio Rodrigo on 12/28/15.
//  Copyright © 2015 Daniel Clark. All rights reserved.
//

#import "NSTimeZone+WDPR.h"

@implementation NSTimeZone (WDPR)

+ (NSTimeZone*)GMTTimeZone
{
    return [NSTimeZone timeZoneForSecondsFromGMT:0];
}

@end
